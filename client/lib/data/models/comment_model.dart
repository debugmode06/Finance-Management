import 'user_model.dart';

class CommentModel {
  final String id;
  final String proposalId;
  final UserModel? author;
  final String authorRole;
  final String message;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.proposalId,
    this.author,
    required this.authorRole,
    required this.message,
    this.createdAt,
  });

  bool get isFinanceDirector => authorRole == 'finance_director';

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id']?.toString() ?? '',
      proposalId: json['proposalId']?.toString() ?? '',
      author: json['authorId'] is Map
          ? UserModel.fromJson(json['authorId'] as Map<String, dynamic>)
          : null,
      authorRole: json['authorRole'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? relatedProposalId;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.relatedProposalId,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedProposalId: json['relatedProposalId'] is Map
          ? (json['relatedProposalId'] as Map)['_id']?.toString()
          : json['relatedProposalId']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class ActivityLogModel {
  final String id;
  final String? proposalId;
  final UserModel? actor;
  final String actorRole;
  final String action;
  final Map<String, dynamic> metadata;
  final DateTime? timestamp;

  ActivityLogModel({
    required this.id,
    this.proposalId,
    this.actor,
    required this.actorRole,
    required this.action,
    required this.metadata,
    this.timestamp,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['_id']?.toString() ?? '',
      proposalId: json['proposalId']?.toString(),
      actor: json['actorId'] is Map
          ? UserModel.fromJson(json['actorId'] as Map<String, dynamic>)
          : null,
      actorRole: json['actorRole'] ?? '',
      action: json['action'] ?? '',
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }
}

class ProposalHistoryModel {
  final String id;
  final String proposalId;
  final String status;
  final UserModel? changedBy;
  final String? note;
  final DateTime? timestamp;

  ProposalHistoryModel({
    required this.id,
    required this.proposalId,
    required this.status,
    this.changedBy,
    this.note,
    this.timestamp,
  });

  factory ProposalHistoryModel.fromJson(Map<String, dynamic> json) {
    return ProposalHistoryModel(
      id: json['_id']?.toString() ?? '',
      proposalId: json['proposalId']?.toString() ?? '',
      status: json['status'] ?? '',
      changedBy: json['changedBy'] is Map
          ? UserModel.fromJson(json['changedBy'] as Map<String, dynamic>)
          : null,
      note: json['note'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }
}
