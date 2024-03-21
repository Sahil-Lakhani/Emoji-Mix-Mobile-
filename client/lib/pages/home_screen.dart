import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmojiSearchScreen extends StatefulWidget {
  const EmojiSearchScreen({super.key});

  @override
  _EmojiSearchScreenState createState() => _EmojiSearchScreenState();
}

class _EmojiSearchScreenState extends State<EmojiSearchScreen> {
  final TextEditingController _emojiController = TextEditingController();
  List<String> _emojis = [];
  String? _imageUrl;
  String? _selectedEmoji;

  Future<void> _getPossibleEmojisForCombination() async {
    final url = Uri.parse(
        'http://192.168.0.153:3000/api/getPossibleEmojisForCombination');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emoji': _emojiController.text}),
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        setState(() {
          _emojis =
              List<String>.from(jsonDecode(response.body)['possibleEmojis']);
        });
        print(_emojis);
      } else {
        setState(() {
          _emojis = [];
        });
        print('Failed to fetch possible emojis: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _emojis = [];
      });
    }
  }

  Future<void> _findValidEmojiCombo() async {
    if (_emojis.isNotEmpty &&
        _emojiController.text.isNotEmpty &&
        _selectedEmoji != null) {
      final leftEmoji = _emojiController.text;
      final rightEmoji = _selectedEmoji!;

      final url =
          Uri.parse('http://192.168.0.153:3000/api/findValidEmojiCombo');
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
          print(response.statusCode);
          print(response.body);
          setState(() {
            _imageUrl = jsonDecode(response.body);
            print('Image URL: $_imageUrl');
          });
        } else {
          setState(() {
            _imageUrl = null;
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void printSelectedEmoji(String emoji) {
    var leftEmoji = _emojiController.text;
    var rightEmoji = emoji;
    print('leftEmoji: $leftEmoji');
    print('rightEmoji: $rightEmoji');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emojiController,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Enter Emoji',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _getPossibleEmojisForCombination,
              child: const Text('Search', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Left Emoji: ${_emojiController.text}',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 20),
                Text('Right Emoji: ${_selectedEmoji ?? "Not selected"}',
                    style: const TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              //call the findValidEmojiCombo function here
              onPressed: _findValidEmojiCombo,
              child: const Text(
                'Generate',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            if (_imageUrl != null)
              Image.network(
                _imageUrl!,
                height: 40,
                width: 30,
              ),
            const SizedBox(height: 20.0),
            Text(
              'Available Emojis for Combinations: ${_emojis.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  return GridTile(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = _emojis[index];
                        });
                        printSelectedEmoji(_emojis[index]);
                      },
                      child: Center(
                        child: Text(_emojis[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
