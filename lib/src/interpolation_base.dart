import 'dart:convert';

const String _spaces = r'[\s]*';
const String _paramExpressionSet = r'[\w]+';

/// The option for the [Interpolation] to find placeholder inside String & Json
/// objects and interpolate (replace) them with provided values.
///
/// The default options are:
/// ```
/// {
///   prefix = '{',
///   suffix = '}',
///   subKeyPointer = '.',
/// }
/// ```
/// Hence, a string with placeholder would look like
/// ```dart
/// var str = "Hi, my name is '{name}'. I'm {age}. I am {education.degree} {education.profession}.";
/// ```
/// and, the appropriate value collection for it may be
/// ```dart
/// var value = {
///   'name': 'David',
///   'age': 29,
///   'education': {
///     'degree': 'M.B.B.S',
///     'profession': 'Doctor'
///   }
/// }
/// ```
/// Similarly a json equivalent dart object may be
/// ```dart
/// var obj = {
///   'a': 'a',
///   'b': 10,
///   'c': {
///     'd': 'd',
///     'e': 'Hello {c.d}',
///     'f': 'Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}'
///   }
/// };
/// ```
/// which contains its own placeholder value in itself.
class InterpolationOption {
  final String _prefix;
  final String _suffix;
  final String _subKeyPointer;

  InterpolationOption._init(this._prefix, this._suffix, this._subKeyPointer);

  /// Create an InterpolationOption instance with the default values (if not specified)
  /// ```
  /// {
  ///   prefix = '{',
  ///   suffix = '}',
  ///   subKeyPointer = '.',
  /// }
  /// ```
  factory InterpolationOption(
          {String prefix = '{',
          String suffix = '}',
          String subKeyPointer = '.'}) =>
      InterpolationOption._init(prefix, suffix, subKeyPointer);

  String _escapedTrim(String val) => RegExp.escape(val.trim());

  /// the trimmed and Regex escaped form of [prefix]
  String get prefix => _escapedTrim(_prefix);

  /// the trimmed and Regex escaped form of [suffix]
  String get suffix => _escapedTrim(_suffix);

  /// the trimmed and Regex escaped form of [subKeyPointer]
  String get subKeyPointer => _escapedTrim(_subKeyPointer);
}

/// The [Interpolation] class to handle String & Json interpolation.
///
/// Create an instance of [Interpolation]
/// ```dart
/// var interpolation = Interpolation();
/// // or with custom option
/// var interpolation = Interpolation(
///    option: InterpolationOption(prefix: r'$(', suffix: ')', subKeyPointer: '_'));
/// ```
/// Now, a string with placeholder would look like
/// ```dart
/// var str = "Hi, my name is '{name}'. I'm {age}. I am {education.degree} {education.profession}.";
/// ```
/// and, the appropriate value collection for it may be
/// ```dart
/// var value = {
///   'name': 'David',
///   'age': 29,
///   'education': {
///     'degree': 'M.B.B.S',
///     'profession': 'Doctor'
///   }
/// }
/// ```
/// Now, just use [eval] to get the interpolated string
/// ```dart
/// print(interpolation.eval(str, value));
/// // output: Hi, my name is 'David'. I'm 29. I am M.B.B.S Doctor.
/// ```
///
/// Similarly a json equivalent dart object may be
/// ```dart
/// var obj = {
///   'a': 'a',
///   'b': 10,
///   'c': {
///     'd': 'd',
///     'e': 'Hello {c.d}',
///     'f': 'Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}'
///   }
/// };
/// ```
/// which contains its own placeholder value in itself.
/// Let's [resolve] this to get the interpolated object
/// ```dart
/// print(interpolation.resolve(obj));
/// // output: {a: a, b: 10, c: {d: d, e: Hello d, f: Hi "a", am I deep enough, or need to show "Hello d" with 10}}
/// ```
class Interpolation {
  final InterpolationOption _option;
  RegExp _paramRegex;

  Interpolation._init(this._option) {
    _paramRegex = _getParamRegex;
  }

  /// Default factory constructor for [Interpolation].
  ///
  /// ```dart
  /// var interpolation = Interpolation();
  /// // or with custom option
  /// var interpolation = Interpolation(
  ///    option: InterpolationOption(prefix: r'$(', suffix: ')', subKeyPointer: '_'));
  /// ```
  factory Interpolation({InterpolationOption option}) =>
      Interpolation._init(option ?? InterpolationOption());

