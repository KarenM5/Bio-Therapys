import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🔹 Importa dotenv
import 'screens/login_screen.dart';
import 'screens/register_user_screen.dart';
import 'screens/role_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_symptoms_screen.dart';
import 'screens/book_appointment_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/view_patients_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/view_symptoms_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Cargar las variables de entorno (.env)
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioTherapys',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterUserScreen(),
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
