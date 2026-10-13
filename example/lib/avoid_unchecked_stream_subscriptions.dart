import 'dart:async';

void main() {
  // BAD: Stream subscription not stored
  final stream = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
  stream.listen((data) {
    print(data);
  });

  // GOOD: Stream subscription stored and can be cancelled
  final stream2 = Stream<int>.periodic(Duration(seconds: 1), (i) => i);
  final subscription = stream2.listen((data) {
    print(data);
  });
  subscription.cancel();
}
