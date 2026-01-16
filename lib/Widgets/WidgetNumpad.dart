import 'package:flutter/material.dart';
import '../Class/ClassObject.dart';

class Widgetnumpad extends StatelessWidget {
  final ValueChanged<String> onNumberTap;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  final String currentValue;
  final String submitText;

  const Widgetnumpad({
    super.key,
    required this.onNumberTap,
    required this.onDelete,
    required this.onClear,
    required this.onSubmit,
    required this.currentValue,
    this.submitText = 'ยืนยัน | CONFIRM',
  });

  Widget _buildButton(String text, {VoidCallback? onTap, Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onTap,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            children: row
                .map(
                  (e) => _buildButton(
                    e,
                    onTap: () {
                      if (e == '0' && currentValue.isEmpty) return;

                      onNumberTap(e);
                    },
                  ),
                )
                .toList(),
          ),

        Row(
          children: [
            _buildButton('C', color: Colors.grey, onTap: onClear),
            _buildButton(
              '0',
              onTap: () {
                if (currentValue.isEmpty) return;
                onNumberTap('0');
              },
            ),
            _buildButton('⌫', color: Colors.red, onTap: onDelete),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: currentValue.isEmpty ? null : onSubmit,
                  child: Text(
                    submitText,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
