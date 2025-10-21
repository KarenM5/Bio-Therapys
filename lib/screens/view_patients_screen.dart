import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ViewPatientsScreen extends StatefulWidget {
  const ViewPatientsScreen({super.key});

  @override
  State<ViewPatientsScreen> createState() => _ViewPatientsScreenState();
}

class _ViewPatientsScreenState extends State<ViewPatientsScreen> {
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final data = await DatabaseHelper.instance.getPatients();
    setState(() {
      _patients = data;
    });
  }

  Future<void> _deletePatient(int id) async {
    await DatabaseHelper.instance.deletePatient(id);
    _loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _patients.isEmpty
          ? const Center(child: Text('No hay pacientes registrados'))
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.teal),
                    title: Text('${patient['name']} ${patient['lastname']}'),
                    subtitle: Text(
                        'Edad: ${patient['age']}  | Peso: ${patient['weight']} kg'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deletePatient(patient['id'] as int),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
