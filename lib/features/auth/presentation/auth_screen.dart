import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'demo@expenseiq.app');
  final _password = TextEditingController(text: 'password123');
  bool _signup = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        context.go('/dashboard');
      }
      next.whenOrNull(
        error: (error, stackTrace) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        ),
      );
    });

    final authState = ref.watch(authProvider);
    if (authState.valueOrNull != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/dashboard');
        }
      });
    }
    return Scaffold(
      body: GradientShell(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0.94, end: 1),
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Hero(
                          tag: 'brand',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              'ExpenseIQ',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Private, intelligent money management.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) => value != null && value.contains('@')
                              ? null
                              : 'Enter a valid email.',
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          autofillHints: const <String>[AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) => value != null && value.length >= 6
                              ? null
                              : 'Use at least 6 characters.',
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _sendReset,
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: authState.isLoading ? null : _submit,
                          icon: authState.isLoading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(_signup ? Icons.person_add : Icons.login),
                          label: Text(_signup ? 'Create account' : 'Log in'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : () => ref.read(authProvider.notifier).googleLogin(),
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Continue with Google'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _signup = !_signup),
                          child: Text(
                            _signup
                                ? 'Already have an account? Log in'
                                : 'New here? Create an account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = ref.read(authProvider.notifier);
    if (_signup) {
      await controller.signup(_email.text.trim(), _password.text);
    } else {
      await controller.login(_email.text.trim(), _password.text);
    }
  }

  Future<void> _sendReset() async {
    try {
      await ref.read(authProvider.notifier).sendPasswordReset(_email.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
