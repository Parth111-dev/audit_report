import 'base_audit_model.dart';

class FramingAuditForm extends BaseAuditForm {
  // Framing specific fields
  String frameType;
  String frameMaterial;
  String frameDimensions;
  String cornerJointQuality;
  String sealantApplication;
  String frameFlatness;
  String mountingHoleAlignment;
  String groundingHoleQuality;
  String surfaceFinish;
  String visualInspection;
  String dimensionalAccuracy;
  String operatorName;
  String machineId;
  String batchNumber;
  String torqueReadings;
  String sealantBatchNumber;
  String defectCount;
  String remarks;
  String passFailStatus;

  FramingAuditForm({
    required String serialNumber,
    required String auditDate,
    required String shift,
    required String po,
    required String moduleType,
    required String createdAt,
    required String auditorName,
    required String verifiedBy,
    this.frameType = '',
    this.frameMaterial = '',
    this.frameDimensions = '',
    this.cornerJointQuality = '',
    this.sealantApplication = '',
    this.frameFlatness = '',
    this.mountingHoleAlignment = '',
    this.groundingHoleQuality = '',
    this.surfaceFinish = '',
    this.visualInspection = '',
    this.dimensionalAccuracy = '',
    this.operatorName = '',
    this.machineId = '',
    this.batchNumber = '',
    this.torqueReadings = '',
    this.sealantBatchNumber = '',
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
         formType: 'framing',
       );

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = getCommonFields();

    // Add framing specific fields
    data.addAll({
      'frameType': frameType,
      'frameMaterial': frameMaterial,
      'frameDimensions': frameDimensions,
      'cornerJointQuality': cornerJointQuality,
      'sealantApplication': sealantApplication,
      'frameFlatness': frameFlatness,
      'mountingHoleAlignment': mountingHoleAlignment,
      'groundingHoleQuality': groundingHoleQuality,
      'surfaceFinish': surfaceFinish,
      'visualInspection': visualInspection,
      'dimensionalAccuracy': dimensionalAccuracy,
      'operatorName': operatorName,
      'machineId': machineId,
      'batchNumber': batchNumber,
      'torqueReadings': torqueReadings,
      'sealantBatchNumber': sealantBatchNumber,
      'defectCount': defectCount,
      'remarks': remarks,
      'passFailStatus': passFailStatus,
    });

    return data;
  }

  // Factory constructor to create a FramingAuditForm from a map
  factory FramingAuditForm.fromMap(Map<String, dynamic> map) {
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

    return FramingAuditForm(
      serialNumber: safeRequiredString(map['serialNumber']),
      auditDate: parseAuditDate(map['auditDate']),
      shift: safeRequiredString(map['shift']),
      po: safeRequiredString(map['po']),
      moduleType: safeRequiredString(map['moduleType']),
      createdAt: parseAuditDate(map['createdAt']),
      auditorName: safeRequiredString(map['auditorName']),
      verifiedBy: safeString(map['verifiedBy']),
      frameType: safeString(map['frameType']),
      frameMaterial: safeString(map['frameMaterial']),
      frameDimensions: safeString(map['frameDimensions']),
      cornerJointQuality: safeString(map['cornerJointQuality']),
      sealantApplication: safeString(map['sealantApplication']),
      frameFlatness: safeString(map['frameFlatness']),
      mountingHoleAlignment: safeString(map['mountingHoleAlignment']),
      groundingHoleQuality: safeString(map['groundingHoleQuality']),
      surfaceFinish: safeString(map['surfaceFinish']),
      visualInspection: safeString(map['visualInspection']),
      dimensionalAccuracy: safeString(map['dimensionalAccuracy']),
      operatorName: safeString(map['operatorName']),
      machineId: safeString(map['machineId']),
      batchNumber: safeString(map['batchNumber']),
      torqueReadings: safeString(map['torqueReadings']),
      sealantBatchNumber: safeString(map['sealantBatchNumber']),
      defectCount: safeString(map['defectCount']),
      remarks: safeString(map['remarks']),
      passFailStatus: safeString(map['passFailStatus']),
    );
  }
}
