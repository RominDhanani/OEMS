import 'expense_model.dart';

class ExpansionModel {
  final int id;
  final int managerId;
  final String managerName;
  final double requestedAmount;
  final double? approvedAmount;
  final String justification;
  final String status; // PENDING, APPROVED, REJECTED, ALLOCATED
  final String? rejectionReason;
  final List<ExpenseDocument>? documents;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? chequeImagePath;

  ExpansionModel({
    required this.id,
    required this.managerId,
    required this.managerName,
    required this.requestedAmount,
    this.approvedAmount,
    required this.justification,
    required this.status,
    this.rejectionReason,
    this.documents,
    required this.requestedAt,
    this.approvedAt,
    this.chequeImagePath,
  });


  factory ExpansionModel.fromJson(Map<String, dynamic> json) {
    return ExpansionModel(
      id: json['id'],
      managerId: json['manager_id'],
      managerName: json['manager_name'] ?? '',
      requestedAmount: json['requested_amount'] != null 
          ? double.parse(json['requested_amount'].toString()) 
          : 0.0,
      approvedAmount: json['approved_amount'] != null 
          ? double.parse(json['approved_amount'].toString()) 
          : null,
      justification: json['justification'] ?? '',
      status: json['status'] ?? 'PENDING',
      rejectionReason: json['rejection_reason'],
      documents: json['documents'] != null 
          ? (json['documents'] as List).map((i) => ExpenseDocument.fromJson(Map<String, dynamic>.from(i))).toList()
          : null,
      requestedAt: json['requested_at'] != null 
          ? DateTime.parse(json['requested_at']) 
          : DateTime.now(),
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at']) 
          : null,
      chequeImagePath: json['cheque_image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'managerId': managerId,
      'managerName': managerName,
      'requestedAmount': requestedAmount,
      'approvedAmount': approvedAmount,
      'justification': justification,
      'status': status,
      'rejectionReason': rejectionReason,
      'documents': documents?.map((d) => d.toJson()).toList(),
      'requestedAt': requestedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'chequeImagePath': chequeImagePath,
    };
  }
}
