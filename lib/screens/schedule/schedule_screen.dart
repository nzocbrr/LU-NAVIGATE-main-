import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_colors.dart';
import '../../data/schedule_pdf_parser.dart';
import '../../models/schedule_item.dart';
import '../../widgets/schedule_card.dart';
import '../../widgets/vacant_schedule_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _schedulePreferenceKey = 'imported_weekly_schedule';
  String _selectedDay = 'Mon';
  Map<String, List<ScheduleItem>> _schedule =
      const <String, List<ScheduleItem>>{};
  bool _hasImportedSchedule = false;
  bool _isImporting = false;
  String _importStatus = 'Import PDF';

  @override
  void initState() {
    super.initState();
    _restoreImportedSchedule();
  }

  Future<void> _restoreImportedSchedule() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedSchedule = preferences.getString(_schedulePreferenceKey);
      if (savedSchedule == null) return;
      final decoded = jsonDecode(savedSchedule) as Map<String, dynamic>;
      final restored = <String, List<ScheduleItem>>{};
      for (final entry in decoded.entries) {
        restored[entry.key] = (entry.value as List<dynamic>).map((value) {
          final item = value as Map<String, dynamic>;
          return ScheduleItem.classSession(
            id: item['id'] as String,
            subject: item['subject'] as String,
            time: item['time'] as String,
            room: item['room'] as String,
            instructor: item['instructor'] as String,
            section: item['section'] as String,
          );
        }).toList();
      }
      if (!mounted || restored.isEmpty) return;
      setState(() {
        _schedule = restored;
        _hasImportedSchedule = true;
        _selectedDay = _days.firstWhere(
          restored.containsKey,
          orElse: () => _days.first,
        );
      });
    } catch (_) {
      // Keep the schedule empty if saved data is invalid.
    }
  }

  Future<void> _importSchedulePdf() async {
    if (_isImporting) return;
    setState(() {
      _isImporting = true;
      _importStatus = 'Choose PDF';
    });
    var failureStage = 'open the PDF picker';
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: 'Choose registration form PDF',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (files.isEmpty) return;

      final file = files.first;
      setState(() => _importStatus = 'Checking PDF');
      final fileSize = await file.length();
      if (fileSize != null && fileSize > 20 * 1024 * 1024) {
        _showMessage('Choose a PDF smaller than 20 MB.');
        return;
      }

      failureStage = 'read the selected file';
      setState(() => _importStatus = 'Reading PDF');
      final bytes = await file.readAsBytes();
      failureStage = 'extract schedule text from the PDF';
      setState(() => _importStatus = 'Parsing schedule');
      final schedule = await SchedulePdfParser.parsePdf(
        bytes,
        sourceName: file.name,
      );
      final meetingCount =
          schedule.values.fold<int>(0, (count, items) => count + items.length);
      if (meetingCount == 0) {
        _showMessage(
          'No schedule rows were found. Use a text-based PDF with a weekday and time range on each class row.',
        );
        return;
      }
      if (!mounted) return;

      final shouldImport = await _reviewSchedule(file.name, schedule);
      if (shouldImport != true || !mounted) return;

      failureStage = 'save the imported schedule';
      setState(() => _importStatus = 'Saving schedule');
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _schedulePreferenceKey,
        jsonEncode({
          for (final entry in schedule.entries)
            entry.key: [
              for (final item in entry.value)
                {
                  'id': item.id,
                  'subject': item.subject,
                  'time': item.time,
                  'room': item.room,
                  'instructor': item.instructor,
                  'section': item.section,
                },
            ],
        }),
      );
      setState(() {
        _schedule = schedule;
        _hasImportedSchedule = true;
        _selectedDay = _days.firstWhere(
          schedule.containsKey,
          orElse: () => _days.first,
        );
      });
      _showMessage('Imported $meetingCount class meetings from ${file.name}.');
    } on TimeoutException {
      _showMessage(
        'PDF extraction took too long. Try exporting a searchable PDF and import again.',
      );
    } on FormatException catch (error) {
      _showMessage(error.message.toString());
    } catch (error, stackTrace) {
      debugPrint(
          'Schedule import failed while trying to $failureStage: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage(
          'Could not $failureStage. See the debug console for details.');
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importStatus = 'Import PDF';
        });
      }
    }
  }

  Future<bool?> _reviewSchedule(
    String fileName,
    Map<String, List<ScheduleItem>> schedule,
  ) {
    final meetingCount =
        schedule.values.fold<int>(0, (count, items) => count + items.length);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Review imported schedule'),
        content: SizedBox(
          width: 440,
          height: MediaQuery.sizeOf(dialogContext).height * .5,
          child: ListView(
            children: [
              Text('$fileName · $meetingCount class meetings found'),
              const SizedBox(height: 12),
              ..._previewRows(schedule, Theme.of(dialogContext).colorScheme),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Import schedule'),
          ),
        ],
      ),
    );
  }

  List<Widget> _previewRows(
    Map<String, List<ScheduleItem>> schedule,
    ColorScheme colorScheme,
  ) {
    final rows = <Widget>[];
    for (final day in _days) {
      final items = schedule[day];
      if (items == null || items.isEmpty) continue;
      rows.add(Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text(day,
            style: TextStyle(
                color: colorScheme.primary, fontWeight: FontWeight.w700)),
      ));
      for (final item in items) {
        rows.add(ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(item.subject ?? 'Class', maxLines: 2),
          subtitle: Text('${item.time} · ${item.room} · ${item.instructor}'),
        ));
      }
    }
    return rows;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _schedule[_selectedDay] ?? const <ScheduleItem>[];
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? AppColors.surfaceDark : Colors.white;
    final subtitleBg = isDark ? AppColors.cardDark : const Color(0xFFF3F4F6);
    final subtitleBorder =
        isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: headerBg,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Academic Timetable',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hasImportedSchedule
                                  ? 'Imported registration schedule'
                                  : 'Import your registration form to add classes',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: .55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _isImporting ? null : _importSchedulePdf,
                        icon: _isImporting
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.upload_file_outlined, size: 16),
                        label:
                            Text(_isImporting ? _importStatus : 'Import PDF'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: headerBg,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: _days.map((day) {
                      final selected = _selectedDay == day;
                      return Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: day == _days.last ? 0 : 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryGreen
                                  : (isDark
                                      ? AppColors.cardDark
                                      : const Color(0xFFF3F4F6)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => _selectedDay = day),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 9),
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : cs.onSurface.withValues(alpha: .6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: subtitleBg,
                    border: Border(bottom: BorderSide(color: subtitleBorder)),
                  ),
                  child: Text.rich(TextSpan(
                    text: 'Enrolled Schedule for ',
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: .65)),
                    children: [
                      TextSpan(
                          text: _selectedDay,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  )),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                sliver: schedule.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptySchedule())
                    : SliverList.builder(
                        itemCount: schedule.length,
                        itemBuilder: (context, index) {
                          final item = schedule[index];
                          return item.isVacant
                              ? VacantScheduleCard(item: item)
                              : ScheduleCard(item: item);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 44, color: cs.onSurface.withValues(alpha: .3)),
          const SizedBox(height: 12),
          Text(
            'No classes listed in your registration form for this day.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: cs.onSurface.withValues(alpha: .45)),
          ),
        ],
      ),
    );
  }
}
