
import 'dart:async';

const timeout = const Duration(milliseconds: 100);
const ms = const Duration(milliseconds: 1);
Timer _twoFingerTimer;
bool _twoFingerScrollAndTimerUnder100ms = false;

startTimeout([int milliseconds]) {
  var duration = milliseconds == null ? timeout : ms * milliseconds;
  return Timer(duration, handleTimeout);
}

void handleTimeout() {  // callback function
  _twoFingerScrollAndTimerUnder100ms = false;
  _twoFingerTimer.cancel();
}

void setTimerTwoFinger() {
  if (_twoFingerScrollAndTimerUnder100ms) {
    _twoFingerTimer.cancel();
    _twoFingerTimer = startTimeout(100);
  } else {
    _twoFingerScrollAndTimerUnder100ms = true;
    _twoFingerTimer = startTimeout(100);
  }
}

bool isTwoFingerScrollAndTimerUnder100ms() {
  return _twoFingerScrollAndTimerUnder100ms;
}