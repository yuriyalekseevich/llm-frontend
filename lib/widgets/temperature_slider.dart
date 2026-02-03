import 'package:flutter/material.dart';

class TemperatureSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const TemperatureSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Creativity Control:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const Spacer(),
            Chip(
              label: Text('${value.toStringAsFixed(1)}'),
              backgroundColor: _getTemperatureColor(value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: 0,
          max: 1,
          divisions: 10,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'More Factual',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'More Creative',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Color _getTemperatureColor(double value) {
    if (value < 0.3) return Colors.green.shade100;
    if (value < 0.7) return Colors.orange.shade100;
    return Colors.red.shade100;
  }
}