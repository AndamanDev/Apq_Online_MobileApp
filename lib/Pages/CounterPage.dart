import 'package:apq_m1/Class/ClassObject.dart';
import 'package:apq_m1/Models/ModelsBranchSearch.dart';
import 'package:apq_m1/Pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:apq_m1/Models/ModelsAuth.dart';
import 'package:provider/provider.dart';
import '../Api/MobileQueueController/ActionBranchSearch.dart';
import '../Api/MobileQueueController/ActionCounterSearch.dart';
import '../Models/ModelsCounterSearch.dart';
import '../Provider/ProviderAuth.dart';
import '../Provider/ProviderQueue.dart';

class Counterpage extends StatelessWidget {
  final Modelsauth auth;

  const Counterpage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกเค้าเตอร์ | Select Counter'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<ProviderAuth>().logout();
          },
        ),
      ),

      body: FutureBuilder<List<Modelsbranchsearch>>(
        future: ActionBranchsearch(context: context, branchid: auth.data),
        builder: (context, branchSnapshot) {
          if (branchSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!branchSnapshot.hasData || branchSnapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลสาขา'));
          }

          final branch = branchSnapshot.data!.first;

          // 🔒 เช็กวันหมดอายุสาขา
          if (!isBranchActive(branch.branchEndDate)) {
            return const Center(
              child: Text(
                'สาขานี้หมดอายุแล้ว',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return FutureBuilder<List<Modelscountersearch>>(
            future: ActionCounterSearch(context: context, branchid: auth.data),
            builder: (context, counterSnapshot) {
              if (counterSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!counterSnapshot.hasData || counterSnapshot.data!.isEmpty) {
                return const Center(child: Text('ไม่พบข้อมูล Counter'));
              }

              final counters = counterSnapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: counters.length,
                itemBuilder: (context, index) {
                  final counter = counters[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        counter.kioskName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) =>
                                  ProviderQueue(context, branch.branchId)
                                    ..load(),
                              child: Homepage(branchId: branch.branchId),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  bool isBranchActive(String branchEndDate) {
    try {
      final endDate = DateTime.parse(branchEndDate);
      final now = DateTime.now();
      return !now.isAfter(endDate);
    } catch (_) {
      return false;
    }
  }
}
