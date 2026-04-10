// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class _FooState extends State<StatefulWidget> {
  Widget build(context) {
    return BackButton(
      onPressed: () {
        // LINT: Avoid calling 'setState' with an empty callback.
        //  Try updating the callback or removing this invocation.
        setState(() {});
      },
    );
  }
}
