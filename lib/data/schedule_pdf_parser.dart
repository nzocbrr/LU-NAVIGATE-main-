import 'dart:async';
import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

import '../models/schedule_item.dart';

class SchedulePdfParser {
  static final _timeRangePattern = RegExp(
    r'(\d{1,2}(?::\d{2})?\s*(?:a\.?m\.?|p\.?m\.?)?)\s*(?:-|–|—|to)\s*(\d{1,2}(?::\d{2})?\s*(?:a\.?m\.?|p\.?m\.?)?)',
    caseSensitive: false,
  );

  static final _dayPattern = RegExp(
    r'\b(SUNDAY|SUN|SATURDAY|SAT|MONDAY|MON|TUESDAY|TUES|TUE|WEDNESDAY|WED|THURSDAY|THUR|THU|FRIDAY|FRI|MWF|M-W-F|TTH|T-TH|TR|MW|WF|M|T|W|TH|R|F)\b',
    caseSensitive: false,
  );

  static final _fieldLabelPattern = RegExp(
    r'\b(?:DAY|DAYS|TIME|COURSE(?:\s+CODE)?|SUBJECT|ROOM|RM|INSTRUCTOR|PROFESSOR|SECTION)\s*[:#]',
    caseSensitive: false,
  );
  static final _courseStartPattern = RegExp(
    r'^\d{2,4}\s+[A-Z]{1,5}\s*-?\s*\d{1,5}[A-Z]?\s+(.+)$',
    caseSensitive: false,
  );
  static final _unitDaySuffixPattern = RegExp(
    r'^(.*?)\s+\d+\s+(SUNDAY|SUN|SATURDAY|SAT|MONDAY|MON|TUESDAY|TUES|TUE|WEDNESDAY|WED|THURSDAY|THUR|THU|FRIDAY|FRI|TH|R|M|T|W|F)\b(?:\s+(.*))?$',
    caseSensitive: false,
  );
  static final _unitDayLinePattern = RegExp(
    r'^\d+\s+(SUNDAY|SUN|SATURDAY|SAT|MONDAY|MON|TUESDAY|TUES|TUE|WEDNESDAY|WED|THURSDAY|THUR|THU|FRIDAY|FRI|TH|R|M|T|W|F)\b(?:\s+(.*))?$',
    caseSensitive: false,
  );
  static final _dayOnlyPattern = RegExp(
    r'^(SUNDAY|SUN|SATURDAY|SAT|MONDAY|MON|TUESDAY|TUES|TUE|WEDNESDAY|WED|THURSDAY|THUR|THU|FRIDAY|FRI|MWF|M-W-F|TTH|T-TH|TR|MW|WF|TH|R|M|T|W|F)\b(?:\s+(.*))?$',
    caseSensitive: false,
  );
  static final _roomPattern = RegExp(
    r'^(?:OL|N/?A|[A-Z]{1,3}\s*-?\s*\d{1,4}[A-Z]?|PE\s+ROOM\s+\d+|LU\s+GROUNDS(?:\s+\d+)?)$',
    caseSensitive: false,
  );
  static final _inlineRoomPattern = RegExp(
    r'\b(?:N/?A|OL|PE\s+ROOM\s+\d+|LU\s+GROUNDS(?:\s+\d+)?|[A-Z]{1,3}\s*-?\s*\d{1,4}[A-Z]?)\b',
    caseSensitive: false,
  );
  static final _instructorPattern = RegExp(
    r'^(?:[A-Z]\.\s*[A-Z][A-Z.\u00C0-\u00FF]*(?:\s+[A-Z][A-Z.\u00C0-\u00FF]*)*|\.{1,2}\s+[A-Z][A-Z.\u00C0-\u00FF]*(?:\s+[A-Z][A-Z.\u00C0-\u00FF]*)*(?:\s+\d+)?)$',
    caseSensitive: false,
  );

