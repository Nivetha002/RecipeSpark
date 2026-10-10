const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// "10 Oct 2026, 9:41 PM"
String formatDateTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${_months[d.month - 1]} ${d.year}, $h:$m $ampm';
}
