import 'base_audit_model.dart';
import 'sheet_cutting_audit_model.dart';
import 'cell_cutting_audit_model.dart';
import 'framing_audit_model.dart';

class AuditFormFactory {
  // Create an audit form based on the form type
  static BaseAuditForm createAuditForm(
    String formType,
    Map<String, dynamic> data,
  ) {
    switch (formType) {
      case 'sheet_cutting':
        return SheetCuttingAuditForm.fromjson(data);
      case 'cell_cutting':
        return CellCuttingAuditForm.fromMap(data);
      case 'framing':
        return FramingAuditForm.fromMap(data);
      default:
        throw Exception('Unknown form type: $formType');
    }
  }

  // Convert a map to the appropriate audit form type
  static BaseAuditForm fromMap(Map<String, dynamic> map) {
    final formType =
        map['formType'] as String? ??
        'sheet_cutting'; // Default to sheet_cutting if not specified
    return createAuditForm(formType, map);
  }

  // Get a new instance of an audit form with a generated serial number
  static BaseAuditForm getNewForm(String formType) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();

    switch (formType) {
      case 'sheet_cutting':
        return SheetCuttingAuditForm(
          serialNumber: 'SC-$timestamp',
          auditDate: now.toIso8601String(),
          shift: '',
          po: '',
          moduleType: '',
          createdAt: now.toIso8601String(),
          auditorName: '',
          verifiedBy: '',
        );
      case 'cell_cutting':
        return CellCuttingAuditForm(
          serialNumber: 'CC-$timestamp',
          auditDate: now.toIso8601String(),
          shift: '',
          po: '',
          moduleType: '',
          createdAt: now.toIso8601String(),
          auditorName: '',
          verifiedBy: '',
        );
      case 'framing':
        return FramingAuditForm(
          serialNumber: 'FR-$timestamp',
          auditDate: now.toIso8601String(),
          shift: '',
          po: '',
          moduleType: '',
          createdAt: now.toIso8601String(),
          auditorName: '',
          verifiedBy: '',
        );
      default:
        throw Exception('Unknown form type: $formType');
    }
  }
}
