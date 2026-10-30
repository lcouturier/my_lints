import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/common/extensions.dart';

void main() {
  test('test 1', () {
    final result = [1, 2, 3, 4].hashJoin([3]);
    expect(result.length, 1);
  });

  test('test 2', () {
    final result = [1, 2, 3, 4].hashJoin([1, 2, 3, 4]);
    expect(result.length, 4);
  });

  test('test 3', () {
    final result = [1, 2, 3, 4].hashJoin([1, 2, 3, 4, 4]);
    expect(result.length, 5);
  });

  test('test 4', () {
    final result = [1, 2, 3, 4, 4].intersect([1, 2, 3, 4], unique: false);
    expect(result.length, 5);
  });

  test('test 5', () {
    final result = [1, 2, 3, 4, 4].intersect([1, 2, 3, 4]);
    expect(result.length, 4);
  });
}
