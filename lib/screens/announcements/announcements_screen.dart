import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../data/announcements_data.dart';
import '../../models/announcement.dart';
import '../../widgets/announcement_card.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState
    extends State<AnnouncementsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  AnnouncementFilter _filter = AnnouncementFilter.all;
  final Set<String> _readIds = <String>{};
  final List<Announcement> _announcements =
      List<Announcement>.of(initialAnnouncements);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Announcement> get _visibleAnnouncements {
    final normalizedQuery = _query.toLowerCase();
    return _announcements.where((item) {
      final categoryMatches = _filter == AnnouncementFilter.all ||
          (_filter == AnnouncementFilter.classes &&
              item.category ==
                  AnnouncementCategory.classUpdate) ||
          (_filter == AnnouncementFilter.emergency &&
              item.category ==
                  AnnouncementCategory.emergency);
      final searchMatches =
          item.title.toLowerCase().contains(normalizedQuery) ||
              item.body
                  .toLowerCase()
                  .contains(normalizedQuery) ||
              item.author
                  .toLowerCase()
                  .contains(normalizedQuery);
      return categoryMatches && searchMatches;
    }).toList(growable: false);
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(
        const Duration(milliseconds: 1200));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Updated'),
        content: const Text(
            'You are up to date with the latest announcements.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'))
        ],
      ),
    );
  }

  Future<void> _confirmDismiss(
      Announcement announcement) async {
    final shouldDismiss = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Announcement'),
        content: Text(
            'Are you sure you want to remove "${announcement.title}"?'),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.red),
              child: const Text('Dismiss')),
        ],
      ),
    );
    if (shouldDismiss == true && mounted) {
      setState(() => _announcements
          .removeWhere((item) => item.id == announcement.id));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final announcements = _visibleAnnouncements;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? AppColors.surfaceDark : Colors.white;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: headerBg,
            padding:
                const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              'Announcements & Alerts',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface),
            ),
          ),
          _searchBox(context, cs, isDark),
          _filterRow(context, isDark),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _refresh,
              child: announcements.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.only(bottom: 110),
                      children: const [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 40),
                          child: _EmptyAnnouncements(),
                        )
                      ],
                    )
                  : ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 110),
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final announcement =
                            announcements[index];
                        return AnnouncementCard(
                          announcement: announcement,
                          isRead: _readIds
                              .contains(announcement.id),
                          onTap: () => setState(() {
                            if (!_readIds
                                .add(announcement.id)) {
                              _readIds.remove(
                                  announcement.id);
                            }
                          }),
                          onDismiss: () => unawaited(
                              _confirmDismiss(announcement)),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox(
      BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding:
          const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: .04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                )
              ],
      ),
      child: Row(
        children: [
          Icon(Icons.search,
              color: cs.onSurface.withValues(alpha: .4),
              size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _query = value),
              style: TextStyle(
                  fontSize: 13, color: cs.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    'Search updates, professors, or keywords...',
                hintStyle: TextStyle(
                    color: cs.onSurface
                        .withValues(alpha: .4)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(
                        vertical: 12),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: Icon(Icons.cancel,
                  size: 16,
                  color:
                      cs.onSurface.withValues(alpha: .4)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(
                  minWidth: 26, minHeight: 26),
              tooltip: 'Clear search',
            ),
        ],
      ),
    );
  }

  Widget _filterRow(
      BuildContext context, bool isDark) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _FilterTab(
            label: 'All',
            selected:
                _filter == AnnouncementFilter.all,
            onTap: () => setState(
                () => _filter = AnnouncementFilter.all),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: 'Classes',
            selected:
                _filter == AnnouncementFilter.classes,
            onTap: () => setState(() =>
                _filter = AnnouncementFilter.classes),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: '🚨 Emergency',
            selected:
                _filter == AnnouncementFilter.emergency,
            emergency: true,
            onTap: () => setState(() =>
                _filter =
                    AnnouncementFilter.emergency),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

enum AnnouncementFilter { all, classes, emergency }

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
    this.emergency = false,
  });

  final String label;
  final bool selected;
  final bool emergency;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = emergency
        ? (isDark
            ? const Color(0xFF2D1515)
            : const Color(0xFFFEF2F2))
        : (selected
            ? AppColors.primaryGreen
            : (isDark
                ? AppColors.cardDark
                : const Color(0xFFE5E7EB)));
    final color = emergency
        ? AppColors.red
        : (selected
            ? Colors.white
            : (isDark
                ? AppColors.secondaryTextDark
                : AppColors.secondaryText));
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: emergency
              ? Border.all(
                  color: isDark
                      ? const Color(0xFF7F1D1D)
                      : const Color(0xFFFCA5A5))
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 9),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      emergency || selected
                          ? FontWeight.w700
                          : FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyAnnouncements extends StatelessWidget {
  const _EmptyAnnouncements();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(Icons.notifications_off_outlined,
            size: 40,
            color: cs.onSurface.withValues(alpha: .3)),
        const SizedBox(height: 8),
        Text(
          'No announcements found',
          style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: .45),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
