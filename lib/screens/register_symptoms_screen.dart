import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class RegisterSymptomsScreen extends StatefulWidget {
  final int? patientId; // ahora opcional
  final String? patientName;

  const RegisterSymptomsScreen({
    super.key,
    this.patientId,
    this.patientName,
  });

  @override
  State<RegisterSymptomsScreen> createState() => _RegisterSymptomsScreenState();
}

class _RegisterSymptomsScreenState extends State<RegisterSymptomsScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _symptomList = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.patientName ?? '';
    _loadSymptoms();
  }

  // 🔹 Cargar síntomas
  Future<void> _loadSymptoms() async {
    List<Map<String, dynamic>> data = [];

    if (widget.patientId != null) {
      data = await dbHelper.getSymptomsByPatientId(widget.patientId!);
    } else {
      data = await dbHelper.getSymptoms(); // 🔸 carga todos si no hay ID
    }

    setState(() {
      _symptomList = data;
    });
  }

  // 🔹 Agregar nuevo síntoma
  Future<void> _addSymptom() async {
    final description = _symptomController.text.trim();
    final enteredName = _nameController.text.trim().isEmpty
        ? 'Paciente desconocido'
        : _nameController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe un síntoma')),
      );
      return;
    }

    final symptom = {
      'patient_id': widget.patientId ?? 0, // 🔸 si no hay ID, guarda 0
      'patientName': enteredName,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    };

    await dbHelper.insertSymptom(symptom);
    _symptomController.clear();
    await _loadSymptoms();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Síntoma guardado correctamente para $enteredName'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  // 🔹 Eliminar síntoma
  Future<void> _deleteSymptom(int id) async {
    await dbHelper.deleteSymptom(id);
    await _loadSymptoms();
  }

  // 🔹 Interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Síntomas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧍‍♀️ Nombre del paciente
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del Paciente',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Nuevo Registro',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _symptomController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción de los síntomas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.healing),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addSymptom,
                icon: const Icon(Icons.add),
                label: const Text('Guardar Síntoma'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const Divider(height: 30, thickness: 2),
            const Text(
              'Historial de Síntomas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📋 Lista de síntomas
            Expanded(
              child: _symptomList.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay síntomas registrados.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _symptomList.length,
                      itemBuilder: (context, index) {
                        final item = _symptomList[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            title: Text(item['description']),
                            subtitle: Text(
                              'Paciente: ${item['patientName'] ?? 'Desconocido'}\n'
                              'Fecha: ${DateTime.parse(item['date']).toLocal().toString().split('.')[0]}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSymptom(item['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
