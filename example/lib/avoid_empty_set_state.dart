// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class _FooState extends State<StatefulWidget> {
  Widget build(context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10), // LINT
      child: BackButton(
        onPressed: () {
          // LINT: Avoid calling 'setState' with an empty callback.
          //  Try updating the callback or removing this invocation.
          setState(() {
            if (context.mounted) {
              // do something
            }
          });
        },
      ),
    );
  }
}
