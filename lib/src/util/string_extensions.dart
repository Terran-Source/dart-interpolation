extension StringConcatenation on String {
  String toUniqueChars([String extra]) =>
      (this + (extra ?? '')).split('').toSet().join('');
}
