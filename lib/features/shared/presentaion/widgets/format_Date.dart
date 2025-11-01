import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDate(Timestamp timestamp) {
  DateTime now = DateTime.now();
  DateTime deadline = timestamp.toDate();

  if (deadline.year == now.year &&
      deadline.month == now.month &&
      deadline.day == now.day) {
    return "Today";
  } else if (deadline.year == now.year &&
      deadline.month == now.month &&
      deadline.day == now.day + 1) {
    return "Tomorrow";
  } else {
    return DateFormat('dd MMM yyyy').format(deadline);
  }
}
