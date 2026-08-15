import '../../features/profile/domain/user_profile.dart';

/// Strips display formatting so `Uri(scheme: 'tel', path: phone)` in
/// live_call_screen.dart produces a dialable URI (spaces would become %20).
/// Keeps digits, a single leading `+`, and DTMF/pause chars.
String normalizePhoneNumber(String raw) {
  final kept = raw.replaceAll(RegExp(r'[^0-9+*#,;]'), '');
  if (!kept.contains('+')) return kept;
  return (kept.startsWith('+') ? '+' : '') + kept.replaceAll('+', '');
}

/// Flattens a picked phone contact down to the two plain strings the shared
/// `emergencyContact: {name, phone}` schema allows. Returns null when the
/// pick carried no usable number.
EmergencyContact? mapPickedContact({
  String? fullName,
  String? selectedPhoneNumber,
  List<String>? phoneNumbers,
}) {
  final rawPhone = selectedPhoneNumber ??
      ((phoneNumbers != null && phoneNumbers.isNotEmpty) ? phoneNumbers.first : '');
  final phone = normalizePhoneNumber(rawPhone);
  if (phone.isEmpty) return null;
  var name = (fullName ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  if (name.isEmpty) name = phone;
  return EmergencyContact(name: name, phone: phone);
}
