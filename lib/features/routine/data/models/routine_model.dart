class RoutineModel {
  final String course;
  final String teacher;
  final String room;
  final String time;

  RoutineModel({
    required this.course,
    required this.teacher,
    required this.room,
    required this.time,
  });

  Map<String, dynamic> toFireStore() {
    return {
      'course': course,
      'teacher': teacher,
      'room': room,
      'time': time,
    };
  }

  factory RoutineModel.fromFireStore(Map<String, dynamic> map) {
    return RoutineModel(
      course: map['course'] ?? '',
      teacher: map['teacher'] ?? '',
      room: map['room'] ?? '',
      time: map['time'] ?? '',
    );
  }
}