  static Future<Map<String, List<ScheduleItem>>> parsePdf(
    Uint8List bytes, {
    required String sourceName,
  }) async {
    await pdfrxFlutterInitialize().timeout(const Duration(seconds: 20));
    final document = await PdfDocument.openData(
      bytes,
      sourceName: sourceName,
    ).timeout(const Duration(seconds: 20));
    try {
      final schedule = <String, List<ScheduleItem>>{};
      for (final page in document.pages) {
        final pageText =
            await page.loadText().timeout(const Duration(seconds: 20));
        final pageSchedule = parseText(
          pageText?.fullText ?? '',
          idPrefix: 'page-${page.pageNumber}',
        );
        _mergeSchedule(schedule, pageSchedule);
      }
      _sortSchedule(schedule);
      return schedule;
    } finally {
      await document.dispose();
    }
  }

  static Map<String, List<ScheduleItem>> parsePositionedText(
    Iterable<SchedulePdfTextFragment> fragments, {
    required double pageWidth,
    String idPrefix = 'layout',
  }) {
    final positionedFragments = fragments.toList();
    final columns = _tableColumns(positionedFragments, pageWidth);
    final lines = _groupLines(positionedFragments);
    final courseRows = <int>[];

    for (var index = 0; index < lines.length; index++) {
      final courseCode = _columnText(
        lines[index],
        columns.courseCodeLeft,
        columns.courseCodeRight,
      );
      if (_isCourseCode(courseCode)) courseRows.add(index);
    }

    final result = <String, List<ScheduleItem>>{};
    var nextId = 0;
    for (var rowIndex = 0; rowIndex < courseRows.length; rowIndex++) {
      final start = courseRows[rowIndex];
      final end = rowIndex + 1 < courseRows.length
          ? courseRows[rowIndex + 1]
          : lines.length;
      final rowLines = lines.sublist(start, end);
      final subject = rowLines
          .map((line) => _columnText(
                line,
                columns.descriptionLeft,
                columns.descriptionRight,
              ))
          .where((text) => text.isNotEmpty)
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (subject.isEmpty || _isHeader(subject)) continue;

      final instructor = rowLines
          .map((line) => _columnText(
                line,
                columns.instructorLeft,
                columns.instructorRight,
              ))
          .firstWhere((text) => text.isNotEmpty, orElse: () => 'TBA');

      for (final line in rowLines) {
        final days = _daysIn(_columnText(
          line,
          columns.dayLeft,
          columns.dayRight,
        ));
        final timeCell = _columnText(
          line,
          columns.timeLeft,
          columns.timeRight,
        );
        final timeMatch = _timeRangePattern.firstMatch(timeCell);
        if (days.isEmpty || timeMatch == null) continue;

        final time = '${timeMatch.group(1)} - ${timeMatch.group(2)}'
            .replaceAll(RegExp(r'\s+'), ' ')
            .toUpperCase();
        final room = _columnText(
          line,
          columns.roomLeft,
          columns.roomRight,
        );
        for (final day in days) {
          final item = ScheduleItem.classSession(
            id: '$idPrefix-${nextId++}',
            subject: subject,
            time: time,
            room: room.isEmpty ? 'TBA' : room,
            instructor: instructor,
            section: 'Imported',
          );
          (result[day] ??= []).add(item);
        }
      }
    }

    _sortSchedule(result);
    return result;
  }

