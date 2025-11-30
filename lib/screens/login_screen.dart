import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';

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
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Por favor, completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final db = DatabaseHelper.instance;
    final apiUrl = dotenv.env['API_URL'];

    try {
      // 🔹 PRIMERO: Intentar login con el servidor remoto (API)
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar / sincronizar usuario en SQLite
        await db.insertUser({
          'id': data['id'],
          'username': data['username'],
          'password': password,
          'role': data['role'] ?? 'user',
        });

        _goToHome(data['role'], data['id'], data['username']);
        return;
      } else {
        throw Exception('Credenciales incorrectas');
      }
    } catch (e) {
      // 🔸 SI FALLA EL SERVIDOR → MODO OFFLINE
      final user = await db.getUser(username, password);

      if (user != null) {
        _goToHome(user['role'], user['id'], user['username']);
      } else {
        setState(() {
          _errorText = 'Usuario o contraseña incorrectos';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToHome(String role, int id, String username) {
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'role': role, 'patientId': id, 'patientName': username},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00897B), Color(0xFF004D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.spa_rounded, color: Colors.white, size: 90),
                const SizedBox(height: 10),
                const Text(
                  'BioTherapys',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  color: Colors.white,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00695C),
                            ),
                          ),
                          const SizedBox(height: 25),
                          TextFormField(
                            controller: _userController,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (_errorText != null)
                            Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 25),
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.teal,
                                )
                              : ElevatedButton.icon(
                                  onPressed: _login,
                                  icon: const Icon(Icons.login),
                                  label: const Text('Entrar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00695C),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              '¿No tienes cuenta? Regístrate aquí',
                              style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
