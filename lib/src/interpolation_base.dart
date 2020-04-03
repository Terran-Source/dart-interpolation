import 'dart:convert';
//import 'util/string_extensions.dart';

const String _spaces = r'[\s]*';
const String _paramExpressionSet = r'[\w]+';
// const String _allowedFuncExpressions = "{}()+-*/%:|?,.\$!&'\"#";
// const List<String> _allowedOperators = [
//   '==',
//   '===',
//   '!=',
//   '!==',
//   '<',
//   '<=',
//   '>',
//   '>='
// ];

class InterpolationOption {
  final String _prefix;
  final String _suffix;
  final String _subKeyPointer;
  // final String _funcSpecifier;
  // final String _escapeSpecifier;

  InterpolationOption._init(
    this._prefix,
    this._suffix,
    this._subKeyPointer,
    //this._funcSpecifier, this._escapeSpecifier
  );

  /// Create an InterpolationOption instance with the default values (if not specified)
  /// ```
  /// {
  ///   prefix = '{',
  ///   suffix = '}',
  ///   subKeyPointer = '.',
  /// }
  /// ```
  factory InterpolationOption({
    prefix = '{',
    suffix = '}',
    subKeyPointer = '.',
    // funcSpecifier = '=',
    // escapeSpecifier = '*'
  }) =>
      InterpolationOption._init(
          prefix, suffix, subKeyPointer //, funcSpecifier, escapeSpecifier
          );

  String _escapedTrim(String val) => RegExp.escape(val.trim());

  String get prefix => _escapedTrim(_prefix);
  String get suffix => _escapedTrim(_suffix);
  String get subKeyPointer => _escapedTrim(_subKeyPointer);
  // String get funcSpecifier => _escapedTrim(_funcSpecifier);
  // String get escapeSpecifier => _escapedTrim(_escapeSpecifier);
}

class Interpolation {
  final InterpolationOption _option;
  RegExp paramRegex;
  //RegExp funcRegex;

  Interpolation._init(this._option) {
    paramRegex = _getParamRegex;
    //funcRegex = _getFuncRegex();
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

  // String _funcExpressionSet(String extra) =>
  //     r'[\s\w' +
  //     RegExp.escape(_allowedFuncExpressions.toUniqueChars(extra)) +
  //     r']+';
  // String get _getOperatorSet =>
  //     _allowedOperators.map((op) => RegExp.escape(op.trim())).join('|');

  // RegExp _getFuncRegex([bool isEscapeRegex = false]) {
  //   var expressionSet = _funcExpressionSet(_option._subKeyPointer);
  //   return RegExp(
  //       '${_option.prefix}'
  //       '${(isEscapeRegex ? '((' : '')}'
  //       '${_option.funcSpecifier}'
  //       '${(isEscapeRegex ? ')?' : '')}'
  //       '($_spaces$expressionSet'
  //       '(?:(${_getOperatorSet})${expressionSet})*$_spaces)'
  //       '${(isEscapeRegex ? '(' : '')}'
  //       '${_option.funcSpecifier}'
  //       '${(isEscapeRegex ? ')?)' : '')}'
  //       '${_option.suffix}',
  //       caseSensitive: true,
  //       multiLine: false,
  //       dotAll: true);
  // }

  String traverse(Map<String, dynamic> obj, String key) {
    var result = key
        .split(_option._subKeyPointer)
        .fold(obj, (parent, k) => parent is String ? parent : parent[k]);
    return result?.toString() ?? '${_option._prefix}$key${_option.suffix}';
  }

  Set<String> _getMatchSet(String str) =>
      paramRegex.allMatches(str).map((match) => match.group(1)).toSet();

  String _getInterpolated(String str, Map<String, String> values,
      [bool keepAlive = false]) {
    //log(`Found match: ${str.match(regex)}`);
    return str.replaceAllMapped(paramRegex, (match) {
      var param = match.group(1).trim();
      return values.containsKey(param)
          ? values[param]
          : keepAlive ? match.group(0) : '';
    });
  }

  // String _getInterpolatedFunc(String str, RegExp funcRegex, RegExp paramRegex,
  //     Map<String, String> values,
  //     [bool keepAlive = false]) {
  //   // log(`Found func match: ${str.match(funcRegex)}`);
  //   // return str.replace(funcRegex, (match, expression) => {
  //   //   let $val = {};
  //   //   expression = expression.trim().replace(paramRegex, (m, param) => {
  //   //     $val[param] = values.hasOwnProperty(param)
  //   //       ? values[param].toString()
  //   //       : '';
  //   //     return `$val['${param}']`;
  //   //   });
  //   //   return new Function('$val', `return ${expression}`)($val);
  //   // });
  //   return '';
  // }

  Map<String, String> _flattenAndResolve(
      Map<String, dynamic> obj, Set<String> matchSet,
      [Map<String, String> oldCache, bool keepAlive = false]) {
    //var paramRegex = _getParamRegex;
    var cache = oldCache ?? <String, String>{};
    matchSet.forEach((match) {
      if (cache.containsKey(match)) return;
      var hasParam = false;
      // Step 1: Get current value
      var curVal = traverse(obj, match);
      // Step 2: If it contains other parameters
      if (paramRegex.hasMatch(curVal)) {
        // it's time to update cache with missing matchSet
        var missingMatchSet = _getMatchSet(curVal);
        missingMatchSet.removeAll(cache.keys);
        if (missingMatchSet.isNotEmpty) {
          cache = _flattenAndResolve(
              obj,
              missingMatchSet,
              //funcRegex,
              cache,
              keepAlive);
        }
        hasParam = true;
      }
      // // Step 3: If it contains function expression
      // if (funcRegex.hasMatch(curVal)) {
      //   // we already gathered all params in the last step, so
      //   curVal = getInterpolatedFunc(curVal, funcRegex, paramRegex, cache);
      // }
      // Step 4: If it still contains other parameters
      if (hasParam && paramRegex.hasMatch(curVal)) {
        curVal = _getInterpolated(curVal, cache, keepAlive);
      }
      // Step 5: Finally
      cache[match] = curVal;
    });
    return cache;
  }

  String eval(String str, Map<String, dynamic> values,
      [bool keepAlive = false]) {
    if (paramRegex.hasMatch(str)) {
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
