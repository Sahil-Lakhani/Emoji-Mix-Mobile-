import 'dart:convert';
import 'package:http/http.dart' as http;

class EmojiService {
  static Future<List<String>> getPossibleEmojisForCombination(
      String inputEmoji) async {
    final url = Uri.parse(
        'http://192.168.0.153:3000/api/getPossibleEmojisForCombination');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emoji': inputEmoji}),
      );

      if (response.statusCode == 200) {
        return List<String>.from(
            jsonDecode(response.body)['possibleEmojis'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<String?> findValidEmojiCombo(
      String leftEmoji, String rightEmoji) async {
    final url = Uri.parse('http://192.168.0.153:3000/api/findValidEmojiCombo');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'leftEmoji': leftEmoji,
          'rightEmoji': rightEmoji,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
