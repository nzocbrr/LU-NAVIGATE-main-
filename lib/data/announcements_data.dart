import '../models/announcement.dart';

const initialAnnouncements = <Announcement>[
  Announcement(id: 'e1', category: AnnouncementCategory.emergency, title: 'CAMPUS SUSPENSION NOTICE', body: 'Classes are suspended today due to severe typhoon conditions. Stay safe everyone.', time: '10 mins ago', author: 'University Admin'),
  Announcement(id: 'c1', category: AnnouncementCategory.classUpdate, title: 'Data Science 101 Rescheduled', body: 'Class shifted to Room 304 for today due to air conditioning maintenance.', time: '1 hour ago', author: 'Prof. Cabrera'),
  Announcement(id: 'c2', category: AnnouncementCategory.classUpdate, title: 'Software Eng. Quiz Moved', body: 'Quiz originally scheduled for Thursday is moved to next Monday.', time: '3 hours ago', author: 'Engr. Santos'),
];