  static Map<String, List<ScheduleItem>> parseText(
    String text, {
    String idPrefix = 'import',
  }) {
    final registrationSchedule = _parseRegistrationRows(text, idPrefix);
    if (registrationSchedule.isNotEmpty) return registrationSchedule;

    final result = <String, List<ScheduleItem>>{};
    var nextId = 0;

    for (final rawLine in text.split(RegExp(r'[\r\n]+'))) {
      final line = rawLine.replaceAll(RegExp(r'\s+'), ' ').trim();
      final timeMatch = _timeRangePattern.firstMatch(line);
      final days = _daysIn(line);
      if (timeMatch == null || days.isEmpty) continue;

      final time = '${timeMatch.group(1)} - ${timeMatch.group(2)}'
          .replaceAll(RegExp(r'\s+'), ' ')
          .toUpperCase();
      final fields = line
          .split(RegExp(r'\s*[|\t]\s*'))
          .map(_cleanField)
          .where((field) => field.isNotEmpty)
          .toList();
      final subject = fields.isNotEmpty ? fields.first : '';
      if (subject.isEmpty || _isHeader(subject)) continue;

      final item = ScheduleItem.classSession(
        id: '$idPrefix-${nextId++}',
        subject: subject,
        time: time,
        room: fields.length > 1 ? fields[1] : 'TBA',
        instructor: fields.length > 2 ? fields[2] : 'TBA',
        section: fields.length > 3 ? fields[3] : 'Imported',
      );

      for (final day in days) {
        (result[day] ??= []).add(item);
      }
    }

    _sortSchedule(result);
    return result;
  }

  static Map<String, List<ScheduleItem>> _parseRegistrationRows(
    String text,
    String idPrefix,
  ) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .toList();
    final courseRows = <int>[];
    for (var index = 0; index < lines.length; index++) {
      if (_courseStartPattern.hasMatch(lines[index])) courseRows.add(index);
    }

    final result = <String, List<ScheduleItem>>{};
    var nextId = 0;
    for (var rowIndex = 0; rowIndex < courseRows.length; rowIndex++) {
      final start = courseRows[rowIndex];
      final end = rowIndex + 1 < courseRows.length
          ? courseRows[rowIndex + 1]
          : lines.length;
      final firstLine = _courseStartPattern.firstMatch(lines[start])!;
      final rowLines = [
        firstLine.group(1)!,
        ...lines.skip(start + 1).take(end - start - 1)
      ];
      final description = <String>[];
      final days = <String>[];
      final times = <String>[];
      final rooms = <String>[];
      var instructor = 'TBA';
      var meetingColumnsStarted = false;

      for (final line in rowLines) {
        if (line.toLowerCase().startsWith('total units')) break;
        final suffix = _unitDaySuffixPattern.firstMatch(line);
        final unitDayLine = _unitDayLinePattern.firstMatch(line);
        final dayOnly = _dayOnlyPattern.firstMatch(line);
        final inlineFields = suffix?.group(3) ??
          unitDayLine?.group(2) ??
          dayOnly?.group(2) ??
          line;
        final timeMatches = _timeRangePattern.allMatches(inlineFields).toList();
        final isRoom = _roomPattern.hasMatch(line);
        final isInstructor = _instructorPattern.hasMatch(line);
        final inlineRoom = _inlineRoomPattern.firstMatch(inlineFields);
        final hasScheduleData = suffix != null ||
            unitDayLine != null ||
            dayOnly != null ||
            timeMatches.isNotEmpty ||
            isRoom ||
          isInstructor ||
          inlineRoom != null;

        if (!meetingColumnsStarted && !hasScheduleData) {
          description.add(line);
          continue;
        }
        meetingColumnsStarted = meetingColumnsStarted || hasScheduleData;

        if (suffix != null) {
          final courseDescription = suffix.group(1)!.trim();
          if (courseDescription.isNotEmpty) description.add(courseDescription);
          days.addAll(_daysIn(suffix.group(2)!));
        } else if (unitDayLine != null) {
          days.addAll(_daysIn(unitDayLine.group(1)!));
        } else if (dayOnly != null) {
          days.addAll(_daysIn(line));
        }

        for (final match in timeMatches) {
          times.add('${match.group(1)} - ${match.group(2)}'
              .replaceAll(RegExp(r'\s+'), ' '));
        }
        if (isRoom) rooms.add(line);
        if (inlineRoom != null && !isRoom) {
          rooms.add(inlineRoom.group(0)!);
          final inlineInstructor = inlineFields
              .replaceRange(inlineRoom.start, inlineRoom.end, '')
              .replaceAll(_timeRangePattern, ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          if (_instructorPattern.hasMatch(inlineInstructor)) {
            instructor = inlineInstructor;
          }
        }
        if (isInstructor) instructor = line;
      }

      final subject =
          description.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim().replaceFirst(
                RegExp(r'^\(?PATHFit\s*1\)?\s*', caseSensitive: false),
                '',
              );
      if (subject.isEmpty || days.isEmpty || times.isEmpty) continue;

      final meetingCount =
          days.length > times.length ? days.length : times.length;
      for (var meetingIndex = 0; meetingIndex < meetingCount; meetingIndex++) {
        final day =
            days.length == 1 ? days.first : days[meetingIndex % days.length];
        final time = times.length == 1
            ? times.first
            : times[meetingIndex % times.length];
        final room = rooms.isEmpty
            ? 'TBA'
            : rooms.length == 1
                ? rooms.first
                : rooms[meetingIndex % rooms.length];
        final item = ScheduleItem.classSession(
          id: '$idPrefix-${nextId++}',
          subject: subject,
          time: time,
          room: room,
          instructor: instructor,
          section: 'Imported',
        );
        (result[day] ??= []).add(item);
      }
    }

    _sortSchedule(result);
    return result;
  }

