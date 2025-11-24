
import 'package:intl/intl.dart';


String formatTime(DateTime? dateTime) {
  if (dateTime == null) return "Unknown time";
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) return "Just now";
  if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
  if (difference.inHours < 24) return "${difference.inHours}h ago";
  if (difference.inDays < 7) return "${difference.inDays}d ago";

  return DateFormat('MMM dd, yyyy').format(dateTime);
}
