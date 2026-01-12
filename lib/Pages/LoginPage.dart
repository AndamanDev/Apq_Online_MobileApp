import 'package:apq_m1/Widgets/WidgetInput.dart';
import 'package:apq_m1/Widgets/WidgetsLogin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return WidgetsloginTemplate(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// LOGO
          const Text('Logo', style: AppTextStyles.logo),
          const SizedBox(height: 40),

          /// DOMAIN
          WidgetinputTemplate(
            controller: domainController,
            hint: 'Domain',
            icon: Icons.language_outlined,
          ),
          const SizedBox(height: 16),

          /// USERNAME
          WidgetinputTemplate(
            controller: usernameController,
            hint: 'Username',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          /// PASSWORD
          WidgetinputTemplate(
            controller: passwordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
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
    );
  }

  void _onLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final domain = domainController.text.trim();

    if (username.isEmpty || password.isEmpty || domain.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')));
      return;
    }

    final result = await ActionLogin(
      domain: domain,
      username: username,
      password: password,
    );

    if (result.success) {
      final auth = Modelsauth(
        domain: domain,
        username: username,
        data: result.data['data'],
      );

      await Databaseauth.saveAuth(auth);
      await context.read<ProviderAuth>().loadFromDb();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const InitPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message ?? 'Login failed')));
    }
  }
}
