import 'package:interpolation/interpolation.dart';
import 'package:test/test.dart';

void main() {
  group('Simple String Interpolation:', () {
    Interpolation interpolation;
    setUp(() {
      interpolation = Interpolation();
    });

    test('First Test with couple of interpolation', () {
      const str = "Hi, my name is '{name}'. I'm {age}.";
      const values = {'name': 'David', 'age': 18};
      var result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });

    test('Test with just single interpolation', () {
      const str = "Hi, I'm {name}";
      const values = {'name': 'David'};
      var result = interpolation.eval(str, values);
      expect(result, equals("Hi, I'm ${values["name"]}"));
    });
  });
  group('String Interpolation (custom option)', () {
    Interpolation interpolation;
    const str = r"Hi, my name is '${name}'. I'm ${age}.";
    const values = {'name': 'David', 'age': 18};
    setUp(() {
      var option = InterpolationOption(prefix: r'${');
      interpolation = Interpolation(option: option);
    });

    test('First Test - prefix: "\${"', () {
      var result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });
  });
}
