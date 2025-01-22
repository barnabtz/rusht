class ChatMessageModel {
  final String id;
  final String bookingId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String status;
  final String? error;

  const ChatMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.status = 'sent',
    this.error,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'sent',
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'error': error,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? bookingId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    String? status,
    String? error,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ChatMessageModel &&
      other.id == id &&
      other.bookingId == bookingId &&
      other.senderId == senderId &&
      other.content == content &&
      other.createdAt == createdAt &&
      other.status == status &&
      other.error == error;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      bookingId.hashCode ^
      senderId.hashCode ^
      content.hashCode ^
      createdAt.hashCode ^
      status.hashCode ^
      error.hashCode;
  }
}
