import 'package:flutter/material.dart';

import '../i18n/app_i18n.dart';

/// PIN / password field with obscuring toggle.
class PinField extends StatefulWidget {
  const PinField({
    super.key,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.labelText,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  /// Overrides the default i18n label. Used when the same field appears twice
  /// (e.g. "Choose PIN" vs "Confirm PIN") on the registration form.
  final String? labelText;

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: TextInputType.number,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.labelText ?? AppI18n.t(context, 'form.pin.label'),
        hintText: AppI18n.t(context, 'form.pin.hint'),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscure ? AppI18n.t(context, 'form.pin.show') : AppI18n.t(context, 'form.pin.hide'),
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        ),
      ),
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
