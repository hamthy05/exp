import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/api_constants.dart';

class ReminderService {
  final String baseUrl = '$kBaseApiUrl/api/reminders';

  Future<List<dynamic>> getReminders(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reminders');
    }
  }

  Future<dynamic> createReminder(
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create reminder');
    }
  }

  Future<dynamic> updateReminder(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update reminder');
    }
  }

  Future<void> deleteReminder(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete reminder');
    }
  }
}