  static _ScheduleColumns _tableColumns(
    List<SchedulePdfTextFragment> fragments,
    double pageWidth,
  ) {
    final centers = [
      _headerCenter(fragments, 'COURSE CODE', pageWidth * .19),
      _headerCenter(fragments, 'COURSE DESCRIPTION', pageWidth * .38),
      _headerCenter(fragments, 'UNITS', pageWidth * .52),
      _headerCenter(fragments, 'DAY', pageWidth * .59),
      _headerCenter(fragments, 'TIME', pageWidth * .66),
      _headerCenter(fragments, 'ROOM', pageWidth * .76),
      _headerCenter(fragments, 'INSTRUCTOR', pageWidth * .87),
    ];
    final boundaries = <double>[
      centers[0] - (centers[1] - centers[0]) / 2,
      for (var index = 0; index < centers.length - 1; index++)
        (centers[index] + centers[index + 1]) / 2,
      pageWidth,
    ];
    return _ScheduleColumns(
      courseCodeLeft: boundaries[0],
      courseCodeRight: boundaries[1],
      descriptionLeft: boundaries[1],
      descriptionRight: boundaries[2],
      dayLeft: boundaries[3],
      dayRight: boundaries[4],
      timeLeft: boundaries[4],
      timeRight: boundaries[5],
      roomLeft: boundaries[5],
      roomRight: boundaries[6],
      instructorLeft: boundaries[6],
      instructorRight: boundaries[7],
    );
  }

  static double _headerCenter(
    List<SchedulePdfTextFragment> fragments,
    String label,
    double fallback,
  ) {
    final normalizedLabel = label.replaceAll(RegExp(r'[^A-Z]'), '');
    for (final fragment in fragments) {
      final normalizedText =
          fragment.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
      if (normalizedText.contains(normalizedLabel)) {
        return (fragment.left + fragment.right) / 2;
      }
    }
    return fallback;
  }

  static List<_ScheduleTextLine> _groupLines(
    List<SchedulePdfTextFragment> fragments,
  ) {
    final ordered = fragments.toList()
      ..sort((first, second) => second.centerY.compareTo(first.centerY));
    final lines = <_ScheduleTextLine>[];
    for (final fragment in ordered) {
      if (lines.isNotEmpty &&
          (lines.last.centerY - fragment.centerY).abs() <= 4) {
        lines.last.fragments.add(fragment);
      } else {
        lines.add(_ScheduleTextLine(fragment));
      }
    }
    return lines;
  }

