import '../models/schedule_item.dart';

const weeklySchedule = <String, List<ScheduleItem>>{
  'Mon': [
    ScheduleItem.classSession(id: '1', subject: 'Software Engineering 1', time: '08:00 AM - 10:00 AM', room: 'OL', instructor: 'J. Avila', section: 'BSCS-DS 3A'),
    ScheduleItem.classSession(id: '2', subject: 'Applications Development and Emerging Technologies', time: '10:00 AM - 12:00 PM', room: 'OL', instructor: 'D. Palma', section: 'BSCS-DS 3A'),
    ScheduleItem.classSession(id: '3', subject: 'Architecture and Organization', time: '01:00 PM - 03:00 PM', room: 'OL', instructor: 'J. Ropal', section: 'BSCS-DS 3A'),
    ScheduleItem.classSession(id: '4', subject: 'Information Assurance and Security', time: '03:00 PM - 04:00 PM', room: 'OL', instructor: 'R. EDEC', section: 'BSCS-DS 3A'),
  ],
  'Tue': [
    ScheduleItem.classSession(id: '5', subject: 'Automata Theory and Formal Languages', time: '09:00 AM - 11:00 AM', room: 'OL', instructor: 'B. Belarmino', section: 'BSCS-DS 3A'),
    ScheduleItem.vacant(id: 'v1', duration: '3 Hours Gap', time: '11:00 AM - 02:00 PM', recommendation: 'Suggested: Lunch break and study hall at the student center.'),
    ScheduleItem.classSession(id: '6', subject: 'Data Mining and Data Warehousing', time: '02:00 PM - 04:00 PM', room: 'OL', instructor: 'J. Ropal', section: 'BSCS-DS 3A'),
  ],
  'Wed': [
    ScheduleItem.classSession(id: '7', subject: 'Data Mining and Data Warehousing', time: '10:00 AM - 01:00 PM', room: 'AV 407a', instructor: 'J. Ropal', section: 'BSCS-DS 3A'),
    ScheduleItem.vacant(id: 'v2', duration: '3 Hours Gap', time: '01:00 PM - 04:00 PM', recommendation: 'Suggested: Library stay or group review.'),
    ScheduleItem.classSession(id: '8', subject: 'Automata Theory and Formal Languages', time: '04:00 PM - 07:00 PM', room: 'CL 2a', instructor: 'B. Belarmino', section: 'BSCS-DS 3A'),
  ],
  'Thu': [
    ScheduleItem.classSession(id: '9', subject: 'Architecture and Organization', time: '10:00 AM - 01:00 PM', room: 'CL 2a', instructor: 'J. Ropal', section: 'BSCS-DS 3A'),
    ScheduleItem.vacant(id: 'v3', duration: '3 Hours Gap', time: '01:00 PM - 04:00 PM', recommendation: 'Suggested: Rest or early prep for evening lab.'),
    ScheduleItem.classSession(id: '10', subject: 'Applications Development and Emerging Technologies', time: '04:00 PM - 07:00 PM', room: 'CL 1a', instructor: 'D. Palma', section: 'BSCS-DS 3A'),
  ],
  'Fri': [
    ScheduleItem.classSession(id: '11', subject: 'Information Assurance and Security', time: '01:00 PM - 03:00 PM', room: 'AV 402a', instructor: 'R. EDEC', section: 'BSCS-DS 3A'),
    ScheduleItem.vacant(id: 'v4', duration: '1 Hour Gap', time: '03:00 PM - 04:00 PM', recommendation: 'Suggested: Quick transition time.'),
    ScheduleItem.classSession(id: '12', subject: 'Software Engineering 1', time: '04:00 PM - 07:00 PM', room: 'AV 406a', instructor: 'J. Avila', section: 'BSCS-DS 3A'),
  ],
};
