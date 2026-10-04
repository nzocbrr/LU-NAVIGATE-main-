import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _coursesByCollege = <String, List<String>>{
    'CoEng - College of Engineering': [
      'Bachelor of Science in Mechanical Engineering (BSME)',
    ],
    'CBAA - College of Business, Accountancy and Administration': [
      'Bachelor of Science in Accountancy (BSA)',
      'Bachelor of Science in Accounting Information System (BSAIS)',
      'Bachelor of Science in Entrepreneurship (BS Entrep)',
      'Bachelor of Science in Tourism Management (BSTM)',
    ],
    'CHS - College of Health Sciences': [
      'Diploma in Midwifery',
    ],
    'CAS - College of Arts and Sciences': [
      'Bachelor of Arts in Communication (BAC)',
      'Bachelor of Science in Psychology (BSPsych)',
      'Bachelor of Arts in Psychology (AB Psych)',
    ],
    'CCS - College of Computing Studies': [
      'Bachelor of Science in Computer Science (BSCS)',
      'Bachelor of Science in Information Technology (BSIT)',
    ],
    'CoEd - College of Education': [
      'Bachelor of Elementary Education (BEEd)',
      'Bachelor of Secondary Education (BSEd)',
      'Bachelor of Physical Education (BPEd)',
    ],
  };

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _obscurePassword = true;
  String? _selectedProgram;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final error = _isRegistering
        ? authProvider.register(
            name: _nameController.text.trim(),
            studentId: _studentIdController.text.trim(),
            email: _emailController.text.trim(),
            program: _selectedProgram ?? '',
            password: _passwordController.text,
          )
        : authProvider.login(
            studentId: _studentIdController.text.trim(),
            password: _passwordController.text,
          );

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  String? _validateEmail(String? value) {
    final requiredError = _required(value, 'Email');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final requiredError = _required(value, 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 6) return 'Use at least 6 characters.';
    return null;
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryGreen,
                    size: 46,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegistering
                        ? 'Create your account'
                        : 'Welcome to LU-Nav',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRegistering
                        ? 'Register to explore your campus.'
                        : 'Sign in to continue to your campus companion.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_isRegistering) ...[
                          _input(
                            controller: _nameController,
                            label: 'Full name',
                            icon: Icons.person_outline,
                            validator: (value) => _required(value, 'Name'),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          _input(
                            controller: _studentIdController,
                            label: 'Student ID',
                            icon: Icons.badge_outlined,
                            validator: (value) =>
                                _required(value, 'Student ID'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                        ],
                        _isRegistering
                            ? _input(
                                controller: _emailController,
                                label: 'Email address',
                                icon: Icons.email_outlined,
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              )
                            : _input(
                                controller: _studentIdController,
                                label: 'Student ID',
                                icon: Icons.badge_outlined,
                                validator: (value) =>
                                    _required(value, 'Student ID'),
                                textInputAction: TextInputAction.next,
                              ),
                        if (_isRegistering) ...[
                          const SizedBox(height: 14),
                          _programDropdown(),
                        ],
                        const SizedBox(height: 14),
                        _input(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          validator: _validatePassword,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(_isRegistering ? 'Register' : 'Log In'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _isRegistering
                            ? 'Already have an account?'
                            : 'New to LU-Nav?',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: _toggleMode,
                        child: Text(_isRegistering ? 'Log in' : 'Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _programDropdown() {
    final courseOptions = _coursesByCollege.values.expand((courses) => courses);
    return DropdownButtonFormField<String>(
      initialValue: _selectedProgram,
      isExpanded: true,
      menuMaxHeight: 420,
      decoration: InputDecoration(
        labelText: 'Program / course',
        prefixIcon: const Icon(Icons.school_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      items: [
        for (final college in _coursesByCollege.entries) ...[
          DropdownMenuItem<String>(
            value: 'college-${college.key}',
            enabled: false,
            child: Text(
              college.key,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          for (final course in college.value)
            DropdownMenuItem<String>(
              value: course,
              child: Text(
                course,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ],
      validator: (value) =>
          courseOptions.contains(value) ? null : 'Select a course.',
      onChanged: (value) => setState(() => _selectedProgram = value),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }
}
