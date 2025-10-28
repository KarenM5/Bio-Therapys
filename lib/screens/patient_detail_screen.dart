import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text(
          'Expediente de ${patient['name']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.teal.shade200,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${patient['name']} ${patient['lastname'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const Divider(height: 30, thickness: 1.2),
                _infoRow('🆔 ID', patient['id'].toString()),
                _infoRow('🎂 Edad', '${patient['age'] ?? '-'} años'),
                _infoRow('⚖️ Peso', '${patient['weight'] ?? '-'} kg'),
                _infoRow('💓 Frecuencia cardíaca',
                    '${patient['heart_rate'] ?? '-'} bpm'),
                _infoRow('🦠 Enfermedad', patient['disease'] ?? 'No registrada'),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Text(value,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
