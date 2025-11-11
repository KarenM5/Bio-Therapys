import 'package:flutter/material.dart';
import 'add_patient_screen.dart';
import 'view_patients_screen.dart';
import 'schedule_screen.dart';
import 'register_symptoms_screen.dart';
import 'book_appointment_screen.dart';
import 'view_symptoms_screen.dart';

class HomeScreen extends StatelessWidget {
  final String role;
  final int? patientId;
  final String? patientName;

  const HomeScreen({
    super.key,
    required this.role,
    this.patientId,
    this.patientName,
  });

  Widget _menuCard(BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.teal.shade700),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final isTerapeuta = role == 'terapeuta';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTerapeuta
            ? 'BioTherapys - Panel Terapeuta'
            : 'BioTherapys - Panel Paciente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            if (isTerapeuta) ...[
              _menuCard(context, 'Agregar Paciente', Icons.person_add, const AddPatientScreen()),
              _menuCard(context, 'Ver Pacientes', Icons.people, const ViewPatientsScreen()),
              _menuCard(context, 'Agenda', Icons.calendar_today, const ScheduleScreen()),
              _menuCard(context, 'Ver Síntomas', Icons.note, const ViewSymptomsScreen()),
            ] else if (patientId != null && patientName != null) ...[
              _menuCard(
                context,
                'Registrar Síntomas',
                Icons.note_add,
                RegisterSymptomsScreen(patientId: patientId!, patientName: patientName!),
              ),
              _menuCard(context, 'Agendar Cita', Icons.calendar_month, const BookAppointmentScreen()),
            ],
          ],
        ),
      ),
    );
  }
}
