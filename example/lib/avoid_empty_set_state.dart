// ignore_for_file: unused_element

import 'package:flutter/material.dart';

// // LINT: This 'EdgeInsets' constructor can be simplified. Try to simplify it.
// EdgeInsets.fromLTRB(8, 0, 8, 0);

// // LINT: This 'EdgeInsets' constructor can be simplified. Try to simplify it.
// EdgeInsets.fromLTRB(8, 0, 0, 0);

// // LINT: This 'EdgeInsets' constructor can be simplified. Try to simplify it.
// EdgeInsets.only(left: 16, right: 16);

// LINT: This 'EdgeInsets' constructor can be simplified. Try to simplify it.
// EdgeInsets.fromLTRB(8, 8, 8, 8);

class _FooState extends State<StatefulWidget> {
  Widget build(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 0), // LINT
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
