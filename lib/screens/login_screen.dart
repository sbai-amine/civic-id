import 'package:flutter/material.dart';

import '../controllers/login_controller.dart';
import '../i18n/app_i18n.dart';
import '../models/login_credentials.dart';
import '../models/sign_in_result.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/national_id_field.dart';
import '../widgets/pin_field.dart';
import '../widgets/primary_button.dart';

/// Login UI: validates input, calls backend via [LoginController], navigates on success.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _pinController = TextEditingController();
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController();
    _nationalIdController.addListener(_onCredentialChanged);
    _pinController.addListener(_onCredentialChanged);
  }

  void _onCredentialChanged() {
    if (_loginController.errorMessage != null) {
      _loginController.clearError();
    }
  }

  @override
  void dispose() {
    _nationalIdController.removeListener(_onCredentialChanged);
    _pinController.removeListener(_onCredentialChanged);
    _nationalIdController.dispose();
    _pinController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await _loginController.signIn(
      LoginCredentials(
        nationalId: _nationalIdController.text.trim(),
        pin: _pinController.text.trim(),
      ),
    );

    if (!mounted) return;

    if (result is SignInSuccess) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
    // [SignInFailure]: error message is already on the controller for the UI.
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
            listenable: _loginController,
            builder: (context, _) {
              final errorText = _loginController.errorMessage;
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
                                AppI18n.t(context, 'login.title'),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppI18n.t(context, 'login.subtitle'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (errorText != null) ...[
                                const SizedBox(height: 16),
                                _LoginErrorBanner(message: errorText),
                              ],
                              const SizedBox(height: 24),
                              NationalIdField(
                                controller: _nationalIdController,
                                validator: Validators.nationalId,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              const SizedBox(height: 14),
                              PinField(
                                controller: _pinController,
                                validator: Validators.pin,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _onLogin(),
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: AppI18n.t(context, 'login.button'),
                                isLoading: _loginController.isLoading,
                                onPressed: _onLogin,
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

/// Inline error surface for mock/API failures (distinct from field validators).
class _LoginErrorBanner extends StatelessWidget {
  const _LoginErrorBanner({required this.message});

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
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
              size: 22,
            ),
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
