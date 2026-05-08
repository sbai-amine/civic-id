import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/register_api_service.dart';

/// Simulated government issuance flow. Demonstrates how a BridgeID account is
/// created after in-person identity verification. Reachable only from the
/// verifier app's settings screen, and only in debug builds.
class GovernmentIssuanceScreen extends StatefulWidget {
  const GovernmentIssuanceScreen({super.key});

  @override
  State<GovernmentIssuanceScreen> createState() =>
      _GovernmentIssuanceScreenState();
}

class _GovernmentIssuanceScreenState extends State<GovernmentIssuanceScreen> {
  int _currentStep = 0;
  bool _isIssuing = false;
  RegisterResult? _issueResult;
  String? _generatedPin;

  final _step1FormKey = GlobalKey<FormState>();
  final _cinController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _docExamined = false;
  bool _photoMatch = false;
  bool _dataMatch = false;

  @override
  void dispose() {
    _cinController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  bool get _allVerified => _docExamined && _photoMatch && _dataMatch;

  String _generatePin() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  String? _validateNotEmpty(String? value, String label) {
    if ((value?.trim() ?? '').isEmpty) return '$label cannot be empty';
    return null;
  }

  void _onStepContinue() {
    switch (_currentStep) {
      case 0:
        if (_step1FormKey.currentState?.validate() ?? false) {
          setState(() => _currentStep = 1);
        }
      case 1:
        if (_allVerified) {
          final pin = _generatePin();
          setState(() {
            _currentStep = 2;
            _isIssuing = true;
            _generatedPin = pin;
          });
          _issueAccountWithPin(pin);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Complete all verification checks before proceeding.'),
            ),
          );
        }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0 && _currentStep < 2) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _issueAccountWithPin(String pin) async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final result = await RegisterApiService().register(
      nationalId: _cinController.text.trim(),
      fullName: _fullNameController.text.trim(),
      pin: pin,
    );
    if (!mounted) return;
    setState(() {
      _isIssuing = false;
      _issueResult = result;
    });
  }

  void _resetAll() {
    setState(() {
      _currentStep = 0;
      _isIssuing = false;
      _issueResult = null;
      _generatedPin = null;
      _docExamined = false;
      _photoMatch = false;
      _dataMatch = false;
      _cinController.clear();
      _fullNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Issuance Portal'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCC02)),
            ),
            child: const Text(
              'SIMULATED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF57F17),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              controlsBuilder: (context, details) {
                if (_currentStep == 2) return const SizedBox.shrink();
                const buttonStyle = ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size(64, 44)),
                );
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(
                        style: buttonStyle,
                        onPressed: details.onStepContinue,
                        child: Text(
                          _currentStep == 1
                              ? 'Confirm & Issue Account'
                              : 'Continue',
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Citizen Information'),
                  subtitle:
                      const Text('Enter details as shown on the national ID'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: Form(
                    key: _step1FormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _cinController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'National ID',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) =>
                              _validateNotEmpty(v, 'National ID'),
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _fullNameController,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'As printed on the national ID',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => _validateNotEmpty(v, 'Full name'),
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('Physical ID Verification'),
                  subtitle:
                      const Text('Agent confirms all checks before issuance'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content: Column(
                    children: [
                      _VerifyCheckTile(
                        label: 'National ID document examined',
                        checked: _docExamined,
                        onChanged: (v) =>
                            setState(() => _docExamined = v ?? false),
                      ),
                      _VerifyCheckTile(
                        label: 'Photo on document matches citizen',
                        checked: _photoMatch,
                        onChanged: (v) =>
                            setState(() => _photoMatch = v ?? false),
                      ),
                      _VerifyCheckTile(
                        label: 'Personal data matches records',
                        checked: _dataMatch,
                        onChanged: (v) =>
                            setState(() => _dataMatch = v ?? false),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Account Issuance'),
                  subtitle: const Text('Digital identity account creation'),
                  isActive: _currentStep >= 2,
                  state: StepState.indexed,
                  content: _buildIssuanceContent(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuanceContent(ThemeData theme) {
    if (_isIssuing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating digital identity account…'),
          ],
        ),
      );
    }

    final result = _issueResult;
    if (result == null) return const SizedBox.shrink();

    if (result is RegisterSuccess) {
      return _IssuanceSuccessCard(
        nationalId: _cinController.text.trim(),
        fullName: _fullNameController.text.trim(),
        generatedPin: _generatedPin!,
        onDone: () => Navigator.of(context).pop(),
        onIssueAnother: _resetAll,
      );
    }

    final failure = result as RegisterFailure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    failure.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.tonal(
          onPressed: _resetAll,
          child: const Text('Start Over'),
        ),
      ],
    );
  }
}

class _VerifyCheckTile extends StatelessWidget {
  const _VerifyCheckTile({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: checked,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}

class _IssuanceSuccessCard extends StatelessWidget {
  const _IssuanceSuccessCard({
    required this.nationalId,
    required this.fullName,
    required this.generatedPin,
    required this.onDone,
    required this.onIssueAnother,
  });

  final String nationalId;
  final String fullName;
  final String generatedPin;
  final VoidCallback onDone;
  final VoidCallback onIssueAnother;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4CAF50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF2E7D32), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Account Successfully Issued',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'National ID', value: nationalId),
              if (fullName.isNotEmpty)
                _InfoRow(label: 'Full Name', value: fullName),
              const SizedBox(height: 12),
              const Text(
                'Temporary PIN',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4CAF50)),
                    ),
                    child: Text(
                      generatedPin,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 10,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Copy PIN',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: generatedPin));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Temporary PIN copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined,
                        color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onDone,
          icon: const Icon(Icons.done),
          label: const Text('Close'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onIssueAnother,
          child: const Text('Issue Another Account'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontSize: 13, color: Color(0xFF616161))),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
