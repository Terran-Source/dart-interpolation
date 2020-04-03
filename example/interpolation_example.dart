import 'package:interpolation/interpolation.dart';

void main() {
  var interpolation = Interpolation();
  var str = "Hi, my name is '{name}'. I'm {age}.";

  var obj = {
    'a': 'a',
    'b': 10,
    'c': {
      'd': 'd',
      'e': 'Hello {c.d}',
      'f': 'Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}'
    }
  };

  print(interpolation.eval(str, {'name': 'David', 'age': 18}));
  // output: Hi, my name is 'David'. I'm 18.
  print(interpolation.resolve(obj));
  // output: {a: a, b: 10, c: {d: d, e: Hello d, f: Hi "a", am I deep enough, or need to show "Hello d" with 10}}
  print(obj);
  // original object is not changed
  // output: {a: a, b: 10, c: {d: d, e: Hello {c.d}, f: Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}}}
}
