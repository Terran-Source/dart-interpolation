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
  var str = "Hi, my name is '{name}'. I'm {age}.";

  print(interpolation.eval(str, {'name': 'David', 'age': 18}));
  // output: Hi, my name is 'David'. I'm 18.

  var obj = {
    'a': 'a',
    'b': 10,
    'c': {
      'd': 'd',
      'e': 'Hello {c.d}',
      'f': 'Hi "{a}", am I deep enough, or need to show "{c.e}" with {b}'
    }
  };

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
