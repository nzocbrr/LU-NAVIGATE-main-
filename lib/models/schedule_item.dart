class ScheduleItem {
  const ScheduleItem.classSession({
    required this.id,
    required this.subject,
    required this.time,
    required this.room,
    required this.instructor,
    required this.section,
  })  : isVacant = false,
        duration = null,
        recommendation = null;

  const ScheduleItem.vacant({
    required this.id,
    required this.duration,
    required this.time,
    required this.recommendation,
  })  : isVacant = true,
        subject = null,
        room = null,
        instructor = null,
        section = null;

  final String id;
  final bool isVacant;
  final String time;
  final String? subject;
  final String? room;
  final String? instructor;
  final String? section;
  final String? duration;
  final String? recommendation;
}
