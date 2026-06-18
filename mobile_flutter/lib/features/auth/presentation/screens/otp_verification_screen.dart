import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});
  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() { _otpController.dispose(); super.dispose(); }

  void _verify() {
    if (_formKey.currentState!.validate()) {
      ref.read(authStateProvider.notifier).verifyPhoneOtp(widget.phone, _otpController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!), backgroundColor: AppColors.error));
      if (next.isAuthenticated) context.go('/home');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification OTP'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sms, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Code de vérification', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Un code a été envoyé à ${widget.phone}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextFormField(controller: _otpController, keyboardType: TextInputType.number, maxLength: 6, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, letterSpacing: 8), decoration: const InputDecoration(hintText: '● ● ● ● ● ●', counterText: ''), validator: (v) => v == null || v.length != 6 ? 'Code à 6 chiffres' : null),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: authState.isLoading ? null : _verify, child: authState.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Vérifier')),
              const SizedBox(height: 16),
              TextButton(onPressed: () => context.pop(), child: const Text('Modifier le numéro')),
            ],
          ),
        ),
      ),
    );
  }
}
