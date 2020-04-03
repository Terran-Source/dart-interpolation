import 'dart:convert';

const String _spaces = r'[\s]*';
const String _paramExpressionSet = r'[\w]+';

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

  String get prefix => _escapedTrim(_prefix);
  String get suffix => _escapedTrim(_suffix);
  String get subKeyPointer => _escapedTrim(_subKeyPointer);
}

class Interpolation {
  final InterpolationOption _option;
  RegExp _paramRegex;

  Interpolation._init(this._option) {
    _paramRegex = _getParamRegex;
  }

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

  String traverse(Map<String, dynamic> obj, String key) {
    var result = key
        .split(_option._subKeyPointer)
        .fold(obj, (parent, k) => parent is String ? parent : parent[k]);
    return result?.toString() ?? '${_option._prefix}$key${_option.suffix}';
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
      var curVal = traverse(obj, match);
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

  String eval(String str, Map<String, dynamic> values,
      [bool keepAlive = false]) {
    if (_paramRegex.hasMatch(str)) {
      var missingMatchSet = _getMatchSet(str);
      var cache = _flattenAndResolve(values, missingMatchSet, null, keepAlive);
      str = _getInterpolated(str, cache, keepAlive);
    }
    return str;
  }

  Map<String, dynamic> resolve(Map<String, dynamic> obj,
      [bool keepAlive = false]) {
    var jsonString = json.encode(obj);
    jsonString = eval(jsonString, obj, keepAlive);
    return json.decode(jsonString);
  }
}
