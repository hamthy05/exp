import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/authService.dart';
import 'package:flutter_app/services/api_constants.dart';

class TransactionService {
  static const String baseUrl = '$kBaseApiUrl/api/transactions';

  static Future<bool> createTransaction(
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
    return response.statusCode == 201;
  }

  // --- ADD THIS METHOD ---
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Convert date string to DateTime object for each transaction
      return data.map<Map<String, dynamic>>((tx) {
        final txMap = Map<String, dynamic>.from(tx);
        if (txMap['date'] is String) {
          txMap['date'] = DateTime.parse(txMap['date']);
        }
        return txMap;
      }).toList();
    } else {
      return [];
    }
  }

  // Fetch Single Transaction by ID
  static Future<Map<String, dynamic>?> getTransactionById(String id) async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      data['date'] = DateTime.parse(data['date']);
      return data;
    }
    return null;
  }

  // Update Transaction
  static Future<bool> updateTransaction(
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
    return response.statusCode == 200;
  }

  // Delete Transaction
  static Future<bool> deleteTransaction(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
