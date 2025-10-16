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
  if (value == null) return '';

  if (value is String) {
    try {
      // Try to parse and format consistently
      DateTime.parse(value);
      return value;
    } catch (e) {
      return value;
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

  return value.toString();
}

class AuditForm {
  dynamic id;
  String serialNumber;
  String auditDate;
  String auditorName;
  String verifiedBy;
  String shift;
  String po;
  String moduleType;
  String createdAt;

  AuditForm({
    this.id,
    required this.serialNumber,
    required this.auditDate,
    required this.auditorName,
    required this.verifiedBy,
    required this.shift,
    required this.po,
    required this.moduleType,
    required this.createdAt,
  });

  // Stage 1: Floor
  String? preLamTempOb1;
  String? preLamTempOb2;
  String? preLamTempRemark;
  String? laminationTempOb1;
  String? laminationTempOb2;
  String? laminationTempRemark;
  String? preLamHumidityOb1;
  String? preLamHumidityOb2;
  String? preLamHumidityRemark;

  // Stage 2: Front Glass Loading
  String? glassMakeOb1;
  String? glassMakeOb2;
  String? glassMakeRemark;
  String? glassPalletNoOb1;
  String? glassPalletNoOb2;
  String? glassPalletNoRemark;
  String? glassSizeOb1;
  String? glassSizeOb2;
  String? glassSizeRemark;

  // Stage 3: Front side EVA Cutting
  String? evaMakeOb1;
  String? evaMakeOb2;
  String? evaMakeRemark;
  String? evaTypeOb1;
  String? evaTypeOb2;
  String? evaTypeRemark;
  String? evaRollNoOb1;
  String? evaRollNoOb2;
  String? evaRollNoRemark;
  String? evaExpiryDateOb1;
  String? evaExpiryDateOb2;
  String? evaExpiryDateRemark;
  String? evaSizeOb1;
  String? evaSizeOb2;
  String? evaSizeRemark;

  // Stage 4: Stringer
  String? cellMakeOb1;
  String? cellMakeOb2;
  String? cellMakeRemark;
  String? cellEfficiencyOb1;
  String? cellEfficiencyOb2;
  String? cellEfficiencyRemark;
  String? cellWattageOb1;
  String? cellWattageOb2;
  String? cellWattageRemark;
  String? cellSizeOb1;
  String? cellSizeOb2;
  String? cellSizeRemark;
  String? cellDefectsOb1;
  String? cellDefectsOb2;
  String? cellDefectsRemark;
  String? cleanlinessOb1;
  String? cleanlinessOb2;
  String? cleanlinessRemark;
  String? ribbonMakeOb1;
  String? ribbonMakeOb2;
  String? ribbonMakeRemark;
  String? ribbonSizeOb1;
  String? ribbonSizeOb2;
  String? ribbonSizeRemark;
  String? fluxMakeOb1;
  String? fluxMakeOb2;
  String? fluxMakeRemark;
  String? fluxTypeOb1;
  String? fluxTypeOb2;
  String? fluxTypeRemark;
  String? fluxExpiryDateOb1;
  String? fluxExpiryDateOb2;
  String? fluxExpiryDateRemark;
  String? solderingTempOb1;
  String? solderingTempOb2;
  String? solderingTempRemark;
  String? workingHeatersOb1;
  String? workingHeatersOb2;
  String? workingHeatersRemark;
  String? solderingPowerOb1;
  String? solderingPowerOb2;
  String? solderingPowerRemark;
  String? solderTimeOb1;
  String? solderTimeOb2;
  String? solderTimeRemark;
  String? ribbonAlignmentOb1;
  String? ribbonAlignmentOb2;
  String? ribbonAlignmentRemark;
  String? ribbonDimensionsOb1;
  String? ribbonDimensionsOb2;
  String? ribbonDimensionsRemark;
  String? cellToCellGapOb1;
  String? cellToCellGapOb2;
  String? cellToCellGapRemark;
  String? stringLengthOb1;
  String? stringLengthOb2;
  String? stringLengthRemark;
  String? peelTestResultOb1;
  String? peelTestResultOb2;
  String? peelTestResultRemark;
  String? elInspectionOb1;
  String? elInspectionOb2;
  String? elInspectionRemark;

  // Stage 5: Lay-up & Auto Bussing
  String? busbarMakeOb1;
  String? busbarMakeOb2;
  String? busbarMakeRemark;
  String? busbarSizeOb1;
  String? busbarSizeOb2;
  String? busbarSizeRemark;
  String? cellToBusbarDistanceOb1;
  String? cellToBusbarDistanceOb2;
  String? cellToBusbarDistanceRemark;
  String? stringToStringGapOb1;
  String? stringToStringGapOb2;
  String? stringToStringGapRemark;
  String? topSideGapOb1;
  String? topSideGapOb2;
  String? topSideGapRemark;
  String? middleSideGapOb1;
  String? middleSideGapOb2;
  String? middleSideGapRemark;
  String? bottomSideGapOb1;
  String? bottomSideGapOb2;
  String? bottomSideGapRemark;
  String? leftSideGapOb1;
  String? leftSideGapOb2;
  String? leftSideGapRemark;
  String? rightSideGapOb1;
  String? rightSideGapOb2;
  String? rightSideGapRemark;

  // Stage 6: Auto Tapping
  String? tapMakeOb1;
  String? tapMakeOb2;
  String? tapMakeRemark;
  String? tapPositionOb1;
  String? tapPositionOb2;
  String? tapPositionRemark;
  String? tapSizeOb1;
  String? tapSizeOb2;
  String? tapSizeRemark;

  // Stage 7: Rear side EVA Cutting
  String? rearEvaMakeOb1;
  String? rearEvaMakeOb2;
  String? rearEvaMakeRemark;
  String? rearEvaTypeOb1;
  String? rearEvaTypeOb2;
  String? rearEvaTypeRemark;
  String? rearEvaRollNoOb1;
  String? rearEvaRollNoOb2;
  String? rearEvaRollNoRemark;
  String? rearEvaExpiryDateOb1;
  String? rearEvaExpiryDateOb2;
  String? rearEvaExpiryDateRemark;
  String? rearEvaSizeOb1;
  String? rearEvaSizeOb2;
  String? rearEvaSizeRemark;

  // Stage 8: Rear Side Back Sheet/Glass
  String? backsheetMakeOb1;
  String? backsheetMakeOb2;
  String? backsheetMakeRemark;
  String? backsheetTypeOb1;
  String? backsheetTypeOb2;
  String? backsheetTypeRemark;
  String? backsheetRollNoOb1;
  String? backsheetRollNoOb2;
  String? backsheetRollNoRemark;
  String? backsheetDimensionsOb1;
  String? backsheetDimensionsOb2;
  String? backsheetDimensionsRemark;

  // Stage 9: Logo & Barcode Fixing
  String? logoPositionOkOb1;
  String? logoPositionOkOb2;
  String? logoPositionOkRemark;
  String? barcodePositionOkOb1;
  String? barcodePositionOkOb2;
  String? barcodePositionOkRemark;

  // Stage 10: Pre-EL Inspection
  String? preElSerialNoOb1;
  String? preElSerialNoOb2;
  String? preElSerialNoRemark;
  String? preElCurrentOb1;
  String? preElCurrentOb2;
  String? preElCurrentRemark;
  String? preElVoltageOb1;
  String? preElVoltageOb2;
  String? preElVoltageRemark;
  String? preElDefectsOb1;
  String? preElDefectsOb2;
  String? preElDefectsRemark;

  // Stage 11: Auto Edge Taping
  String? edgeTapingOkOb1;
  String? edgeTapingOkOb2;
  String? edgeTapingOkRemark;

  // Stage 12: Lamination Process
  String? laminatorNoOb1;
  String? laminatorNoOb2;
  String? laminatorNoRemark;
  String? laminationTempsCh01Ob1;
  String? laminationTempsCh01Ob2;
  String? laminationTempsCh02Ob1;
  String? laminationTempsCh02Ob2;
  String? laminationTempsCh03Ob1;
  String? laminationTempsCh03Ob2;
  String? laminationTempsRemark;
  String? vacuumTimesCh01Ob1;
  String? vacuumTimesCh01Ob2;
  String? vacuumTimesCh02Ob1;
  String? vacuumTimesCh02Ob2;
  String? vacuumTimesCh03Ob1;
  String? vacuumTimesCh03Ob2;
  String? vacuumTimesRemark;
  String? upperventOneCh01Ob1;
  String? upperventOneCh01Ob2;
  String? upperventOneCh02Ob1;
  String? upperventOneCh02Ob2;
  String? upperventOneCh03Ob1;
  String? upperventOneCh03Ob2;
  String? upperventOneRemark;
  String? laminationOneCh01Ob1;
  String? laminationOneCh01Ob2;
  String? laminationOneCh02Ob1;
  String? laminationOneCh02Ob2;
  String? laminationOneCh03Ob1;
  String? laminationOneCh03Ob2;
  String? laminationOneRemark;
  String? upperventSecCh01Ob1;
  String? upperventSecCh01Ob2;
  String? upperventSecCh02Ob1;
  String? upperventSecCh02Ob2;
  String? upperventSecCh03Ob1;
  String? upperventSecCh03Ob2;
  String? upperventSecRemark;
  String? laminationSecCh01Ob1;
  String? laminationSecCh01Ob2;
  String? laminationSecCh02Ob1;
  String? laminationSecCh02Ob2;
  String? laminationSecCh03Ob1;
  String? laminationSecCh03Ob2;
  String? laminationSecRemark;
  String? upperventThirdCh01Ob1;
  String? upperventThirdCh01Ob2;
  String? upperventThirdCh02Ob1;
  String? upperventThirdCh02Ob2;
  String? upperventThirdCh03Ob1;
  String? upperventThirdCh03Ob2;
  String? upperventThirdRemark;
  String? laminationThirdCh01Ob1;
  String? laminationThirdCh01Ob2;
  String? laminationThirdCh02Ob1;
  String? laminationThirdCh02Ob2;
  String? laminationThirdCh03Ob1;
  String? laminationThirdCh03Ob2;
  String? laminationThirdRemark;
  String? lowerVentTimeCh01Ob1;
  String? lowerVentTimeCh01Ob2;
  String? lowerVentTimeCh02Ob1;
  String? lowerVentTimeCh02Ob2;
  String? lowerVentTimeCh03Ob1;
  String? lowerVentTimeCh03Ob2;
  String? lowerVentTimeRemark;
  String? totalCycleTimeCh01Ob1;
  String? totalCycleTimeCh01Ob2;
  String? totalCycleTimeCh02Ob1;
  String? totalCycleTimeCh02Ob2;
  String? totalCycleTimeCh03Ob1;
  String? totalCycleTimeCh03Ob2;
  String? totalCycleTimeRemark;

  // Stage 13: Auto Edge Trimming
  String? trimmingOkOb1;
  String? trimmingOkOb2;
  String? trimmingOkRemark;

  // Stage 14: Framing Process
  String? frameSerialNoOb1;
  String? frameSerialNoOb2;
  String? frameSerialNoRemark;
  String? frameMakeOb1;
  String? frameMakeOb2;
  String? frameMakeRemark;
  String? cornerKeyMakeOb1;
  String? cornerKeyMakeOb2;
  String? cornerKeyMakeRemark;
  String? profileCutAngleOb1;
  String? profileCutAngleOb2;
  String? profileCutAngleRemark;
  String? frameLengthOb1;
  String? frameLengthOb2;
  String? frameLengthRemark;
  String? frameWidthOb1;
  String? frameWidthOb2;
  String? frameWidthRemark;
  String? frameHeightOb1;
  String? frameHeightOb2;
  String? frameHeightRemark;
  String? mountingHoleOb1;
  String? mountingHoleOb2;
  String? mountingHoleRemark;
  String? xPitchOb1;
  String? xPitchOb2;
  String? xPitchRemark;
  String? yPitchOb1;
  String? yPitchOb2;
  String? yPitchRemark;
  String? groundHoleDiaOb1;
  String? groundHoleDiaOb2;
  String? groundHoleDiaRemark;
  String? groundHoleDistanceOb1;
  String? groundHoleDistanceOb2;
  String? groundHoleDistanceRemark;
  String? drainHoleSizeOb1;
  String? drainHoleSizeOb2;
  String? drainHoleSizeRemark;
  String? drainHoleDistanceOb1;
  String? drainHoleDistanceOb2;
  String? drainHoleDistanceRemark;
  String? diagonalLengthOb1;
  String? diagonalLengthOb2;
  String? diagonalLengthRemark;
  String? sealantMakeOb1;
  String? sealantMakeOb2;
  String? sealantMakeRemark;
  String? sealantTypeOb1;
  String? sealantTypeOb2;
  String? sealantTypeRemark;
  String? sealantWeightOb1;
  String? sealantWeightOb2;
  String? sealantWeightRemark;
  String? scratchDentsOb1;
  String? scratchDentsOb2;
  String? scratchDentsRemark;
  String? frameDefectsOb1;
  String? frameDefectsOb2;
  String? frameDefectsRemark;

  // Stage 15: Junction Box Assembly
  String? jbSerialNoOb1;
  String? jbSerialNoOb2;
  String? jbSerialNoRemark;
  String? jbMakeOb1;
  String? jbMakeOb2;
  String? jbMakeRemark;
  String? jbTypeOb1;
  String? jbTypeOb2;
  String? jbTypeRemark;
  String? diodeModelOb1;
  String? diodeModelOb2;
  String? diodeModelRemark;
  String? jbPlacementOb1;
  String? jbPlacementOb2;
  String? jbPlacementRemark;
  String? jbSealantWeightsAOb1;
  String? jbSealantWeightsAOb2;
  String? jbSealantWeightsBOb1;
  String? jbSealantWeightsBOb2;
  String? jbSealantWeightsCOb1;
  String? jbSealantWeightsCOb2;
  String? jbSealantWeightsRemark;
  String? solderingQualityOb1;
  String? solderingQualityOb2;
  String? solderingQualityRemark;
  String? pottingSealantMakeOb1;
  String? pottingSealantMakeOb2;
  String? pottingSealantMakeRemark;
  String? pottingSealantTypeOb1;
  String? pottingSealantTypeOb2;
  String? pottingSealantTypeRemark;
  String? pottingSealantExpiryOb1;
  String? pottingSealantExpiryOb2;
  String? pottingSealantExpiryRemark;
  String? curingTimeOb1;
  String? curingTimeOb2;
  String? curingTimeRemark;
  String? pottingSealantWeightsAOb1;
  String? pottingSealantWeightsAOb2;
  String? pottingSealantWeightsBOb1;
  String? pottingSealantWeightsBOb2;
  String? pottingSealantWeightsCOb1;
  String? pottingSealantWeightsCOb2;
  String? pottingSealantWeightsRemark;
  String? pottingRatioAOb1;
  String? pottingRatioBOb1;
  String? pottingRatioOb1;
  String? pottingRatioAOb2;
  String? pottingRatioBOb2;
  String? pottingRatioOb2;
  String? pottingRatioRemark;
  String? cableLengthOb1;
  String? cableLengthOb2;
  String? cableLengthRemark;
  String? visualStatusOb1;
  String? visualStatusOb2;
  String? visualStatusRemark;

  // Stage 16: Curing Line
  String? curingTimeLineOb1;
  String? curingTimeLineOb2;
  String? curingTimeLineRemark;
  String? curingTempOb1;
  String? curingTempOb2;
  String? curingTempRemark;
  String? curingHumidityOb1;
  String? curingHumidityOb2;
  String? curingHumidityRemark;

  // Stage 17: Module Cleaning
  String? cleaningOkOb1;
  String? cleaningOkOb2;
  String? cleaningOkRemark;

  // Stage 18: Hi-Pot Testing
  String? hipotSerialNoOb1;
  String? hipotSerialNoOb2;
  String? hipotSerialNoRemark;
  String? dcwOb1;
  String? dcwOb2;
  String? dcwRemark;
  String? irOb1;
  String? irOb2;
  String? irRemark;
  String? groundContinuityOb1;
  String? groundContinuityOb2;
  String? groundContinuityRemark;

  // Stage 19: Post-EL Inspection
  String? postElSerialNoOb1;
  String? postElSerialNoOb2;
  String? postElSerialNoRemark;
  String? postElCurrentOb1;
  String? postElCurrentOb2;
  String? postElCurrentRemark;
  String? postElVoltageOb1;
  String? postElVoltageOb2;
  String? postElVoltageRemark;
  String? postElDefectsOb1;
  String? postElDefectsOb2;
  String? postElDefectsRemark;

  // Stage 20: Sun Simulator
  String? calibrationDateOb1;
  String? calibrationDateOb2;
  String? calibrationDateRemark;
  String? sunSerialNoOb1;
  String? sunSerialNoOb2;
  String? sunSerialNoRemark;
  String? modulePowerOb1;
  String? modulePowerOb2;
  String? modulePowerRemark;
  String? iscOb1;
  String? iscOb2;
  String? iscRemark;
  String? vocOb1;
  String? vocOb2;
  String? vocRemark;
  String? impOb1;
  String? impOb2;
  String? impRemark;
  String? vmpOb1;
  String? vmpOb2;
  String? vmpRemark;
  String? moduleTempOb1;
  String? moduleTempOb2;
  String? moduleTempRemark;
  String? fillFactorOb1;
  String? fillFactorOb2;
  String? fillFactorRemark;
  String? efficiencyOb1;
  String? efficiencyOb2;
  String? efficiencyRemark;
  String? ivCurveOkOb1;
  String? ivCurveOkOb2;
  String? ivCurveOkRemark;

  // Stage 21: FQC
  String? visualInspectionOb1;
  String? visualInspectionOb2;
  String? visualInspectionRemark;
  String? jbCoverFitmentOb1;
  String? jbCoverFitmentOb2;
  String? jbCoverFitmentRemark;
  String? labelPlacementOb1;
  String? labelPlacementOb2;
  String? labelPlacementRemark;
  String? fqcDefectsOb1;
  String? fqcDefectsOb2;
  String? fqcDefectsRemark;

  // Stage 22: Auto Sorter & Packing
  String? sortingStatusOb1;
  String? sortingStatusOb2;
  String? sortingStatusRemark;
  String? palletConditionOb1;
  String? palletConditionOb2;
  String? palletConditionRemark;

  // notes
  String? frontNotesController;
  String? backNotesController;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serialNumber': serialNumber,
      'auditDate': auditDate,
      'auditorName': auditorName,
      'verifiedBy': verifiedBy,
      'shift': shift,
      'po': po,
      'moduleType': moduleType,
      'createdAt': createdAt,

      'preLamTempOb1': preLamTempOb1,
      'preLamTempOb2': preLamTempOb2,
      'preLamTempRemark': preLamTempRemark,

      'laminationTempOb1': laminationTempOb1,
      'laminationTempOb2': laminationTempOb2,
      'laminationTempRemark': laminationTempRemark,

      'preLamHumidityOb1': preLamHumidityOb1,
      'preLamHumidityOb2': preLamHumidityOb2,
      'preLamHumidityRemark': preLamHumidityRemark,

      'glassMakeOb1': glassMakeOb1,
      'glassMakeOb2': glassMakeOb2,
      'glassMakeRemark': glassMakeRemark,

      'glassPalletNoOb1': glassPalletNoOb1,
      'glassPalletNoOb2': glassPalletNoOb2,
      'glassPalletNoRemark': glassPalletNoRemark,

      'glassSizeOb1': glassSizeOb1,
      'glassSizeOb2': glassSizeOb2,
      'glassSizeRemark': glassSizeRemark,

      'evaMakeOb1': evaMakeOb1,
      'evaMakeOb2': evaMakeOb2,
      'evaMakeRemark': evaMakeRemark,

      'evaTypeOb1': evaTypeOb1,
      'evaTypeOb2': evaTypeOb2,
      'evaTypeRemark': evaTypeRemark,

      'evaRollNoOb1': evaRollNoOb1,
      'evaRollNoOb2': evaRollNoOb2,
      'evaRollNoRemark': evaRollNoRemark,

      'evaExpiryDateOb1': evaExpiryDateOb1,
      'evaExpiryDateOb2': evaExpiryDateOb2,
      'evaExpiryDateRemark': evaExpiryDateRemark,

      'evaSizeOb1': evaSizeOb1,
      'evaSizeOb2': evaSizeOb2,
      'evaSizeRemark': evaSizeRemark,

      'cellMakeOb1': cellMakeOb1,
      'cellMakeOb2': cellMakeOb2,
      'cellMakeRemark': cellMakeRemark,

      'cellEfficiencyOb1': cellEfficiencyOb1,
      'cellEfficiencyOb2': cellEfficiencyOb2,
      'cellEfficiencyRemark': cellEfficiencyRemark,

      'cellWattageOb1': cellWattageOb1,
      'cellWattageOb2': cellWattageOb2,
      'cellWattageRemark': cellWattageRemark,

      'cellSizeOb1': cellSizeOb1,
      'cellSizeOb2': cellSizeOb2,
      'cellSizeRemark': cellSizeRemark,

      'cellDefectsOb1': cellDefectsOb1,
      'cellDefectsOb2': cellDefectsOb2,
      'cellDefectsRemark': cellDefectsRemark,

      'cleanlinessOb1': cleanlinessOb1,
      'cleanlinessOb2': cleanlinessOb2,
      'cleanlinessRemark': cleanlinessRemark,

      'ribbonMakeOb1': ribbonMakeOb1,
      'ribbonMakeOb2': ribbonMakeOb2,
      'ribbonMakeRemark': ribbonMakeRemark,

      'ribbonSizeOb1': ribbonSizeOb1,
      'ribbonSizeOb2': ribbonSizeOb2,
      'ribbonSizeRemark': ribbonSizeRemark,

      'fluxMakeOb1': fluxMakeOb1,
      'fluxMakeOb2': fluxMakeOb2,
      'fluxMakeRemark': fluxMakeRemark,

      'fluxTypeOb1': fluxTypeOb1,
      'fluxTypeOb2': fluxTypeOb2,
      'fluxTypeRemark': fluxTypeRemark,

      'fluxExpiryDateOb1': fluxExpiryDateOb1,
      'fluxExpiryDateOb2': fluxExpiryDateOb2,
      'fluxExpiryDateRemark': fluxExpiryDateRemark,

      'solderingTempOb1': solderingTempOb1,
      'solderingTempOb2': solderingTempOb2,
      'solderingTempRemark': solderingTempRemark,

      'workingHeatersOb1': workingHeatersOb1,
      'workingHeatersOb2': workingHeatersOb2,
      'workingHeatersRemark': workingHeatersRemark,

      'solderingPowerOb1': solderingPowerOb1,
      'solderingPowerOb2': solderingPowerOb2,
      'solderingPowerRemark': solderingPowerRemark,

      'solderTimeOb1': solderTimeOb1,
      'solderTimeOb2': solderTimeOb2,
      'solderTimeRemark': solderTimeRemark,

      'ribbonAlignmentOb1': ribbonAlignmentOb1,
      'ribbonAlignmentOb2': ribbonAlignmentOb2,
      'ribbonAlignmentRemark': ribbonAlignmentRemark,

      'ribbonDimensionsOb1': ribbonDimensionsOb1,
      'ribbonDimensionsOb2': ribbonDimensionsOb2,
      'ribbonDimensionsRemark': ribbonDimensionsRemark,

      'cellToCellGapOb1': cellToCellGapOb1,
      'cellToCellGapOb2': cellToCellGapOb2,
      'cellToCellGapRemark': cellToCellGapRemark,

      'stringLengthOb1': stringLengthOb1,
      'stringLengthOb2': stringLengthOb2,
      'stringLengthRemark': stringLengthRemark,

      'peelTestResultOb1': peelTestResultOb1,
      'peelTestResultOb2': peelTestResultOb2,
      'peelTestResultRemark': peelTestResultRemark,

      'elInspectionOb1': elInspectionOb1,
      'elInspectionOb2': elInspectionOb2,
      'elInspectionRemark': elInspectionRemark,

      'busbarMakeOb1': busbarMakeOb1,
      'busbarMakeOb2': busbarMakeOb2,
      'busbarMakeRemark': busbarMakeRemark,

      'busbarSizeOb1': busbarSizeOb1,
      'busbarSizeOb2': busbarSizeOb2,
      'busbarSizeRemark': busbarSizeRemark,

      'cellToBusbarDistanceOb1': cellToBusbarDistanceOb1,
      'cellToBusbarDistanceOb2': cellToBusbarDistanceOb2,
      'cellToBusbarDistanceRemark': cellToBusbarDistanceRemark,

      'stringToStringGapOb1': stringToStringGapOb1,
      'stringToStringGapOb2': stringToStringGapOb2,
      'stringToStringGapRemark': stringToStringGapRemark,

      'topSideGapOb1': topSideGapOb1,
      'topSideGapOb2': topSideGapOb2,
      'topSideGapRemark': topSideGapRemark,

      'middleSideGapOb1': middleSideGapOb1,
      'middleSideGapOb2': middleSideGapOb2,
      'middleSideGapRemark': middleSideGapRemark,

      'bottomSideGapOb1': bottomSideGapOb1,
      'bottomSideGapOb2': bottomSideGapOb2,
      'bottomSideGapRemark': bottomSideGapRemark,

      'leftSideGapOb1': leftSideGapOb1,
      'leftSideGapOb2': leftSideGapOb2,
      'leftSideGapRemark': leftSideGapRemark,

      'rightSideGapOb1': rightSideGapOb1,
      'rightSideGapOb2': rightSideGapOb2,
      'rightSideGapRemark': rightSideGapRemark,

      'tapMakeOb1': tapMakeOb1,
      'tapMakeOb2': tapMakeOb2,
      'tapMakeRemark': tapMakeRemark,

      'tapPositionOb1': tapPositionOb1,
      'tapPositionOb2': tapPositionOb2,
      'tapPositionRemark': tapPositionRemark,

      'tapSizeOb1': tapSizeOb1,
      'tapSizeOb2': tapSizeOb2,
      'tapSizeRemark': tapSizeRemark,

      'rearEvaMakeOb1': rearEvaMakeOb1,
      'rearEvaMakeOb2': rearEvaMakeOb2,
      'rearEvaMakeRemark': rearEvaMakeRemark,

      'rearEvaTypeOb1': rearEvaTypeOb1,
      'rearEvaTypeOb2': rearEvaTypeOb2,
      'rearEvaTypeRemark': rearEvaTypeRemark,

      'rearEvaRollNoOb1': rearEvaRollNoOb1,
      'rearEvaRollNoOb2': rearEvaRollNoOb2,
      'rearEvaRollNoRemark': rearEvaRollNoRemark,

      'rearEvaExpiryDateOb1': rearEvaExpiryDateOb1,
      'rearEvaExpiryDateOb2': rearEvaExpiryDateOb2,
      'rearEvaExpiryDateRemark': rearEvaExpiryDateRemark,

      'rearEvaSizeOb1': rearEvaSizeOb1,
      'rearEvaSizeOb2': rearEvaSizeOb2,
      'rearEvaSizeRemark': rearEvaSizeRemark,

      'backsheetMakeOb1': backsheetMakeOb1,
      'backsheetMakeOb2': backsheetMakeOb2,
      'backsheetMakeRemark': backsheetMakeRemark,

      'backsheetTypeOb1': backsheetTypeOb1,
      'backsheetTypeOb2': backsheetTypeOb2,
      'backsheetTypeRemark': backsheetTypeRemark,

      'backsheetRollNoOb1': backsheetRollNoOb1,
      'backsheetRollNoOb2': backsheetRollNoOb2,
      'backsheetRollNoRemark': backsheetRollNoRemark,

      'backsheetDimensionsOb1': backsheetDimensionsOb1,
      'backsheetDimensionsOb2': backsheetDimensionsOb2,
      'backsheetDimensionsRemark': backsheetDimensionsRemark,

      'logoPositionOkOb1': logoPositionOkOb1,
      'logoPositionOkOb2': logoPositionOkOb2,
      'logoPositionOkRemark': logoPositionOkRemark,

      'barcodePositionOkOb1': barcodePositionOkOb1,
      'barcodePositionOkOb2': barcodePositionOkOb2,
      'barcodePositionOkRemark': barcodePositionOkRemark,

      // Stage 10: Pre-El Inspection
      'preElSerialNoOb1': preElSerialNoOb1,
      'preElSerialNoOb2': preElSerialNoOb2,
      'preElSerialNoRemark': preElSerialNoRemark,

      'preElCurrentOb1': preElCurrentOb1,
      'preElCurrentOb2': preElCurrentOb2,
      'preElCurrentRemark': preElCurrentRemark,

      'preElVoltageOb1': preElVoltageOb1,
      'preElVoltageOb2': preElVoltageOb2,
      'preElVoltageRemark': preElVoltageRemark,

      'preElDefectsOb1': preElDefectsOb1,
      'preElDefectsOb2': preElDefectsOb2,
      'preElDefectsRemark': preElDefectsRemark,

      // Stage 11: Auto Edge Taping
      'edgeTapingOkOb1': edgeTapingOkOb1,
      'edgeTapingOkOb2': edgeTapingOkOb2,
      'edgeTapingOkRemark': edgeTapingOkRemark,

      // Stage 12: Lamination Process
      'laminatorNoOb1': laminatorNoOb1,
      'laminatorNoOb2': laminatorNoOb2,
      'laminatorNoRemark': laminatorNoRemark,

      // Lamination Temps (Map ko handle karna thoda different hoga)
      'laminationTempsCh01Ob1': laminationTempsCh01Ob1,
      'laminationTempsCh01Ob2': laminationTempsCh01Ob2,

      'laminationTempsCh02Ob1': laminationTempsCh02Ob1,
      'laminationTempsCh02Ob2': laminationTempsCh02Ob2,

      'laminationTempsCh03Ob1': laminationTempsCh03Ob1,
      'laminationTempsCh03Ob2': laminationTempsCh03Ob2,
      'laminationTempsRemark': laminationTempsRemark,

      // Vacuum Times
      'vacuumTimesCh01Ob1': vacuumTimesCh01Ob1,
      'vacuumTimesCh01Ob2': vacuumTimesCh01Ob2,

      'vacuumTimesCh02Ob1': vacuumTimesCh02Ob1,
      'vacuumTimesCh02Ob2': vacuumTimesCh02Ob2,

      'vacuumTimesCh03Ob1': vacuumTimesCh03Ob1,
      'vacuumTimesCh03Ob2': vacuumTimesCh03Ob2,
      'vacuumTimesRemark': vacuumTimesRemark,

      // Upper vent 1
      'upperventOneCh01Ob1': upperventOneCh01Ob1,
      'upperventOneCh01Ob2': upperventOneCh01Ob2,

      'upperventOneCh02Ob1': upperventOneCh02Ob1,
      'upperventOneCh02Ob2': upperventOneCh02Ob2,

      'upperventOneCh03Ob1': upperventOneCh03Ob1,
      'upperventOneCh03Ob2': upperventOneCh03Ob2,
      'upperventOneRemark': upperventOneRemark,

      // Lamination 1 (Map ko handle karna thoda different hoga)
      'laminationOneCh01Ob1': laminationOneCh01Ob1,
      'laminationOneCh01Ob2': laminationOneCh01Ob2,

      'laminationOneCh02Ob1': laminationOneCh02Ob1,
      'laminationOneCh02Ob2': laminationOneCh02Ob2,

      'laminationOneCh03Ob1': laminationOneCh03Ob1,
      'laminationOneCh03Ob2': laminationOneCh03Ob2,
      'laminationOneRemark': laminationOneRemark,

      // Upper vent 2
      'upperventSecCh01Ob1': upperventSecCh01Ob1,
      'upperventSecCh01Ob2': upperventSecCh01Ob2,

      'upperventSecCh02Ob1': upperventSecCh02Ob1,
      'upperventSecCh02Ob2': upperventSecCh02Ob2,

      'upperventSecCh03Ob1': upperventSecCh03Ob1,
      'upperventSecCh03Ob2': upperventSecCh03Ob2,
      'upperventSecRemark': upperventSecRemark,

      // Lamination 2 (Map ko handle karna thoda different hoga)
      'laminationSecCh01Ob1': laminationSecCh01Ob1,
      'laminationSecCh01Ob2': laminationSecCh01Ob2,

      'laminationSecCh02Ob1': laminationSecCh02Ob1,
      'laminationSecCh02Ob2': laminationSecCh02Ob2,

      'laminationSecCh03Ob1': laminationSecCh03Ob1,
      'laminationSecCh03Ob2': laminationSecCh03Ob2,
      'laminationSecRemark': laminationSecRemark,

      // Upper vent 3
      'upperventThirdCh01Ob1': upperventThirdCh01Ob1,
      'upperventThirdCh01Ob2': upperventThirdCh01Ob2,

      'upperventThirdCh02Ob1': upperventThirdCh02Ob1,
      'upperventThirdCh02Ob2': upperventThirdCh02Ob2,

      'upperventThirdCh03Ob1': upperventThirdCh03Ob1,
      'upperventThirdCh03Ob2': upperventThirdCh03Ob2,
      'upperventThirdRemark': upperventThirdRemark,

      // Lamination 3 (Map ko handle karna thoda different hoga)
      'laminationThirdCh01Ob1': laminationThirdCh01Ob1,
      'laminationThirdCh01Ob2': laminationThirdCh01Ob2,

      'laminationThirdCh02Ob1': laminationThirdCh02Ob1,
      'laminationThirdCh02Ob2': laminationThirdCh02Ob2,

      'laminationThirdCh03Ob1': laminationThirdCh03Ob1,
      'laminationThirdCh03Ob2': laminationThirdCh03Ob2,
      'laminationThirdRemark': laminationThirdRemark,

      // Lower Vent Time (Map ko handle karna thoda different hoga)
      'lowerVentTimeCh01Ob1': lowerVentTimeCh01Ob1,
      'lowerVentTimeCh01Ob2': lowerVentTimeCh01Ob2,

      'lowerVentTimeCh02Ob1': lowerVentTimeCh02Ob1,
      'lowerVentTimeCh02Ob2': lowerVentTimeCh02Ob2,

      'lowerVentTimeCh03Ob1': lowerVentTimeCh03Ob1,
      'lowerVentTimeCh03Ob2': lowerVentTimeCh03Ob2,
      'lowerVentTimeRemark': lowerVentTimeRemark,

      // Lower Vent Time (Map ko handle karna thoda different hoga)
      'totalCycleTimeCh01Ob1': totalCycleTimeCh01Ob1,
      'totalCycleTimeCh01Ob2': totalCycleTimeCh01Ob2,

      'totalCycleTimeCh02Ob1': totalCycleTimeCh02Ob1,
      'totalCycleTimeCh02Ob2': totalCycleTimeCh02Ob2,

      'totalCycleTimeCh03Ob1': totalCycleTimeCh03Ob1,
      'totalCycleTimeCh03Ob2': totalCycleTimeCh03Ob2,
      'totalCycleTimeRemark': totalCycleTimeRemark,

      // Stage 13: Auto Edge Trimming
      'trimmingOkOb1': trimmingOkOb1,
      'trimmingOkOb2': trimmingOkOb2,
      'trimmingOkRemark': trimmingOkRemark,

      // Stage 14: Framing Process
      'frameSerialNoOb1': frameSerialNoOb1,
      'frameSerialNoOb2': frameSerialNoOb2,
      'frameSerialNoRemark': frameSerialNoRemark,

      'frameMakeOb1': frameMakeOb1,
      'frameMakeOb2': frameMakeOb2,
      'frameMakeRemark': frameMakeRemark,

      'cornerKeyMakeOb1': cornerKeyMakeOb1,
      'cornerKeyMakeOb2': cornerKeyMakeOb2,
      'cornerKeyMakeRemark': cornerKeyMakeRemark,

      'profileCutAngleOb1': profileCutAngleOb1,
      'profileCutAngleOb2': profileCutAngleOb2,
      'profileCutAngleRemark': profileCutAngleRemark,

      'frameLengthOb1': frameLengthOb1,
      'frameLengthOb2': frameLengthOb2,
      'frameLengthRemark': frameLengthRemark,

      'frameWidthOb1': frameWidthOb1,
      'frameWidthOb2': frameWidthOb2,
      'frameWidthRemark': frameWidthRemark,

      'frameHeightOb1': frameHeightOb1,
      'frameHeightOb2': frameHeightOb2,
      'frameHeightRemark': frameHeightRemark,

      'mountingHoleOb1': mountingHoleOb1,
      'mountingHoleOb2': mountingHoleOb2,
      'mountingHoleRemark': mountingHoleRemark,

      'xPitchOb1': xPitchOb1,
      'xPitchOb2': xPitchOb2,
      'xPitchRemark': xPitchRemark,

      'yPitchOb1': yPitchOb1,
      'yPitchOb2': yPitchOb2,
      'yPitchRemark': yPitchRemark,

      'groundHoleDiaOb1': groundHoleDiaOb1,
      'groundHoleDiaOb2': groundHoleDiaOb2,
      'groundHoleDiaRemark': groundHoleDiaRemark,

      'groundHoleDistanceOb1': groundHoleDistanceOb1,
      'groundHoleDistanceOb2': groundHoleDistanceOb2,
      'groundHoleDistanceRemark': groundHoleDistanceRemark,

      'drainHoleSizeOb1': drainHoleSizeOb1,
      'drainHoleSizeOb2': drainHoleSizeOb2,
      'drainHoleSizeRemark': drainHoleSizeRemark,

      'drainHoleDistanceOb1': drainHoleDistanceOb1,
      'drainHoleDistanceOb2': drainHoleDistanceOb2,
      'drainHoleDistanceRemark': drainHoleDistanceRemark,

      'diagonalLengthOb1': diagonalLengthOb1,
      'diagonalLengthOb2': diagonalLengthOb2,
      'diagonalLengthRemark': diagonalLengthRemark,

      'sealantMakeOb1': sealantMakeOb1,
      'sealantMakeOb2': sealantMakeOb2,
      'sealantMakeRemark': sealantMakeRemark,

      'sealantTypeOb1': sealantTypeOb1,
      'sealantTypeOb2': sealantTypeOb2,
      'sealantTypeRemark': sealantTypeRemark,

      'scratchDentsOb1': scratchDentsOb1,
      'scratchDentsOb2': scratchDentsOb2,
      'scratchDentsRemark': scratchDentsRemark,

      'sealantWeightOb1': sealantWeightOb1,
      'sealantWeightOb2': sealantWeightOb2,
      'sealantWeightRemark': sealantWeightRemark,

      'frameDefectsOb1': frameDefectsOb1,
      'frameDefectsOb2': frameDefectsOb2,
      'frameDefectsRemark': frameDefectsRemark,

      // Stage 15: Junction Box Assembly
      'jbSerialNoOb1': jbSerialNoOb1,
      'jbSerialNoOb2': jbSerialNoOb2,
      'jbSerialNoRemark': jbSerialNoRemark,

      'jbMakeOb1': jbMakeOb1,
      'jbMakeOb2': jbMakeOb2,
      'jbMakeRemark': jbMakeRemark,

      'jbTypeOb1': jbTypeOb1,
      'jbTypeOb2': jbTypeOb2,
      'jbTypeRemark': jbTypeRemark,

      'diodeModelOb1': diodeModelOb1,
      'diodeModelOb2': diodeModelOb2,
      'diodeModelRemark': diodeModelRemark,

      'jbPlacementOb1': jbPlacementOb1,
      'jbPlacementOb2': jbPlacementOb2,
      'jbPlacementRemark': jbPlacementRemark,

      // JB Sealant Weights
      'jbSealantWeightsAOb1': jbSealantWeightsAOb1,
      'jbSealantWeightsAOb2': jbSealantWeightsAOb2,

      'jbSealantWeightsBOb1': jbSealantWeightsBOb1,
      'jbSealantWeightsBOb2': jbSealantWeightsBOb2,

      'jbSealantWeightsCOb1': jbSealantWeightsCOb1,
      'jbSealantWeightsCOb2': jbSealantWeightsCOb2,
      'jbSealantWeightsRemark': jbSealantWeightsRemark,

      'solderingQualityOb1': solderingQualityOb1,
      'solderingQualityOb2': solderingQualityOb2,
      'solderingQualityRemark': solderingQualityRemark,

      'pottingSealantMakeOb1': pottingSealantMakeOb1,
      'pottingSealantMakeOb2': pottingSealantMakeOb2,
      'pottingSealantMakeRemark': pottingSealantMakeRemark,

      'pottingSealantTypeOb1': pottingSealantTypeOb1,
      'pottingSealantTypeOb2': pottingSealantTypeOb2,
      'pottingSealantTypeRemark': pottingSealantTypeRemark,

      'pottingSealantExpiryOb1': pottingSealantExpiryOb1,
      'pottingSealantExpiryOb2': pottingSealantExpiryOb2,
      'pottingSealantExpiryRemark': pottingSealantExpiryRemark,

      'curingTimeOb1': curingTimeOb1,
      'curingTimeOb2': curingTimeOb2,
      'curingTimeRemark': curingTimeRemark,

      // Potting Sealant Weights
      'pottingSealantWeightAOb1': pottingSealantWeightsAOb1,
      'pottingSealantWeightAOb2': pottingSealantWeightsAOb2,

      'pottingSealantWeightBOb1': pottingSealantWeightsBOb1,
      'pottingSealantWeightBOb2': pottingSealantWeightsBOb2,

      'pottingSealantWeightCOb1': pottingSealantWeightsCOb1,
      'pottingSealantWeightCOb2': pottingSealantWeightsCOb2,
      'pottingSealantWeightCRemark': pottingSealantWeightsRemark,

      'pottingRatioAOb1': pottingRatioAOb1,
      'pottingRatioBOb1': pottingRatioBOb1,
      'pottingRatioOb1': pottingRatioOb1,
      'pottingRatioAOb2': pottingRatioAOb2,
      'pottingRatioBOb2': pottingRatioBOb2,
      'pottingRatioOb2': pottingRatioOb2,
      'pottingRatioRemark': pottingRatioRemark,

      'cableLengthOb1': cableLengthOb1,
      'cableLengthOb2': cableLengthOb2,
      'cableLengthRemark': cableLengthRemark,

      'visualStatusOb1': visualStatusOb1,
      'visualStatusOb2': visualStatusOb2,
      'visualStatusRemark': visualStatusRemark,

      // Stage 16: Curing Line
      'curingTimeLineOb1': curingTimeLineOb1,
      'curingTimeLineOb2': curingTimeLineOb2,
      'curingTimeLineRemark': curingTimeLineRemark,

      'curingTempOb1': curingTempOb1,
      'curingTempOb2': curingTempOb2,
      'curingTempRemark': curingTempRemark,

      'curingHumidityOb1': curingHumidityOb1,
      'curingHumidityOb2': curingHumidityOb2,
      'curingHumidityRemark': curingHumidityRemark,

      // Stage 17: Module Cleaning
      'cleaningOkOb1': cleaningOkOb1,
      'cleaningOkOb2': cleaningOkOb2,
      'cleaningOkRemark': cleaningOkRemark,

      // Stage 18: Hi-Pot Testing
      'hipotSerialNoOb1': hipotSerialNoOb1,
      'hipotSerialNoOb2': hipotSerialNoOb2,
      'hipotSerialNoRemark': hipotSerialNoRemark,

      'dcwOb1': dcwOb1,
      'dcwOb2': dcwOb2,
      'dcwRemark': dcwRemark,

      'irOb1': irOb1,
      'irOb2': irOb2,
      'irRemark': irRemark,

      'groundContinuityOb1': groundContinuityOb1,
      'groundContinuityOb2': groundContinuityOb2,
      'groundContinuityRemark': groundContinuityRemark,

      // Stage 19: Post-El Inspection
      'postElSerialNoOb1': postElSerialNoOb1,
      'postElSerialNoOb2': postElSerialNoOb2,
      'postElSerialNoRemark': postElSerialNoRemark,

      'postElCurrentOb1': postElCurrentOb1,
      'postElCurrentOb2': postElCurrentOb2,
      'postElCurrentRemark': postElCurrentRemark,

      'postElVoltageOb1': postElVoltageOb1,
      'postElVoltageOb2': postElVoltageOb2,
      'postElVoltageRemark': postElVoltageRemark,

      'postElDefectsOb1': postElDefectsOb1,
      'postElDefectsOb2': postElDefectsOb2,
      'postElDefectsRemark': postElDefectsRemark,

      // Stage 20: Sun Simulator
      'calibrationDateOb1': calibrationDateOb1,
      'calibrationDateOb2': calibrationDateOb2,
      'calibrationDateRemark': calibrationDateRemark,

      'sunSerialNoOb1': sunSerialNoOb1,
      'sunSerialNoOb2': sunSerialNoOb2,
      'sunSerialNoRemark': sunSerialNoRemark,

      'modulePowerOb1': modulePowerOb1,
      'modulePowerOb2': modulePowerOb2,
      'modulePowerRemark': modulePowerRemark,

      'iscOb1': iscOb1,
      'iscOb2': iscOb2,
      'iscRemark': iscRemark,

      'vocOb1': vocOb1,
      'vocOb2': vocOb2,
      'vocRemark': vocRemark,

      'impOb1': impOb1,
      'impOb2': impOb2,
      'impRemark': impRemark,

      'vmpOb1': vmpOb1,
      'vmpOb2': vmpOb2,
      'vmpRemark': vmpRemark,

      'moduleTempOb1': moduleTempOb1,
      'moduleTempOb2': moduleTempOb2,
      'moduleTempRemark': moduleTempRemark,

      'fillFactorOb1': fillFactorOb1,
      'fillFactorOb2': fillFactorOb2,
      'fillFactorRemark': fillFactorRemark,

      'efficiencyOb1': efficiencyOb1,
      'efficiencyOb2': efficiencyOb2,
      'efficiencyRemark': efficiencyRemark,

      'ivCurveOkOb1': ivCurveOkOb1,
      'ivCurveOkOb2': ivCurveOkOb2,
      'ivCurveOkRemark': ivCurveOkRemark,

      // Stage 21: FQC
      'visualInspectionOb1': visualInspectionOb1,
      'visualInspectionOb2': visualInspectionOb2,
      'visualInspectionRemark': visualInspectionRemark,

      'jbCoverFitmentOb1': jbCoverFitmentOb1,
      'jbCoverFitmentOb2': jbCoverFitmentOb2,
      'jbCoverFitmentRemark': jbCoverFitmentRemark,

      'labelPlacementOb1': labelPlacementOb1,
      'labelPlacementOb2': labelPlacementOb2,
      'labelPlacementRemark': labelPlacementRemark,

      'fqcDefectsOb1': fqcDefectsOb1,
      'fqcDefectsOb2': fqcDefectsOb2,
      'fqcDefectsRemark': fqcDefectsRemark,

      // Stage 22: Auto Sorter & Packing
      'sortingStatusOb1': sortingStatusOb1,
      'sortingStatusOb2': sortingStatusOb2,
      'sortingStatusRemark': sortingStatusRemark,

      'palletConditionOb1': palletConditionOb1,
      'palletConditionOb2': palletConditionOb2,
      'palletConditionRemark': palletConditionRemark,

      'frontNotesController': frontNotesController,
      'backNotesController': backNotesController,
    };
  }

  factory AuditForm.fromJson(Map<String, dynamic> json) {
    // First create the AuditForm with required fields
    final form = AuditForm(
      id: parseMongoId(json['_id']),
      serialNumber: json['serialNumber'] ?? '',
      auditDate: parseAuditDate(json['auditDate']),
      auditorName: json['auditorName'] ?? '',
      verifiedBy: json['verifiedBy'] ?? '',
      shift: json['shift'] ?? '',
      po: json['po'] ?? '',
      moduleType: json['moduleType'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );

    // Now set all the optional fields
    // Stage 1: Floor
    form.preLamTempOb1 = json['preLamTempOb1'];
    form.preLamTempOb2 = json['preLamTempOb2'];
    form.preLamTempRemark = json['preLamTempRemark'];

    form.laminationTempOb1 = json['laminationTempOb1'];
    form.laminationTempOb2 = json['laminationTempOb2'];
    form.laminationTempRemark = json['laminationTempRemark'];

    form.preLamHumidityOb1 = json['preLamHumidityOb1'];
    form.preLamHumidityOb2 = json['preLamHumidityOb2'];
    form.preLamHumidityRemark = json['preLamHumidityRemark'];

    // Stage 2: Front Glass Loading
    form.glassMakeOb1 = json['glassMakeOb1'];
    form.glassMakeOb2 = json['glassMakeOb2'];
    form.glassMakeRemark = json['glassMakeRemark'];

    form.glassPalletNoOb1 = json['glassPalletNoOb1'];
    form.glassPalletNoOb2 = json['glassPalletNoOb2'];
    form.glassPalletNoRemark = json['glassPalletNoRemark'];

    form.glassSizeOb1 = json['glassSizeOb1'];
    form.glassSizeOb2 = json['glassSizeOb2'];
    form.glassSizeRemark = json['glassSizeRemark'];

    // Stage 3: Front side EVA Cutting
    form.evaMakeOb1 = json['evaMakeOb1'];
    form.evaMakeOb2 = json['evaMakeOb2'];
    form.evaMakeRemark = json['evaMakeRemark'];

    form.evaTypeOb1 = json['evaTypeOb1'];
    form.evaTypeOb2 = json['evaTypeOb2'];
    form.evaTypeRemark = json['evaTypeRemark'];

    form.evaRollNoOb1 = json['evaRollNoOb1'];
    form.evaRollNoOb2 = json['evaRollNoOb2'];
    form.evaRollNoRemark = json['evaRollNoRemark'];

    form.evaExpiryDateOb1 = json['evaExpiryDateOb1'];
    form.evaExpiryDateOb2 = json['evaExpiryDateOb2'];
    form.evaExpiryDateRemark = json['evaExpiryDateRemark'];

    form.evaSizeOb1 = json['evaSizeOb1'];
    form.evaSizeOb2 = json['evaSizeOb2'];
    form.evaSizeRemark = json['evaSizeRemark'];

    // Stage 4: Stringer
    form.cellMakeOb1 = json['cellMakeOb1'];
    form.cellMakeOb2 = json['cellMakeOb2'];
    form.cellMakeRemark = json['cellMakeRemark'];

    form.cellEfficiencyOb1 = json['cellEfficiencyOb1'];
    form.cellEfficiencyOb2 = json['cellEfficiencyOb2'];
    form.cellEfficiencyRemark = json['cellEfficiencyRemark'];

    form.cellWattageOb1 = json['cellWattageOb1'];
    form.cellWattageOb2 = json['cellWattageOb2'];
    form.cellWattageRemark = json['cellWattageRemark'];

    form.cellSizeOb1 = json['cellSizeOb1'];
    form.cellSizeOb2 = json['cellSizeOb2'];
    form.cellSizeRemark = json['cellSizeRemark'];

    form.cellDefectsOb1 = json['cellDefectsOb1'];
    form.cellDefectsOb2 = json['cellDefectsOb2'];
    form.cellDefectsRemark = json['cellDefectsRemark'];

    form.cleanlinessOb1 = json['cleanlinessOb1'];
    form.cleanlinessOb2 = json['cleanlinessOb2'];
    form.cleanlinessRemark = json['cleanlinessRemark'];

    form.ribbonMakeOb1 = json['ribbonMakeOb1'];
    form.ribbonMakeOb2 = json['ribbonMakeOb2'];
    form.ribbonMakeRemark = json['ribbonMakeRemark'];

    form.ribbonSizeOb1 = json['ribbonSizeOb1'];
    form.ribbonSizeOb2 = json['ribbonSizeOb2'];
    form.ribbonSizeRemark = json['ribbonSizeRemark'];

    form.fluxMakeOb1 = json['fluxMakeOb1'];
    form.fluxMakeOb2 = json['fluxMakeOb2'];
    form.fluxMakeRemark = json['fluxMakeRemark'];

    form.fluxTypeOb1 = json['fluxTypeOb1'];
    form.fluxTypeOb2 = json['fluxTypeOb2'];
    form.fluxTypeRemark = json['fluxTypeRemark'];

    form.fluxExpiryDateOb1 = json['fluxExpiryDateOb1'];
    form.fluxExpiryDateOb2 = json['fluxExpiryDateOb2'];
    form.fluxExpiryDateRemark = json['fluxExpiryDateRemark'];

    form.solderingTempOb1 = json['solderingTempOb1'];
    form.solderingTempOb2 = json['solderingTempOb2'];
    form.solderingTempRemark = json['solderingTempRemark'];

    form.workingHeatersOb1 = json['workingHeatersOb1'];
    form.workingHeatersOb2 = json['workingHeatersOb2'];
    form.workingHeatersRemark = json['workingHeatersRemark'];

    form.solderingPowerOb1 = json['solderingPowerOb1'];
    form.solderingPowerOb2 = json['solderingPowerOb2'];
    form.solderingPowerRemark = json['solderingPowerRemark'];

    form.solderTimeOb1 = json['solderTimeOb1'];
    form.solderTimeOb2 = json['solderTimeOb2'];
    form.solderTimeRemark = json['solderTimeRemark'];

    form.ribbonAlignmentOb1 = json['ribbonAlignmentOb1'];
    form.ribbonAlignmentOb2 = json['ribbonAlignmentOb2'];
    form.ribbonAlignmentRemark = json['ribbonAlignmentRemark'];

    form.ribbonDimensionsOb1 = json['ribbonDimensionsOb1'];
    form.ribbonDimensionsOb2 = json['ribbonDimensionsOb2'];
    form.ribbonDimensionsRemark = json['ribbonDimensionsRemark'];

    form.cellToCellGapOb1 = json['cellToCellGapOb1'];
    form.cellToCellGapOb2 = json['cellToCellGapOb2'];
    form.cellToCellGapRemark = json['cellToCellGapRemark'];

    form.stringLengthOb1 = json['stringLengthOb1'];
    form.stringLengthOb2 = json['stringLengthOb2'];
    form.stringLengthRemark = json['stringLengthRemark'];

    form.peelTestResultOb1 = json['peelTestResultOb1'];
    form.peelTestResultOb2 = json['peelTestResultOb2'];
    form.peelTestResultRemark = json['peelTestResultRemark'];

    form.elInspectionOb1 = json['elInspectionOb1'];
    form.elInspectionOb2 = json['elInspectionOb2'];
    form.elInspectionRemark = json['elInspectionRemark'];

    // Stage 5: Lay-up & Auto Bussing
    form.busbarMakeOb1 = json['busbarMakeOb1'];
    form.busbarMakeOb2 = json['busbarMakeOb2'];
    form.busbarMakeRemark = json['busbarMakeRemark'];

    form.busbarSizeOb1 = json['busbarSizeOb1'];
    form.busbarSizeOb2 = json['busbarSizeOb2'];
    form.busbarSizeRemark = json['busbarSizeRemark'];

    form.cellToBusbarDistanceOb1 = json['cellToBusbarDistanceOb1'];
    form.cellToBusbarDistanceOb2 = json['cellToBusbarDistanceOb2'];
    form.cellToBusbarDistanceRemark = json['cellToBusbarDistanceRemark'];

    form.stringToStringGapOb1 = json['stringToStringGapOb1'];
    form.stringToStringGapOb2 = json['stringToStringGapOb2'];
    form.stringToStringGapRemark = json['stringToStringGapRemark'];

    form.topSideGapOb1 = json['topSideGapOb1'];
    form.topSideGapOb2 = json['topSideGapOb2'];
    form.topSideGapRemark = json['topSideGapRemark'];

    form.middleSideGapOb1 = json['middleSideGapOb1'];
    form.middleSideGapOb2 = json['middleSideGapOb2'];
    form.middleSideGapRemark = json['middleSideGapRemark'];

    form.bottomSideGapOb1 = json['bottomSideGapOb1'];
    form.bottomSideGapOb2 = json['bottomSideGapOb2'];
    form.bottomSideGapRemark = json['bottomSideGapRemark'];

    form.leftSideGapOb1 = json['leftSideGapOb1'];
    form.leftSideGapOb2 = json['leftSideGapOb2'];
    form.leftSideGapRemark = json['leftSideGapRemark'];

    form.rightSideGapOb1 = json['rightSideGapOb1'];
    form.rightSideGapOb2 = json['rightSideGapOb2'];
    form.rightSideGapRemark = json['rightSideGapRemark'];

    // Stage 6: Auto Tapping
    form.tapMakeOb1 = json['tapMakeOb1'];
    form.tapMakeOb2 = json['tapMakeOb2'];
    form.tapMakeRemark = json['tapMakeRemark'];

    form.tapPositionOb1 = json['tapPositionOb1'];
    form.tapPositionOb2 = json['tapPositionOb2'];
    form.tapPositionRemark = json['tapPositionRemark'];

    form.tapSizeOb1 = json['tapSizeOb1'];
    form.tapSizeOb2 = json['tapSizeOb2'];
    form.tapSizeRemark = json['tapSizeRemark'];

    // Stage 7: Rear side EVA Cutting
    form.rearEvaMakeOb1 = json['rearEvaMakeOb1'];
    form.rearEvaMakeOb2 = json['rearEvaMakeOb2'];
    form.rearEvaMakeRemark = json['rearEvaMakeRemark'];

    form.rearEvaTypeOb1 = json['rearEvaTypeOb1'];
    form.rearEvaTypeOb2 = json['rearEvaTypeOb2'];
    form.rearEvaTypeRemark = json['rearEvaTypeRemark'];

    form.rearEvaRollNoOb1 = json['rearEvaRollNoOb1'];
    form.rearEvaRollNoOb2 = json['rearEvaRollNoOb2'];
    form.rearEvaRollNoRemark = json['rearEvaRollNoRemark'];

    form.rearEvaExpiryDateOb1 = json['rearEvaExpiryDateOb1'];
    form.rearEvaExpiryDateOb2 = json['rearEvaExpiryDateOb2'];
    form.rearEvaExpiryDateRemark = json['rearEvaExpiryDateRemark'];

    form.rearEvaSizeOb1 = json['rearEvaSizeOb1'];
    form.rearEvaSizeOb2 = json['rearEvaSizeOb2'];
    form.rearEvaSizeRemark = json['rearEvaSizeRemark'];

    // Stage 8: Rear Side Back Sheet/Glass
    form.backsheetMakeOb1 = json['backsheetMakeOb1'];
    form.backsheetMakeOb2 = json['backsheetMakeOb2'];
    form.backsheetMakeRemark = json['backsheetMakeRemark'];

    form.backsheetTypeOb1 = json['backsheetTypeOb1'];
    form.backsheetTypeOb2 = json['backsheetTypeOb2'];
    form.backsheetTypeRemark = json['backsheetTypeRemark'];

    form.backsheetRollNoOb1 = json['backsheetRollNoOb1'];
    form.backsheetRollNoOb2 = json['backsheetRollNoOb2'];
    form.backsheetRollNoRemark = json['backsheetRollNoRemark'];

    form.backsheetDimensionsOb1 = json['backsheetDimensionsOb1'];
    form.backsheetDimensionsOb2 = json['backsheetDimensionsOb2'];
    form.backsheetDimensionsRemark = json['backsheetDimensionsRemark'];

    // Stage 9: Logo & Barcode Fixing
    form.logoPositionOkOb1 = json['logoPositionOkOb1'];
    form.logoPositionOkOb2 = json['logoPositionOkOb2'];
    form.logoPositionOkRemark = json['logoPositionOkRemark'];

    form.barcodePositionOkOb1 = json['barcodePositionOkOb1'];
    form.barcodePositionOkOb2 = json['barcodePositionOkOb2'];
    form.barcodePositionOkRemark = json['barcodePositionOkRemark'];

    // Continue for remaining stages...
    // Stage 10: Pre-El Inspection
    form.preElSerialNoOb1 = json['preElSerialNoOb1'];
    form.preElSerialNoOb2 = json['preElSerialNoOb2'];
    form.preElSerialNoRemark = json['preElSerialNoRemark'];

    form.preElCurrentOb1 = json['preElCurrentOb1'];
    form.preElCurrentOb2 = json['preElCurrentOb2'];
    form.preElCurrentRemark = json['preElCurrentRemark'];

    form.preElVoltageOb1 = json['preElVoltageOb1'];
    form.preElVoltageOb2 = json['preElVoltageOb2'];
    form.preElVoltageRemark = json['preElVoltageRemark'];

    form.preElDefectsOb1 = json['preElDefectsOb1'];
    form.preElDefectsOb2 = json['preElDefectsOb2'];
    form.preElDefectsRemark = json['preElDefectsRemark'];

    // Stage 11: Auto Edge Taping
    form.edgeTapingOkOb1 = json['edgeTapingOkOb1'];
    form.edgeTapingOkOb2 = json['edgeTapingOkOb2'];
    form.edgeTapingOkRemark = json['edgeTapingOkRemark'];

    // Stage 12: Lamination Process
    form.laminatorNoOb1 = json['laminatorNoOb1'];
    form.laminatorNoOb2 = json['laminatorNoOb2'];
    form.laminatorNoRemark = json['laminatorNoRemark'];

    // For lamination temps (converting from individual fields)
    form.laminationTempsCh01Ob1 = json['laminationTempsCh01Ob1'];
    form.laminationTempsCh01Ob2 = json['laminationTempsCh01Ob2'];

    form.laminationTempsCh02Ob1 = json['laminationTempsCh02Ob1'];
    form.laminationTempsCh02Ob2 = json['laminationTempsCh02Ob2'];

    form.laminationTempsCh03Ob1 = json['laminationTempsCh03Ob1'];
    form.laminationTempsCh03Ob2 = json['laminationTempsCh03Ob2'];
    form.laminationTempsRemark = json['laminationTempsRemark'];

    form.vacuumTimesCh01Ob1 = json['vacuumTimesCh01Ob1'];
    form.vacuumTimesCh01Ob2 = json['vacuumTimesCh01Ob2'];

    form.vacuumTimesCh02Ob1 = json['vacuumTimesCh02Ob1'];
    form.vacuumTimesCh02Ob2 = json['vacuumTimesCh02Ob2'];

    form.vacuumTimesCh03Ob1 = json['vacuumTimesCh03Ob1'];
    form.vacuumTimesCh03Ob2 = json['vacuumTimesCh03Ob2'];
    form.vacuumTimesRemark = json['vacuumTimesRemark'];

    // upper Vent 1
    form.upperventOneCh01Ob1 = json['upperventOneCh01Ob1'];
    form.upperventOneCh01Ob2 = json['upperventOneCh01Ob2'];

    form.upperventOneCh02Ob1 = json['upperventOneCh02Ob1'];
    form.upperventOneCh02Ob2 = json['upperventOneCh02Ob2'];

    form.upperventOneCh03Ob1 = json['upperventOneCh03Ob1'];
    form.upperventOneCh03Ob2 = json['upperventOneCh03Ob2'];
    form.upperventOneRemark = json['upperventOneRemark'];

    // lamination 1
    form.laminationOneCh01Ob1 = json['laminationOneCh01Ob1'];
    form.laminationOneCh01Ob2 = json['laminationOneCh01Ob2'];

    form.laminationOneCh02Ob1 = json['laminationOneCh02Ob1'];
    form.laminationOneCh02Ob2 = json['laminationOneCh02Ob2'];

    form.laminationOneCh03Ob1 = json['laminationOneCh03Ob1'];
    form.laminationOneCh03Ob2 = json['laminationOneCh03Ob2'];
    form.laminationOneRemark = json['laminationOneRemark'];

    // upper Vent 2
    form.upperventSecCh01Ob1 = json['upperventSecCh01Ob1'];
    form.upperventSecCh01Ob2 = json['upperventSecCh01Ob2'];

    form.upperventSecCh02Ob1 = json['upperventSecCh02Ob1'];
    form.upperventSecCh02Ob2 = json['upperventSecCh02Ob2'];

    form.upperventSecCh03Ob1 = json['upperventSecCh03Ob1'];
    form.upperventSecCh03Ob2 = json['upperventSecCh03Ob2'];
    form.upperventSecRemark = json['upperventSecRemark'];

    // lamination 2
    form.laminationSecCh01Ob1 = json['laminationSecCh01Ob1'];
    form.laminationSecCh01Ob2 = json['laminationSecCh01Ob2'];

    form.laminationSecCh02Ob1 = json['laminationSecCh02Ob1'];
    form.laminationSecCh02Ob2 = json['laminationSecCh02Ob2'];

    form.laminationSecCh03Ob1 = json['laminationSecCh03Ob1'];
    form.laminationSecCh03Ob2 = json['laminationSecCh03Ob2'];
    form.laminationSecRemark = json['laminationSecRemark'];

    // upper Vent 3
    form.upperventThirdCh01Ob1 = json['upperventThirdCh01Ob1'];
    form.upperventThirdCh01Ob2 = json['upperventThirdCh01Ob2'];

    form.upperventThirdCh02Ob1 = json['upperventThirdCh02Ob1'];
    form.upperventThirdCh02Ob2 = json['upperventThirdCh02Ob2'];

    form.upperventThirdCh03Ob1 = json['upperventThirdCh03Ob1'];
    form.upperventThirdCh03Ob2 = json['upperventThirdCh03Ob2'];
    form.upperventThirdRemark = json['upperventThirdRemark'];

    // lamination 3
    form.laminationThirdCh01Ob1 = json['laminationThirdCh01Ob1'];
    form.laminationThirdCh01Ob2 = json['laminationThirdCh01Ob2'];

    form.laminationThirdCh02Ob1 = json['laminationThirdCh02Ob1'];
    form.laminationThirdCh02Ob2 = json['laminationThirdCh02Ob2'];

    form.laminationThirdCh03Ob1 = json['laminationThirdCh03Ob1'];
    form.laminationThirdCh03Ob2 = json['laminationThirdCh03Ob2'];
    form.laminationThirdRemark = json['laminationThirdRemark'];

    // lowe vent time
    form.lowerVentTimeCh01Ob1 = json['lowerVentTimeCh01Ob1'];
    form.lowerVentTimeCh01Ob2 = json['lowerVentTimeCh01Ob2'];

    form.lowerVentTimeCh02Ob1 = json['lowerVentTimeCh02Ob1'];
    form.lowerVentTimeCh02Ob2 = json['lowerVentTimeCh02Ob2'];

    form.lowerVentTimeCh03Ob1 = json['lowerVentTimeCh03Ob1'];
    form.lowerVentTimeCh03Ob2 = json['lowerVentTimeCh03Ob2'];
    form.lowerVentTimeRemark = json['lowerVentTimeRemark'];

    // Total cycle time
    form.totalCycleTimeCh01Ob1 = json['totalCycleTimeCh01Ob1'];
    form.totalCycleTimeCh01Ob2 = json['totalCycleTimeCh01Ob2'];

    form.totalCycleTimeCh02Ob1 = json['totalCycleTimeCh02Ob1'];
    form.totalCycleTimeCh02Ob2 = json['totalCycleTimeCh02Ob2'];

    form.totalCycleTimeCh03Ob1 = json['totalCycleTimeCh03Ob1'];
    form.totalCycleTimeCh03Ob2 = json['totalCycleTimeCh03Ob2'];
    form.totalCycleTimeRemark = json['totalCycleTimeRemark'];

    // Stage 13: Auto Edge Trimming
    form.trimmingOkOb1 = json['trimmingOkOb1'];
    form.trimmingOkOb2 = json['trimmingOkOb2'];
    form.trimmingOkRemark = json['trimmingOkRemark'];

    // Stage 14: Framing Process
    form.frameSerialNoOb1 = json['frameSerialNoOb1'];
    form.frameSerialNoOb2 = json['frameSerialNoOb2'];
    form.frameSerialNoRemark = json['frameSerialNoRemark'];

    form.frameMakeOb1 = json['frameMakeOb1'];
    form.frameMakeOb2 = json['frameMakeOb2'];
    form.frameMakeRemark = json['frameMakeRemark'];

    form.cornerKeyMakeOb1 = json['cornerKeyMakeOb1'];
    form.cornerKeyMakeOb2 = json['cornerKeyMakeOb2'];
    form.cornerKeyMakeRemark = json['cornerKeyMakeRemark'];

    form.profileCutAngleOb1 = json['profileCutAngleOb1'];
    form.profileCutAngleOb2 = json['profileCutAngleOb2'];
    form.profileCutAngleRemark = json['profileCutAngleRemark'];

    form.frameLengthOb1 = json['frameLengthOb1'];
    form.frameLengthOb2 = json['frameLengthOb2'];
    form.frameLengthRemark = json['frameLengthRemark'];

    form.frameWidthOb1 = json['frameWidthOb1'];
    form.frameWidthOb2 = json['frameWidthOb2'];
    form.frameWidthRemark = json['frameWidthRemark'];

    form.frameHeightOb1 = json['frameHeightOb1'];
    form.frameHeightOb2 = json['frameHeightOb2'];
    form.frameHeightRemark = json['frameHeightRemark'];

    form.mountingHoleOb1 = json['mountingHoleOb1'];
    form.mountingHoleOb2 = json['mountingHoleOb2'];
    form.mountingHoleRemark = json['mountingHoleRemark'];

    form.xPitchOb1 = json['xPitchOb1'];
    form.xPitchOb2 = json['xPitchOb2'];
    form.xPitchRemark = json['xPitchRemark'];

    form.yPitchOb1 = json['yPitchOb1'];
    form.yPitchOb2 = json['yPitchOb2'];
    form.yPitchRemark = json['yPitchRemark'];

    form.groundHoleDiaOb1 = json['groundHoleDiaOb1'];
    form.groundHoleDiaOb2 = json['groundHoleDiaOb2'];
    form.groundHoleDiaRemark = json['groundHoleDiaRemark'];

    form.groundHoleDistanceOb1 = json['groundHoleDistanceOb1'];
    form.groundHoleDistanceOb2 = json['groundHoleDistanceOb2'];
    form.groundHoleDistanceRemark = json['groundHoleDistanceRemark'];

    form.drainHoleSizeOb1 = json['drainHoleSizeOb1'];
    form.drainHoleSizeOb2 = json['drainHoleSizeOb2'];
    form.drainHoleSizeRemark = json['drainHoleSizeRemark'];

    form.drainHoleDistanceOb1 = json['drainHoleDistanceOb1'];
    form.drainHoleDistanceOb2 = json['drainHoleDistanceOb2'];
    form.drainHoleDistanceRemark = json['drainHoleDistanceRemark'];

    form.diagonalLengthOb1 = json['diagonalLengthOb1'];
    form.diagonalLengthOb2 = json['diagonalLengthOb2'];
    form.diagonalLengthRemark = json['diagonalLengthRemark'];

    form.sealantMakeOb1 = json['sealantMakeOb1'];
    form.sealantMakeOb2 = json['sealantMakeOb2'];
    form.sealantMakeRemark = json['sealantMakeRemark'];

    form.scratchDentsOb1 = json['scratchDentsOb1'];
    form.scratchDentsOb2 = json['scratchDentsOb2'];
    form.scratchDentsRemark = json['scratchDentsRemark'];

    form.sealantTypeOb1 = json['sealantTypeOb1'];
    form.sealantTypeOb2 = json['sealantTypeOb2'];
    form.sealantTypeRemark = json['sealantTypeRemark'];

    form.sealantWeightOb1 = json['sealantWeightOb1'];
    form.sealantWeightOb2 = json['sealantWeightOb2'];
    form.sealantWeightRemark = json['sealantWeightRemark'];

    form.frameDefectsOb1 = json['frameDefectsOb1'];
    form.frameDefectsOb2 = json['frameDefectsOb2'];
    form.frameDefectsRemark = json['frameDefectsRemark'];

    // Stage 15: Junction Box Assembly
    form.jbSerialNoOb1 = json['jbSerialNoOb1'];
    form.jbSerialNoOb2 = json['jbSerialNoOb2'];
    form.jbSerialNoRemark = json['jbSerialNoRemark'];

    form.jbMakeOb1 = json['jbMakeOb1'];
    form.jbMakeOb2 = json['jbMakeOb2'];
    form.jbMakeRemark = json['jbMakeRemark'];

    form.jbTypeOb1 = json['jbTypeOb1'];
    form.jbTypeOb2 = json['jbTypeOb2'];
    form.jbTypeRemark = json['jbTypeRemark'];

    form.diodeModelOb1 = json['diodeModelOb1'];
    form.diodeModelOb2 = json['diodeModelOb2'];
    form.diodeModelRemark = json['diodeModelRemark'];

    form.jbPlacementOb1 = json['jbPlacementOb1'];
    form.jbPlacementOb2 = json['jbPlacementOb2'];
    form.jbPlacementRemark = json['jbPlacementRemark'];

    form.jbSealantWeightsAOb1 = json['jbSealantWeightsAOb1'];
    form.jbSealantWeightsAOb2 = json['jbSealantWeightsAOb2'];
    form.jbSealantWeightsBOb1 = json['jbSealantWeightsBOb1'];
    form.jbSealantWeightsBOb2 = json['jbSealantWeightsBOb2'];
    form.jbSealantWeightsCOb1 = json['jbSealantWeightsCOb1'];
    form.jbSealantWeightsCOb2 = json['jbSealantWeightsCOb2'];
    form.jbSealantWeightsRemark = json['jbSealantWeightsRemark'];

    form.solderingQualityOb1 = json['solderingQualityOb1'];
    form.solderingQualityOb2 = json['solderingQualityOb2'];
    form.solderingQualityRemark = json['solderingQualityRemark'];

    form.pottingSealantMakeOb1 = json['pottingSealantMakeOb1'];
    form.pottingSealantMakeOb2 = json['pottingSealantMakeOb2'];
    form.pottingSealantMakeRemark = json['pottingSealantMakeRemark'];

    form.pottingSealantTypeOb1 = json['pottingSealantTypeOb1'];
    form.pottingSealantTypeOb2 = json['pottingSealantTypeOb2'];
    form.pottingSealantTypeRemark = json['pottingSealantTypeRemark'];

    form.pottingSealantExpiryOb1 = json['pottingSealantExpiryOb1'];
    form.pottingSealantExpiryOb2 = json['pottingSealantExpiryOb2'];
    form.pottingSealantExpiryRemark = json['pottingSealantExpiryRemark'];

    form.curingTimeOb1 = json['curingTimeOb1'];
    form.curingTimeOb2 = json['curingTimeOb2'];
    form.curingTimeRemark = json['curingTimeRemark'];

    form.pottingSealantWeightsAOb1 = json['pottingSealantWeightAOb1'];
    form.pottingSealantWeightsAOb2 = json['pottingSealantWeightAOb2'];

    form.pottingSealantWeightsBOb1 = json['pottingSealantWeightBOb1'];
    form.pottingSealantWeightsBOb2 = json['pottingSealantWeightBOb2'];

    form.pottingSealantWeightsCOb1 = json['pottingSealantWeightCOb1'];
    form.pottingSealantWeightsCOb2 = json['pottingSealantWeightCOb2'];
    form.pottingSealantWeightsRemark = json['pottingSealantWeightCRemark'];

    form.pottingRatioAOb1 = json['pottingRatioAOb1'];
    form.pottingRatioBOb1 = json['pottingRatioBOb1'];
    form.pottingRatioOb1 = json['pottingRatioOb1'];
    form.pottingRatioAOb2 = json['pottingRatioAOb2'];
    form.pottingRatioBOb2 = json['pottingRatioBOb2'];
    form.pottingRatioOb2 = json['pottingRatioOb2'];
    form.pottingRatioRemark = json['pottingRatioRemark'];

    form.cableLengthOb1 = json['cableLengthOb1'];
    form.cableLengthOb2 = json['cableLengthOb2'];
    form.cableLengthRemark = json['cableLengthRemark'];

    form.visualStatusOb1 = json['visualStatusOb1'];
    form.visualStatusOb2 = json['visualStatusOb2'];
    form.visualStatusRemark = json['visualStatusRemark'];

    // Stage 16: Curing Line
    form.curingTimeLineOb1 = json['curingTimeLineOb1'];
    form.curingTimeLineOb2 = json['curingTimeLineOb2'];
    form.curingTimeLineRemark = json['curingTimeLineRemark'];

    form.curingTempOb1 = json['curingTempOb1'];
    form.curingTempOb2 = json['curingTempOb2'];
    form.curingTempRemark = json['curingTempRemark'];

    form.curingHumidityOb1 = json['curingHumidityOb1'];
    form.curingHumidityOb2 = json['curingHumidityOb2'];
    form.curingHumidityRemark = json['curingHumidityRemark'];

    // Stage 17: Module Cleaning
    form.cleaningOkOb1 = json['cleaningOkOb1'];
    form.cleaningOkOb2 = json['cleaningOkOb2'];
    form.cleaningOkRemark = json['cleaningOkRemark'];

    // Stage 18: Hi-Pot Testing
    form.hipotSerialNoOb1 = json['hipotSerialNoOb1'];
    form.hipotSerialNoOb2 = json['hipotSerialNoOb2'];
    form.hipotSerialNoRemark = json['hipotSerialNoRemark'];

    form.dcwOb1 = json['dcwOb1'];
    form.dcwOb2 = json['dcwOb2'];
    form.dcwRemark = json['dcwRemark'];

    form.irOb1 = json['irOb1'];
    form.irOb2 = json['irOb2'];
    form.irRemark = json['irRemark'];

    form.groundContinuityOb1 = json['groundContinuityOb1'];
    form.groundContinuityOb2 = json['groundContinuityOb2'];
    form.groundContinuityRemark = json['groundContinuityRemark'];

    // Stage 19: Post-El Inspection
    form.postElSerialNoOb1 = json['postElSerialNoOb1'];
    form.postElSerialNoOb2 = json['postElSerialNoOb2'];
    form.postElSerialNoRemark = json['postElSerialNoRemark'];

    form.postElCurrentOb1 = json['postElCurrentOb1'];
    form.postElCurrentOb2 = json['postElCurrentOb2'];
    form.postElCurrentRemark = json['postElCurrentRemark'];

    form.postElVoltageOb1 = json['postElVoltageOb1'];
    form.postElVoltageOb2 = json['postElVoltageOb2'];
    form.postElVoltageRemark = json['postElVoltageRemark'];

    form.postElDefectsOb1 = json['postElDefectsOb1'];
    form.postElDefectsOb2 = json['postElDefectsOb2'];
    form.postElDefectsRemark = json['postElDefectsRemark'];

    // Stage 20: Sun Simulator
    form.calibrationDateOb1 = json['calibrationDateOb1'];
    form.calibrationDateOb2 = json['calibrationDateOb2'];
    form.calibrationDateRemark = json['calibrationDateRemark'];

    form.sunSerialNoOb1 = json['sunSerialNoOb1'];
    form.sunSerialNoOb2 = json['sunSerialNoOb2'];
    form.sunSerialNoRemark = json['sunSerialNoRemark'];

    form.modulePowerOb1 = json['modulePowerOb1'];
    form.modulePowerOb2 = json['modulePowerOb2'];
    form.modulePowerRemark = json['modulePowerRemark'];

    form.iscOb1 = json['iscOb1'];
    form.iscOb2 = json['iscOb2'];
    form.iscRemark = json['iscRemark'];

    form.vocOb1 = json['vocOb1'];
    form.vocOb2 = json['vocOb2'];
    form.vocRemark = json['vocRemark'];

    form.impOb1 = json['impOb1'];
    form.impOb2 = json['impOb2'];
    form.impRemark = json['impRemark'];

    form.vmpOb1 = json['vmpOb1'];
    form.vmpOb2 = json['vmpOb2'];
    form.vmpRemark = json['vmpRemark'];

    form.moduleTempOb1 = json['moduleTempOb1'];
    form.moduleTempOb2 = json['moduleTempOb2'];
    form.moduleTempRemark = json['moduleTempRemark'];

    form.fillFactorOb1 = json['fillFactorOb1'];
    form.fillFactorOb2 = json['fillFactorOb2'];
    form.fillFactorRemark = json['fillFactorRemark'];

    form.efficiencyOb1 = json['efficiencyOb1'];
    form.efficiencyOb2 = json['efficiencyOb2'];
    form.efficiencyRemark = json['efficiencyRemark'];

    form.ivCurveOkOb1 = json['ivCurveOkOb1'];
    form.ivCurveOkOb2 = json['ivCurveOkOb2'];
    form.ivCurveOkRemark = json['ivCurveOkRemark'];

    // Stage 21: FQC
    form.visualInspectionOb1 = json['visualInspectionOb1'];
    form.visualInspectionOb2 = json['visualInspectionOb2'];
    form.visualInspectionRemark = json['visualInspectionRemark'];

    form.jbCoverFitmentOb1 = json['jbCoverFitmentOb1'];
    form.jbCoverFitmentOb2 = json['jbCoverFitmentOb2'];
    form.jbCoverFitmentRemark = json['jbCoverFitmentRemark'];

    form.labelPlacementOb1 = json['labelPlacementOb1'];
    form.labelPlacementOb2 = json['labelPlacementOb2'];
    form.labelPlacementRemark = json['labelPlacementRemark'];

    form.fqcDefectsOb1 = json['fqcDefectsOb1'];
    form.fqcDefectsOb2 = json['fqcDefectsOb2'];
    form.fqcDefectsRemark = json['fqcDefectsRemark'];

    // Stage 22: Auto Sorter & Packing
    form.sortingStatusOb1 = json['sortingStatusOb1'];
    form.sortingStatusOb2 = json['sortingStatusOb2'];
    form.sortingStatusRemark = json['sortingStatusRemark'];

    form.palletConditionOb1 = json['palletConditionOb1'];
    form.palletConditionOb2 = json['palletConditionOb2'];
    form.palletConditionRemark = json['palletConditionRemark'];

    form.frontNotesController = json['frontNotesController'];
    form.backNotesController = json['backNotesController'];

    return form;
  }
}
