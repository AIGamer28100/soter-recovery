import 'package:flutter_test/flutter_test.dart';
import 'package:soter_recovery/platform/contacts/contact_mapping.dart';

void main() {
  group('normalizePhoneNumber', () {
    test('strips spaces and keeps a single leading +', () {
      expect(normalizePhoneNumber('+91 98765 43210'), '+919876543210');
    });

    test('strips parens, spaces, and dashes', () {
      expect(normalizePhoneNumber('(555) 123-4567'), '5551234567');
    });

    test('strips dots', () {
      expect(normalizePhoneNumber('555.123.4567'), '5551234567');
    });

    test('keeps leading + with parens and dashes', () {
      expect(normalizePhoneNumber('+1 (555) 123-4567'), '+15551234567');
    });

    test('keeps commas (DTMF pause chars) and strips dash', () {
      expect(normalizePhoneNumber('555-1234,,89'), '5551234,,89');
    });

    test('returns empty string when no digits or allowed chars survive', () {
      expect(normalizePhoneNumber('abc'), '');
    });
  });

  group('mapPickedContact', () {
    test('uses selectedPhoneNumber and collapses whitespace in name', () {
      final contact = mapPickedContact(
        fullName: 'Ada  Lovelace',
        selectedPhoneNumber: '+91 98765 43210',
      );

      expect(contact, isNotNull);
      expect(contact!.name, 'Ada Lovelace');
      expect(contact.phone, '+919876543210');
    });

    test('falls back to the first entry of phoneNumbers when selected is null', () {
      final contact = mapPickedContact(
        selectedPhoneNumber: null,
        phoneNumbers: ['555 1234'],
      );

      expect(contact, isNotNull);
      expect(contact!.phone, '5551234');
    });

    test('returns null when phoneNumbers is empty and no selection', () {
      final contact = mapPickedContact(
        selectedPhoneNumber: null,
        phoneNumbers: [],
      );

      expect(contact, isNull);
    });

    test('returns null when phoneNumbers is null and no selection', () {
      final contact = mapPickedContact(
        selectedPhoneNumber: null,
        phoneNumbers: null,
      );

      expect(contact, isNull);
    });

    test('falls back to the normalized phone as the name when fullName is empty', () {
      final contact = mapPickedContact(
        fullName: '',
        selectedPhoneNumber: '+91 98765 43210',
      );

      expect(contact, isNotNull);
      expect(contact!.name, contact.phone);
      expect(contact.name, '+919876543210');
    });

    test('returns null when normalized selected number has no usable chars', () {
      final contact = mapPickedContact(selectedPhoneNumber: '---');

      expect(contact, isNull);
    });
  });
}
