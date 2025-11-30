import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../db/database_helper.dart';

class SyncService {
  final db = DatabaseHelper.instance;
  final String? apiUrl = dotenv.env['API_URL'];

  Future<void> syncLocalPatientsToServer() async {
    try {
      final localPatients = await db.getPatients();
      if (localPatients.isEmpty) return;

      for (final patient in localPatients) {
        await _uploadPatientToServer(patient);
      }
    } catch (e) {
      print('❌ Error durante sincronización: $e');
    }
  }

  Future<void> _uploadPatientToServer(Map<String, dynamic> patient) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/patients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': patient['name'],
          'lastname': patient['lastname'],
          'age': patient['age'],
          'weight': patient['weight'],
          'heart_rate': patient['heart_rate'],  // 👈 ahora coincide con Prisma
          'disease': patient['disease'],
        }),
      );

      if (response.statusCode == 201) {
        print('✔ Paciente sincronizado con el servidor');
      } else {
        print('⚠ Error al subir paciente: ${response.body}');
      }
    } catch (e) {
      print('⚠ Sin conexión con el servidor, guardado offline');
    }
  }
}
