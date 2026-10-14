import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({required this.save, super.key});

  final VoidCallback save; // LINT: Name widget callback fields with the `on` prefix.

  @override
  Widget build(BuildContext context) => const SizedBox();
}
