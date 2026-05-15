void foo() {
  bool isNotValid = false; //LINT
  if (!isNotValid) {
    print('is not valid');
  }
  if (!IsNotCustomer()) {
    print('is not customer');
  }
}

bool notificationEnabled = false;
bool isDisabled = true; //LINT

bool IsNotCustomer() {
  //LINT
  return false;
}
