import 'base_audit_model.dart';

class SheetCuttingAuditForm extends BaseAuditForm {
  // Sheet cutting specific fields
  String materialType;
  String sheetThickness;
  String cutDimensions;
  String edgeQuality;
  String surfaceFinish;
  String cutAccuracy;
  String operatorName;
  String machineId;
  String batchNumber;
  String defectCount;
  String remarks;
  String passFailStatus;

  SheetCuttingAuditForm({
    required String serialNumber,
    required String auditDate,
    required String shift,
    required String po,
    required String moduleType,
    required String createdAt,
    required String auditorName,
    required String verifiedBy,
    this.materialType = '',
    this.sheetThickness = '',
    this.cutDimensions = '',
    this.edgeQuality = '',
    this.surfaceFinish = '',
    this.cutAccuracy = '',
    this.operatorName = '',
    this.machineId = '',
    this.batchNumber = '',
    this.defectCount = '',
    this.remarks = '',
    this.passFailStatus = '',
  }) : super(
         serialNumber: serialNumber,
         auditDate: auditDate,
         shift: shift,
         po: po,
         moduleType: moduleType,
         createdAt: createdAt,
         auditorName: auditorName,
         verifiedBy: verifiedBy,
         formType: 'sheet_cutting',
       );

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = getCommonFields();

    // Add sheet cutting specific fields
    data.addAll({
      'materialType': materialType,
      'sheetThickness': sheetThickness,
      'cutDimensions': cutDimensions,
      'edgeQuality': edgeQuality,
      'surfaceFinish': surfaceFinish,
      'cutAccuracy': cutAccuracy,
      'operatorName': operatorName,
      'machineId': machineId,
      'batchNumber': batchNumber,
      'defectCount': defectCount,
      'remarks': remarks,
      'passFailStatus': passFailStatus,
    });

    return data;
  }

  // Factory constructor to create a SheetCuttingAuditForm from a map
  factory SheetCuttingAuditForm.fromMap(Map<String, dynamic> map) {
    // Add debug logging to see what data we're receiving
    print('🔍 Creating SheetCuttingAuditForm from map: ${map.keys.toList()}');

    // Helper function to safely get string value
    String safeString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      final stringValue = value.toString();
      return stringValue;
    }

    String safeRequiredString(dynamic value, [String defaultValue = 'N/A']) {
      final result = safeString(value, defaultValue);
      return result.isEmpty ? defaultValue : result;
    }

    // Extract the ID from the map
    dynamic id;
    if (map.containsKey('_id')) {
      id = map['_id'];
    }

    // Create the form with the ID
    final form = SheetCuttingAuditForm(
      serialNumber: safeRequiredString(map['serialNumber']),
      auditDate: parseAuditDate(map['auditDate']),
      shift: safeRequiredString(map['shift']),
      po: safeRequiredString(map['po']),
      moduleType: safeRequiredString(map['moduleType']),
      createdAt: parseAuditDate(map['createdAt']),
      auditorName: safeRequiredString(map['auditorName']),
      verifiedBy: safeString(map['verifiedBy']),
      materialType: safeString(map['materialType']),
      sheetThickness: safeString(map['sheetThickness']),
      cutDimensions: safeString(map['cutDimensions']),
      edgeQuality: safeString(map['edgeQuality']),
      surfaceFinish: safeString(map['surfaceFinish']),
      cutAccuracy: safeString(map['cutAccuracy']),
      operatorName: safeString(map['operatorName']),
      machineId: safeString(map['machineId']),
      batchNumber: safeString(map['batchNumber']),
      defectCount: safeString(map['defectCount']),
      remarks: safeString(map['remarks']),
      passFailStatus: safeString(map['passFailStatus']),
    );

    // Set the ID after creation
    form.id = id;

    return form;
  }
}
