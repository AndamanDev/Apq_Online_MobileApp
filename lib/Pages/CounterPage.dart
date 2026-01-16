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

class Counterpage extends StatefulWidget {
  final Modelsauth auth;
  const Counterpage({super.key, required this.auth});

  @override
  State<Counterpage> createState() => _CounterpageState();
}

class _CounterpageState extends State<Counterpage> {
  Modelsbranchsearch? branch;
  List<Modelscountersearch> counters = [];

  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final branches =
          await ActionBranchsearch(branchid: widget.auth.data);

      if (branches.isEmpty) return;

      final b = branches.first;

      if (!isBranchActive(b.branchEndDate)) {
        return;
      }

      final counterList =
          await ActionCounterSearch(branchid: widget.auth.data);

      setState(() {
        branch = b;
        counters = counterList;
        initialized = true;
      });
    } catch (e) {
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Counter'),
        automaticallyImplyLeading: false,
      ),

      body: !initialized
          ? const SizedBox.shrink() // ❌ ไม่โชว์ loading
          : branch == null
              ? const Center(child: Text('ไม่สามารถใช้งานสาขานี้ได้'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: counters.length,
                  itemBuilder: (context, index) {
                    final counter = counters[index];

                    return Card(
                      key: ValueKey(counter.kioskId),
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
                                    ProviderQueue(branch!.branchId)..load(),
                                child: Homepage(
                                  branchId: branch!.branchId,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  bool isBranchActive(String branchEndDate) {
    try {
      final endDate = DateTime.parse(branchEndDate);
      return !DateTime.now().isAfter(endDate);
    } catch (_) {
      return false;
    }
  }
}
