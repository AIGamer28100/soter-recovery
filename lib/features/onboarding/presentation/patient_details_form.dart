import 'package:flutter/material.dart';

import '../../profile/domain/user_profile.dart';

class PatientDetailsForm extends StatelessWidget {
  const PatientDetailsForm({
    super.key,
    required this.busy,
    required this.picking,
    required this.pickedContact,
    required this.pickerErrorMessage,
    required this.manualEntryVisible,
    required this.nameController,
    required this.phoneController,
    required this.caregiverEmailController,
    required this.onPickContact,
    required this.onSubmit,
  });

  final bool busy;
  final bool picking;
  final EmergencyContact? pickedContact;
  final String? pickerErrorMessage;
  final bool manualEntryVisible;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController caregiverEmailController;
  final VoidCallback onPickContact;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([nameController, phoneController]),
      builder: (context, _) {
        final canSubmit = !busy && !picking && (
            pickedContact != null ||
            (manualEntryVisible &&
             nameController.text.trim().isNotEmpty &&
             phoneController.text.trim().isNotEmpty));

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Who should we reach?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Add one person you'd want called on a hard night. They'll be one tap "
              "away inside the app, and if you nominate them by email, they'll be "
              "able to sign in as your caregiver.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            // Pick/picked/error block
            if (pickedContact == null && !manualEntryVisible) ...[
              OutlinedButton.icon(
                onPressed: (busy || picking) ? null : onPickContact,
                icon: const Icon(Icons.contacts_outlined),
                label: Text(picking ? 'Opening contacts…' : 'Choose from contacts'),
              ),
              const SizedBox(height: 8),
              Text(
                "We only see the one person you pick — we never read your contact list.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ] else if (pickedContact != null) ...[
              ListTile(
                key: const ValueKey('picked-contact-tile'),
                leading: const Icon(Icons.person_outline),
                title: Text(pickedContact!.name),
                subtitle: Text(pickedContact!.phone),
                trailing: TextButton(
                  onPressed: (busy || picking) ? null : onPickContact,
                  child: const Text('Change'),
                ),
              ),
            ],
            if (pickerErrorMessage != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  pickerErrorMessage!,
                  key: const ValueKey('picker-error'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            // Manual entry block
            if (manualEntryVisible) ...[
              Column(
                key: const ValueKey('manual-entry'),
                children: [
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(hintText: "Their name"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: "Their phone number"),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: caregiverEmailController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "Their Google email (optional)"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: canSubmit ? onSubmit : null,
              child: Text(busy ? 'Saving…' : 'Save and continue'),
            ),
            const SizedBox(height: 12),
            Text(
              "A contact is required — on a hard night you shouldn't have to go "
              "looking for a number. Add their Google email too and they can sign "
              "in as your caregiver to see your patterns and get alerts. Only you "
              "can grant that, and only to an address you enter here.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        );
      },
    );
  }
}
