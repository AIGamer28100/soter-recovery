import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';

import '../../core/errors/app_exception.dart';
import '../../features/profile/domain/user_profile.dart';
import 'contact_mapping.dart';

/// The system picker could not be opened or failed. Callers should offer a
/// degraded manual-entry path — otherwise onboarding is unfinishable.
class ContactPickerUnavailable extends AppException {
  const ContactPickerUnavailable(super.message);
}

/// A contact came back with no usable number. Callers should ask the person
/// to pick again — manual entry is NOT offered for this case.
class ContactHasNoPhoneNumber extends AppException {
  const ContactHasNoPhoneNumber(super.message);
}

class ContactPickerService {
  const ContactPickerService(this._picker);
  final FlutterNativeContactPicker _picker;

  /// Returns null when the person backed out of the system picker.
  Future<EmergencyContact?> pickEmergencyContact() async {
    final Contact? picked;
    try {
      picked = await _picker.selectPhoneNumber();
    } on PlatformException {
      throw const ContactPickerUnavailable(
          "Couldn't open your contacts. You can type their details instead.");
    } on MissingPluginException {
      throw const ContactPickerUnavailable(
          "Couldn't open your contacts. You can type their details instead.");
    }
    if (picked == null) return null;
    final contact = mapPickedContact(
      fullName: picked.fullName,
      selectedPhoneNumber: picked.selectedPhoneNumber,
      phoneNumbers: picked.phoneNumbers,
    );
    if (contact == null) {
      throw const ContactHasNoPhoneNumber(
          "That contact doesn't have a phone number saved. Try another one.");
    }
    return contact;
  }
}

final contactPickerServiceProvider = Provider<ContactPickerService>(
  (ref) => ContactPickerService(FlutterNativeContactPicker()),
);