  RegExp get _getParamRegex => RegExp(
      '${_option.prefix}'
      '($_spaces$_paramExpressionSet'
      '(?:(${_option.subKeyPointer})$_paramExpressionSet)*$_spaces)'
      '${_option.suffix}',
      caseSensitive: true,
      multiLine: false,
      dotAll: true);

  /// Get the value of the [key] from a complex [obj].
  ///
  /// Supports multi-level traversing.
  /// That's where the `InterpolationOption.subKeyPointer` comes into place.
  ///
  /// If [keepAlive] is set to `true`, it'll leave all placeholders
  /// intact if the value is not found inside [obj].
  /// Or else, it'll be substituted with '' (empty String)
  ///
  /// Example:
  /// ```dart
  /// var interpolation = Interpolation();
  /// var obj = {
  ///   'a': 'a',
  ///   'b': 10,
  ///   'c': {
  ///     'd': 'd',
  ///     'e': 'Hello {c.d}',
  ///     'f': 'Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}'
  ///   }
  /// };
  /// print(interpolation.traverse(obj, 'b'));
  /// // output: 10
  /// print(interpolation.traverse(obj, 'c.e'));
  /// // output: Hello {c.d}
  /// print(interpolation.traverse(obj, 'c.g')); // not present
  /// // output: (empty string)
  /// print(interpolation.traverse(obj, 'c.g', true)); // not present but keepAlive
  /// // output: {c.g}
  /// ```
  String traverse(Map<String, dynamic> obj, String key,
      [bool keepAlive = false]) {
    var result = key
        .split(_option._subKeyPointer)
        .fold(obj, (parent, k) => parent is String ? parent : parent[k]);
    return result?.toString() ??
        (keepAlive ? '${_option._prefix}$key${_option._suffix}' : '');
  }

  Set<String> _getMatchSet(String str) =>
      _paramRegex.allMatches(str).map((match) => match.group(1)).toSet();

  String _getInterpolated(String str, Map<String, String> values,
      [bool keepAlive = false]) {
    return str.replaceAllMapped(_paramRegex, (match) {
      var param = match.group(1).trim();
      return values.containsKey(param)
          ? values[param]
          : keepAlive ? match.group(0) : '';
    });
  }

  Map<String, String> _flattenAndResolve(
      Map<String, dynamic> obj, Set<String> matchSet,
      [Map<String, String> oldCache, bool keepAlive = false]) {
    var cache = oldCache ?? <String, String>{};
    matchSet.forEach((match) {
      if (cache.containsKey(match)) return;
      // Step 1: Get current value
      var curVal = traverse(obj, match, keepAlive);
      // Step 2: If it contains other parameters
      if (_paramRegex.hasMatch(curVal)) {
        // it's time to update cache with missing matchSet
        var missingMatchSet = _getMatchSet(curVal);
        missingMatchSet.removeAll(cache.keys);
        if (missingMatchSet.isNotEmpty) {
          cache = _flattenAndResolve(obj, missingMatchSet, cache, keepAlive);
        }
        curVal = _getInterpolated(curVal, cache, keepAlive);
      }
      // Step 5: Finally
      cache[match] = curVal;
    });
    return cache;
  }

  /// Evaluate (substitute) [str] with provided [values].
  ///
  /// If [keepAlive] is set to `true`, it'll leave all placeholders
  /// intact if the value is not found inside [values].
  /// Or else, it'll be substituted with '' (empty String)
  String eval(String str, Map<String, dynamic> values,
      [bool keepAlive = false]) {
    if (_paramRegex.hasMatch(str)) {
      var missingMatchSet = _getMatchSet(str);
      var cache = _flattenAndResolve(values, missingMatchSet, null, keepAlive);
      str = _getInterpolated(str, cache, keepAlive);
    }
    return str;
  }

  /// Resolve (substitute all placeholders) inside a json equivalent
  /// dart [obj] with its own values.
  ///
  /// If [keepAlive] is set to `true`, it'll leave all placeholders
  /// intact if the value is not found inside [obj].
  /// Or else, it'll be substituted with '' (empty String)
  Map<String, dynamic> resolve(Map<String, dynamic> obj,
      [bool keepAlive = false]) {
    var jsonString = json.encode(obj);
    jsonString = eval(jsonString, obj, keepAlive);
    return json.decode(jsonString);
  }
}
