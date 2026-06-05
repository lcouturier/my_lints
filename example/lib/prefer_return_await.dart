// ignore_for_file: unused_local_variable

Future<String> bad1() async {
  try {
    final data = Future.value('Fetched data'); // LINT: prefer_return_await
    return data;
  } catch (e) {
    return 'Error: $e';
  }
}

Future<String> good() async {
  try {
    final data = await Future.value('Fetched data');
    return data;
  } catch (e) {
    return await Future.value('Error: $e');
  }
}

Future<String> good2() {
  final data = Future.value('Fetched data');
  return data;
}

Future<String> good3() async {
  try {
    final callback = () {
      return Future.value('Fetched data');
    };
    return await callback();
  } catch (e) {
    return 'Error: $e';
  }
}

Future<String> bad2() async {
  try {
    final callback = () {
      return Future.value('Fetched data');
    };
    return callback();
  } catch (e) {
    return 'Error: $e';
  }
}

class MyGood {
  Future<String> fetchData() async {
    try {
      final data = Future.value('Fetched data');
      return data;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
