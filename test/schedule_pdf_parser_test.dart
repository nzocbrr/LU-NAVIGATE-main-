import 'package:flutter_test/flutter_test.dart';
import 'package:lu_navigate/data/schedule_pdf_parser.dart';

void main() {
  SchedulePdfTextFragment cell(String text, double x, double y,
      {double width = 80}) {
    return SchedulePdfTextFragment(
      text: text,
      left: x - width / 2,
      top: y + 4,
      right: x + width / 2,
      bottom: y - 4,
    );
  }

  test('groups parsed rows by weekday and sorts each day by start time', () {
    const extractedText = '''
MON | 01:00 PM - 03:00 PM | Architecture | OL | J. Ropal | BSCS-DS 3A
MWF | 08:00 AM - 10:00 AM | Software Engineering | CL 2a | J. Avila | BSCS-DS 3A
TTH | 09:00 AM - 11:00 AM | Automata Theory | AV 407a | B. Belarmino | BSCS-DS 3A
''';

    final schedule = SchedulePdfParser.parseText(extractedText);

    expect(schedule.keys, containsAll(['Mon', 'Tue', 'Wed', 'Thu', 'Fri']));
    expect(schedule['Mon']!.map((item) => item.subject), [
      'Software Engineering',
      'Architecture',
    ]);
    expect(schedule['Tue']!.single.subject, 'Automata Theory');
    expect(schedule['Thu']!.single.subject, 'Automata Theory');
    expect(schedule['Fri']!.single.subject, 'Software Engineering');
    expect(schedule['Mon']!.first.room, 'CL 2a');
    expect(schedule['Mon']!.first.instructor, 'J. Avila');
  });

  test('ignores rows without a weekday and time range', () {
    final schedule = SchedulePdfParser.parseText(
      'Student Registration Form\nCourse | Day | Time\nSoftware Engineering',
    );

    expect(schedule, isEmpty);
  });

  test('parses multiline course meetings from the Laguna registration table',
      () {
    final fragments = [
      cell('Course Code', 190, 800),
      cell('Course Description', 380, 800),
      cell('Units', 520, 800),
      cell('Day', 590, 800),
      cell('Time', 660, 800),
      cell('Room', 760, 800),
      cell('Instructor', 870, 800),
      cell('CS 3115', 190, 700),
      cell('Information Assurance and Security', 380, 700, width: 180),
      cell('3', 520, 700),
      cell('M', 590, 700),
      cell('3:00-4:00', 660, 700),
      cell('OL', 760, 700),
      cell('R. EDEC', 870, 692),
      cell('F', 590, 685),
      cell('1:00-3:00', 660, 685),
      cell('AV 402a', 760, 685),
      cell('CC 3105', 190, 640),
      cell('Applications Development and Emerging', 380, 640, width: 180),
      cell('3', 520, 640),
      cell('M', 590, 640),
      cell('10:00-12:00', 660, 640),
      cell('OL', 760, 640),
      cell('D. Palma', 870, 632),
      cell('Technologies', 380, 625),
      cell('Th', 590, 625),
      cell('4:00-7:00', 660, 625),
      cell('CL 1a', 760, 625),
    ];

    final schedule = SchedulePdfParser.parsePositionedText(
      fragments,
      pageWidth: 1000,
    );

    expect(schedule['Mon']!.map((item) => item.subject), [
      'Applications Development and Emerging Technologies',
      'Information Assurance and Security',
    ]);
    expect(schedule['Mon']!.first.time, '10:00 - 12:00');
    expect(schedule['Tue'], isNull);
    expect(schedule['Thu']!.single.subject,
        'Applications Development and Emerging Technologies');
    expect(schedule['Thu']!.single.room, 'CL 1a');
    expect(schedule['Fri']!.single.time, '1:00 - 3:00');
    expect(schedule['Fri']!.single.room, 'AV 402a');
    expect(schedule['Mon']!.last.instructor, 'R. EDEC');
  });

  test('parses the pasted Laguna University registration form text', () {
    const extractedText = '''
578 CS 3115 Information Assurance and Security 3 M
F
3:00-4:00
1:00-3:00
OL
AV 402a
R. EDEC
574 CC 3105 Applications Development and Emerging
Technologies
3 M
Th
10:00-12:00
4:00-7:00
OL
CL 1a
D. Palma
575 CS 3112 Automata Theory and Formal Languages 3 T
W
9:00-11:00
4:00-7:00
OL
CL 2a
B. Belarmino
576 CS 3113 Architecture and Organization 3 M
Th
1:00-3:00
10:00-1:00
OL
CL 2a
J. Ropal
577 CS 3114 Software Engineering 1 3 M
F
8:00-10:00
4:00-7:00
OL
AV 406a
J. Avila
579 DS-3101 Data Mining and Data Warehousing 3 T
W
2:00-4:00
10:00-1:00
OL
AV 407a
J. Ropal
Total Units: 18
''';

    final schedule = SchedulePdfParser.parseText(extractedText);
    final meetingCount =
        schedule.values.fold<int>(0, (total, items) => total + items.length);

    expect(meetingCount, 12);
    expect(schedule['Mon']!.first.subject, 'Software Engineering 1');
    expect(schedule['Mon']!.first.time, '8:00 - 10:00');
    expect(
        schedule['Thu']!.any((item) =>
            item.subject ==
                'Applications Development and Emerging Technologies' &&
            item.room == 'CL 1a' &&
            item.time == '4:00 - 7:00'),
        isTrue);
    expect(
        schedule['Fri']!.any((item) =>
            item.subject == 'Information Assurance and Security' &&
            item.room == 'AV 402a' &&
            item.time == '1:00 - 3:00'),
        isTrue);
    expect(
        schedule['Wed']!.any((item) =>
            item.subject == 'Data Mining and Data Warehousing' &&
            item.room == 'AV 407a' &&
            item.time == '10:00 - 1:00'),
        isTrue);
  });

      test('keeps the courses and meetings from the larger form in their rows',
        () {
      const extractedText = '''
    646 GE 1 Understanding the Self 3 W
    Th
    8:00-10:00
    9:00-10:00
    NA
    NB 303
    L. Bueno
    651 CC 1100 Introduction to Computing 3 M
    W
    Th
    7:00-9:00
    7:00-8:00
    7:00-9:00
    NB 306
    NA
    NB 303
    E. Bergonio
    652 CC 1101 Computer Programming 1
    (Fundamentals of Programming)
    3 M
    W
    Th
    11:00-1:00
    11:00-12:00
    11:00-1:00
    NB 306
    NA
    NB 303
    P. Toledo
    647 GE 2 Readings in Philippine History 3 T
    Th
    11:00-1:00
    4:00-5:00
    NA
    LU-08
    M. NABIA
    648 GE 3 Mathematics in the Modern World 3 M
    T
    W
    9:00-10:00
    9:00-10:00
    3:00-4:00
    NB 105
    NA
    NA
    .. LIT Teacher 8
    649 GE 4 Purposive Communication 3 T
    Th
    2:00-4:00
    2:00-3:00
    NA
    LU-08
    .. New BAC Teacher 2
    469 MST 01 Environmental Science 3 T
    Th
    7:00-9:00
    3:00-4:00
    NA
    LU-08
    J. Urrete
    653 PE 1 (PATHFit
    1)
    Movement Competency Training 2 M 2:00-4:00 PE Room 3 B. Pornela
    981 NSTP 1 Reserve Officer Training Corps 1 3 Sun 8:00-12:00 LU Grounds 9 .. ROTC Coordinator
    2
    Total Units: 26
    ''';

      final schedule = SchedulePdfParser.parseText(extractedText);
      final meetingCount =
        schedule.values.fold<int>(0, (total, items) => total + items.length);

      expect(meetingCount, 19);
      expect(schedule['Mon']!.any((item) =>
        item.subject == 'Introduction to Computing' &&
        item.time == '7:00 - 9:00' &&
        item.room == 'NB 306'), isTrue);
      expect(schedule['Wed']!.any((item) =>
        item.subject == 'Mathematics in the Modern World' &&
        item.room == 'NA'), isTrue);
      expect(schedule['Mon']!.any((item) =>
        item.subject == 'Movement Competency Training' &&
        item.room == 'PE Room 3'), isTrue);
      expect(schedule['Sun']!.single.subject,
        'Reserve Officer Training Corps 1');
      expect(schedule['Sun']!.single.room, 'LU Grounds 9');
      });
}
