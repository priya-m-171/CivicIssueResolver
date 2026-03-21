import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_constants.dart';

/// Uses the Gemini REST API directly via HTTP.
class AIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // Use gemini-2.5-flash — confirmed working with this API key
  static const String _modelName = 'gemini-2.5-flash';

  static Future<Map<String, String>?> analyzeImage(XFile imageFile) async {
    try {
      final apiKey = AppConstants.geminiApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        debugPrint('[AIService] No API key configured.');
        return null;
      }

      // Read image and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final mimeType = imageFile.name.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';

      debugPrint('[AIService] Image: ${imageBytes.length} bytes, $mimeType');

      final categoryList = AppConstants.categories.join(', ');

      final prompt =
          'Civic issue photo analysis. Pick ONE category from: [$categoryList]. Assign priority: low/medium/high/severe. Reply ONLY with JSON: {"category":"...","priority":"...","title":"max 10 words","description":"1 sentence"}. If not a civic issue use category Unknown.';

      final url = Uri.parse(
        '$_baseUrl/$_modelName:generateContent?key=$apiKey',
      );

      final requestBody = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {'mime_type': mimeType, 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1,
          'maxOutputTokens': 2048,
          'thinkingConfig': {'thinkingBudget': 0},
        },
      });

      debugPrint('[AIService] Calling $_modelName ...');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('[AIService] Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[AIService] Error body: ${response.body}');
        return null;
      }

      // Parse the API response
      final Map<String, dynamic> apiResponse = jsonDecode(response.body);

      // Extract the text from candidates
      final candidates = apiResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        debugPrint('[AIService] No candidates in response');
        debugPrint('[AIService] Full response: ${response.body}');
        return null;
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        debugPrint('[AIService] No parts in response');
        return null;
      }

      // Concatenate ALL non-thought text parts (model may split response across parts)
      final StringBuffer textBuffer = StringBuffer();
      for (final part in parts) {
        if (part is Map<String, dynamic> && part.containsKey('text')) {
          // Skip thinking/thought parts if present
          if (part.containsKey('thought') && part['thought'] == true) continue;
          textBuffer.write(part['text']?.toString() ?? '');
        }
      }
      String rawText = textBuffer.toString();

      debugPrint('[AIService] Raw text length: ${rawText.length}');
      // Log first 200 chars since debugPrint truncates
      debugPrint(
        '[AIService] Raw text start: ${rawText.substring(0, rawText.length > 200 ? 200 : rawText.length)}',
      );
      debugPrint(
        '[AIService] Raw text end: ${rawText.substring(rawText.length > 100 ? rawText.length - 100 : 0)}',
      );

      // Write full response to a log file for debugging
      try {
        final dir = await getApplicationDocumentsDirectory();
        final logFile = File('${dir.path}/ai_debug.txt');
        await logFile.writeAsString(
          'Response body length: ${response.body.length}\n'
          'Parts count: ${parts.length}\n'
          'RawText length: ${rawText.length}\n'
          'RawText: $rawText\n',
        );
        debugPrint('[AIService] Debug log saved to: ${logFile.path}');
      } catch (_) {}

      if (rawText.isEmpty) {
        debugPrint('[AIService] Empty text in response');
        return null;
      }

      // Clean markdown fences
      if (rawText.contains('```')) {
        rawText = rawText.replaceAll('```json', '').replaceAll('```', '');
      }
      rawText = rawText.trim();

      // Extract JSON
      final startIdx = rawText.indexOf('{');
      final endIdx = rawText.lastIndexOf('}');
      if (startIdx == -1 || endIdx == -1 || endIdx <= startIdx) {
        debugPrint('[AIService] Could not find JSON in: $rawText');
        return null;
      }

      final jsonStr = rawText.substring(startIdx, endIdx + 1);
      debugPrint('[AIService] JSON: $jsonStr');

      final Map<String, dynamic> parsed = jsonDecode(jsonStr);

      final category = (parsed['category']?.toString() ?? 'Unknown').trim();
      final priority = (parsed['priority']?.toString() ?? 'medium')
          .trim()
          .toLowerCase();
      final title = (parsed['title']?.toString() ?? '').trim();
      final description = (parsed['description']?.toString() ?? '').trim();

      debugPrint(
        '[AIService] Result -> category: $category | priority: $priority | title: $title',
      );

      return {
        'category': category,
        'priority': priority,
        'title': title,
        'description': description,
      };
    } catch (e, stackTrace) {
      debugPrint('[AIService] Error: $e');
      debugPrint('[AIService] Stack: $stackTrace');
      return null;
    }
  }
}
