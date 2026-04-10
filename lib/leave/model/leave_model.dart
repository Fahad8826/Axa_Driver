import 'package:intl/intl.dart';

class LeaveModel {
  final int? id;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? createdAt;

  LeaveModel({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] as int?,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': status,
    };
  }

  String get formattedStartDate {
    try {
      final date = DateTime.parse(startDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return startDate;
    }
  }

  String get formattedEndDate {
    try {
      final date = DateTime.parse(endDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return endDate;
    }
  }
}
