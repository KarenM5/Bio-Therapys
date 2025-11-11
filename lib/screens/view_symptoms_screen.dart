import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ViewSymptomsScreen extends StatefulWidget {
  const ViewSymptomsScreen({super.key});
  @override
  State<ViewSymptomsScreen> createState() => _ViewSymptomsScreenState();
}

class _ViewSymptomsScreenState extends State<ViewSymptomsScreen> {
  List<Map<String, dynamic>> _symptoms = [];
  Future<void> _loadSymptoms() async {
    final data = await DatabaseHelper.instance.getSymptoms();
    setState(() {
      _symptoms = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Síntomas Registrados'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _symptoms.isEmpty
          ? const Center(child: Text('No hay síntomas registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _symptoms.length,
              itemBuilder: (context, index) {
                final symptom = _symptoms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(symptom['patientName']),
                    subtitle: Text(symptom['description']),
                    trailing: Text(
                      symptom['date'].toString().substring(0, 10),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
