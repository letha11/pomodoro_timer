class TimeConverter {
  /// Time Format
  /// hhh:mm:ss
  /// the hour can up to as many as the user wants can be hundred, thousands, etc.
  /// if the seconds doesn't reach an hour, the hour(hhh) should be gone.
  static fromSeconds(int seconds) {
    late String result;

    /// `~/` operator will divide two integers, and `rounding down` to nearest integer
    /// example: 2 integers divided resulting 3.7, it will round down to nearest integer which is 3,
    /// the result will be 3
    int hours = seconds ~/ 3600;
    int minutes = seconds ~/ 60;
    if (hours > 0) {
      minutes %= 60;
    }
    int remainingSeconds = seconds % 60; // modulo
    String hourStr = hours.toStringAndPad();
    String minuteStr = minutes.toStringAndPad();
    String secondStr = remainingSeconds.toStringAndPad();

    result = hours <= 0 ? '$minuteStr:$secondStr' : '$hourStr:$minuteStr:$secondStr';

    return result;
  }
}

extension IntX on int {
  /// Converting an `int` to `String`
  /// and add padding to it.
  String toStringAndPad() => toString().padLeft(2, '0');
}
