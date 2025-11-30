import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../services/sync_service.dart'; 

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final patient = {
        'name': _nameController.text,
        'lastname': _lastnameController.text,
        'age': int.tryParse(_ageController.text),
        'weight': double.tryParse(_weightController.text),
        'heart_rate': int.tryParse(_heartRateController.text),
        'disease': _diseaseController.text,
        'synced': 0, // 👈 Para saber si ya se subió al servidor
      };

      // Guardar en SQLite como siempre
      await DatabaseHelper.instance.insertPatient(patient);

      // 🔄 Intentar sincronizar al backend si hay internet
      await SyncService().syncLocalPatientsToServer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente guardado correctamente')),
        );
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Paciente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Nombre', 'Ingrese el nombre'),
              _buildTextField(_lastnameController, 'Apellido', 'Ingrese el apellido'),
              _buildTextField(_ageController, 'Edad', 'Ingrese la edad', inputType: TextInputType.number),
              _buildTextField(_weightController, 'Peso (kg)', 'Ingrese el peso', inputType: TextInputType.number),
              _buildTextField(_heartRateController, 'Frecuencia (bpm)', 'Ingrese la frecuencia cardiaca', inputType: TextInputType.number),
              _buildTextField(_diseaseController, 'Enfermedad', 'Ingrese la enfermedad'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Paciente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _savePatient,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo requerido';
          return null;
        },
      ),
    );
  }
}
