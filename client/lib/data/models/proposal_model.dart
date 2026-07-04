import 'user_model.dart';

class AttachmentModel {
  final String id;
  final String url;
  final String fileName;
  final String fileType;
  final String category;
  final DateTime? uploadedAt;

  AttachmentModel({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.category,
    this.uploadedAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['_id']?.toString() ?? '',
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      category: json['category'] ?? 'other',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString())
          : null,
    );
  }
}

class BillModel {
  final String id;
  final String url;
  final String fileName;
  final String fileType;
  final double amount;
  final String verificationStatus;
  final String? verificationNote;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;

  BillModel({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.amount,
    required this.verificationStatus,
    this.verificationNote,
    this.uploadedAt,
    this.verifiedAt,
  });

  bool get isPending => verificationStatus == 'Pending';
  bool get isVerified => verificationStatus == 'Verified';
  bool get needsCorrection => verificationStatus == 'Need Correction';
  bool get isCompleted => verificationStatus == 'Completed';

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['_id']?.toString() ?? '',
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      verificationStatus: json['verificationStatus'] ?? 'Pending',
      verificationNote: json['verificationNote'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString())
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'].toString())
          : null,
    );
  }
}

class ProposalModel {
  final String id;
  final String title;
  final String department;
  final String eventName;
  final String purpose;
  final String description;
  final double requestedBudget;
  final double? approvedBudget;
  final double actualExpense;
  final String priority;
  final DateTime requiredDate;
  final String? notes;
  final List<AttachmentModel> attachments;
  final List<BillModel> bills;
  final String status;
  final String? rejectionReason;
  final UserModel? createdBy;
  final UserModel? reviewedBy;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProposalModel({
    required this.id,
    required this.title,
    required this.department,
    required this.eventName,
    required this.purpose,
    required this.description,
    required this.requestedBudget,
    this.approvedBudget,
    required this.actualExpense,
    required this.priority,
    required this.requiredDate,
    this.notes,
    required this.attachments,
    required this.bills,
    required this.status,
    this.rejectionReason,
    this.createdBy,
    this.reviewedBy,
    this.submittedAt,
    this.approvedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  double? get remainingBudget {
    if (approvedBudget == null) return null;
    return approvedBudget! - actualExpense;
  }

  bool get isOverBudget {
    if (remainingBudget == null) return false;
    return remainingBudget! < 0;
  }

  bool get isDraft => status == 'Draft';
  bool get isSubmitted => status == 'Submitted';
  bool get isUnderReview => status == 'Under Review';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
  bool get isResubmitted => status == 'Resubmitted';
  bool get isWaitingForBills => status == 'Waiting for Bills';
  bool get isCompleted => status == 'Completed';

  bool get isEditable => isDraft || isRejected;
  bool get canSubmit => isDraft || isRejected;

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      department: json['department'] ?? '',
      eventName: json['eventName'] ?? '',
      purpose: json['purpose'] ?? '',
      description: json['description'] ?? '',
      requestedBudget: (json['requestedBudget'] ?? 0).toDouble(),
      approvedBudget: json['approvedBudget'] != null
          ? (json['approvedBudget']).toDouble()
          : null,
      actualExpense: (json['actualExpense'] ?? 0).toDouble(),
      priority: json['priority'] ?? '',
      requiredDate: DateTime.tryParse(json['requiredDate']?.toString() ?? '') ??
          DateTime.now(),
      notes: json['notes'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => AttachmentModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      bills: (json['bills'] as List<dynamic>?)
              ?.map((b) => BillModel.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] ?? 'Draft',
      rejectionReason: json['rejectionReason'],
      createdBy: json['createdBy'] is Map
          ? UserModel.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      reviewedBy: json['reviewedBy'] is Map
          ? UserModel.fromJson(json['reviewedBy'] as Map<String, dynamic>)
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
