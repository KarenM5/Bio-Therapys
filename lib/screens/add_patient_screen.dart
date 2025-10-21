import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final patient = {
        'name': _nameController.text.trim(),
        'lastname': _lastNameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'disease': _diseaseController.text.trim(),
        'weight': double.tryParse(_weightController.text) ?? 0.0,
      };

      await DatabaseHelper.instance.insertPatient(patient);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente agregado correctamente')),
      );

      _formKey.currentState!.reset();
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _diseaseController,
                decoration: const InputDecoration(labelText: 'Enfermedad'),
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Peso',
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _savePatient,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
