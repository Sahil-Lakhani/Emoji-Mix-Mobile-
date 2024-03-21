import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class EmojiSearchScreen extends StatefulWidget {
  const EmojiSearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmojiSearchScreenState createState() => _EmojiSearchScreenState();
}

class _EmojiSearchScreenState extends State<EmojiSearchScreen> {
  final TextEditingController _emojiController = TextEditingController();
  List<String> _emojis = [];

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
        setState(() {
          _emojis =
              List<String>.from(jsonDecode(response.body)['possibleEmojis']);
        });
        print(_emojis);
        print(_emojis.length);
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

  void printSelectedEmoji(String emoji) {
    print('Selected Emoji: $emoji');
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
              decoration: const InputDecoration(labelText: 'Enter Emoji'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _getPossibleEmojisForCombination,
              child: const Text('Search'),
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
                      onTap: () => printSelectedEmoji(_emojis[index]),
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
