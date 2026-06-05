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
