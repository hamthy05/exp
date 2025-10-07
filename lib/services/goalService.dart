import 'dart:convert';
import 'package:http/http.dart' as http;
import 'authService.dart';
import 'package:flutter_app/services/api_constants.dart';

class GoalService {
  static const String baseUrl = '$kBaseApiUrl/api/goals';

  static Future<List<dynamic>> getGoals() async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> createGoal(Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateGoal(String id, Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteGoal(String id) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
