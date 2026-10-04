class Announcement {
  const Announcement({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    required this.author,
  });

  final String id;
  final AnnouncementCategory category;
  final String title;
  final String body;
  final String time;
  final String author;
}

enum AnnouncementCategory { classUpdate, emergency }
