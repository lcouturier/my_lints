// ✅ GOOD - Low complexity functions
void simpleFunction() {
  print('Hello');
}

void moderateComplexity(int x) {
  if (x > 0) {
    print('Positive');
  } else if (x < 0) {
    print('Negative');
  } else {
    print('Zero');
  }
}

void withLoop(List<int> items) {
  for (final item in items) {
    print(item);
  }
}

void withTryCatch(String input) {
  try {
    print(int.parse(input));
  } catch (e) {
    print('Error');
  }
}

// ❌ BAD - High complexity function
void complexFunction(User user, List<Item> items) {
  if (user.age == null) return;
  if (user.age! < 18) {
    if (user.isActive) {
      print('Young active user');
    } else {
      print('Young inactive user');
    }
  } else if (user.age! < 30) {
    if (user.hasPermission) {
      print('Adult with permission');
    } else {
      print('Adult without permission');
    }
  } else {
    print('Older user');
  }

  switch (user.status) {
    case Status.active:
      print('Active');
      break;
    case Status.inactive:
      print('Inactive');
      break;
    case Status.pending:
      print('Pending');
      break;
  }

  for (final item in items) {
    if (item.isValid && item.isAvailable) {
      print('Valid item');
    }
  }

  while (user.hasNotifications) {
    print('Notification');
    user.hasNotifications = false;
  }

  try {
    processUser(user);
  } catch (e) {
    handleError(e);
  }
}

// ❌ BAD - Complex method with many conditions
class Processor {
  void processData(Data? data) {
    if (data == null) return;
    if (data.isInvalid) return;
    if (data.isExpired) {
      if (data.canRenew) {
        renew(data);
      } else {
        archive(data);
      }
    } else {
      if (data.isReady) {
        if (data.hasPermission) {
          process(data);
        } else {
          requestPermission(data);
        }
      } else {
        wait(data);
      }
    }

    switch (data.type) {
      case DataType.a:
        handleA(data);
        break;
      case DataType.b:
        handleB(data);
        break;
      case DataType.c:
        handleC(data);
        break;
    }
  }
}

// Helper classes for examples
class User {
  final int? age;
  final bool isActive;
  final bool hasPermission;
  final bool isVerified;
  final Status status;
  bool hasNotifications;

  User({
    this.age,
    required this.isActive,
    required this.hasPermission,
    required this.isVerified,
    required this.status,
    required this.hasNotifications,
  });
}

enum Status { active, inactive, pending }

class Item {
  final bool isValid;
  final bool isAvailable;

  Item({required this.isValid, required this.isAvailable});
}

class Data {
  final bool isInvalid;
  final bool isExpired;
  final bool canRenew;
  final bool isReady;
  final bool hasPermission;
  final DataType type;

  Data({
    required this.isInvalid,
    required this.isExpired,
    required this.canRenew,
    required this.isReady,
    required this.hasPermission,
    required this.type,
  });
}

enum DataType { a, b, c }

void processUser(User user) {}
void handleError(Object e) {}
void renew(Data data) {}
void archive(Data data) {}
void process(Data data) {}
void requestPermission(Data data) {}
void wait(Data data) {}
void handleA(Data data) {}
void handleB(Data data) {}
void handleC(Data data) {}
