class ExpenseModel {
  final int id;
  final int userId;
  final String userName;
  final String userRole;
  final String title;
  final String category;
  final String? department;
  final double amount;
  final DateTime expenseDate;
  final String? description;
  final String status; // PENDING_APPROVAL, RECEIPT_APPROVED, FUND_ALLOCATED, COMPLETED, REJECTED, etc.
  final String? rejectionReason;
  final int? approvedBy;
  final String? approvedByName;
  final String? approvedByRole;
  final List<ExpenseDocument>? documents;
  final int? managerId;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.title,
    required this.category,
    this.department,
    required this.amount,
    required this.expenseDate,
    this.description,
    required this.status,
    this.rejectionReason,
    this.approvedBy,
    this.approvedByName,
    this.approvedByRole,
    this.documents,
    this.managerId,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['full_name'] ?? '',
      userRole: json['user_role'] ?? '',
      title: json['title'],
      category: json['category'],
      department: json['department'],
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      expenseDate: json['expense_date'] != null 
          ? DateTime.parse(json['expense_date']) 
          : DateTime.now(),
      description: json['description'],
      status: json['status'] ?? 'PENDING',
      rejectionReason: json['rejection_reason'],
      approvedBy: json['approved_by'],
      approvedByName: json['approved_by_name'],
      approvedByRole: json['approved_by_role'],
      documents: json['documents'] != null 
          ? (json['documents'] as List).map((i) => ExpenseDocument.fromJson(i)).toList()
          : (json['document_path'] != null 
              ? [ExpenseDocument(
                  id: 0, 
                  documentPath: json['document_path'], 
                  originalFilename: 'Attachment', 
                  fileType: 'image/jpeg'
                )] 
              : null),
      managerId: json['manager_id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'title': title,
      'category': category,
      'department': department,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String(),
      'description': description,
      'status': status,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'approvedByName': approvedByName,
      'approvedByRole': approvedByRole,
      'managerId': managerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ExpenseDocument {
  final int id;
  final String documentPath;
  final String originalFilename;
  final String fileType;

  ExpenseDocument({
    required this.id,
    required this.documentPath,
    required this.originalFilename,
    required this.fileType,
  });

  factory ExpenseDocument.fromJson(Map<String, dynamic> json) {
    return ExpenseDocument(
      id: json['id'],
      documentPath: json['document_path'],
      originalFilename: json['original_filename'],
      fileType: json['file_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_path': documentPath,
      'original_filename': originalFilename,
      'file_type': fileType,
    };
  }
}
