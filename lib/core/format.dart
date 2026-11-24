/// 10917 -> "10.917"
String fmt(int n) => n
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

String _two(int n) => n.toString().padLeft(2, '0');

/// "Hoje 14:20", "Ontem 23:04" ou "03/11/2026"
String dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  final hm = '${_two(d.hour)}:${_two(d.minute)}';
  if (diff == 0) return 'Hoje $hm';
  if (diff == 1) return 'Ontem $hm';
  return '${_two(d.day)}/${_two(d.month)}/${d.year}';
}

String fullDate(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

String sizeLabel(int bytes) {
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(2).replaceAll('.', ',')} KB';
  return '${(kb / 1024).toStringAsFixed(2).replaceAll('.', ',')} MB';
}