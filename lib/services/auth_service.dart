import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:4000"; // Cambiar si usas celular real

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await storage.write(key: "token", value: data["token"]);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }
}
