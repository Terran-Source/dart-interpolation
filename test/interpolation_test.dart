import 'package:interpolation/interpolation.dart';
import 'package:test/test.dart';

void main() {
  group('A simple String Interpolation', () {
    Interpolation interpolation;
    const str = "Hi, my name is '{name}'. I'm {age}.";
    const values = {'name': 'David', 'age': 18};
    setUp(() {
      interpolation = Interpolation();
    });

    test('First Test', () {
      var result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });
  });
  group('A String Interpolation with custom parameter boundary', () {
    Interpolation interpolation;
    const str = r"Hi, my name is '${name}'. I'm ${age}.";
    const values = {'name': 'David', 'age': 18};
    setUp(() {
      var option = InterpolationOption(prefix: r'${');
      interpolation = Interpolation(option: option);
    });

    test('First Test', () {
      var result = interpolation.eval(str, values);
      expect(result,
          equals("Hi, my name is '${values["name"]}'. I'm ${values["age"]}."));
    });
  });
}
