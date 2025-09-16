import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/chat_models.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final UserService _userService = UserService();
  final _userCache = <int, UserObject>{};

  Future<UserObject?> _getCachedUser(int accountId) async {
    if (!_userCache.containsKey(accountId)) {
      final user = await _userService.getUserByAccountId(accountId);
      if (user != null) {
        _userCache[accountId] = user;
      }
    }
    return _userCache[accountId];
  }

  //  account ID for the current user.
  Future<int?> _getCurrentAccountId() async {
    final user = await _userService.getCurrentUser();
    return user.accountId;
  }

  Future<List<ChatSummary>> fetchChatSummaries() async {
    final accountId = await _getCurrentAccountId();
    if (accountId == null) return [];

    final enrollmentResponse = await _supabase
        .from('eventenrollment')
        .select('eventid')
        .eq('accountid', accountId);

    if (enrollmentResponse.isEmpty) return [];

    final eventIds =
    enrollmentResponse.map<int>((e) => e['eventid'] as int).toList();

    final chatResponse = await _supabase
        .from('chat')
        .select('chat_id, event:event_id(eventname, eventimageurl)')
        .inFilter('event_id', eventIds);

    final List<ChatSummary> summaries = [];
    for (final chatData in chatResponse) {
      final chatId = chatData['chat_id'];
      final eventData = chatData['event'] as Map<String, dynamic>?;

      if (eventData == null) continue;

      final lastMessageResponse = await _supabase
          .from('message')
          .select('messagecontent, createdat, attachment_id')
          .eq('chat_id', chatId)
          .order('createdat', ascending: false)
          .limit(1)
          .maybeSingle();

      summaries.add(ChatSummary(
        chatId: chatId,
        eventName: eventData['eventname'] ?? 'Untitled Event',
        eventImageUrl: eventData['eventimageurl'],
        lastMessage: lastMessageResponse == null
            ? 'No messages yet'
            : (lastMessageResponse['attachment_id'] != null
            ? '📷 Photo'
            : lastMessageResponse['messagecontent']),
        lastMessageTimestamp: lastMessageResponse == null
            ? DateTime.now()
            : DateTime.parse(lastMessageResponse['createdat']).toLocal(),
      ));
    }

    summaries.sort((a, b) =>
        b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));

    return summaries;
  }

  Stream<List<ChatMessage>> getMessagesStream(int chatId) {
    final controller = StreamController<List<ChatMessage>>.broadcast();

    Future<void> fetchInitialMessages() async {
      try {
        final response = await _supabase
            .from('message')
            .select('*, messageattachment:attachment_id(fileurl)')
            .eq('chat_id', chatId)
            .order('createdat', ascending: true);

        final messages = <ChatMessage>[];
        for (final map in response) {
          final author = await _getCachedUser(map['enrolledpersona']);
          messages.add(ChatMessage.fromMap(map, author: author));
        }
        controller.add(messages);
      } catch (e) {
        controller.addError(e);
      }
    }

    fetchInitialMessages();

    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchInitialMessages();
    });

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Future<void> sendMessage({required int chatId, required String text}) async {
    final accountId = await _getCurrentAccountId();
    if (accountId == null || text.trim().isEmpty) return;

    await _supabase.from('message').insert({
      'chat_id': chatId,
      'enrolledpersona': accountId,
      'messagecontent': text.trim(),
      'createdat': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> sendImage({required int chatId, required File imageFile}) async {
    final accountId = await _getCurrentAccountId();
    if (accountId == null) return;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      await _supabase.storage.from('chat-attachments').upload(fileName, imageFile);
      final imageUrl = _supabase.storage.from('chat-attachments').getPublicUrl(fileName);

      final attachmentResponse = await _supabase
          .from('messageattachment')
          .insert({'fileurl': imageUrl}).select('messageattachment_id')
          .single();
      final attachmentId = attachmentResponse['messageattachment_id'];

      await _supabase.from('message').insert({
        'chat_id': chatId,
        'enrolledpersona': accountId,
        'messagecontent': null,
        'attachment_id': attachmentId,
        'createdat': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      print("Error sending image: $e");
    }
  }
}
