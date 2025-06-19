class MessageModel {
  final int messageId;
  final int? chatId;
  final int? enrolledPersonaId;
  final String? messageContent;
  final DateTime? createdAt;
  final int? attachmentId;
  final String? attachmentUrl;

  MessageModel({
    required this.messageId,
    this.chatId,
    this.enrolledPersonaId,
    this.messageContent,
    this.createdAt,
    this.attachmentId,
    this.attachmentUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> m) {
    return MessageModel(
      messageId:        m['message_id']       as int,
      chatId:           m['chat_id']          as int?,
      enrolledPersonaId:m['enrolledpersona']  as int?,
      messageContent:   m['messagecontent']   as String?,
      createdAt:        m['createdat']        != null
          ? DateTime.parse(m['createdat'] as String)
          : null,
      attachmentId:     m['attachment_id']    as int?,
      attachmentUrl:  (m['messageattachment'] != null)
          ? (m['messageattachment']['fileurl'] as String)
          : null,
    );
  }

  /// Use for insert/update payloads.
  Map<String, dynamic> toMap() {
    return {
      if (messageId != 0) 'message_id': messageId,
      'chat_id'         : chatId,
      'enrolledpersona' : enrolledPersonaId,
      'messagecontent'  : messageContent,
      'createdat'       : createdAt?.toIso8601String(),
      'attachment_id'   : attachmentId,
    };
  }
}
