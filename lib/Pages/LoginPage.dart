import 'package:apq_m1/Widgets/WidgetInput.dart';
import 'package:apq_m1/Widgets/WidgetsLogin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Class/ClassDialog.dart';
import '../Class/ClassObject.dart';
import '../Database/DatabaseAuth.dart';
import '../Models/ModelsAuth.dart';
import '../Provider/ProviderAuth.dart';
import '../api/MobileQueueController/ActionLogin.dart';
import 'InitPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final domainController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WidgetsloginTemplate(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo/apqueue_logo2.png', fit: BoxFit.contain),
              const SizedBox(height: 40),
              WidgetinputTemplate(
                controller: domainController,
                hint: 'Domain',
                icon: Icons.language_outlined,
                suffixIcon: null,
              ),
              const SizedBox(height: 16),
              WidgetinputTemplate(
                controller: usernameController,
                hint: 'Username',
                icon: Icons.person_outline,
                suffixIcon: null,
              ),
              const SizedBox(height: 16),
              WidgetinputTemplate(
                controller: passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: AppColors.white, width: 2),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _onLogin,
                  child: const Text('Log in', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),

        const Positioned(
          bottom: 12,
          right: 30,
          child: Text(
            'Version 13.01.26',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  void _onLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final domain = domainController.text.trim();

    if (username.isEmpty || password.isEmpty || domain.isEmpty) {
      await ClassDialog.error(context, 'กรุณากรอกข้อมูลให้ครบ');
      return;
    }

    try {
      final result = await ActionLogin(
        domain: domain,
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (result.success) {
        final auth = Modelsauth(
          domain: domain,
          username: username,
          data: result.data['data'],
          node: '/nodeapq/socket.io',
        );

        await Databaseauth.saveAuth(auth);
        await context.read<ProviderAuth>().loadFromDb();

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const InitPage()),
          (route) => false,
        );
      } else {
        // await ClassDialog.error(context, result.message == 'OS Error: No addess' ?? 'Login failed');
        final msg = result.message?.contains('addess') == true
            ? 'Domain ผิด หรือ ป้อนรหัสผิด'
            : 'Domain ผิด หรือ ป้อนรหัสผิด';
        await ClassDialog.error(context, msg);
      }
    } catch (e) {
      if (!mounted) return;
      await ClassDialog.error(
        context,
        'ไม่สามารถเข้าสู่ระบบได้\n${e.toString()}',
      );
    }
  }
}
