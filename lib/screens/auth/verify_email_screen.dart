import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false; // local UI state, so setState is fine

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final ok = await context.read<AuthProvider>().checkVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    // If verified, AuthGate rebuilds and shows the home screen by itself
    if (!ok) _showMessage('Not verified yet. Check your inbox and spam.');
  }

  Future<void> _resend() async {
    try {
      await context.read<AuthProvider>().resendVerification();
      if (mounted) _showMessage('Verification email sent.');
    } catch (_) {
      if (mounted) _showMessage('Could not send email. Try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  'We sent a verification link to\n${auth.email}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Open the link, then come back and tap the button below.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _checking ? null : _check,
                  child: _checking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("I've verified my email"),
                ),
                TextButton(
                  onPressed: _resend,
                  child: const Text('Resend email'),
                ),
                TextButton(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  child: const Text('Use a different account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
