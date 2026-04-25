import 'package:flutter/material.dart';

import '../i18n/app_i18n.dart';

/// National ID text field — isolated for reuse and testing.
class NationalIdField extends StatelessWidget {
  const NationalIdField({
    super.key,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.username],
      decoration: InputDecoration(
        labelText: AppI18n.t(context, 'form.nationalId.label'),
        hintText: AppI18n.t(context, 'form.nationalId.hint'),
        prefixIcon: const Icon(Icons.badge_outlined),
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
