final hello = '${'hello'}';
final world = '${'hello'} world';

final code = '${42}';
final enabled = '${true}';
final nullable = '${null}';

class User {
  final String name;
  User(this.name);
}

final user = User('Alice');
final userName = user.name;
final text = '${(userName)}'; //

final label = '${user.toString()}'; //LINT
final name = '${user.name}';
final upperName = '${user.name.toUpperCase()}';
final greeting = '${user.name} says hello!';

final complex = 'User: ${user.name.toUpperCase()} (${user.toString()})'; // LINT

final first = 'First';
final second = 'Second';
final combined = '$first - ${second}'; //LINT
final combined2 = '$first - ${second}m';
final anotherHello = 'Hello, ${first}'; //LINT
