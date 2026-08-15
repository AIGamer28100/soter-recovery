import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soter_recovery/features/onboarding/presentation/patient_details_form.dart';
import 'package:soter_recovery/features/profile/domain/user_profile.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    bool busy = false,
    bool picking = false,
    EmergencyContact? pickedContact,
    String? pickerErrorMessage,
    bool manualEntryVisible = false,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController caregiverEmailController,
    required VoidCallback onPickContact,
    required VoidCallback onSubmit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PatientDetailsForm(
            busy: busy,
            picking: picking,
            pickedContact: pickedContact,
            pickerErrorMessage: pickerErrorMessage,
            manualEntryVisible: manualEntryVisible,
            nameController: nameController,
            phoneController: phoneController,
            caregiverEmailController: caregiverEmailController,
            onPickContact: onPickContact,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }

  group('PatientDetailsForm', () {
    testWidgets('default state shows pick button, one text field, submit disabled', (tester) async {
      final nameController = TextEditingController();
      final phoneController = TextEditingController();
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      await pump(
        tester,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () {},
        onSubmit: () {},
      );

      expect(find.text('Choose from contacts'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      final submit = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(submit.onPressed, isNull);
    });

    testWidgets('picking state disables pick button and shows opening label', (tester) async {
      final nameController = TextEditingController();
      final phoneController = TextEditingController();
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      await pump(
        tester,
        picking: true,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () {},
        onSubmit: () {},
      );

      final pickButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(pickButton.onPressed, isNull);
      expect(find.text('Opening contacts…'), findsOneWidget);
    });

    testWidgets('picked contact shows tile, change button, one text field, submit enabled', (tester) async {
      final nameController = TextEditingController();
      final phoneController = TextEditingController();
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      const contact = EmergencyContact(name: 'Jane Doe', phone: '+15551234567');

      await pump(
        tester,
        pickedContact: contact,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () {},
        onSubmit: () {},
      );

      expect(find.byKey(const ValueKey('picked-contact-tile')), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('+15551234567'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      final submit = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(submit.onPressed, isNotNull);
    });

    testWidgets('picker error message is shown as a live region without leaking manual entry', (tester) async {
      final nameController = TextEditingController();
      final phoneController = TextEditingController();
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      await pump(
        tester,
        pickerErrorMessage: 'Something went wrong',
        manualEntryVisible: false,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () {},
        onSubmit: () {},
      );

      final errorFinder = find.byKey(const ValueKey('picker-error'));
      expect(errorFinder, findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);

      final semantics = tester.widget<Semantics>(
        find.ancestor(of: errorFinder, matching: find.byType(Semantics)).first,
      );
      expect(semantics.properties.liveRegion, isTrue);

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('manual entry visible with empty controllers shows 3 fields and disables submit', (tester) async {
      final nameController = TextEditingController();
      final phoneController = TextEditingController();
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      await pump(
        tester,
        manualEntryVisible: true,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () {},
        onSubmit: () {},
      );

      expect(find.byType(TextField), findsNWidgets(3));
      final submit = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(submit.onPressed, isNull);
    });

    testWidgets('manual entry filled enables submit and invokes onSubmit once when tapped', (tester) async {
      final nameController = TextEditingController(text: 'John Smith');
      final phoneController = TextEditingController(text: '5551234567');
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      var submitCount = 0;

      await pump(
        tester,
        manualEntryVisible: true,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () {},
        onSubmit: () => submitCount++,
      );

      final submit = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(submit.onPressed, isNotNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(submitCount, 1);
    });

    testWidgets('busy state disables submit and shows saving label', (tester) async {
      final nameController = TextEditingController();
      final phoneController = TextEditingController();
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      const contact = EmergencyContact(name: 'Jane Doe', phone: '+15551234567');

      await pump(
        tester,
        busy: true,
        pickedContact: contact,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () {},
        onSubmit: () {},
      );

      final submit = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(submit.onPressed, isNull);
      expect(find.text('Saving…'), findsOneWidget);
    });

    testWidgets('tapping choose from contacts invokes onPickContact once', (tester) async {
      final nameController = TextEditingController();
      final phoneController = TextEditingController();
      final caregiverEmailController = TextEditingController();
      addTearDown(() {
        nameController.dispose();
        phoneController.dispose();
        caregiverEmailController.dispose();
      });

      var pickCount = 0;

      await pump(
        tester,
        nameController: nameController,
        phoneController: phoneController,
        caregiverEmailController: caregiverEmailController,
        onPickContact: () => pickCount++,
        onSubmit: () {},
      );

      await tester.tap(find.text('Choose from contacts'));
      await tester.pump();

      expect(pickCount, 1);
    });
  });
}
