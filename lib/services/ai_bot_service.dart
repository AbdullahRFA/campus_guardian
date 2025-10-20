// lib/services/ai_bot_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiBotService {
  // Get the API key from the environment file
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> getResponse(String query) async {
    if (_apiKey == null) {
      throw Exception("API key not found. Make sure you have a .env file.");
    }

    final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey";

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
        // Safely access the response text
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        return text ?? "Sorry, I couldn't get a response. Please try again.";
      } else {
        // Provide a more user-friendly error
        return "Error: Failed to fetch response (Status code: ${response.statusCode})";
      }
    } catch (e) {
      // Handle network or other exceptions
      return "Error: An exception occurred - $e";
    }
  }
}