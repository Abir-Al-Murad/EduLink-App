String getTimeStatus(DateTime? uploadedAt) {
  if (uploadedAt == null) return "Unknown";
  final now = DateTime.now();
  final difference = now.difference(uploadedAt);

  if (difference.inMinutes < 1) return "NEW";
  if (difference.inHours < 1) return "RECENT";
  if (difference.inHours < 24) return "TODAY";
  return "EARLIER";
}