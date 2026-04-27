import 'package:flutter/material.dart';

import '../controllers/register_controller.dart';
import '../i18n/app_i18n.dart';
import '../models/register_request.dart';
import '../models/register_result.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/national_id_field.dart';
import '../widgets/pin_field.dart';
import '../widgets/primary_button.dart';

/// Demo self-registration screen.
///
/// Clearly labelled as demo mode — real deployment uses government-gated
/// issuance (see [GovernmentIssuanceScreen]).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  late final RegisterController _registerController;

  @override
  void initState() {
    super.initState();
    _registerController = RegisterController();
    for (final c in [
      _nationalIdController,
      _fullNameController,
      _pinController,
      _confirmPinController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (_registerController.errorMessage != null) {
      _registerController.clearError();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nationalIdController,
      _fullNameController,
      _pinController,
      _confirmPinController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _registerController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await _registerController.register(
      RegisterRequest(
        nationalId: _nationalIdController.text.trim(),
        fullName: _fullNameController.text.trim(),
        pin: _pinController.text.trim(),
      ),
    );

    if (!mounted) return;

    if (result is RegisterSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo account created. You can now sign in.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF4FF), Color(0xFFF8FAFF)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _registerController,
            builder: (context, _) {
              final errorText = _registerController.errorMessage;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppI18n.t(context, 'app.name'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F4CBA),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Create Demo Account',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Register to explore the dashboard, QR codes, and civic services.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const _DemoModeBanner(),
                              if (errorText != null) ...[
                                const SizedBox(height: 12),
                                _ErrorBanner(message: errorText),
                              ],
                              const SizedBox(height: 20),
                              NationalIdField(
                                controller: _nationalIdController,
                                validator: Validators.nationalId,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _fullNameController,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'As on your national ID',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: Validators.fullName,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              const SizedBox(height: 14),
                              PinField(
                                controller: _pinController,
                                validator: Validators.newPin,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                                labelText: 'Choose PIN (4–6 digits)',
                              ),
                              const SizedBox(height: 14),
                              PinField(
                                controller: _confirmPinController,
                                validator: (v) => Validators.confirmPin(
                                    v, _pinController.text),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _onRegister(),
                                labelText: 'Confirm PIN',
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: 'Create Demo Account',
                                isLoading: _registerController.isLoading,
                                onPressed: _onRegister,
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('or'),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.govIssuance),
                                icon: const Icon(
                                    Icons.account_balance_outlined),
                                label: const Text(
                                    'Government Issuance Portal (Simulated)'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.login),
                                child: const Text(
                                    'Already have an account? Sign In'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DemoModeBanner extends StatelessWidget {
  const _DemoModeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFF57F17), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF5D4037), height: 1.4),
                children: [
                  TextSpan(
                    text: 'DEMO MODE: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'In a real deployment, CivicKey accounts are issued by authorized government agents after in-person identity verification. This ensures your digital identity is legally bound to your physical identity.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline,
                color: theme.colorScheme.onErrorContainer, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
