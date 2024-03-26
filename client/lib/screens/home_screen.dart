import 'package:flutter/material.dart';
import '/services/emoji_service.dart';

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

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _getPossibleEmojisForCombination() async {
    final emojis = await EmojiService.getPossibleEmojisForCombination(
        _emojiController.text);
    setState(() {
      _emojis = emojis;
    });
  }

  Future<void> _findValidEmojiCombo() async {
    if (_emojis.isNotEmpty &&
        _emojiController.text.isNotEmpty &&
        _selectedEmoji != null) {
      final imageUrl = await EmojiService.findValidEmojiCombo(
          _emojiController.text, _selectedEmoji!);
      setState(() {
        _imageUrl = imageUrl;
      });
    }
  }

  // void printSelectedEmoji(String emoji) {
  //   print('leftEmoji: ${_emojiController.text}, rightEmoji: $emoji');
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emoji Search'),
        ),
         body: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emojiController,
                  style: const TextStyle(fontSize: 22),
                  decoration: const InputDecoration(
                    labelText: 'Enter Emoji',
                  ),
                  focusNode: _focusNode,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _focusNode.unfocus();
                    _getPossibleEmojisForCombination();
                  },
                  child: const Text('Search', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Left Emoji: ${_emojiController.text}',
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 20),
                      Text('Right Emoji: ${_selectedEmoji ?? " "}',
                          style: const TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _focusNode.unfocus();
                    _findValidEmojiCombo();
                  },
                  child: const Text('Generate', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20.0),
                if (_imageUrl != null)
                  Image.network(
                    _imageUrl!,
                    height: 120,
                  ),
                const SizedBox(height: 20.0),
                Text(
                  'Available Emojis for Combinations: ${_emojis.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                        },
                        child: Center(
                          child: Text(_emojis[index]),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
