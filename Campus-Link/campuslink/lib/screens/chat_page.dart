import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String title = "Pub Quiz";

  // In‐memory list of messages
  final List<_Message> _messages = [
    _Message(text: 'Hey I would be 5 min late', time: '8:11 PM', isMe: false),
    _Message(text: 'No problem', time: '8:11 PM', isMe: true),
  ];

  // Controller for the text input
  final TextEditingController _controller = TextEditingController();
  // ImagePicker instance to open camera
  final ImagePicker _picker = ImagePicker();

  // Sends a text message
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final formattedTime = now.format(context);

    setState(() {
      _messages.add(
        _Message(text: text, time: formattedTime, isMe: true),
      );
    });

    _controller.clear();
  }

  // Opens the camera, captures an image, and adds a placeholder message
  void _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final now = TimeOfDay.now();
      final formattedTime = now.format(context);

      setState(() {
        // For now, we add a placeholder text indicating an image was captured.
        // You can later replace this with an Image widget in the chat bubble.
        _messages.add(
          _Message(
            text: "[Image captured: ${photo.name}]",
            time: formattedTime,
            isMe: true,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title),
      body: Column(
        children: [
          // List of chat bubbles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(
                  text: msg.text,
                  time: msg.time,
                  isMe: msg.isMe,
                );
              },
            ),
          ),

          // Input bar with send & camera functionality
          _MessageInputBar(
            controller: _controller,
            onSend: _sendMessage,
            onCameraTap: _openCamera,
          ),
        ],
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}

/// Simple message model
class _Message {
  final String text;
  final String time;
  final bool isMe;

  _Message({required this.text, required this.time, required this.isMe});
}

/// A single chat bubble. If [isMe] is true, it’s right-aligned and blue; otherwise left-aligned and gray.
class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? Colors.blue[400] : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black87;

    final rowAlignment = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final columnAlignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final borderRadius = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: rowAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If it’s someone else’s message, show an avatar
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[400],
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],

          Column(
            crossAxisAlignment: columnAlignment,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: borderRadius,
                ),
                child: Text(
                  text,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(
                  left: isMe ? 0 : 44, // shift right if there was an avatar
                  right: isMe ? 8 : 0,
                ),
                child: Text(
                  time,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),

          // If it’s “my” message, leave empty space where avatar would be
          if (isMe) SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// The bottom input bar with emoji, text field, attach, camera, mic icons.
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onCameraTap;

  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          // Emoji button (no action yet)
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),

          // Text input with send icon
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  GestureDetector(
                    onTap: onSend,
                    child: Icon(Icons.send, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Attach/file button (no action yet)
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[700]),
            onPressed: () {},
          ),

          // Camera button
          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[700]),
            onPressed: onCameraTap,
          ),

          // Mic (voice) button (no action yet)
          IconButton(
            icon: Icon(Icons.mic_none_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
