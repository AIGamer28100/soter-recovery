import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/domain/user_profile.dart';
import '../../../platform/contacts/contact_picker_service.dart';
import '../../../platform/contacts/contact_mapping.dart';
import '../../../core/errors/app_exception.dart';
import '../application/onboarding_controller.dart';
import 'patient_details_form.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _caregiverEmailController = TextEditingController();
  EmergencyContact? _pickedContact;
  String? _pickerError;
  bool _manualEntryVisible = false;
  bool _picking = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _caregiverEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    setState(() {
      _picking = true;
      _pickerError = null;
    });
    try {
      final contact =
          await ref.read(contactPickerServiceProvider).pickEmergencyContact();
      if (!mounted) return;
      setState(() {
        _picking = false;
        if (contact != null) _pickedContact = contact; // null == cancelled
      });
    } on ContactHasNoPhoneNumber catch (e) {
      if (!mounted) return;
      setState(() {
        _picking = false;
        _pickerError = e.message;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _picking = false;
        _pickerError = e.message;
        _manualEntryVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final signedInEmail = ref.watch(authStateChangesProvider).value?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  switch (state.step) {
                    OnboardingStep.chooseRole => _ChooseRole(
                        busy: state.isSubmitting,
                        onPatient: controller.chooseRoleGoToPatientDetails,
                        onCaregiver: controller.chooseCaregiverRole,
                      ),
                    OnboardingStep.patientDetails => PatientDetailsForm(
                        busy: state.isSubmitting,
                        picking: _picking,
                        pickedContact: _pickedContact,
                        pickerErrorMessage: _pickerError,
                        manualEntryVisible: _manualEntryVisible,
                        nameController: _nameController,
                        phoneController: _phoneController,
                        caregiverEmailController: _caregiverEmailController,
                        onPickContact: _pickContact,
                        onSubmit: () {
                          final contact = _pickedContact ??
                              EmergencyContact(
                                name: _nameController.text.trim(),
                                phone: normalizePhoneNumber(_phoneController.text.trim()),
                              );
                          controller.submitPatient(
                            contact: contact,
                            caregiverEmail: _caregiverEmailController.text.trim().isEmpty
                                ? null
                                : _caregiverEmailController.text.trim(),
                          );
                        },
                      ),
                    OnboardingStep.caregiverNotFound => _CaregiverNotFound(
                        email: signedInEmail,
                        onBack: controller.backToChoice,
                      ),
                  },
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChooseRole extends StatelessWidget {
  const _ChooseRole({required this.busy, required this.onPatient, required this.onCaregiver});

  final bool busy;
  final VoidCallback onPatient;
  final VoidCallback onCaregiver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Who's using this?",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          "This helps us tailor what you see. You can't change this later in this build.",
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: busy ? null : onPatient,
          child: const Text("I'm the person in recovery"),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: busy ? null : onCaregiver,
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("I'm a caregiver"),
        ),
      ],
    );
  }
}

class _CaregiverNotFound extends StatelessWidget {
  const _CaregiverNotFound({required this.email, required this.onBack});

  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'No invitation yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              children: [
                const TextSpan(
                  text: "Nobody has added this email as their caregiver yet. For "
                      "their privacy, only the person in recovery can grant that — "
                      "ask them to add ",
                ),
                TextSpan(
                  text: email,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                const TextSpan(text: ' in their app, then sign in again.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton(onPressed: onBack, child: const Text('Back')),
        ],
      ),
    );
  }
}
