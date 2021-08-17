import 'package:interpolation/interpolation.dart';
import 'package:test/test.dart';

void main() {
  late Interpolation interpolation;

  group('Simple String Interpolation:', () {
    setUp(() {
      interpolation = Interpolation();
    });

    test('First Test with couple of interpolation', () {
      const str = "Hi, my name is '{ name }'. I'm {age}.";
      const values = {'name': 'David', 'age': 18};
      final result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });

    test('First Test with couple of interpolation, with space', () {
      const str = "Hi, my name is '{ name }'. I'm {age}.";
      const values = {'name': 'David', 'age': 18};
      final result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });

    test('Test with just single interpolation', () {
      const str = "Hi, I'm {name}";
      const values = {'name': 'David'};
      final result = interpolation.eval(str, values);
      expect(result, equals("Hi, I'm ${values["name"]}"));
    });
  });

  group('String Interpolation (custom option)', () {
    const str = r"Hi, my name is '${name}'. I'm ${ age }.";
    const values = {'name': 'David', 'age': 18};

    setUp(() {
      final option = InterpolationOption(prefix: r'${');
      interpolation = Interpolation(option: option);
    });

    test('- prefix: "\${"', () {
      final result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });

    test('- prefix: "\${" - Test with just single interpolation', () {
      final strSingle = r"Hi, my name is '${name}'.";
      final result = interpolation.eval(strSingle, values);
      expect(result, equals("Hi, my name is '${values["name"]}'."));
    });

    test('- prefix: "\${", with space', () {
      final strSingle = r"Hi, my name is '${ name }'. I'm ${age}.";
      final result = interpolation.eval(strSingle, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });
  });

  group('String Interpolation (custom option, with space)', () {
    const str = r"Hi, my name is '${ name }'. I'm ${age}.";
    const values = {'name': 'David', 'age': 18};

    setUp(() {
      final option = InterpolationOption(prefix: r' ${ ', suffix: r' } ');
      interpolation = Interpolation(option: option);
    });

    test('- prefix: "\${"', () {
      final result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });

    test('- prefix: "\${" - Test with just single interpolation', () {
      final strSingle = r"Hi, my name is '${name}'.";
      final result = interpolation.eval(strSingle, values);
      expect(result, equals("Hi, my name is '${values["name"]}'."));
    });

    test('- prefix: "\${", with space', () {
      final strSingle = r"Hi, my name is '${ name }'. I'm ${ age }.";
      final result = interpolation.eval(strSingle, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });
  });

  group('Simple Json Interpolation:', () {
    setUp(() {
      interpolation = Interpolation();
    });

    test('First Test with full object multi-level interpolation', () {
      final obj = {
        'a': '{ c.d }',
        'b': 10,
        'c': {
          'd': 'd',
          'e': 'Hello {c.d}',
          'f': 'Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}'
        },
        'g': 'High level => \${c.f}'
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.e'), "Hello {c.d}");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), "{c.g}");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {
              'd': 'd',
              'e': 'Hello ${result["c"]["d"]}',
              'f':
                  'Hi "${result["a"]}", am I deep enough, or need to show "${result["c"]["e"]}" with ${result["b"]}'
            },
            'g':
                'High level => \$${result["c"]["f"]}' // 'High level => ${result["c"]["f"]}'
          }));
    });

    test('First Test with full object multi-level interpolation, with space',
        () {
      final obj = {
        'a': '{c.d}',
        'b': 10,
        'c': {
          'd': 'd',
          'e': 'Hello { c.d }',
          'f':
              'Hi "{a}", am I deep enough, or need to show "{ c.e }" with { b }'
        },
        'g': 'High level => \${ c.f }'
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.e'), "Hello { c.d }");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), "{c.g}");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {
              'd': 'd',
              'e': 'Hello ${result["c"]["d"]}',
              'f':
                  'Hi "${result["a"]}", am I deep enough, or need to show "${result["c"]["e"]}" with ${result["b"]}'
            },
            'g':
                'High level => \$${result["c"]["f"]}' // 'High level => ${result["c"]["f"]}'
          }));
    });

    test('Test with just single interpolation', () {
      final obj = {
        'a': '{ c.d}',
        'b': 10,
        'c': {'d': 'd'}
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.d'), "d");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), "{c.g}");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {'d': 'd'}
          }));
    });
  });

  group('Json Interpolation (custom option):', () {
    setUp(() {
      final option = InterpolationOption(prefix: r'${');
      interpolation = Interpolation(option: option);
    });

    test('Full object multi-level interpolation - prefix: "\${"', () {
      final obj = {
        'a': '\${ c.d }',
        'b': 10,
        'c': {
          'd': 'd',
          'e': 'Hello \${c.d}',
          'f':
              'Hi "\${a}", am I deep enough, or need to show "\${c.e}" with \${b}'
        },
        'g': 'High level => \$\${c.f}'
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.e'), "Hello \${c.d}");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), "\${c.g}");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {
              'd': 'd',
              'e': 'Hello ${result["c"]["d"]}',
              'f':
                  'Hi "${result["a"]}", am I deep enough, or need to show "${result["c"]["e"]}" with ${result["b"]}'
            },
            'g':
                'High level => \$${result["c"]["f"]}' // 'High level => ${result["c"]["f"]}'
          }));
    });

    test('Full object multi-level interpolation - prefix: "\${", with space',
        () {
      final obj = {
        'a': '\${ c.d }',
        'b': 10,
        'c': {
          'd': 'd',
          'e': 'Hello \${ c.d }',
          'f':
              'Hi "\${a}", am I deep enough, or need to show "\${ c.e }" with \${b}'
        },
        'g': 'High level => \$\${ c.f }'
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.e'), "Hello \${ c.d }");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), "\${c.g}");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {
              'd': 'd',
              'e': 'Hello ${result["c"]["d"]}',
              'f':
                  'Hi "${result["a"]}", am I deep enough, or need to show "${result["c"]["e"]}" with ${result["b"]}'
            },
            'g':
                'High level => \$${result["c"]["f"]}' // 'High level => ${result["c"]["f"]}'
          }));
    });

    test('Single interpolation - prefix: "\${"', () {
      final obj = {
        'a': '\${ c.d}',
        'b': 10,
        'c': {'d': 'd'}
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.d'), "d");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), "\${c.g}");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {'d': 'd'}
          }));
    });
  });

  group('Json Interpolation (custom option, with space):', () {
    setUp(() {
      final option = InterpolationOption(prefix: r' ${ ', suffix: r' } ');
      interpolation = Interpolation(option: option);
    });

    test(
        'Full object multi-level interpolation - prefix: " \${ ", suffix: " } "',
        () {
      final obj = {
        'a': ' \${ c.d } ',
        'b': 10,
        'c': {
          'd': 'd',
          'e': 'Hello \${c.d}',
          'f':
              'Hi "\${a}", am I deep enough, or need to show "\${c.e}" with \${b}'
        },
        'g': 'High level => \$\${c.f}'
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.e'), "Hello \${c.d}");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), " \${ c.g } ");
      expect(
          result,
          equals({
            'a': ' ${result["c"]["d"]} ',
            'b': 10,
            'c': {
              'd': 'd',
              'e': 'Hello ${result["c"]["d"]}',
              'f':
                  'Hi "${result["a"]}", am I deep enough, or need to show "${result["c"]["e"]}" with ${result["b"]}'
            },
            'g':
                'High level => \$${result["c"]["f"]}' // 'High level => ${result["c"]["f"]}'
          }));
    });

    test(
        'Full object multi-level interpolation - prefix: " \${ ", suffix: " } ", with space',
        () {
      final obj = {
        'a': '\${ c.d }',
        'b': 10,
        'c': {
          'd': 'd',
          'e': 'Hello \${ c.d }',
          'f':
              'Hi "\${a}", am I deep enough, or need to show "\${ c.e }" with \${b}'
        },
        'g': 'High level => \$\${ c.f }'
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.e'), "Hello \${ c.d }");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), " \${ c.g } ");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {
              'd': 'd',
              'e': 'Hello ${result["c"]["d"]}',
              'f':
                  'Hi "${result["a"]}", am I deep enough, or need to show "${result["c"]["e"]}" with ${result["b"]}'
            },
            'g':
                'High level => \$${result["c"]["f"]}' // 'High level => ${result["c"]["f"]}'
          }));
    });

    test('Single interpolation - prefix: " \${ ", suffix: " } "', () {
      final obj = {
        'a': '\${ c.d}',
        'b': 10,
        'c': {'d': 'd'}
      };

      final result = interpolation.resolve(obj);
      expect(interpolation.traverse(obj, 'b'), "10");
      expect(interpolation.traverse(obj, 'c.d'), "d");
      expect(interpolation.traverse(obj, 'c.g'), "");
      expect(interpolation.traverse(obj, 'c.g', true), " \${ c.g } ");
      expect(
          result,
          equals({
            'a': '${result["c"]["d"]}',
            'b': 10,
            'c': {'d': 'd'}
          }));
    });
  });
}
