import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (!auth.hasCredentials) {
                  return _buildKeyForm(auth);
                }
                return _buildPinForm(auth);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyForm(AuthProvider auth) {
    return Card(
      color: const Color(0xFF2B2B2B),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Первый вход',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              'Введите API ключ (OpenRouter или VseGPT).',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'API ключ',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 10),
              Text(auth.error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            if (auth.generatedPin != null) ...[
              const SizedBox(height: 10),
              Text(
                'Ваш PIN: ${auth.generatedPin}',
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final ok =
                            await context.read<AuthProvider>().registerWithApiKey(
                                  _keyController.text,
                                );
                        if (!mounted || !ok) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ключ сохранен. Используйте PIN для входа.'),
                          ),
                        );
                      },
                child: auth.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Проверить ключ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinForm(AuthProvider auth) {
    return Card(
      color: const Color(0xFF2B2B2B),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Введите PIN',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              'Для входа используйте 4-значный PIN.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'PIN',
                labelStyle: TextStyle(color: Colors.white70),
                counterText: '',
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 10),
              Text(auth.error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            context.read<AuthProvider>().loginWithPin(
                                  _pinController.text,
                                );
                          },
                    child: const Text('Войти'),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => context.read<AuthProvider>().resetKey(),
                  child: const Text('Сбросить ключ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
