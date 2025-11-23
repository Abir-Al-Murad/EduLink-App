String getDeadlineStatus(DateTime deadlineDate,{bool isCompleted = false}) {
  if (isCompleted) {
    return 'Task Completed';
  }
  final now = DateTime.now();
  // final deadlineDate = model.deadline.toDate();
  final difference = deadlineDate.difference(now).inDays;

  if (difference < 0) {
    return "Overdue by ${difference.abs()} day${difference.abs() == 1 ? '' : 's'}";
  } else if (difference == 0) {
    return "Due today";
  } else if (difference == 1) {
    return "Due tomorrow";
  } else {
    return "Due in $difference days";
  }
}
