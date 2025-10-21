// lib/services/ai_bot_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiBotService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> getResponse(String query) async {
    // --- TEMPORARY DEBUG STEP ---
    // This will print the key to your console.
    // REMOVE THIS LINE after we solve the problem.
    if (kDebugMode) {
      print("Using API Key: $_apiKey");
    }
    // ----------------------------

    if (_apiKey == null || _apiKey!.isEmpty) {
      return "Error: API key is missing. Check your .env file setup.";
    }

    // The corrected, confirmed URL
    final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey";
    final body = {
      "contents": [
        {
          "parts": [
            {"text": query}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        return text ?? "Sorry, I couldn't get a response. Please try again.";
      } else {
        // This will now print the body of the error response from Google
        return "Error: Failed to fetch response (Status code: ${response.statusCode})\nBody: ${response.body}";
      }
    } catch (e) {
      return "Error: An exception occurred - $e";
    }
  }
}