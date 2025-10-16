import 'base_audit_model.dart';

class CellCuttingAuditForm extends BaseAuditForm {
  // Cell cutting specific fields
  String cellType;
  String cellEfficiency;
  String cellDimensions;
  String busbarAlignment;
  String solderQuality;
  String visualInspection;
  String electricalOutput;
  String operatorName;
  String machineId;
  String batchNumber;
  String defectCount;
  String remarks;
  String passFailStatus;

  CellCuttingAuditForm({
    required String serialNumber,
    required String auditDate,
    required String shift,
    required String po,
    required String moduleType,
    required String createdAt,
    required String auditorName,
    required String verifiedBy,
    this.cellType = '',
    this.cellEfficiency = '',
    this.cellDimensions = '',
    this.busbarAlignment = '',
    this.solderQuality = '',
    this.visualInspection = '',
    this.electricalOutput = '',
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
         formType: 'cell_cutting',
       );

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = getCommonFields();

    // Add cell cutting specific fields
    data.addAll({
      'cellType': cellType,
      'cellEfficiency': cellEfficiency,
      'cellDimensions': cellDimensions,
      'busbarAlignment': busbarAlignment,
      'solderQuality': solderQuality,
      'visualInspection': visualInspection,
      'electricalOutput': electricalOutput,
      'operatorName': operatorName,
      'machineId': machineId,
      'batchNumber': batchNumber,
      'defectCount': defectCount,
      'remarks': remarks,
      'passFailStatus': passFailStatus,
    });

    return data;
  }

  // Factory constructor to create a CellCuttingAuditForm from a map
  factory CellCuttingAuditForm.fromMap(Map<String, dynamic> map) {
    // Add debug logging to see what data we're receiving
    print('🔍 Creating CellCuttingAuditForm from map: ${map.keys.toList()}');

    // Helper function to safely get string value
    String safeString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      final stringValue = value.toString();
      return stringValue == 'null' ? defaultValue : stringValue;
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
    final form = CellCuttingAuditForm(
      serialNumber: safeRequiredString(map['serialNumber']),
      auditDate: parseAuditDate(map['auditDate']),
      shift: safeRequiredString(map['shift']),
      po: safeRequiredString(map['po']),
      moduleType: safeRequiredString(map['moduleType']),
      createdAt: parseAuditDate(map['createdAt']),
      auditorName: safeRequiredString(map['auditorName']),
      verifiedBy: safeString(map['verifiedBy']),
      cellType: safeString(map['cellType']),
      cellEfficiency: safeString(map['cellEfficiency']),
      cellDimensions: safeString(map['cellDimensions']),
      busbarAlignment: safeString(map['busbarAlignment']),
      solderQuality: safeString(map['solderQuality']),
      visualInspection: safeString(map['visualInspection']),
      electricalOutput: safeString(map['electricalOutput']),
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
