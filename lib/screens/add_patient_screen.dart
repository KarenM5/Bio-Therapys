import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _hrvController = TextEditingController();

  bool _isSaving = false;
  bool _consentGiven = false;
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedImage != null) {
      setState(() => _imageFile = File(pickedImage.path));
    }
  }

  Future<void> _savePatient() async {
    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe otorgar el consentimiento de uso de datos biométricos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final now = DateTime.now();

      final patient = {
        'name': _nameController.text.trim(),
        'lastname': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'disease': _diseaseController.text.trim(),
        'hrv': double.tryParse(_hrvController.text) ?? 0.0,
        'photo_path': _imageFile?.path ?? '',
        'consent': _consentGiven ? 1 : 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      try {
        await DatabaseHelper.instance.insertPatient(patient);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Paciente agregado correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 800));
          setState(() => _isSaving = false);
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Agregar Paciente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 20),
                  Text(
                    'Guardando paciente...',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const Text(
                          'Registro de Paciente',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Email / ID
                        _buildTextField(
                          controller: _emailController,
                          label: 'Correo electrónico / ID',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty
                              ? 'Campo obligatorio'
                              : (!v.contains('@')
                                  ? 'Correo no válido'
                                  : null),
                        ),

                        // Nombre
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre',
                          icon: Icons.person,
                        ),

                        // Apellido
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Apellido',
                          icon: Icons.badge,
                        ),

                        // Edad
                        _buildTextField(
                          controller: _ageController,
                          label: 'Edad',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                        ),

                        // Altura
                        _buildTextField(
                          controller: _heightController,
                          label: 'Altura (cm)',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                        ),

                        // Peso
                        _buildTextField(
                          controller: _weightController,
                          label: 'Peso (kg)',
                          icon: Icons.monitor_weight,
                          keyboardType: TextInputType.number,
                        ),

                        // HRV
                        _buildTextField(
                          controller: _hrvController,
                          label: 'Frecuencia cardíaca / HRV inicial',
                          icon: Icons.favorite,
                          keyboardType: TextInputType.number,
                        ),

                        // Enfermedad
                        _buildTextField(
                          controller: _diseaseController,
                          label: 'Enfermedad',
                          icon: Icons.local_hospital,
                        ),

                        const SizedBox(height: 20),

                        // Imagen
                        Row(
                          children: [
                            _imageFile != null
                                ? CircleAvatar(
                                    radius: 35,
                                    backgroundImage: FileImage(_imageFile!),
                                  )
                                : const CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.teal,
                                    child: Icon(Icons.person,
                                        color: Colors.white),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Subir Fotografía'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.teal,
                                  side: const BorderSide(color: Colors.teal),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Consentimiento
                        SwitchListTile(
                          value: _consentGiven,
                          onChanged: (v) => setState(() => _consentGiven = v),
                          title: const Text(
                            'Autorizo el uso de mis datos biométricos con fines médicos y de seguimiento terapéutico',
                            style: TextStyle(fontSize: 14),
                          ),
                          activeColor: Colors.teal,
                        ),

                        const SizedBox(height: 20),

                        // Fecha automática
                        Text(
                          'Fecha de registro: ${DateTime.now().toLocal().toString().split(".").first}',
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          textAlign: TextAlign.right,
                        ),

                        const SizedBox(height: 30),

                        ElevatedButton.icon(
                          onPressed: _savePatient,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Guardar Paciente',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        validator: validator ??
            (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}
