import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

String parseMongoId(dynamic id) {
  if (id == null) return '';

  if (id is String) return id;

  if (id is ObjectId) return id.toString();

  if (id is Map<String, dynamic>) {
    // Handle extended JSON format: {"$oid": "hexstring"}
    if (id.containsKey('\$oid')) {
      return id['\$oid'] as String;
    }
    // Handle other map formats if needed
    return id.toString();
  }

  // Fallback for any other type
  return id.toString();
}

// Helper function to format date as DD/MM/YYYY localtime
String formatDateWithLocalTime() {
  final now = DateTime.now();
  final formatter = DateFormat('dd/MM/yyyy');
  return '${formatter.format(now)} localtime';
}

// Helper function to safely parse auditDate
String parseAuditDate(dynamic value) {
  try {
    if (value == null) return DateTime.now().toIso8601String();

    if (value is String) {
      if (value.isEmpty) return DateTime.now().toIso8601String();
      try {
        // Try to parse and format consistently
        DateTime.parse(value);
        return value;
      } catch (e) {
        // If parsing fails, return the original string if it's not empty
        return value.isNotEmpty ? value : DateTime.now().toIso8601String();
      }
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Map) {
      // Handle MongoDB extended JSON format for dates
      if (value.containsKey('\$date')) {
        final dateValue = value['\$date'];
        if (dateValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue).toIso8601String();
        } else if (dateValue is String) {
          return DateTime.parse(dateValue).toIso8601String();
        }
      }
    }

    // Fallback: convert to string or use current date
    final stringValue = value.toString();
    return stringValue.isNotEmpty && stringValue != 'null' ? stringValue : DateTime.now().toIso8601String();
  } catch (e) {
    print('⚠️ Error parsing date value: $value, error: $e');
    return DateTime.now().toIso8601String();
  }
}

// Base class for all audit forms
abstract class BaseAuditForm {
  dynamic id;
  String serialNumber;
  String auditDate;
  String auditorName;
  String verifiedBy;
  String shift;
  String po;
  String moduleType;
  String createdAt;
  String formType; // To identify the type of form: 'sheet_cutting', 'cell_cutting', 'framing'

  BaseAuditForm({
    this.id,
    required this.serialNumber,
    required this.auditDate,
    required this.auditorName,
    required this.verifiedBy,
    required this.shift,
    required this.po,
    required this.moduleType,
    required this.createdAt,
    required this.formType,
  });

  // Abstract method to be implemented by subclasses
  Map<String, dynamic> toMap();

  // Common fields map that all subclasses will include
  Map<String, dynamic> getCommonFields() {
    return {
      'serialNumber': serialNumber,
      'auditDate': auditDate,
      'shift': shift,
      'po': po,
      'moduleType': moduleType,
      'createdAt': createdAt,
      'auditorName': auditorName,
      'verifiedBy': verifiedBy,
      'formType': formType,
    };
  }
}
