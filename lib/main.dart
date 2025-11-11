import 'package:flutter/material.dart';
import 'screens/role_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_symptoms_screen.dart';
import 'screens/book_appointment_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/view_patients_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/view_symptoms_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioTherapys Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Poppins', // 🔹 Fuente del estilo nuevo
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/role': (context) => const RoleSelectionScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map;
          return HomeScreen(
            role: args['role'],
            patientId: args['patientId'],
            patientName: args['patientName'],
          );
        },
        '/registerSymptoms': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map;
          return RegisterSymptomsScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
          );
        },
        '/bookAppointment': (context) => const BookAppointmentScreen(),
        '/addPatient': (context) => const AddPatientScreen(),
        '/viewPatients': (context) => const ViewPatientsScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/viewSymptoms': (context) => const ViewSymptomsScreen(),
      },
    );
  }
}

// ------------------- LOGIN -------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? _errorText;

  void _login() {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    // Login de ejemplo: admin/admin
    if (user == 'admin' && pass == 'admin') {
      Navigator.pushReplacementNamed(context, '/role');
    } else {
      setState(() {
        _errorText = 'Usuario o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00897B),
              Color(0xFF004D40),
            ], // 🔹 Gradiente estilo nuevo
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌿 Logo del estilo nuevo
                const Icon(Icons.spa_rounded, color: Colors.white, size: 90),
                const SizedBox(height: 10),
                const Text(
                  'BioTherapys',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // 💠 Tarjeta del formulario estilo nuevo
                Card(
                  color: Colors.white,
                  elevation: 12,
                  shadowColor: Colors.teal.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00695C),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _userController,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (_errorText != null)
                            Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.login),
                              label: const Text(
                                'Entrar',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 🌿 Pie decorativo estilo nuevo
                const Text(
                  'Salud y bienestar a un clic de distancia 🌱',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
