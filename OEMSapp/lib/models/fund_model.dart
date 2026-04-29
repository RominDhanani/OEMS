class FundModel {
  final int id;
  final int fromUserId;
  final String fromUserName;
  final int toUserId;
  final String toUserName;
  final double amount;
  final String paymentMode; // CASH, CHEQUE, UPI, BANK_TRANSFER
  final String status; // ALLOCATED, RECEIVED, COMPLETED, REJECTED
  final String? description;
  final String? rejectionReason;
  // Cheque details
  final String? chequeNumber;
  final String? bankName;
  final DateTime? chequeDate;
  final String? accountHolderName;
  // Online payment details
  final String? upiId;
  final String? transactionId;
  
  final int? expansionId;
  final String? chequeImagePath;
  final DateTime createdAt;
  final DateTime? receivedAt;
  final DateTime? allocatedAt;

  FundModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    required this.paymentMode,
    required this.status,
    this.description,
    this.rejectionReason,
    this.chequeNumber,
    this.bankName,
    this.chequeDate,
    this.accountHolderName,
    this.upiId,
    this.transactionId,
    this.expansionId,
    this.chequeImagePath,
    required this.createdAt,
    this.receivedAt,
    this.allocatedAt,
  });

  factory FundModel.fromJson(Map<String, dynamic> json) {
    return FundModel(
      id: json['id'],
      fromUserId: json['from_user_id'],
      fromUserName: json['from_user_name'] ?? '',
      toUserId: json['to_user_id'],
      toUserName: json['to_user_name'] ?? '',
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      paymentMode: json['payment_mode'] ?? 'CASH',
      status: json['status'] ?? 'ALLOCATED',
      description: json['description'],
      rejectionReason: json['rejection_reason'],
      chequeNumber: json['cheque_number'],
      bankName: json['bank_name'],
      chequeDate: json['cheque_date'] != null ? DateTime.parse(json['cheque_date']) : null,
      accountHolderName: json['account_holder_name'],
      upiId: json['upi_id'],
      transactionId: json['transaction_id'],
      expansionId: json['expansion_id'],
      chequeImagePath: json['cheque_image_path'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      receivedAt: json['received_at'] != null ? DateTime.parse(json['received_at']) : null,
      allocatedAt: json['allocated_at'] != null ? DateTime.parse(json['allocated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'amount': amount,
      'paymentMode': paymentMode,
      'status': status,
      'description': description,
      'rejectionReason': rejectionReason,
      'chequeNumber': chequeNumber,
      'bankName': bankName,
      'chequeDate': chequeDate?.toIso8601String(),
      'accountHolderName': accountHolderName,
      'upiId': upiId,
      'transactionId': transactionId,
      'expansionId': expansionId,
      'chequeImagePath': chequeImagePath,
      'createdAt': createdAt.toIso8601String(),
      'receivedAt': receivedAt?.toIso8601String(),
      'allocatedAt': allocatedAt?.toIso8601String(),
    };
  }
}
