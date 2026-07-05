import 'package:flutter/material.dart';

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // This should trigger the lint
    final text = I18n.current.hello;

    return Text(text);
  }
}

class I18n {
  static I18n get current => I18n._();

  static I18n of(BuildContext context) => I18n._();

  I18n._();

  String get hello => 'Hello';
}
