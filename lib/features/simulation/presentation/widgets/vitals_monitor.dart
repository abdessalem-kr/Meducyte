import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';

class VitalsMonitor extends StatelessWidget {
  final Vitals? vitals;
  const VitalsMonitor({super.key, required this.vitals});

  @override
  Widget build(BuildContext context) {
    if (vitals == null) return const SizedBox.shrink();

    final v = vitals!;
    final isHrHigh = v.heartRate > 100;
    final isSpo2Low = v.spo2 < 94;
    final isBpHigh = v.bloodPressure.contains('150') || v.bloodPressure.contains('160');

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isHrHigh || isSpo2Low) ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: (isHrHigh || isSpo2Low)
            ? [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _VitalItem(label: "HR", value: "${v.heartRate}", unit: "bpm", color: isHrHigh ? Colors.red : Colors.green, isAlert: isHrHigh),
          _VitalItem(label: "BP", value: v.bloodPressure, unit: "mmHg", color: isBpHigh ? Colors.orange : Colors.blue, isAlert: isBpHigh),
          _VitalItem(label: "SpO2", value: "${v.spo2}%", unit: "O2", color: isSpo2Low ? Colors.red : Colors.cyan, isAlert: isSpo2Low),
          _VitalItem(label: "Temp", value: "${v.temperature}°C", unit: "T", color: Colors.amber, isAlert: false),
        ],
      ),
    );
  }
}

class _VitalItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isAlert;

  const _VitalItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAlert)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Iconsax.warning_2, size: 10, color: color),
              ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: isAlert ? color : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          unit,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8),
        ),
      ],
    );
  }
}
