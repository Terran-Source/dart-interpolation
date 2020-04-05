# interpolation
A Dart package to handle dynamic String & Json interpolation.

## Usage
A simple usage example:

#### Add the dependency in pubspec.yaml
```yaml
# pubspec.yaml
# add dependencies
dependencies:
  interpolation: <latest-version>

```

#### Now the code
```dart
import 'package:interpolation/interpolation.dart';

void main() {
  var interpolation = Interpolation();
  var str =
      "Hi, my name is '{name}'. I'm {age}. I am {education.degree} {education.profession}.";

  print(interpolation.eval(str, {
    'name': 'David',
    'age': 29,
    'education': {'degree': 'M.B.B.S', 'profession': 'Doctor'}
  }));
  // output: Hi, my name is 'David'. I'm 29. I am M.B.B.S Doctor.

  var obj = {
    'a': 'a',
    'b': 10,
    'c': {
      'd': 'd',
      'e': 'Hello {c.d}',
      'f': 'Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}'
    }
  };

  // traverse the object
  print(interpolation.traverse(obj, 'b'));
  // output: 10
  print(interpolation.traverse(obj, 'c.e'));
  // output: Hello {c.d}
  print(interpolation.traverse(obj, 'c.g')); // not present
  // output: (empty string)
  print(interpolation.traverse(obj, 'c.g', true)); // not present but keepAlive
  // output: {c.g}

  // resolve the object
  print(interpolation.resolve(obj));
  // output: {a: a, b: 10, c: {d: d, e: Hello d, f: Hi "a", am I deep enough, or need to show "Hello d" with 10}}
  print(obj);
  // original object is not changed
  // output: {a: a, b: 10, c: {d: d, e: Hello {c.d}, f: Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}}}
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Terran-Source/dart-interpolation/issues
