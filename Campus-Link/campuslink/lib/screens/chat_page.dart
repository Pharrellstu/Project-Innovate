import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campuslink/models/chat_models.dart';
import 'package:campuslink/services/chat_service.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/widgets/chat_bubble.dart';
import 'package:campuslink/widgets/message_input_bar.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final String chatTitle;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatTitle,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  late Stream<List<ChatMessage>> _messagesStream;
  int? _currentAccountId;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.getMessagesStream(widget.chatId);
    _userService.getCurrentUser().then((user) {
      if (mounted) {
        setState(() {
          _currentAccountId = user.accountId;
        });
      }
    });
  }

  Future<void> _onSend(String text) async {
    await _chatService.sendMessage(chatId: widget.chatId, text: text);
  }

  Future<void> _onSendImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image slightly
    );

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _chatService.sendImage(chatId: widget.chatId, imageFile: imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _currentAccountId == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Be the first to say something!',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  reverse: false, // Set to true if you want newest messages at the bottom and list starts at the end
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.authorAccountId == _currentAccountId;
                    return ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          MessageInputBar(
            onSend: _onSend,
            onAttach: _onSendImage,
          ),
        ],
      ),
    );
  }
}
