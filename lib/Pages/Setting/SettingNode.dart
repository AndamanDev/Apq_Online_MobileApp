import 'package:apq_m1/Database/DatabaseAuth.dart';
import 'package:flutter/material.dart';

import '../../Class/ClassToast.dart';

class Settingnode extends StatefulWidget {
  const Settingnode({super.key});

  @override
  State<Settingnode> createState() => _SettingnodeState();
}

class _SettingnodeState extends State<Settingnode> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNode();
  }

  Future<void> _loadNode() async {
    final auth = await Databaseauth.getAuth();
    if (auth != null) {
      _controller.text = auth.node ?? '';
    }

    // Print ข้อมูลทั้งหมดใน table auth
    final allAuth = await Databaseauth.getAllAuth();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveNode() async {
    final auth = await Databaseauth.getAuth();
    if (auth != null) {
      final updatedAuth = auth.copyWith(node: _controller.text);
      await Databaseauth.saveAuth(updatedAuth);
      ClassToast.success("Node updated successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: const Icon(Icons.signal_cellular_alt, color: Colors.green),
            title: const Text(
              "Node Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            childrenPadding: const EdgeInsets.all(12),
            children: [
              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            labelText: "Node",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _saveNode,
                          child: const Text("Save"),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
