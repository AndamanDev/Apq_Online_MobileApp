import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/ProviderAuth.dart';
import 'CounterPage.dart';
import 'LoginPage.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ProviderAuth>();

    // ตอนเปิดแอป provider ยังโหลด DB ไม่เสร็จ
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // มี auth ใน Provider → เข้าแอป
    if (auth.isLoggedIn) {
      return Counterpage(auth: auth.auth!);
    }

    // ไม่มี auth → login
    return const LoginPage();
  }
}
