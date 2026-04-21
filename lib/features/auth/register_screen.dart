import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.healthWorker;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthService>();
    final err = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      name: _nameCtrl.text.trim(),
      role: _selectedRole,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
    );
    if (mounted) {
      setState(() => _loading = false);
      if (err != null) {
        setState(() => _error = err);
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('BC', style: TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
                      )),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Create Account', style: AppTypography.displaySmall),
                  const SizedBox(height: 8),
                  Text('Register a new staff account',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text('Full Name', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (v) => Validators.required(v, 'Name'),
                    decoration: const InputDecoration(hintText: 'Juan Dela Cruz'),
                  ),
                  const SizedBox(height: 16),

                  Text('Email Address', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    validator: Validators.email,
                    decoration: const InputDecoration(hintText: 'you@example.com'),
                  ),
                  const SizedBox(height: 16),

                  Text('Phone (optional)', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneCtrl,
                    validator: Validators.phone,
                    decoration: const InputDecoration(hintText: '09XX XXX XXXX'),
                  ),
                  const SizedBox(height: 16),

                  Text('Role', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _selectedRole,
                    items: UserRole.values.map((r) => DropdownMenuItem(
                      value: r, child: Text(r.label),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedRole = v!),
                    decoration: const InputDecoration(),
                  ),
                  const SizedBox(height: 16),

                  Text('Password', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      hintText: 'Min 6 characters',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
