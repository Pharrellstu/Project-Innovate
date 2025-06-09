import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campuslink/services/chatpage_service.dart';
import 'package:campuslink/models/message.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final String title;

  const ChatPage({
    Key? key,
    required this.chatId,
    required this.title,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();

  late Future<List<MessageModel>> _futureMessages;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _futureMessages = ChatPageService.fetchMessages(widget.chatId);
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final uid = AuthGate.getCurrentUserId();
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send messages')),
      );
      return;
    }

    final user = await _userService.getCurrentUser();
    final personaId = user.accountId;
    if (personaId == null || personaId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to identify current user')),
      );
      return;
    }

    await ChatPageService.insertMessage(
      chatId: widget.chatId,
      enrolledPersonaId: personaId,
      messageContent: text,
      attachmentId: null,
    );

    _controller.clear();
    setState(_loadMessages);
  }

  Future<void> _sendImage() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final uid = AuthGate.getCurrentUserId();
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send images')),
      );
      return;
    }

    final user = await _userService.getCurrentUser();
    final personaId = user.accountId;
    if (personaId == null || personaId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to identify current user')),
      );
      return;
    }

    // TODO: if you implement attachments, upload to storage here and set attachmentId
    final int? attachmentId = null;

    await ChatPageService.insertMessage(
      chatId: widget.chatId,
      enrolledPersonaId: personaId,
      messageContent: '[Image: ${photo.name}]',
      attachmentId: attachmentId,
    );

    setState(_loadMessages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: widget.title),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<MessageModel>>(
              future: _futureMessages,
              builder: (context, msgSnap) {
                if (msgSnap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (msgSnap.hasError) {
                  return Center(child: Text('Error: ${msgSnap.error}'));
                }
                final messages = msgSnap.data ?? [];

                // We also need the current user's ID for alignment
                return FutureBuilder<UserObject>(
                  future: _userService.getCurrentUser(),
                  builder: (context, userSnap) {
                    final currentId = userSnap.data?.accountId;

                    if (userSnap.connectionState != ConnectionState.done) {
                      // Still loading user → just render messages as “other”
                      return _buildMessageList(messages, null);
                    }
                    return _buildMessageList(messages, currentId);
                  },
                );
              },
            ),
          ),
          _MessageInputBar(
            controller: _controller,
            onSend: _sendText,
            onCameraTap: _sendImage,
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildMessageList(List<MessageModel> messages, int? currentId) {
    if (messages.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final msg = messages[i];
        final isMe = (currentId != null) && (msg.enrolledPersonaId == currentId);
        final time = msg.createdAt != null
            ? TimeOfDay.fromDateTime(msg.createdAt!).format(context)
            : '';
        return _ChatBubble(text: msg.messageContent ?? '', time: time, isMe: isMe);
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const _ChatBubble({
    Key? key,
    required this.text,
    required this.time,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? Colors.blue[400] : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black87;
    final alignment = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    )
        : const BorderRadius.only(
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          if (!isMe) const SizedBox(width: 40),
          Flexible(
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                  ),
                  child: Text(text, style: TextStyle(color: textColor)),
                ),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCameraTap;

  const _MessageInputBar({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
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
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  GestureDetector(
                    onTap: onSend,
                    child: const Icon(Icons.send, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[700]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[700]),
            onPressed: onCameraTap,
          ),
          IconButton(
            icon: Icon(Icons.mic_none_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
