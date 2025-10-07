import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/api_constants.dart';

class CategoryService {
  static const String baseUrl = '$kBaseApiUrl/api/categories';

  // Get all categories
  static Future<List<dynamic>> getCategories(
    String token, {
    required bool isExpense,
  }) async {
    final response = await http
        .get(Uri.parse(baseUrl), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10)); // Add timeout here
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Add category
  static Future<Map<String, dynamic>> addCategory(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add category');
    }
  }

  // Update category
  static Future<Map<String, dynamic>> updateCategory(
    String token,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update category');
    }
  }

  // Delete category
  static Future<void> deleteCategory(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }
}
