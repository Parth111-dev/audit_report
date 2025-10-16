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
  String createdAt = DateFormat.HOUR24_MINUTE_SECOND;

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

    // Initialize all fields with default values or null
    this.preLamTempOb1,
    this.preLamTempOb2,
    this.preLamTempRemark,
    this.laminationTempOb1,
    this.laminationTempOb2,
    this.laminationTempRemark,
    this.preLamHumidityOb1,
    this.preLamHumidityOb2,
    this.preLamHumidityRemark,

    this.glassMakeOb1,
    this.glassMakeOb2,
    this.glassMakeRemark,
    this.glassPalletNoOb1,
    this.glassPalletNoOb2,
    this.glassPalletNoRemark,
    this.glassSizeOb1,
    this.glassSizeOb2,
    this.glassSizeRemark,

    this.evaMakeOb1,
    this.evaMakeOb2,
    this.evaMakeRemark,
    this.evaTypeOb1,
    this.evaTypeOb2,
    this.evaTypeRemark,
    this.evaRollNoOb1,
    this.evaRollNoOb2,
    this.evaRollNoRemark,
    this.evaExpiryDateOb1,
    this.evaExpiryDateOb2,
    this.evaExpiryDateRemark,
    this.evaSizeOb1,
    this.evaSizeOb2,
    this.evaSizeRemark,

    this.cellMakeOb1,
    this.cellMakeOb2,
    this.cellMakeRemark,
    this.cellEfficiencyOb1,
    this.cellEfficiencyOb2,
    this.cellEfficiencyRemark,
    this.cellWattageOb1,
    this.cellWattageOb2,
    this.cellWattageRemark,
    this.cellSizeOb1,
    this.cellSizeOb2,
    this.cellSizeRemark,
    this.cellDefectsOb1,
    this.cellDefectsOb2,
    this.cellDefectsRemark,

    this.cleanlinessOb1,
    this.cleanlinessOb2,
    this.cleanlinessRemark,
    this.ribbonMakeOb1,
    this.ribbonMakeOb2,
    this.ribbonMakeRemark,
    this.ribbonSizeOb1,
    this.ribbonSizeOb2,
    this.ribbonSizeRemark,
    this.fluxMakeOb1,
    this.fluxMakeOb2,
    this.fluxMakeRemark,
    this.fluxTypeOb1,
    this.fluxTypeOb2,
    this.fluxTypeRemark,
    this.fluxExpiryDateOb1,
    this.fluxExpiryDateOb2,
    this.fluxExpiryDateRemark,

    this.solderingTempOb1,
    this.solderingTempOb2,
    this.solderingTempRemark,
    this.workingHeatersOb1,
    this.workingHeatersOb2,
    this.workingHeatersRemark,
    this.solderingPowerOb1,
    this.solderingPowerOb2,
    this.solderingPowerRemark,
    this.solderTimeOb1,
    this.solderTimeOb2,
    this.solderTimeRemark,

    this.ribbonAlignmentOb1,
    this.ribbonAlignmentOb2,
    this.ribbonAlignmentRemark,
    this.ribbonDimensionsOb1,
    this.ribbonDimensionsOb2,
    this.ribbonDimensionsRemark,
    this.cellToCellGapOb1,
    this.cellToCellGapOb2,
    this.cellToCellGapRemark,
    this.stringLengthOb1,
    this.stringLengthOb2,
    this.stringLengthRemark,
    this.peelTestResultOb1,
    this.peelTestResultOb2,
    this.peelTestResultRemark,
    this.elInspectionOb1,
    this.elInspectionOb2,
    this.elInspectionRemark,

    this.busbarMakeOb1,
    this.busbarMakeOb2,
    this.busbarMakeRemark,
    this.busbarSizeOb1,
    this.busbarSizeOb2,
    this.busbarSizeRemark,
    this.cellToBusbarDistanceOb1,
    this.cellToBusbarDistanceOb2,
    this.cellToBusbarDistanceRemark,
    this.stringToStringGapOb1,
    this.stringToStringGapOb2,
    this.stringToStringGapRemark,
    this.topSideGapOb1,
    this.topSideGapOb2,
    this.topSideGapRemark,
    this.middleSideGapOb1,
    this.middleSideGapOb2,
    this.middleSideGapRemark,
    this.bottomSideGapOb1,
    this.bottomSideGapOb2,
    this.bottomSideGapRemark,
    this.leftSideGapOb1,
    this.leftSideGapOb2,
    this.leftSideGapRemark,
    this.rightSideGapOb1,
    this.rightSideGapOb2,
    this.rightSideGapRemark,

    this.tapMakeOb1,
    this.tapMakeOb2,
    this.tapMakeRemark,
    this.tapPositionOb1,
    this.tapPositionOb2,
    this.tapPositionRemark,
    this.tapSizeOb1,
    this.tapSizeOb2,
    this.tapSizeRemark,

    this.rearEvaMakeOb1,
    this.rearEvaMakeOb2,
    this.rearEvaMakeRemark,
    this.rearEvaTypeOb1,
    this.rearEvaTypeOb2,
    this.rearEvaTypeRemark,
    this.rearEvaRollNoOb1,
    this.rearEvaRollNoOb2,
    this.rearEvaRollNoRemark,
    this.rearEvaExpiryDateOb1,
    this.rearEvaExpiryDateOb2,
    this.rearEvaExpiryDateRemark,
    this.rearEvaSizeOb1,
    this.rearEvaSizeOb2,
    this.rearEvaSizeRemark,

    this.backsheetMakeOb1,
    this.backsheetMakeOb2,
    this.backsheetMakeRemark,
    this.backsheetTypeOb1,
    this.backsheetTypeOb2,
    this.backsheetTypeRemark,
    this.backsheetRollNoOb1,
    this.backsheetRollNoOb2,
    this.backsheetRollNoRemark,
    this.backsheetDimensionsOb1,
    this.backsheetDimensionsOb2,
    this.backsheetDimensionsRemark,

    this.logoPositionOkOb1,
    this.logoPositionOkOb2,
    this.logoPositionOkRemark,
    this.barcodePositionOkOb1,
    this.barcodePositionOkOb2,
    this.barcodePositionOkRemark,

    this.preElSerialNoOb1,
    this.preElSerialNoOb2,
    this.preElSerialNoRemark,
    this.preElCurrentOb1,
    this.preElCurrentOb2,
    this.preElCurrentRemark,
    this.preElVoltageOb1,
    this.preElVoltageOb2,
    this.preElVoltageRemark,
    this.preElDefectsOb1,
    this.preElDefectsOb2,
    this.preElDefectsRemark,

    this.edgeTapingOkOb1,
    this.edgeTapingOkOb2,
    this.edgeTapingOkRemark,
    this.laminatorNoOb1,
    this.laminatorNoOb2,
    this.laminatorNoRemark,

    this.laminationTempsCh01Ob1,
    this.laminationTempsCh01Ob2,
    this.laminationTempsCh02Ob1,
    this.laminationTempsCh02Ob2,
    this.laminationTempsCh03Ob1,
    this.laminationTempsCh03Ob2,
    this.laminationTempsRemark,
    this.vacuumTimesCh01Ob1,
    this.vacuumTimesCh01Ob2,
    this.vacuumTimesCh02Ob1,
    this.vacuumTimesCh02Ob2,
    this.vacuumTimesCh03Ob1,
    this.vacuumTimesCh03Ob2,
    this.vacuumTimesRemark,
    this.upperventOneCh01Ob1,
    this.upperventOneCh01Ob2,
    this.upperventOneCh02Ob1,
    this.upperventOneCh02Ob2,
    this.upperventOneCh03Ob1,
    this.upperventOneCh03Ob2,
    this.upperventOneRemark,
    this.laminationOneCh01Ob1,
    this.laminationOneCh01Ob2,
    this.laminationOneCh02Ob1,
    this.laminationOneCh02Ob2,
    this.laminationOneCh03Ob1,
    this.laminationOneCh03Ob2,
    this.laminationOneRemark,
    this.upperventSecCh01Ob1,
    this.upperventSecCh01Ob2,
    this.upperventSecCh02Ob1,
    this.upperventSecCh02Ob2,
    this.upperventSecCh03Ob1,
    this.upperventSecCh03Ob2,
    this.upperventSecRemark,
    this.laminationSecCh01Ob1,
    this.laminationSecCh01Ob2,
    this.laminationSecCh02Ob1,
    this.laminationSecCh02Ob2,
    this.laminationSecCh03Ob1,
    this.laminationSecCh03Ob2,
    this.laminationSecRemark,
    this.upperventThirdCh01Ob1,
    this.upperventThirdCh01Ob2,
    this.upperventThirdCh02Ob1,
    this.upperventThirdCh02Ob2,
    this.upperventThirdCh03Ob1,
    this.upperventThirdCh03Ob2,
    this.upperventThirdRemark,
    this.laminationThirdCh01Ob1,
    this.laminationThirdCh01Ob2,
    this.laminationThirdCh02Ob1,
    this.laminationThirdCh02Ob2,
    this.laminationThirdCh03Ob1,
    this.laminationThirdCh03Ob2,
    this.laminationThirdRemark,
    this.lowerVentTimeCh01Ob1,
    this.lowerVentTimeCh01Ob2,
    this.lowerVentTimeCh02Ob1,
    this.lowerVentTimeCh02Ob2,
    this.lowerVentTimeCh03Ob1,
    this.lowerVentTimeCh03Ob2,
    this.lowerVentTimeRemark,
    this.totalCycleTimeCh01Ob1,
    this.totalCycleTimeCh01Ob2,
    this.totalCycleTimeCh02Ob1,
    this.totalCycleTimeCh02Ob2,
    this.totalCycleTimeCh03Ob1,
    this.totalCycleTimeCh03Ob2,
    this.totalCycleTimeRemark,

    this.trimmingOkOb1,
    this.trimmingOkOb2,
    this.trimmingOkRemark,

    this.frameSerialNoOb1,
    this.frameSerialNoOb2,
    this.frameSerialNoRemark,
    this.frameMakeOb1,
    this.frameMakeOb2,
    this.frameMakeRemark,
    this.cornerKeyMakeOb1,
    this.cornerKeyMakeOb2,
    this.cornerKeyMakeRemark,
    this.profileCutAngleOb1,
    this.profileCutAngleOb2,
    this.profileCutAngleRemark,
    this.frameLengthOb1,
    this.frameLengthOb2,
    this.frameLengthRemark,
    this.frameWidthOb1,
    this.frameWidthOb2,
    this.frameWidthRemark,
    this.frameHeightOb1,
    this.frameHeightOb2,
    this.frameHeightRemark,

    this.mountingHoleOb1,
    this.mountingHoleOb2,
    this.mountingHoleRemark,
    this.xPitchOb1,
    this.xPitchOb2,
    this.xPitchRemark,
    this.yPitchOb1,
    this.yPitchOb2,
    this.yPitchRemark,
    this.groundHoleDiaOb1,
    this.groundHoleDiaOb2,
    this.groundHoleDiaRemark,
    this.groundHoleDistanceOb1,
    this.groundHoleDistanceOb2,
    this.groundHoleDistanceRemark,
    this.drainHoleSizeOb1,
    this.drainHoleSizeOb2,
    this.drainHoleSizeRemark,
    this.drainHoleDistanceOb1,
    this.drainHoleDistanceOb2,
    this.drainHoleDistanceRemark,
    this.diagonalLengthOb1,
    this.diagonalLengthOb2,
    this.diagonalLengthRemark,

    this.sealantMakeOb1,
    this.sealantMakeOb2,
    this.sealantMakeRemark,
    this.sealantTypeOb1,
    this.sealantTypeOb2,
    this.sealantTypeRemark,
    this.sealantWeightOb1,
    this.sealantWeightOb2,
    this.sealantWeightRemark,
    this.scratchDentsOb1,
    this.scratchDentsOb2,
    this.scratchDentsRemark,
    this.frameDefectsOb1,
    this.frameDefectsOb2,
    this.frameDefectsRemark,

    this.jbSerialNoOb1,
    this.jbSerialNoOb2,
    this.jbSerialNoRemark,
    this.jbMakeOb1,
    this.jbMakeOb2,
    this.jbMakeRemark,
    this.jbTypeOb1,
    this.jbTypeOb2,
    this.jbTypeRemark,
    this.diodeModelOb1,
    this.diodeModelOb2,
    this.diodeModelRemark,
    this.jbPlacementOb1,
    this.jbPlacementOb2,
    this.jbPlacementRemark,

    this.jbSealantWeightsAOb1,
    this.jbSealantWeightsAOb2,
    this.jbSealantWeightsBOb1,
    this.jbSealantWeightsBOb2,
    this.jbSealantWeightsCOb1,
    this.jbSealantWeightsCOb2,
    this.jbSealantWeightsRemark,

    this.solderingQualityOb1,
    this.solderingQualityOb2,
    this.solderingQualityRemark,
    this.pottingSealantMakeOb1,
    this.pottingSealantMakeOb2,
    this.pottingSealantMakeRemark,
    this.pottingSealantTypeOb1,
    this.pottingSealantTypeOb2,
    this.pottingSealantTypeRemark,
    this.pottingSealantExpiryOb1,
    this.pottingSealantExpiryOb2,
    this.pottingSealantExpiryRemark,

    this.curingTimeOb1,
    this.curingTimeOb2,
    this.curingTimeRemark,

    this.pottingSealantWeightsAOb1,
    this.pottingSealantWeightsAOb2,
    this.pottingSealantWeightsBOb1,
    this.pottingSealantWeightsBOb2,
    this.pottingSealantWeightsCOb1,
    this.pottingSealantWeightsCOb2,
    this.pottingSealantWeightsRemark,
    this.pottingRatioAOb1,
    this.pottingRatioBOb1,
    this.pottingRatioOb1,
    this.pottingRatioAOb2,
    this.pottingRatioBOb2,
    this.pottingRatioOb2,
    this.pottingRatioRemark,

    this.cableLengthOb1,
    this.cableLengthOb2,
    this.cableLengthRemark,
    this.visualStatusOb1,
    this.visualStatusOb2,
    this.visualStatusRemark,

    this.curingTimeLineOb1,
    this.curingTimeLineOb2,
    this.curingTimeLineRemark,
    this.curingTempOb1,
    this.curingTempOb2,
    this.curingTempRemark,
    this.curingHumidityOb1,
    this.curingHumidityOb2,
    this.curingHumidityRemark,

    this.cleaningOkOb1,
    this.cleaningOkOb2,
    this.cleaningOkRemark,

    this.hipotSerialNoOb1,
    this.hipotSerialNoOb2,
    this.hipotSerialNoRemark,
    this.dcwOb1,
    this.dcwOb2,
    this.dcwRemark,
    this.irOb1,
    this.irOb2,
    this.irRemark,
    this.groundContinuityOb1,
    this.groundContinuityOb2,
    this.groundContinuityRemark,

    this.postElSerialNoOb1,
    this.postElSerialNoOb2,
    this.postElSerialNoRemark,
    this.postElCurrentOb1,
    this.postElCurrentOb2,
    this.postElCurrentRemark,
    this.postElVoltageOb1,
    this.postElVoltageOb2,
    this.postElVoltageRemark,
    this.postElDefectsOb1,
    this.postElDefectsOb2,
    this.postElDefectsRemark,

    this.calibrationDateOb1,
    this.calibrationDateOb2,
    this.calibrationDateRemark,
    this.sunSerialNoOb1,
    this.sunSerialNoOb2,
    this.sunSerialNoRemark,
    this.modulePowerOb1,
    this.modulePowerOb2,
    this.modulePowerRemark,
    this.iscOb1,
    this.iscOb2,
    this.iscRemark,
    this.vocOb1,
    this.vocOb2,
    this.vocRemark,
    this.impOb1,
    this.impOb2,
    this.impRemark,
    this.vmpOb1,
    this.vmpOb2,
    this.vmpRemark,
    this.moduleTempOb1,
    this.moduleTempOb2,
    this.moduleTempRemark,
    this.fillFactorOb1,
    this.fillFactorOb2,
    this.fillFactorRemark,
    this.efficiencyOb1,
    this.efficiencyOb2,
    this.efficiencyRemark,
    this.ivCurveOkOb1,
    this.ivCurveOkOb2,
    this.ivCurveOkRemark,

    this.visualInspectionOb1,
    this.visualInspectionOb2,
    this.visualInspectionRemark,
    this.jbCoverFitmentOb1,
    this.jbCoverFitmentOb2,
    this.jbCoverFitmentRemark,
    this.labelPlacementOb1,
    this.labelPlacementOb2,
    this.labelPlacementRemark,
    this.fqcDefectsOb1,
    this.fqcDefectsOb2,
    this.fqcDefectsRemark,
    this.sortingStatusOb1,
    this.sortingStatusOb2,
    this.sortingStatusRemark,
    this.palletConditionOb1,
    this.palletConditionOb2,
    this.palletConditionRemark,

    this.frontNotesController,
    this.backNotesController,
  });

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
    return AuditForm(
      id: parseMongoId(json['_id']),
      serialNumber: json['serialNumber'] ?? '',
      auditDate: parseAuditDate(json['auditDate']),
      auditorName: json['auditorName'] ?? '',
      verifiedBy: json['verifiedBy'] ?? '',
      shift: json['shift'] ?? '',
      po: json['po'] ?? '',
      moduleType: json['moduleType'] ?? '',
      createdAt: json['createdAt'] ?? '',

      // Stage 1: Floor
      preLamTempOb1: json['preLamTempOb1'],
      preLamTempOb2: json['preLamTempOb2'],
      preLamTempRemark: json['preLamTempRemark'],

      laminationTempOb1: json['laminationTempOb1'],
      laminationTempOb2: json['laminationTempOb2'],
      laminationTempRemark: json['laminationTempRemark'],

      preLamHumidityOb1: json['preLamHumidityOb1'],
      preLamHumidityOb2: json['preLamHumidityOb2'],
      preLamHumidityRemark: json['preLamHumidityRemark'],

      // Stage 2: Front Glass Loading
      glassMakeOb1: json['glassMakeOb1'],
      glassMakeOb2: json['glassMakeOb2'],
      glassMakeRemark: json['glassMakeRemark'],

      glassPalletNoOb1: json['glassPalletNoOb1'],
      glassPalletNoOb2: json['glassPalletNoOb2'],
      glassPalletNoRemark: json['glassPalletNoRemark'],

      glassSizeOb1: json['glassSizeOb1'],
      glassSizeOb2: json['glassSizeOb2'],
      glassSizeRemark: json['glassSizeRemark'],

      // Stage 3: Front side EVA Cutting
      evaMakeOb1: json['evaMakeOb1'],
      evaMakeOb2: json['evaMakeOb2'],
      evaMakeRemark: json['evaMakeRemark'],

      evaTypeOb1: json['evaTypeOb1'],
      evaTypeOb2: json['evaTypeOb2'],
      evaTypeRemark: json['evaTypeRemark'],

      evaRollNoOb1: json['evaRollNoOb1'],
      evaRollNoOb2: json['evaRollNoOb2'],
      evaRollNoRemark: json['evaRollNoRemark'],

      evaExpiryDateOb1: json['evaExpiryDateOb1'],
      evaExpiryDateOb2: json['evaExpiryDateOb2'],
      evaExpiryDateRemark: json['evaExpiryDateRemark'],

      evaSizeOb1: json['evaSizeOb1'],
      evaSizeOb2: json['evaSizeOb2'],
      evaSizeRemark: json['evaSizeRemark'],

      // Stage 4: Stringer
      cellMakeOb1: json['cellMakeOb1'],
      cellMakeOb2: json['cellMakeOb2'],
      cellMakeRemark: json['cellMakeRemark'],

      cellEfficiencyOb1: json['cellEfficiencyOb1'],
      cellEfficiencyOb2: json['cellEfficiencyOb2'],
      cellEfficiencyRemark: json['cellEfficiencyRemark'],

      cellWattageOb1: json['cellWattageOb1'],
      cellWattageOb2: json['cellWattageOb2'],
      cellWattageRemark: json['cellWattageRemark'],

      cellSizeOb1: json['cellSizeOb1'],
      cellSizeOb2: json['cellSizeOb2'],
      cellSizeRemark: json['cellSizeRemark'],

      cellDefectsOb1: json['cellDefectsOb1'],
      cellDefectsOb2: json['cellDefectsOb2'],
      cellDefectsRemark: json['cellDefectsRemark'],

      cleanlinessOb1: json['cleanlinessOb1'],
      cleanlinessOb2: json['cleanlinessOb2'],
      cleanlinessRemark: json['cleanlinessRemark'],

      ribbonMakeOb1: json['ribbonMakeOb1'],
      ribbonMakeOb2: json['ribbonMakeOb2'],
      ribbonMakeRemark: json['ribbonMakeRemark'],

      ribbonSizeOb1: json['ribbonSizeOb1'],
      ribbonSizeOb2: json['ribbonSizeOb2'],
      ribbonSizeRemark: json['ribbonSizeRemark'],

      fluxMakeOb1: json['fluxMakeOb1'],
      fluxMakeOb2: json['fluxMakeOb2'],
      fluxMakeRemark: json['fluxMakeRemark'],

      fluxTypeOb1: json['fluxTypeOb1'],
      fluxTypeOb2: json['fluxTypeOb2'],
      fluxTypeRemark: json['fluxTypeRemark'],

      fluxExpiryDateOb1: json['fluxExpiryDateOb1'],
      fluxExpiryDateOb2: json['fluxExpiryDateOb2'],
      fluxExpiryDateRemark: json['fluxExpiryDateRemark'],

      solderingTempOb1: json['solderingTempOb1'],
      solderingTempOb2: json['solderingTempOb2'],
      solderingTempRemark: json['solderingTempRemark'],

      workingHeatersOb1: json['workingHeatersOb1'],
      workingHeatersOb2: json['workingHeatersOb2'],
      workingHeatersRemark: json['workingHeatersRemark'],

      solderingPowerOb1: json['solderingPowerOb1'],
      solderingPowerOb2: json['solderingPowerOb2'],
      solderingPowerRemark: json['solderingPowerRemark'],

      solderTimeOb1: json['solderTimeOb1'],
      solderTimeOb2: json['solderTimeOb2'],
      solderTimeRemark: json['solderTimeRemark'],

      ribbonAlignmentOb1: json['ribbonAlignmentOb1'],
      ribbonAlignmentOb2: json['ribbonAlignmentOb2'],
      ribbonAlignmentRemark: json['ribbonAlignmentRemark'],

      ribbonDimensionsOb1: json['ribbonDimensionsOb1'],
      ribbonDimensionsOb2: json['ribbonDimensionsOb2'],
      ribbonDimensionsRemark: json['ribbonDimensionsRemark'],

      cellToCellGapOb1: json['cellToCellGapOb1'],
      cellToCellGapOb2: json['cellToCellGapOb2'],
      cellToCellGapRemark: json['cellToCellGapRemark'],

      stringLengthOb1: json['stringLengthOb1'],
      stringLengthOb2: json['stringLengthOb2'],
      stringLengthRemark: json['stringLengthRemark'],

      peelTestResultOb1: json['peelTestResultOb1'],
      peelTestResultOb2: json['peelTestResultOb2'],
      peelTestResultRemark: json['peelTestResultRemark'],

      elInspectionOb1: json['elInspectionOb1'],
      elInspectionOb2: json['elInspectionOb2'],
      elInspectionRemark: json['elInspectionRemark'],

      // Stage 5: Lay-up & Auto Bussing
      busbarMakeOb1: json['busbarMakeOb1'],
      busbarMakeOb2: json['busbarMakeOb2'],
      busbarMakeRemark: json['busbarMakeRemark'],

      busbarSizeOb1: json['busbarSizeOb1'],
      busbarSizeOb2: json['busbarSizeOb2'],
      busbarSizeRemark: json['busbarSizeRemark'],

      cellToBusbarDistanceOb1: json['cellToBusbarDistanceOb1'],
      cellToBusbarDistanceOb2: json['cellToBusbarDistanceOb2'],
      cellToBusbarDistanceRemark: json['cellToBusbarDistanceRemark'],

      stringToStringGapOb1: json['stringToStringGapOb1'],
      stringToStringGapOb2: json['stringToStringGapOb2'],
      stringToStringGapRemark: json['stringToStringGapRemark'],

      topSideGapOb1: json['topSideGapOb1'],
      topSideGapOb2: json['topSideGapOb2'],
      topSideGapRemark: json['topSideGapRemark'],

      middleSideGapOb1: json['middleSideGapOb1'],
      middleSideGapOb2: json['middleSideGapOb2'],
      middleSideGapRemark: json['middleSideGapRemark'],

      bottomSideGapOb1: json['bottomSideGapOb1'],
      bottomSideGapOb2: json['bottomSideGapOb2'],
      bottomSideGapRemark: json['bottomSideGapRemark'],

      leftSideGapOb1: json['leftSideGapOb1'],
      leftSideGapOb2: json['leftSideGapOb2'],
      leftSideGapRemark: json['leftSideGapRemark'],

      rightSideGapOb1: json['rightSideGapOb1'],
      rightSideGapOb2: json['rightSideGapOb2'],
      rightSideGapRemark: json['rightSideGapRemark'],

      // Stage 6: Auto Tapping
      tapMakeOb1: json['tapMakeOb1'],
      tapMakeOb2: json['tapMakeOb2'],
      tapMakeRemark: json['tapMakeRemark'],

      tapPositionOb1: json['tapPositionOb1'],
      tapPositionOb2: json['tapPositionOb2'],
      tapPositionRemark: json['tapPositionRemark'],

      tapSizeOb1: json['tapSizeOb1'],
      tapSizeOb2: json['tapSizeOb2'],
      tapSizeRemark: json['tapSizeRemark'],

      // Stage 7: Rear side EVA Cutting
      rearEvaMakeOb1: json['rearEvaMakeOb1'],
      rearEvaMakeOb2: json['rearEvaMakeOb2'],
      rearEvaMakeRemark: json['rearEvaMakeRemark'],

      rearEvaTypeOb1: json['rearEvaTypeOb1'],
      rearEvaTypeOb2: json['rearEvaTypeOb2'],
      rearEvaTypeRemark: json['rearEvaTypeRemark'],

      rearEvaRollNoOb1: json['rearEvaRollNoOb1'],
      rearEvaRollNoOb2: json['rearEvaRollNoOb2'],
      rearEvaRollNoRemark: json['rearEvaRollNoRemark'],

      rearEvaExpiryDateOb1: json['rearEvaExpiryDateOb1'],
      rearEvaExpiryDateOb2: json['rearEvaExpiryDateOb2'],
      rearEvaExpiryDateRemark: json['rearEvaExpiryDateRemark'],

      rearEvaSizeOb1: json['rearEvaSizeOb1'],
      rearEvaSizeOb2: json['rearEvaSizeOb2'],
      rearEvaSizeRemark: json['rearEvaSizeRemark'],

      // Stage 8: Rear Side Back Sheet/Glass
      backsheetMakeOb1: json['backsheetMakeOb1'],
      backsheetMakeOb2: json['backsheetMakeOb2'],
      backsheetMakeRemark: json['backsheetMakeRemark'],

      backsheetTypeOb1: json['backsheetTypeOb1'],
      backsheetTypeOb2: json['backsheetTypeOb2'],
      backsheetTypeRemark: json['backsheetTypeRemark'],

      backsheetRollNoOb1: json['backsheetRollNoOb1'],
      backsheetRollNoOb2: json['backsheetRollNoOb2'],
      backsheetRollNoRemark: json['backsheetRollNoRemark'],

      backsheetDimensionsOb1: json['backsheetDimensionsOb1'],
      backsheetDimensionsOb2: json['backsheetDimensionsOb2'],
      backsheetDimensionsRemark: json['backsheetDimensionsRemark'],

      // Stage 9: Logo & Barcode Fixing
      logoPositionOkOb1: json['logoPositionOkOb1'],
      logoPositionOkOb2: json['logoPositionOkOb2'],
      logoPositionOkRemark: json['logoPositionOkRemark'],

      barcodePositionOkOb1: json['barcodePositionOkOb1'],
      barcodePositionOkOb2: json['barcodePositionOkOb2'],
      barcodePositionOkRemark: json['barcodePositionOkRemark'],

      // Continue for remaining stages...
      // Stage 10: Pre-El Inspection
      preElSerialNoOb1: json['preElSerialNoOb1'],
      preElSerialNoOb2: json['preElSerialNoOb2'],
      preElSerialNoRemark: json['preElSerialNoRemark'],

      preElCurrentOb1: json['preElCurrentOb1'],
      preElCurrentOb2: json['preElCurrentOb2'],
      preElCurrentRemark: json['preElCurrentRemark'],

      preElVoltageOb1: json['preElVoltageOb1'],
      preElVoltageOb2: json['preElVoltageOb2'],
      preElVoltageRemark: json['preElVoltageRemark'],

      preElDefectsOb1: json['preElDefectsOb1'],
      preElDefectsOb2: json['preElDefectsOb2'],
      preElDefectsRemark: json['preElDefectsRemark'],

      // Stage 11: Auto Edge Taping
      edgeTapingOkOb1: json['edgeTapingOkOb1'],
      edgeTapingOkOb2: json['edgeTapingOkOb2'],
      edgeTapingOkRemark: json['edgeTapingOkRemark'],

      // Stage 12: Lamination Process
      laminatorNoOb1: json['laminatorNoOb1'],
      laminatorNoOb2: json['laminatorNoOb2'],
      laminatorNoRemark: json['laminatorNoRemark'],

      // For lamination temps (converting from individual fields)
      laminationTempsCh01Ob1: json['laminationTempsCh01Ob1'],
      laminationTempsCh01Ob2: json['laminationTempsCh01Ob2'],

      laminationTempsCh02Ob1: json['laminationTempsCh02Ob1'],
      laminationTempsCh02Ob2: json['laminationTempsCh02Ob2'],

      laminationTempsCh03Ob1: json['laminationTempsCh03Ob1'],
      laminationTempsCh03Ob2: json['laminationTempsCh03Ob2'],
      laminationTempsRemark: json['laminationTempsRemark'],

      vacuumTimesCh01Ob1: json['vacuumTimesCh01Ob1'],
      vacuumTimesCh01Ob2: json['vacuumTimesCh01Ob2'],

      vacuumTimesCh02Ob1: json['vacuumTimesCh02Ob1'],
      vacuumTimesCh02Ob2: json['vacuumTimesCh02Ob2'],

      vacuumTimesCh03Ob1: json['vacuumTimesCh03Ob1'],
      vacuumTimesCh03Ob2: json['vacuumTimesCh03Ob2'],
      vacuumTimesRemark: json['vacuumTimesRemark'],

      // upper Vent 1
      upperventOneCh01Ob1: json['upperventOneCh01Ob1'],
      upperventOneCh01Ob2: json['upperventOneCh01Ob2'],

      upperventOneCh02Ob1: json['upperventOneCh02Ob1'],
      upperventOneCh02Ob2: json['upperventOneCh02Ob2'],

      upperventOneCh03Ob1: json['upperventOneCh03Ob1'],
      upperventOneCh03Ob2: json['upperventOneCh03Ob2'],
      upperventOneRemark: json['upperventOneRemark'],

      // lamination 1
      laminationOneCh01Ob1: json['laminationOneCh01Ob1'],
      laminationOneCh01Ob2: json['laminationOneCh01Ob2'],

      laminationOneCh02Ob1: json['laminationOneCh02Ob1'],
      laminationOneCh02Ob2: json['laminationOneCh02Ob2'],

      laminationOneCh03Ob1: json['laminationOneCh03Ob1'],
      laminationOneCh03Ob2: json['laminationOneCh03Ob2'],
      laminationOneRemark: json['laminationOneRemark'],

      // upper Vent 2
      upperventSecCh01Ob1: json['upperventSecCh01Ob1'],
      upperventSecCh01Ob2: json['upperventSecCh01Ob2'],

      upperventSecCh02Ob1: json['upperventSecCh02Ob1'],
      upperventSecCh02Ob2: json['upperventSecCh02Ob2'],

      upperventSecCh03Ob1: json['upperventSecCh03Ob1'],
      upperventSecCh03Ob2: json['upperventSecCh03Ob2'],
      upperventSecRemark: json['upperventSecRemark'],

      // lamination 2
      laminationSecCh01Ob1: json['laminationSecCh01Ob1'],
      laminationSecCh01Ob2: json['laminationSecCh01Ob2'],

      laminationSecCh02Ob1: json['laminationSecCh02Ob1'],
      laminationSecCh02Ob2: json['laminationSecCh02Ob2'],

      laminationSecCh03Ob1: json['laminationSecCh03Ob1'],
      laminationSecCh03Ob2: json['laminationSecCh03Ob2'],
      laminationSecRemark: json['laminationSecRemark'],

      // upper Vent 3
      upperventThirdCh01Ob1: json['upperventThirdCh01Ob1'],
      upperventThirdCh01Ob2: json['upperventThirdCh01Ob2'],

      upperventThirdCh02Ob1: json['upperventThirdCh02Ob1'],
      upperventThirdCh02Ob2: json['upperventThirdCh02Ob2'],

      upperventThirdCh03Ob1: json['upperventThirdCh03Ob1'],
      upperventThirdCh03Ob2: json['upperventThirdCh03Ob2'],
      upperventThirdRemark: json['upperventThirdRemark'],

      // lamination 3
      laminationThirdCh01Ob1: json['laminationThirdCh01Ob1'],
      laminationThirdCh01Ob2: json['laminationThirdCh01Ob2'],

      laminationThirdCh02Ob1: json['laminationThirdCh02Ob1'],
      laminationThirdCh02Ob2: json['laminationThirdCh02Ob2'],

      laminationThirdCh03Ob1: json['laminationThirdCh03Ob1'],
      laminationThirdCh03Ob2: json['laminationThirdCh03Ob2'],
      laminationThirdRemark: json['laminationThirdRemark'],

      // lowe vent time
      lowerVentTimeCh01Ob1: json['lowerVentTimeCh01Ob1'],
      lowerVentTimeCh01Ob2: json['lowerVentTimeCh01Ob2'],

      lowerVentTimeCh02Ob1: json['lowerVentTimeCh02Ob1'],
      lowerVentTimeCh02Ob2: json['lowerVentTimeCh02Ob2'],

      lowerVentTimeCh03Ob1: json['lowerVentTimeCh03Ob1'],
      lowerVentTimeCh03Ob2: json['lowerVentTimeCh03Ob2'],
      lowerVentTimeRemark: json['lowerVentTimeRemark'],

      // Total cycle time
      totalCycleTimeCh01Ob1: json['totalCycleTimeCh01Ob1'],
      totalCycleTimeCh01Ob2: json['totalCycleTimeCh01Ob2'],

      totalCycleTimeCh02Ob1: json['totalCycleTimeCh02Ob1'],
      totalCycleTimeCh02Ob2: json['totalCycleTimeCh02Ob2'],

      totalCycleTimeCh03Ob1: json['totalCycleTimeCh03Ob1'],
      totalCycleTimeCh03Ob2: json['totalCycleTimeCh03Ob2'],
      totalCycleTimeRemark: json['totalCycleTimeRemark'],

      // Stage 13: Auto Edge Trimming
      trimmingOkOb1: json['trimmingOkOb1'],
      trimmingOkOb2: json['trimmingOkOb2'],
      trimmingOkRemark: json['trimmingOkRemark'],

      // Stage 14: Framing Process
      frameSerialNoOb1: json['frameSerialNoOb1'],
      frameSerialNoOb2: json['frameSerialNoOb2'],
      frameSerialNoRemark: json['frameSerialNoRemark'],

      frameMakeOb1: json['frameMakeOb1'],
      frameMakeOb2: json['frameMakeOb2'],
      frameMakeRemark: json['frameMakeRemark'],

      cornerKeyMakeOb1: json['cornerKeyMakeOb1'],
      cornerKeyMakeOb2: json['cornerKeyMakeOb2'],
      cornerKeyMakeRemark: json['cornerKeyMakeRemark'],

      profileCutAngleOb1: json['profileCutAngleOb1'],
      profileCutAngleOb2: json['profileCutAngleOb2'],
      profileCutAngleRemark: json['profileCutAngleRemark'],

      frameLengthOb1: json['frameLengthOb1'],
      frameLengthOb2: json['frameLengthOb2'],
      frameLengthRemark: json['frameLengthRemark'],

      frameWidthOb1: json['frameWidthOb1'],
      frameWidthOb2: json['frameWidthOb2'],
      frameWidthRemark: json['frameWidthRemark'],

      frameHeightOb1: json['frameHeightOb1'],
      frameHeightOb2: json['frameHeightOb2'],
      frameHeightRemark: json['frameHeightRemark'],

      mountingHoleOb1: json['mountingHoleOb1'],
      mountingHoleOb2: json['mountingHoleOb2'],
      mountingHoleRemark: json['mountingHoleRemark'],

      xPitchOb1: json['xPitchOb1'],
      xPitchOb2: json['xPitchOb2'],
      xPitchRemark: json['xPitchRemark'],

      yPitchOb1: json['yPitchOb1'],
      yPitchOb2: json['yPitchOb2'],
      yPitchRemark: json['yPitchRemark'],

      groundHoleDiaOb1: json['groundHoleDiaOb1'],
      groundHoleDiaOb2: json['groundHoleDiaOb2'],
      groundHoleDiaRemark: json['groundHoleDiaRemark'],

      groundHoleDistanceOb1: json['groundHoleDistanceOb1'],
      groundHoleDistanceOb2: json['groundHoleDistanceOb2'],
      groundHoleDistanceRemark: json['groundHoleDistanceRemark'],

      drainHoleSizeOb1: json['drainHoleSizeOb1'],
      drainHoleSizeOb2: json['drainHoleSizeOb2'],
      drainHoleSizeRemark: json['drainHoleSizeRemark'],

      drainHoleDistanceOb1: json['drainHoleDistanceOb1'],
      drainHoleDistanceOb2: json['drainHoleDistanceOb2'],
      drainHoleDistanceRemark: json['drainHoleDistanceRemark'],

      diagonalLengthOb1: json['diagonalLengthOb1'],
      diagonalLengthOb2: json['diagonalLengthOb2'],
      diagonalLengthRemark: json['diagonalLengthRemark'],

      sealantMakeOb1: json['sealantMakeOb1'],
      sealantMakeOb2: json['sealantMakeOb2'],
      sealantMakeRemark: json['sealantMakeRemark'],

      scratchDentsOb1: json['scratchDentsOb1'],
      scratchDentsOb2: json['scratchDentsOb2'],
      scratchDentsRemark: json['scratchDentsRemark'],

      sealantTypeOb1: json['sealantTypeOb1'],
      sealantTypeOb2: json['sealantTypeOb2'],
      sealantTypeRemark: json['sealantTypeRemark'],

      sealantWeightOb1: json['sealantWeightOb1'],
      sealantWeightOb2: json['sealantWeightOb2'],
      sealantWeightRemark: json['sealantWeightRemark'],

      frameDefectsOb1: json['frameDefectsOb1'],
      frameDefectsOb2: json['frameDefectsOb2'],
      frameDefectsRemark: json['frameDefectsRemark'],

      // Stage 15: Junction Box Assembly
      jbSerialNoOb1: json['jbSerialNoOb1'],
      jbSerialNoOb2: json['jbSerialNoOb2'],
      jbSerialNoRemark: json['jbSerialNoRemark'],

      jbMakeOb1: json['jbMakeOb1'],
      jbMakeOb2: json['jbMakeOb2'],
      jbMakeRemark: json['jbMakeRemark'],

      jbTypeOb1: json['jbTypeOb1'],
      jbTypeOb2: json['jbTypeOb2'],
      jbTypeRemark: json['jbTypeRemark'],

      diodeModelOb1: json['diodeModelOb1'],
      diodeModelOb2: json['diodeModelOb2'],
      diodeModelRemark: json['diodeModelRemark'],

      jbPlacementOb1: json['jbPlacementOb1'],
      jbPlacementOb2: json['jbPlacementOb2'],
      jbPlacementRemark: json['jbPlacementRemark'],

      jbSealantWeightsAOb1: json['jbSealantWeightsAOb1'],
      jbSealantWeightsAOb2: json['jbSealantWeightsAOb2'],
      jbSealantWeightsBOb1: json['jbSealantWeightsBOb1'],
      jbSealantWeightsBOb2: json['jbSealantWeightsBOb2'],
      jbSealantWeightsCOb1: json['jbSealantWeightsCOb1'],
      jbSealantWeightsCOb2: json['jbSealantWeightsCOb2'],
      jbSealantWeightsRemark: json['jbSealantWeightsRemark'],

      solderingQualityOb1: json['solderingQualityOb1'],
      solderingQualityOb2: json['solderingQualityOb2'],
      solderingQualityRemark: json['solderingQualityRemark'],

      pottingSealantMakeOb1: json['pottingSealantMakeOb1'],
      pottingSealantMakeOb2: json['pottingSealantMakeOb2'],
      pottingSealantMakeRemark: json['pottingSealantMakeRemark'],

      pottingSealantTypeOb1: json['pottingSealantTypeOb1'],
      pottingSealantTypeOb2: json['pottingSealantTypeOb2'],
      pottingSealantTypeRemark: json['pottingSealantTypeRemark'],

      pottingSealantExpiryOb1: json['pottingSealantExpiryOb1'],
      pottingSealantExpiryOb2: json['pottingSealantExpiryOb2'],
      pottingSealantExpiryRemark: json['pottingSealantExpiryRemark'],

      curingTimeOb1: json['curingTimeOb1'],
      curingTimeOb2: json['curingTimeOb2'],
      curingTimeRemark: json['curingTimeRemark'],

      pottingSealantWeightsAOb1: json['pottingSealantWeightAOb1'],
      pottingSealantWeightsAOb2: json['pottingSealantWeightAOb2'],

      pottingSealantWeightsBOb1: json['pottingSealantWeightBOb1'],
      pottingSealantWeightsBOb2: json['pottingSealantWeightBOb2'],

      pottingSealantWeightsCOb1: json['pottingSealantWeightCOb1'],
      pottingSealantWeightsCOb2: json['pottingSealantWeightCOb2'],
      pottingSealantWeightsRemark: json['pottingSealantWeightCRemark'],

      pottingRatioAOb1: json['pottingRatioAOb1'],
      pottingRatioBOb1: json['pottingRatioBOb1'],
      pottingRatioOb1: json['pottingRatioOb1'],
      pottingRatioAOb2: json['pottingRatioAOb2'],
      pottingRatioBOb2: json['pottingRatioBOb2'],
      pottingRatioOb2: json['pottingRatioOb2'],
      pottingRatioRemark: json['pottingRatioRemark'],

      cableLengthOb1: json['cableLengthOb1'],
      cableLengthOb2: json['cableLengthOb2'],
      cableLengthRemark: json['cableLengthRemark'],

      visualStatusOb1: json['visualStatusOb1'],
      visualStatusOb2: json['visualStatusOb2'],
      visualStatusRemark: json['visualStatusRemark'],

      // Stage 16: Curing Line
      curingTimeLineOb1: json['curingTimeLineOb1'],
      curingTimeLineOb2: json['curingTimeLineOb2'],
      curingTimeLineRemark: json['curingTimeLineRemark'],

      curingTempOb1: json['curingTempOb1'],
      curingTempOb2: json['curingTempOb2'],
      curingTempRemark: json['curingTempRemark'],

      curingHumidityOb1: json['curingHumidityOb1'],
      curingHumidityOb2: json['curingHumidityOb2'],
      curingHumidityRemark: json['curingHumidityRemark'],

      // Stage 17: Module Cleaning
      cleaningOkOb1: json['cleaningOkOb1'],
      cleaningOkOb2: json['cleaningOkOb2'],
      cleaningOkRemark: json['cleaningOkRemark'],

      // Stage 18: Hi-Pot Testing
      hipotSerialNoOb1: json['hipotSerialNoOb1'],
      hipotSerialNoOb2: json['hipotSerialNoOb2'],
      hipotSerialNoRemark: json['hipotSerialNoRemark'],

      dcwOb1: json['dcwOb1'],
      dcwOb2: json['dcwOb2'],
      dcwRemark: json['dcwRemark'],

      irOb1: json['irOb1'],
      irOb2: json['irOb2'],
      irRemark: json['irRemark'],

      groundContinuityOb1: json['groundContinuityOb1'],
      groundContinuityOb2: json['groundContinuityOb2'],
      groundContinuityRemark: json['groundContinuityRemark'],

      // Stage 19: Post-El Inspection
      postElSerialNoOb1: json['postElSerialNoOb1'],
      postElSerialNoOb2: json['postElSerialNoOb2'],
      postElSerialNoRemark: json['postElSerialNoRemark'],

      postElCurrentOb1: json['postElCurrentOb1'],
      postElCurrentOb2: json['postElCurrentOb2'],
      postElCurrentRemark: json['postElCurrentRemark'],

      postElVoltageOb1: json['postElVoltageOb1'],
      postElVoltageOb2: json['postElVoltageOb2'],
      postElVoltageRemark: json['postElVoltageRemark'],

      postElDefectsOb1: json['postElDefectsOb1'],
      postElDefectsOb2: json['postElDefectsOb2'],
      postElDefectsRemark: json['postElDefectsRemark'],

      // Stage 20: Sun Simulator
      calibrationDateOb1: json['calibrationDateOb1'],
      calibrationDateOb2: json['calibrationDateOb2'],
      calibrationDateRemark: json['calibrationDateRemark'],

      sunSerialNoOb1: json['sunSerialNoOb1'],
      sunSerialNoOb2: json['sunSerialNoOb2'],
      sunSerialNoRemark: json['sunSerialNoRemark'],

      modulePowerOb1: json['modulePowerOb1'],
      modulePowerOb2: json['modulePowerOb2'],
      modulePowerRemark: json['modulePowerRemark'],

      iscOb1: json['iscOb1'],
      iscOb2: json['iscOb2'],
      iscRemark: json['iscRemark'],

      vocOb1: json['vocOb1'],
      vocOb2: json['vocOb2'],
      vocRemark: json['vocRemark'],

      impOb1: json['impOb1'],
      impOb2: json['impOb2'],
      impRemark: json['impRemark'],

      vmpOb1: json['vmpOb1'],
      vmpOb2: json['vmpOb2'],
      vmpRemark: json['vmpRemark'],

      moduleTempOb1: json['moduleTempOb1'],
      moduleTempOb2: json['moduleTempOb2'],
      moduleTempRemark: json['moduleTempRemark'],

      fillFactorOb1: json['fillFactorOb1'],
      fillFactorOb2: json['fillFactorOb2'],
      fillFactorRemark: json['fillFactorRemark'],

      efficiencyOb1: json['efficiencyOb1'],
      efficiencyOb2: json['efficiencyOb2'],
      efficiencyRemark: json['efficiencyRemark'],

      ivCurveOkOb1: json['ivCurveOkOb1'],
      ivCurveOkOb2: json['ivCurveOkOb2'],
      ivCurveOkRemark: json['ivCurveOkRemark'],

      // Stage 21: FQC
      visualInspectionOb1: json['visualInspectionOb1'],
      visualInspectionOb2: json['visualInspectionOb2'],
      visualInspectionRemark: json['visualInspectionRemark'],

      jbCoverFitmentOb1: json['jbCoverFitmentOb1'],
      jbCoverFitmentOb2: json['jbCoverFitmentOb2'],
      jbCoverFitmentRemark: json['jbCoverFitmentRemark'],

      labelPlacementOb1: json['labelPlacementOb1'],
      labelPlacementOb2: json['labelPlacementOb2'],
      labelPlacementRemark: json['labelPlacementRemark'],

      fqcDefectsOb1: json['fqcDefectsOb1'],
      fqcDefectsOb2: json['fqcDefectsOb2'],
      fqcDefectsRemark: json['fqcDefectsRemark'],

      // Stage 22: Auto Sorter & Packing
      sortingStatusOb1: json['sortingStatusOb1'],
      sortingStatusOb2: json['sortingStatusOb2'],
      sortingStatusRemark: json['sortingStatusRemark'],

      palletConditionOb1: json['palletConditionOb1'],
      palletConditionOb2: json['palletConditionOb2'],
      palletConditionRemark: json['palletConditionRemark'],

      frontNotesController: json['frontNotesController'],
      backNotesController: json['backNotesController'],
    );
  }
}
