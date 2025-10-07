import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'authService.dart';
import 'package:flutter_app/services/api_constants.dart';

Future<void> exportDataFromBackend(BuildContext context, String format) async {
  try {
    final token = await AuthService.getToken(); // Your auth token logic
    final url = '$kBaseApiUrl/api/backup/export?format=$format';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      if (kIsWeb) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "export.$format")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile: save to file using path_provider + open_file (implement as needed)
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported as $format!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed!'), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export error!'), backgroundColor: Colors.red),
    );
  }
}