  static String _columnText(
    _ScheduleTextLine line,
    double left,
    double right,
  ) {
    final fragments = line.fragments
        .where(
            (fragment) => fragment.centerX >= left && fragment.centerX < right)
        .toList()
      ..sort((first, second) => first.left.compareTo(second.left));
    return fragments
        .map((fragment) => fragment.text)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isCourseCode(String value) => RegExp(
        r'^[A-Z]{1,5}\s*-?\s*\d{3,5}[A-Z]?$',
        caseSensitive: false,
      ).hasMatch(value.trim());

  static void _mergeSchedule(
    Map<String, List<ScheduleItem>> target,
    Map<String, List<ScheduleItem>> source,
  ) {
    for (final entry in source.entries) {
      (target[entry.key] ??= []).addAll(entry.value);
    }
  }

  static void _sortSchedule(Map<String, List<ScheduleItem>> schedule) {
    for (final items in schedule.values) {
      items.sort((first, second) =>
          _startMinutes(first.time).compareTo(_startMinutes(second.time)));
    }
  }

  static List<String> _daysIn(String line) {
    final days = <String>{};
    for (final match in _dayPattern.allMatches(line)) {
      final token = match.group(0)!.toUpperCase().replaceAll('-', '');
      switch (token) {
        case 'SUNDAY':
        case 'SUN':
          days.add('Sun');
        case 'SATURDAY':
        case 'SAT':
          days.add('Sat');
        case 'MONDAY':
        case 'MON':
        case 'M':
          days.add('Mon');
        case 'TUESDAY':
        case 'TUES':
        case 'TUE':
        case 'T':
          days.add('Tue');
        case 'WEDNESDAY':
        case 'WED':
        case 'W':
          days.add('Wed');
        case 'THURSDAY':
        case 'THUR':
        case 'THU':
        case 'TH':
        case 'R':
          days.add('Thu');
        case 'FRIDAY':
        case 'FRI':
        case 'F':
          days.add('Fri');
        case 'MWF':
          days.addAll(['Mon', 'Wed', 'Fri']);
        case 'TTH':
        case 'TR':
          days.addAll(['Tue', 'Thu']);
        case 'MW':
          days.addAll(['Mon', 'Wed']);
        case 'WF':
          days.addAll(['Wed', 'Fri']);
      }
    }
    const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return order.where(days.contains).toList();
  }

  static String _cleanField(String field) {
    var cleaned = field.replaceAll(_dayPattern, ' ');
    final timeMatch = _timeRangePattern.firstMatch(cleaned);
    if (timeMatch != null) {
      cleaned = cleaned.replaceRange(timeMatch.start, timeMatch.end, ' ');
    }
    return cleaned
        .replaceAll(_fieldLabelPattern, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\s,;|:-]+|[\s,;|:-]+$'), '')
        .trim();
  }

  static bool _isHeader(String text) {
    final value = text.toLowerCase();
    return const {'course', 'subject', 'class', 'schedule', 'day', 'time'}
        .contains(value);
  }

  static int _startMinutes(String time) {
    final match = RegExp(
      r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(time);
    if (match == null) return 0;
    var hour = int.parse(match.group(1)!);
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final meridiem = match.group(3)?.toUpperCase();
    if (meridiem == 'PM' && hour < 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    if (meridiem == null && hour >= 1 && hour <= 7) hour += 12;
    return hour * 60 + minute;
  }
}

class SchedulePdfTextFragment {
  const SchedulePdfTextFragment({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;
}

class _ScheduleColumns {
  const _ScheduleColumns({
    required this.courseCodeLeft,
    required this.courseCodeRight,
    required this.descriptionLeft,
    required this.descriptionRight,
    required this.dayLeft,
    required this.dayRight,
    required this.timeLeft,
    required this.timeRight,
    required this.roomLeft,
    required this.roomRight,
    required this.instructorLeft,
    required this.instructorRight,
  });

  final double courseCodeLeft;
  final double courseCodeRight;
  final double descriptionLeft;
  final double descriptionRight;
  final double dayLeft;
  final double dayRight;
  final double timeLeft;
  final double timeRight;
  final double roomLeft;
  final double roomRight;
  final double instructorLeft;
  final double instructorRight;
}

class _ScheduleTextLine {
  _ScheduleTextLine(SchedulePdfTextFragment first)
      : fragments = [first],
        centerY = first.centerY;

  final List<SchedulePdfTextFragment> fragments;
  final double centerY;
}
