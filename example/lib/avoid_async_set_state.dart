import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  const SaveButton({super.key});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  String status = '';

  Future<void> save() async {}

  Future<void> updateStatus() async {
    // LINT: Do not pass an async callback to setState.
    setState(() async {
      await save();
      status = 'Saved';
    });
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: updateStatus,
    child: Text(status),
  );
}
