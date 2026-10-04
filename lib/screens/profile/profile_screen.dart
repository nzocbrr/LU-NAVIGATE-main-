import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../auth_provider.dart';
import '../../theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _feedbackController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _aboutExpanded = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _openFeedbackDialog() async {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send Feedback',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
              const SizedBox(height: 8),
              Text(
                  'Found a bug or have a suggestion for the campus map or schedule? Let us know below.',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.38,
                      color: cs.onSurface.withValues(alpha: .6))),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                minLines: 4,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 13, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  hintStyle:
                      TextStyle(color: cs.onSurface.withValues(alpha: .4)),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.surfaceDark : AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : const Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : const Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.surfaceDark
                                  : const Color(0xFFF3F4F6),
                              foregroundColor:
                                  cs.onSurface.withValues(alpha: .6),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text('Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600)))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: FilledButton(
                          onPressed: () => _submitFeedback(dialogContext),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text('Submit',
                              style: TextStyle(fontWeight: FontWeight.w700)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback(BuildContext dialogContext) async {
    if (_feedbackController.text.trim().isEmpty) {
      await showDialog<void>(
        context: dialogContext,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('Please enter your feedback or issue description.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
      return;
    }
    _feedbackController.clear();
    Navigator.pop(dialogContext);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text(
            'Your feedback has been submitted to the IT support team.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content:
            const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Log Out')),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;
    authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _profileHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _accountCard(),
                  const SizedBox(height: 14),
                  _supportCard(),
                  const SizedBox(height: 18),
                  _logoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    final user = authProvider.value;
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      child: Column(
        children: [
          CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                  radius: 33,
                  backgroundColor: AppColors.orange,
                  child: Text(user?.initials ?? '?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700)))),
          SizedBox(height: 10),
          Text(user?.name ?? 'Student',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 2),
          Text(user?.program ?? '',
              style: TextStyle(color: AppColors.lightGreen, fontSize: 13)),
          SizedBox(height: 2),
          Text('Laguna University',
              style: TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _accountCard() {
    final cs = Theme.of(context).colorScheme;
    final user = authProvider.value;
    return _SectionCard(
      title: 'Account Preferences',
      child: Column(
        children: [
          _InfoRow(
              icon: Icons.credit_card_outlined,
              label: 'Student ID',
              value: user?.studentId ?? ''),
          _InfoRow(
              icon: Icons.school_outlined,
              label: 'Program',
              value: user?.program ?? ''),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Icon(Icons.dark_mode_outlined,
                    size: 18, color: cs.onSurface.withValues(alpha: .6)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Dark Mode',
                        style: TextStyle(fontSize: 13, color: cs.onSurface))),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeProvider,
                  builder: (context, mode, _) {
                    return Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (val) => themeProvider.toggle(),
                      activeTrackColor: AppColors.primaryGreen,
                      inactiveTrackColor: const Color(0xFFD1D1D6),
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Icon(Icons.notifications_outlined,
                    size: 18, color: cs.onSurface.withValues(alpha: .6)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Push Notifications',
                        style: TextStyle(fontSize: 13, color: cs.onSurface))),
                Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                    activeTrackColor: AppColors.primaryGreen,
                    inactiveTrackColor: const Color(0xFFD1D1D6),
                    thumbColor: const WidgetStatePropertyAll(Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportCard() {
    return _SectionCard(
      title: 'Support & Feedback',
      child: Column(
        children: [
          _ActionRow(
              icon: Icons.chat_bubble_outline,
              label: 'Report Issue or Send Feedback',
              onTap: _openFeedbackDialog),
          _ActionRow(
              icon: Icons.info_outline,
              label: 'About Campus App',
              onTap: () => setState(() => _aboutExpanded = !_aboutExpanded),
              expanded: _aboutExpanded,
              last: _aboutExpanded),
          if (_aboutExpanded) _credits(),
        ],
      ),
    );
  }

  Widget _credits() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Laguna University Campus App',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 2),
          Text('Meet the Developers!',
              style: TextStyle(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: .6))),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                  height: 1,
                  color:
                      isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
          const Text('DEVELOPMENT TEAM',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                  color: AppColors.primaryGreen)),
          const SizedBox(height: 8),
          const _CreditItem(role: 'Frontend', name: 'Adriel Enzo M. Cabrera'),
          const _CreditItem(role: 'Backend', name: 'Mark Adrian G. Correa'),
          const _CreditItem(role: 'Backend', name: 'Mark Angel E. Diaz'),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout_outlined, size: 18),
        label: const Text('Log Out'),
        style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.red,
            backgroundColor:
                isDark ? const Color(0xFF2D1515) : const Color(0xFFFEF2F2),
            side: BorderSide(
                color:
                    isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 15,
                color: cs.onSurface,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        child
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : const Color(0xFFF3F4F6)))),
      child: Row(children: [
        Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: .6)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 13, color: cs.onSurface))),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)))
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.expanded = false,
      this.last = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool expanded;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: last
              ? null
              : BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : const Color(0xFFF3F4F6)))),
          child: Row(children: [
            Icon(icon, size: 18, color: AppColors.primaryGreen),
            const SizedBox(width: 10),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500))),
            Icon(expanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                size: 18, color: cs.onSurface.withValues(alpha: .4))
          ]),
        ),
      ),
    );
  }
}

class _CreditItem extends StatelessWidget {
  const _CreditItem({required this.role, required this.name});

  final String role;
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(role,
            style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: .6),
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Flexible(
            child: Text(name,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600)))
      ]),
    );
  }
}
