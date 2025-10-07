import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/services/api_constants.dart';

class AuthService {
  static const String baseUrl = "$kBaseApiUrl/api/auth";

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = jsonDecode(response.body);
    if (data["token"] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", data["token"]);
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String phone,
    String language,
    String currency,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "phone": phone,
        "language": language,
        "currency": currency,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }
}
