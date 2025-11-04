
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class ViewPatientsScreen extends StatefulWidget {
  const ViewPatientsScreen({super.key});

  @override
  State<ViewPatientsScreen> createState() => _ViewPatientsScreenState();
}

class _ViewPatientsScreenState extends State<ViewPatientsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final data = await DatabaseHelper.instance.getPatients();
      setState(() {
        _patients = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar pacientes: $e')),
        );
      }
    }
  }

  Future<void> _deletePatient(int id) async {
    try {
      await DatabaseHelper.instance.deletePatient(id);
      _loadPatients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente eliminado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar paciente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text(
          'Pacientes Registrados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _patients.isEmpty
              ? const Center(
                  child: Text(
                    'No hay pacientes registrados',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.teal.shade100),
                        columnSpacing: 24,
                        border: TableBorder.all(color: Colors.teal.shade100),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Edad')),
                          DataColumn(label: Text('Peso')),
                          DataColumn(label: Text('Frecuencia')),
                          DataColumn(label: Text('Enfermedad')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: _patients.map((patient) {
                          return DataRow(
                            cells: [
                              DataCell(Text(patient['id'].toString())),
                              DataCell(Text(
                                  '${patient['name']} ${patient['lastname'] ?? ''}')),
                              DataCell(Text(patient['age']?.toString() ?? '-')),
                              DataCell(Text(
                                  patient['weight'] != null
                                      ? '${patient['weight']} kg'
                                      : '-')),
                              DataCell(Text(
                                  patient['hrv'] != null
                                      ? '${patient['hrv']} bpm'
                                      : '-')),
                              DataCell(Text(patient['disease'] ?? 'N/A')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.folder_open,
                                        color: Colors.blueAccent),
                                    tooltip: 'Ver expediente',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PatientDetailScreen(
                                            patient: patient,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    tooltip: 'Eliminar paciente',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          title: const Text('Confirmar eliminación'),
                                          content: const Text(
                                              '¿Deseas eliminar este paciente?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        _deletePatient(patient['id'] as int);
                                      }
                                    },
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Agregar Paciente'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          );
          _loadPatients();
        },
      ),
    );
  }
}
