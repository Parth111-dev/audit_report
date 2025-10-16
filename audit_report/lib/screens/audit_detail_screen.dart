import 'package:final_audit/screens/pdf_screen.dart';
import 'package:final_audit/services/audit_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/audit_model.dart';
import '../services/auth_service.dart';

class AuditDetailScreen extends StatefulWidget {
  final AuditForm audit;

  const AuditDetailScreen({Key? key, required this.audit}) : super(key: key);

  @override
  State<AuditDetailScreen> createState() => _AuditDetailScreenState();
}

class _AuditDetailScreenState extends State<AuditDetailScreen> {
  late AuditForm audit;
  late TextEditingController verifiedByController;
  bool isAdmin = false;
  bool isEditing = false;
  bool _isInitialized = false;
  bool _isSaving = false;
  Uint8List? logoBytes;

  // Map to store all editable fields with their controllers
  Map<String, TextEditingController> fieldControllers = {};

  // Map to track which fields are currently being edited
  Map<String, bool> editingFields = {};

  // Map to store original values for cancel functionality
  Map<String, dynamic> originalValues = {};

  @override
  void initState() {
    super.initState();
    audit = widget.audit;
    verifiedByController = TextEditingController(text: audit.verifiedBy);
    _loadLogo();
    _initializeFieldControllers();
  }

  void _initializeFieldControllers() {
    // Initialize controllers for all audit fields
    final auditJson = audit.toJson();

    auditJson.forEach((key, value) {
      if (key != '_id' && key != 'id') {
        fieldControllers[key] = TextEditingController(
          text: value?.toString() ?? '',
        );
        editingFields[key] = false;
        originalValues[key] = value;
      }
    });
  }

  Future<void> _loadLogo() async {
    final data = await rootBundle.load('assets/images/pahalLogo.jpg');
    setState(() {
      logoBytes = data.buffer.asUint8List();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _checkUserRole();
      _isInitialized = true;
    }
  }

  void _checkUserRole() {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Check if current user is admin
    bool userIsAdmin = authService.currentUser?.role == 'Admin';
    print('Current user role: ${authService.currentUser?.role}');
    print('Is admin: $userIsAdmin');

    setState(() {
      isAdmin = userIsAdmin;
    });
  }

  void _enableFieldEdit(String fieldName) {
    if (!isAdmin) return;

    setState(() {
      editingFields[fieldName] = true;
    });
  }

  void _cancelFieldEdit(String fieldName) {
    setState(() {
      editingFields[fieldName] = false;
      fieldControllers[fieldName]?.text =
          originalValues[fieldName]?.toString() ?? '';
    });
  }

  Future<void> _saveFieldEdit(String fieldName) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Update the audit object with new value
      final newValue = fieldControllers[fieldName]?.text ?? '';
      _updateAuditField(fieldName, newValue);

      // Save to database
      final auditService = Provider.of<AuditService>(context, listen: false);
      final success = await auditService.updateAudit(audit);

      if (success) {
        setState(() {
          editingFields[fieldName] = false;
          originalValues[fieldName] = newValue;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Field "$fieldName" updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update field');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating field: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _cancelFieldEdit(fieldName);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      print('🔄 Starting update...');
      print('Audit ID: ${audit.id}');
      print('Audit ID Type: ${audit.id.runtimeType}');

      // ✅ ONLY set verifiedBy when saving and user is admin
      if (isAdmin) {
        String currentUserName =
            Provider.of<AuthService>(
              context,
              listen: false,
            ).currentUser?.fullName ??
            'Admin User';
        print('Setting verified by to: $currentUserName during save');

        verifiedByController.text = currentUserName;
        audit.verifiedBy = currentUserName;
      } else {
        // For non-admin users, use whatever is in the controller
        audit.verifiedBy = verifiedByController.text.trim();
      }

      final auditService = Provider.of<AuditService>(context, listen: false);
      final success = await auditService.updateAudit(audit);

      if (success) {
        setState(() {
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        print(
          '✅ Successfully updated audit with verifiedBy: ${audit.verifiedBy}',
        );
      } else {
        throw Exception('Failed to update audit');
      }
    } catch (e) {
      print('❌ Error saving audit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      verifiedByController.text = audit.verifiedBy;
      isEditing = false;
    });
  }

  // try case

  void _updateAuditField(String fieldName, String value) {
    // Update the audit object based on field name
    switch (fieldName) {
      case 'serialNumber':
        audit.serialNumber = value;
        break;
      case 'auditDate':
        audit.auditDate = value;
        break;

      case 'auditorName':
        audit.auditorName = value;
        break;
      case 'verifiedBy':
        audit.verifiedBy = value;
        break;
      case 'shift':
        audit.shift = value;
        break;
      case 'po':
        audit.po = value;
        break;
      case 'moduleType':
        audit.moduleType = value;
        break;
      case 'createdAt':
        audit.createdAt = value;
        break;

      // Stage 1: Floor
      case 'preLamTempOb1':
        audit.preLamTempOb1 = value;
        break;
      case 'preLamTempOb2':
        audit.preLamTempOb2 = value;
        break;
      case 'preLamTempRemark':
        audit.preLamTempRemark = value;
        break;
      case 'laminationTempOb1':
        audit.laminationTempOb1 = value;
        break;
      case 'laminationTempOb2':
        audit.laminationTempOb2 = value;
        break;
      case 'laminationTempRemark':
        audit.laminationTempRemark = value;
        break;
      case 'preLamHumidityOb1':
        audit.preLamHumidityOb1 = value;
        break;
      case 'preLamHumidityOb2':
        audit.preLamHumidityOb2 = value;
        break;
      case 'preLamHumidityRemark':
        audit.preLamHumidityRemark = value;
        break;

      // Stage 2: Front Glass Loading
      case 'glassMakeOb1':
        audit.glassMakeOb1 = value;
        break;
      case 'glassMakeOb2':
        audit.glassMakeOb2 = value;
        break;
      case 'glassMakeRemark':
        audit.glassMakeRemark = value;
        break;
      case 'glassPalletNoOb1':
        audit.glassPalletNoOb1 = value;
        break;
      case 'glassPalletNoOb2':
        audit.glassPalletNoOb2 = value;
        break;
      case 'glassPalletNoRemark':
        audit.glassPalletNoRemark = value;
        break;
      case 'glassSizeOb1':
        audit.glassSizeOb1 = value;
        break;
      case 'glassSizeOb2':
        audit.glassSizeOb2 = value;
        break;
      case 'glassSizeRemark':
        audit.glassSizeRemark = value;
        break;

      // Stage 3: Front side EVA Cutting
      case 'evaMakeOb1':
        audit.evaMakeOb1 = value;
        break;
      case 'evaMakeOb2':
        audit.evaMakeOb2 = value;
        break;
      case 'evaMakeRemark':
        audit.evaMakeRemark = value;
        break;
      case 'evaTypeOb1':
        audit.evaTypeOb1 = value;
        break;
      case 'evaTypeOb2':
        audit.evaTypeOb2 = value;
        break;
      case 'evaTypeRemark':
        audit.evaTypeRemark = value;
        break;
      case 'evaRollNoOb1':
        audit.evaRollNoOb1 = value;
        break;
      case 'evaRollNoOb2':
        audit.evaRollNoOb2 = value;
        break;
      case 'evaRollNoRemark':
        audit.evaRollNoRemark = value;
        break;
      case 'evaExpiryDateOb1':
        audit.evaExpiryDateOb1 = value;
        break;
      case 'evaExpiryDateOb2':
        audit.evaExpiryDateOb2 = value;
        break;
      case 'evaExpiryDateRemark':
        audit.evaExpiryDateRemark = value;
        break;
      case 'evaSizeOb1':
        audit.evaSizeOb1 = value;
        break;
      case 'evaSizeOb2':
        audit.evaSizeOb2 = value;
        break;
      case 'evaSizeRemark':
        audit.evaSizeRemark = value;
        break;

      // Stage 4: case r':
      // Stage 4: audit.r = value;

      case ' cellMakeOb1':
        audit.cellMakeOb1 = value;
        break;
      case 'cellMakeOb2':
        audit.cellMakeOb2 = value;
        break;
      case 'cellMakeRemark':
        audit.cellMakeRemark = value;
        break;
      case 'cellEfficiencyOb1':
        audit.cellEfficiencyOb1 = value;
        break;
      case 'cellEfficiencyOb2':
        audit.cellEfficiencyOb2 = value;
        break;
      case 'cellEfficiencyRemark':
        audit.cellEfficiencyRemark = value;
        break;
      case 'cellWattageOb1':
        audit.cellWattageOb1 = value;
        break;
      case 'cellWattageOb2':
        audit.cellWattageOb2 = value;
        break;
      case 'cellWattageRemark':
        audit.cellWattageRemark = value;
        break;
      case 'cellSizeOb1':
        audit.cellSizeOb1 = value;
        break;
      case 'cellSizeOb2':
        audit.cellSizeOb2 = value;
        break;
      case 'cellSizeRemark':
        audit.cellSizeRemark = value;
        break;
      case 'cellDefectsOb1':
        audit.cellDefectsOb1 = value;
        break;
      case 'cellDefectsOb2':
        audit.cellDefectsOb2 = value;
        break;
      case 'cellDefectsRemark':
        audit.cellDefectsRemark = value;
        break;
      case 'cleanlinessOb1':
        audit.cleanlinessOb1 = value;
        break;
      case 'cleanlinessOb2':
        audit.cleanlinessOb2 = value;
        break;
      case 'cleanlinessRemark':
        audit.cleanlinessRemark = value;
        break;
      case 'ribbonMakeOb1':
        audit.ribbonMakeOb1 = value;
        break;
      case 'ribbonMakeOb2':
        audit.ribbonMakeOb2 = value;
        break;
      case 'ribbonMakeRemark':
        audit.ribbonMakeRemark = value;
        break;
      case 'ribbonSizeOb1':
        audit.ribbonSizeOb1 = value;
        break;
      case 'ribbonSizeOb2':
        audit.ribbonSizeOb2 = value;
        break;
      case 'ribbonSizeRemark':
        audit.ribbonSizeRemark = value;
        break;
      case 'fluxMakeOb1':
        audit.fluxMakeOb1 = value;
        break;
      case 'fluxMakeOb2':
        audit.fluxMakeOb2 = value;
        break;
      case 'fluxMakeRemark':
        audit.fluxMakeRemark = value;
        break;
      case 'fluxTypeOb1':
        audit.fluxTypeOb1 = value;
        break;
      case 'fluxTypeOb2':
        audit.fluxTypeOb2 = value;
        break;
      case 'fluxTypeRemark':
        audit.fluxTypeRemark = value;
        break;
      case 'fluxExpiryDateOb1':
        audit.fluxExpiryDateOb1 = value;
        break;
      case 'fluxExpiryDateOb2':
        audit.fluxExpiryDateOb2 = value;
        break;
      case 'fluxExpiryDateRemark':
        audit.fluxExpiryDateRemark = value;
        break;
      case 'solderingTempOb1':
        audit.solderingTempOb1 = value;
        break;
      case 'solderingTempOb2':
        audit.solderingTempOb2 = value;
        break;
      case 'solderingTempRemark':
        audit.solderingTempRemark = value;
        break;
      case 'workingHeatersOb1':
        audit.workingHeatersOb1 = value;
        break;
      case 'workingHeatersOb2':
        audit.workingHeatersOb2 = value;
        break;
      case 'workingHeatersRemark':
        audit.workingHeatersRemark = value;
        break;
      case 'solderingPowerOb1':
        audit.solderingPowerOb1 = value;
        break;
      case 'solderingPowerOb2':
        audit.solderingPowerOb2 = value;
        break;
      case 'solderingPowerRemark':
        audit.solderingPowerRemark = value;
        break;
      case 'solderTimeOb1':
        audit.solderTimeOb1 = value;
        break;
      case 'solderTimeOb2':
        audit.solderTimeOb2 = value;
        break;
      case 'solderTimeRemark':
        audit.solderTimeRemark = value;
        break;
      case 'ribbonAlignmentOb1':
        audit.ribbonAlignmentOb1 = value;
        break;
      case 'ribbonAlignmentOb2':
        audit.ribbonAlignmentOb2 = value;
        break;
      case 'ribbonAlignmentRemark':
        audit.ribbonAlignmentRemark = value;
        break;
      case 'ribbonDimensionsOb1':
        audit.ribbonDimensionsOb1 = value;
        break;
      case 'ribbonDimensionsOb2':
        audit.ribbonDimensionsOb2 = value;
        break;
      case 'ribbonDimensionsRemark':
        audit.ribbonDimensionsRemark = value;
        break;
      case 'cellToCellGapOb1':
        audit.cellToCellGapOb1 = value;
        break;
      case 'cellToCellGapOb2':
        audit.cellToCellGapOb2 = value;
        break;
      case 'cellToCellGapRemark':
        audit.cellToCellGapRemark = value;
        break;
      case 'stringLengthOb1':
        audit.stringLengthOb1 = value;
        break;
      case 'stringLengthOb2':
        audit.stringLengthOb2 = value;
        break;
      case 'stringLengthRemark':
        audit.stringLengthRemark = value;
        break;
      case 'peelTestResultOb1':
        audit.peelTestResultOb1 = value;
        break;
      case 'peelTestResultOb2':
        audit.peelTestResultOb2 = value;
        break;
      case 'peelTestResultRemark':
        audit.peelTestResultRemark = value;
        break;
      case 'elInspectionOb1':
        audit.elInspectionOb1 = value;
        break;
      case 'elInspectionOb2':
        audit.elInspectionOb2 = value;
        break;
      case 'elInspectionRemark':
        audit.elInspectionRemark = value;
        break;

      // Stage 5: Lay-up & Auto Bussing
      case 'busbarMakeOb1':
        audit.busbarMakeOb1 = value;
        break;
      case 'busbarMakeOb2':
        audit.busbarMakeOb2 = value;
        break;
      case 'busbarMakeRemark':
        audit.busbarMakeRemark = value;
        break;
      case 'busbarSizeOb1':
        audit.busbarSizeOb1 = value;
        break;
      case 'busbarSizeOb2':
        audit.busbarSizeOb2 = value;
        break;
      case 'busbarSizeRemark':
        audit.busbarSizeRemark = value;
        break;
      case 'cellToBusbarDistanceOb1':
        audit.cellToBusbarDistanceOb1 = value;
        break;
      case 'cellToBusbarDistanceOb2':
        audit.cellToBusbarDistanceOb2 = value;
        break;
      case 'cellToBusbarDistanceRemark':
        audit.cellToBusbarDistanceRemark = value;
        break;
      case 'stringToStringGapOb1':
        audit.stringToStringGapOb1 = value;
        break;
      case 'stringToStringGapOb2':
        audit.stringToStringGapOb2 = value;
        break;
      case 'stringToStringGapRemark':
        audit.stringToStringGapRemark = value;
        break;
      case 'topSideGapOb1':
        audit.topSideGapOb1 = value;
        break;
      case 'topSideGapOb2':
        audit.topSideGapOb2 = value;
        break;
      case 'topSideGapRemark':
        audit.topSideGapRemark = value;
        break;
      case 'middleSideGapOb1':
        audit.middleSideGapOb1 = value;
        break;
      case 'middleSideGapOb2':
        audit.middleSideGapOb2 = value;
        break;
      case 'middleSideGapRemark':
        audit.middleSideGapRemark = value;
        break;
      case 'bottomSideGapOb1':
        audit.bottomSideGapOb1 = value;
        break;
      case 'bottomSideGapOb2':
        audit.bottomSideGapOb2 = value;
        break;
      case 'bottomSideGapRemark':
        audit.bottomSideGapRemark = value;
        break;
      case 'leftSideGapOb1':
        audit.leftSideGapOb1 = value;
        break;
      case 'leftSideGapOb2':
        audit.leftSideGapOb2 = value;
        break;
      case 'leftSideGapRemark':
        audit.leftSideGapRemark = value;
        break;
      case 'rightSideGapOb1':
        audit.rightSideGapOb1 = value;
        break;
      case 'rightSideGapOb2':
        audit.rightSideGapOb2 = value;
        break;
      case 'rightSideGapRemark':
        audit.rightSideGapRemark = value;
        break;

      // Stage 6: Auto Tapping
      case 'tapMakeOb1':
        audit.tapMakeOb1 = value;
        break;
      case 'tapMakeOb2':
        audit.tapMakeOb2 = value;
        break;
      case 'tapMakeRemark':
        audit.tapMakeRemark = value;
        break;
      case 'tapPositionOb1':
        audit.tapPositionOb1 = value;
        break;
      case 'tapPositionOb2':
        audit.tapPositionOb2 = value;
        break;
      case 'tapPositionRemark':
        audit.tapPositionRemark = value;
        break;
      case 'tapSizeOb1':
        audit.tapSizeOb1 = value;
        break;
      case 'tapSizeOb2':
        audit.tapSizeOb2 = value;
        break;
      case 'tapSizeRemark':
        audit.tapSizeRemark = value;
        break;

      // Stage 7: Rear side EVA Cutting
      case 'rearEvaMakeOb1':
        audit.rearEvaMakeOb1 = value;
        break;
      case 'rearEvaMakeOb2':
        audit.rearEvaMakeOb2 = value;
        break;
      case 'rearEvaMakeRemark':
        audit.rearEvaMakeRemark = value;
        break;
      case 'rearEvaTypeOb1':
        audit.rearEvaTypeOb1 = value;
        break;
      case 'rearEvaTypeOb2':
        audit.rearEvaTypeOb2 = value;
        break;
      case 'rearEvaTypeRemark':
        audit.rearEvaTypeRemark = value;
        break;
      case 'rearEvaRollNoOb1':
        audit.rearEvaRollNoOb1 = value;
        break;
      case 'rearEvaRollNoOb2':
        audit.rearEvaRollNoOb2 = value;
        break;
      case 'rearEvaRollNoRemark':
        audit.rearEvaRollNoRemark = value;
        break;
      case 'rearEvaExpiryDateOb1':
        audit.rearEvaExpiryDateOb1 = value;
        break;
      case 'rearEvaExpiryDateOb2':
        audit.rearEvaExpiryDateOb2 = value;
        break;
      case 'rearEvaExpiryDateRemark':
        audit.rearEvaExpiryDateRemark = value;
        break;
      case 'rearEvaSizeOb1':
        audit.rearEvaSizeOb1 = value;
        break;
      case 'rearEvaSizeOb2':
        audit.rearEvaSizeOb2 = value;
        break;
      case 'rearEvaSizeRemark':
        audit.rearEvaSizeRemark = value;
        break;

      // Stage 8: Rear Side Back Sheet/Glass
      case 'backsheetMakeOb1':
        audit.backsheetMakeOb1 = value;
        break;
      case 'backsheetMakeOb2':
        audit.backsheetMakeOb2 = value;
        break;
      case 'backsheetMakeRemark':
        audit.backsheetMakeRemark = value;
        break;
      case 'backsheetTypeOb1':
        audit.backsheetTypeOb1 = value;
        break;
      case 'backsheetTypeOb2':
        audit.backsheetTypeOb2 = value;
        break;
      case 'backsheetTypeRemark':
        audit.backsheetTypeRemark = value;
        break;
      case 'backsheetRollNoOb1':
        audit.backsheetRollNoOb1 = value;
        break;
      case 'backsheetRollNoOb2':
        audit.backsheetRollNoOb2 = value;
        break;
      case 'backsheetRollNoRemark':
        audit.backsheetRollNoRemark = value;
        break;
      case 'backsheetDimensionsOb1':
        audit.backsheetDimensionsOb1 = value;
        break;
      case 'backsheetDimensionsOb2':
        audit.backsheetDimensionsOb2 = value;
        break;
      case 'backsheetDimensionsRemark':
        audit.backsheetDimensionsRemark = value;
        break;

      // Stage 9: Logo & Barcode Fixing
      case 'logoPositionOkOb1':
        audit.logoPositionOkOb1 = value;
        break;
      case 'logoPositionOkOb2':
        audit.logoPositionOkOb2 = value;
        break;
      case 'logoPositionOkRemark':
        audit.logoPositionOkRemark = value;
        break;
      case 'barcodePositionOkOb1':
        audit.barcodePositionOkOb1 = value;
        break;
      case 'barcodePositionOkOb2':
        audit.barcodePositionOkOb2 = value;
        break;
      case 'barcodePositionOkRemark':
        audit.barcodePositionOkRemark = value;
        break;

      // Stage 10: Pre-EL Inspection
      case 'preElSerialNoOb1':
        audit.preElSerialNoOb1 = value;
        break;
      case 'preElSerialNoOb2':
        audit.preElSerialNoOb2 = value;
        break;
      case 'preElSerialNoRemark':
        audit.preElSerialNoRemark = value;
        break;
      case 'preElCurrentOb1':
        audit.preElCurrentOb1 = value;
        break;
      case 'preElCurrentOb2':
        audit.preElCurrentOb2 = value;
        break;
      case 'preElCurrentRemark':
        audit.preElCurrentRemark = value;
        break;
      case 'preElVoltageOb1':
        audit.preElVoltageOb1 = value;
        break;
      case 'preElVoltageOb2':
        audit.preElVoltageOb2 = value;
        break;
      case 'preElVoltageRemark':
        audit.preElVoltageRemark = value;
        break;
      case 'preElDefectsOb1':
        audit.preElDefectsOb1 = value;
        break;
      case 'preElDefectsOb2':
        audit.preElDefectsOb2 = value;
        break;
      case 'preElDefectsRemark':
        audit.preElDefectsRemark = value;
        break;

      // Stage 11: Auto Edge Taping
      case 'edgeTapingOkOb1':
        audit.edgeTapingOkOb1 = value;
        break;
      case 'edgeTapingOkOb2':
        audit.edgeTapingOkOb2 = value;
        break;
      case 'edgeTapingOkRemark':
        audit.edgeTapingOkRemark = value;
        break;

      // Stage 12: Lamination Process
      case 'laminatorNoOb1':
        audit.laminatorNoOb1 = value;
        break;
      case 'laminatorNoOb2':
        audit.laminatorNoOb2 = value;
        break;
      case 'laminatorNoRemark':
        audit.laminatorNoRemark = value;
        break;
      case 'laminationTempsCh01Ob1':
        audit.laminationTempsCh01Ob1 = value;
        break;
      case 'laminationTempsCh01Ob2':
        audit.laminationTempsCh01Ob2 = value;
        break;
      case 'laminationTempsCh02Ob1':
        audit.laminationTempsCh02Ob1 = value;
        break;
      case 'laminationTempsCh02Ob2':
        audit.laminationTempsCh02Ob2 = value;
        break;
      case 'laminationTempsCh03Ob1':
        audit.laminationTempsCh03Ob1 = value;
        break;
      case 'laminationTempsCh03Ob2':
        audit.laminationTempsCh03Ob2 = value;
        break;
      case 'laminationTempsRemark':
        audit.laminationTempsRemark = value;
        break;
      case 'vacuumTimesCh01Ob1':
        audit.vacuumTimesCh01Ob1 = value;
        break;
      case 'vacuumTimesCh01Ob2':
        audit.vacuumTimesCh01Ob2 = value;
        break;
      case 'vacuumTimesCh02Ob1':
        audit.vacuumTimesCh02Ob1 = value;
        break;
      case 'vacuumTimesCh02Ob2':
        audit.vacuumTimesCh02Ob2 = value;
        break;
      case 'vacuumTimesCh03Ob1':
        audit.vacuumTimesCh03Ob1 = value;
        break;
      case 'vacuumTimesCh03Ob2':
        audit.vacuumTimesCh03Ob2 = value;
        break;
      case 'vacuumTimesRemark':
        audit.vacuumTimesRemark = value;
        break;
      case 'upperventOneCh01Ob1':
        audit.upperventOneCh01Ob1 = value;
        break;
      case 'upperventOneCh01Ob2':
        audit.upperventOneCh01Ob2 = value;
        break;
      case 'upperventOneCh02Ob1':
        audit.upperventOneCh02Ob1 = value;
        break;
      case 'upperventOneCh02Ob2':
        audit.upperventOneCh02Ob2 = value;
        break;
      case 'upperventOneCh03Ob1':
        audit.upperventOneCh03Ob1 = value;
        break;
      case 'upperventOneCh03Ob2':
        audit.upperventOneCh03Ob2 = value;
        break;
      case 'upperventOneRemark':
        audit.upperventOneRemark = value;
        break;
      case 'laminationOneCh01Ob1':
        audit.laminationOneCh01Ob1 = value;
        break;
      case 'laminationOneCh01Ob2':
        audit.laminationOneCh01Ob2 = value;
        break;
      case 'laminationOneCh02Ob1':
        audit.laminationOneCh02Ob1 = value;
        break;
      case 'laminationOneCh02Ob2':
        audit.laminationOneCh02Ob2 = value;
        break;
      case 'laminationOneCh03Ob1':
        audit.laminationOneCh03Ob1 = value;
        break;
      case 'laminationOneCh03Ob2':
        audit.laminationOneCh03Ob2 = value;
        break;
      case 'laminationOneRemark':
        audit.laminationOneRemark = value;
        break;
      case 'upperventSecCh01Ob1':
        audit.upperventSecCh01Ob1 = value;
        break;
      case 'upperventSecCh01Ob2':
        audit.upperventSecCh01Ob2 = value;
        break;
      case 'upperventSecCh02Ob1':
        audit.upperventSecCh02Ob1 = value;
        break;
      case 'upperventSecCh02Ob2':
        audit.upperventSecCh02Ob2 = value;
        break;
      case 'upperventSecCh03Ob1':
        audit.upperventSecCh03Ob1 = value;
        break;
      case 'upperventSecCh03Ob2':
        audit.upperventSecCh03Ob2 = value;
        break;
      case 'upperventSecRemark':
        audit.upperventSecRemark = value;
        break;
      case 'laminationSecCh01Ob1':
        audit.laminationSecCh01Ob1 = value;
        break;
      case 'laminationSecCh01Ob2':
        audit.laminationSecCh01Ob2 = value;
        break;
      case 'laminationSecCh02Ob1':
        audit.laminationSecCh02Ob1 = value;
        break;
      case 'laminationSecCh02Ob2':
        audit.laminationSecCh02Ob2 = value;
        break;
      case 'laminationSecCh03Ob1':
        audit.laminationSecCh03Ob1 = value;
        break;
      case 'laminationSecCh03Ob2':
        audit.laminationSecCh03Ob2 = value;
        break;
      case 'laminationSecRemark':
        audit.laminationSecRemark = value;
        break;
      case 'upperventThirdCh01Ob1':
        audit.upperventThirdCh01Ob1 = value;
        break;
      case 'upperventThirdCh01Ob2':
        audit.upperventThirdCh01Ob2 = value;
        break;
      case 'upperventThirdCh02Ob1':
        audit.upperventThirdCh02Ob1 = value;
        break;
      case 'upperventThirdCh02Ob2':
        audit.upperventThirdCh02Ob2 = value;
        break;
      case 'upperventThirdCh03Ob1':
        audit.upperventThirdCh03Ob1 = value;
        break;
      case 'upperventThirdCh03Ob2':
        audit.upperventThirdCh03Ob2 = value;
        break;
      case 'upperventThirdRemark':
        audit.upperventThirdRemark = value;
        break;
      case 'laminationThirdCh01Ob1':
        audit.laminationThirdCh01Ob1 = value;
        break;
      case 'laminationThirdCh01Ob2':
        audit.laminationThirdCh01Ob2 = value;
        break;
      case 'laminationThirdCh02Ob1':
        audit.laminationThirdCh02Ob1 = value;
        break;
      case 'laminationThirdCh02Ob2':
        audit.laminationThirdCh02Ob2 = value;
        break;
      case 'laminationThirdCh03Ob1':
        audit.laminationThirdCh03Ob1 = value;
        break;
      case 'laminationThirdCh03Ob2':
        audit.laminationThirdCh03Ob2 = value;
        break;
      case 'laminationThirdRemark':
        audit.laminationThirdRemark = value;
        break;
      case 'lowerVentTimeCh01Ob1':
        audit.lowerVentTimeCh01Ob1 = value;
        break;
      case 'lowerVentTimeCh01Ob2':
        audit.lowerVentTimeCh01Ob2 = value;
        break;
      case 'lowerVentTimeCh02Ob1':
        audit.lowerVentTimeCh02Ob1 = value;
        break;
      case 'lowerVentTimeCh02Ob2':
        audit.lowerVentTimeCh02Ob2 = value;
        break;
      case 'lowerVentTimeCh03Ob1':
        audit.lowerVentTimeCh03Ob1 = value;
        break;
      case 'lowerVentTimeCh03Ob2':
        audit.lowerVentTimeCh03Ob2 = value;
        break;
      case 'lowerVentTimeRemark':
        audit.lowerVentTimeRemark = value;
        break;
      case 'totalCycleTimeCh01Ob1':
        audit.totalCycleTimeCh01Ob1 = value;
        break;
      case 'totalCycleTimeCh01Ob2':
        audit.totalCycleTimeCh01Ob2 = value;
        break;
      case 'totalCycleTimeCh02Ob1':
        audit.totalCycleTimeCh02Ob1 = value;
        break;
      case 'totalCycleTimeCh02Ob2':
        audit.totalCycleTimeCh02Ob2 = value;
        break;
      case 'totalCycleTimeCh03Ob1':
        audit.totalCycleTimeCh03Ob1 = value;
        break;
      case 'totalCycleTimeCh03Ob2':
        audit.totalCycleTimeCh03Ob2 = value;
        break;
      case 'totalCycleTimeRemark':
        audit.totalCycleTimeRemark = value;
        break;

      // Stage 13: Auto Edge Trimming
      case 'trimmingOkOb1':
        audit.trimmingOkOb1 = value;
        break;
      case 'trimmingOkOb2':
        audit.trimmingOkOb2 = value;
        break;
      case 'trimmingOkRemark':
        audit.trimmingOkRemark = value;
        break;

      // Stage 14: Framing Process
      case 'frameSerialNoOb1':
        audit.frameSerialNoOb1 = value;
        break;
      case 'frameSerialNoOb2':
        audit.frameSerialNoOb2 = value;
        break;
      case 'frameSerialNoRemark':
        audit.frameSerialNoRemark = value;
        break;
      case 'frameMakeOb1':
        audit.frameMakeOb1 = value;
        break;
      case 'frameMakeOb2':
        audit.frameMakeOb2 = value;
        break;
      case 'frameMakeRemark':
        audit.frameMakeRemark = value;
        break;
      case 'cornerKeyMakeOb1':
        audit.cornerKeyMakeOb1 = value;
        break;
      case 'cornerKeyMakeOb2':
        audit.cornerKeyMakeOb2 = value;
        break;
      case 'cornerKeyMakeRemark':
        audit.cornerKeyMakeRemark = value;
        break;
      case 'profileCutAngleOb1':
        audit.profileCutAngleOb1 = value;
        break;
      case 'profileCutAngleOb2':
        audit.profileCutAngleOb2 = value;
        break;
      case 'profileCutAngleRemark':
        audit.profileCutAngleRemark = value;
        break;
      case 'frameLengthOb1':
        audit.frameLengthOb1 = value;
        break;
      case 'frameLengthOb2':
        audit.frameLengthOb2 = value;
        break;
      case 'frameLengthRemark':
        audit.frameLengthRemark = value;
        break;
      case 'frameWidthOb1':
        audit.frameWidthOb1 = value;
        break;
      case 'frameWidthOb2':
        audit.frameWidthOb2 = value;
        break;
      case 'frameWidthRemark':
        audit.frameWidthRemark = value;
        break;
      case 'frameHeightOb1':
        audit.frameHeightOb1 = value;
        break;
      case 'frameHeightOb2':
        audit.frameHeightOb2 = value;
        break;
      case 'frameHeightRemark':
        audit.frameHeightRemark = value;
        break;
      case 'mountingHoleOb1':
        audit.mountingHoleOb1 = value;
        break;
      case 'mountingHoleOb2':
        audit.mountingHoleOb2 = value;
        break;
      case 'mountingHoleRemark':
        audit.mountingHoleRemark = value;
        break;
      case 'xPitchOb1':
        audit.xPitchOb1 = value;
        break;
      case 'xPitchOb2':
        audit.xPitchOb2 = value;
        break;
      case 'xPitchRemark':
        audit.xPitchRemark = value;
        break;
      case 'yPitchOb1':
        audit.yPitchOb1 = value;
        break;
      case 'yPitchOb2':
        audit.yPitchOb2 = value;
        break;
      case 'yPitchRemark':
        audit.yPitchRemark = value;
        break;
      case 'groundHoleDiaOb1':
        audit.groundHoleDiaOb1 = value;
        break;
      case 'groundHoleDiaOb2':
        audit.groundHoleDiaOb2 = value;
        break;
      case 'groundHoleDiaRemark':
        audit.groundHoleDiaRemark = value;
        break;
      case 'groundHoleDistanceOb1':
        audit.groundHoleDistanceOb1 = value;
        break;
      case 'groundHoleDistanceOb2':
        audit.groundHoleDistanceOb2 = value;
        break;
      case 'groundHoleDistanceRemark':
        audit.groundHoleDistanceRemark = value;
        break;
      case 'drainHoleSizeOb1':
        audit.drainHoleSizeOb1 = value;
        break;
      case 'drainHoleSizeOb2':
        audit.drainHoleSizeOb2 = value;
        break;
      case 'drainHoleSizeRemark':
        audit.drainHoleSizeRemark = value;
        break;
      case 'drainHoleDistanceOb1':
        audit.drainHoleDistanceOb1 = value;
        break;
      case 'drainHoleDistanceOb2':
        audit.drainHoleDistanceOb2 = value;
        break;
      case 'drainHoleDistanceRemark':
        audit.drainHoleDistanceRemark = value;
        break;
      case 'diagonalLengthOb1':
        audit.diagonalLengthOb1 = value;
        break;
      case 'diagonalLengthOb2':
        audit.diagonalLengthOb2 = value;
        break;
      case 'diagonalLengthRemark':
        audit.diagonalLengthRemark = value;
        break;
      case 'sealantMakeOb1':
        audit.sealantMakeOb1 = value;
        break;
      case 'sealantMakeOb2':
        audit.sealantMakeOb2 = value;
        break;
      case 'sealantMakeRemark':
        audit.sealantMakeRemark = value;
        break;
      case 'sealantTypeOb1':
        audit.sealantTypeOb1 = value;
        break;
      case 'sealantTypeOb2':
        audit.sealantTypeOb2 = value;
        break;
      case 'sealantTypeRemark':
        audit.sealantTypeRemark = value;
        break;
      case 'sealantWeightOb1':
        audit.sealantWeightOb1 = value;
        break;
      case 'sealantWeightOb2':
        audit.sealantWeightOb2 = value;
        break;
      case 'sealantWeightRemark':
        audit.sealantWeightRemark = value;
        break;
      case 'scratchDentsOb1':
        audit.scratchDentsOb1 = value;
        break;
      case 'scratchDentsOb2':
        audit.scratchDentsOb2 = value;
        break;
      case 'scratchDentsRemark':
        audit.scratchDentsRemark = value;
        break;
      case 'frameDefectsOb1':
        audit.frameDefectsOb1 = value;
        break;
      case 'frameDefectsOb2':
        audit.frameDefectsOb2 = value;
        break;
      case 'frameDefectsRemark':
        audit.frameDefectsRemark = value;
        break;

      // Stage 15: Junction Box Assembly
      case 'jbSerialNoOb1':
        audit.jbSerialNoOb1 = value;
        break;
      case 'jbSerialNoOb2':
        audit.jbSerialNoOb2 = value;
        break;
      case 'jbSerialNoRemark':
        audit.jbSerialNoRemark = value;
        break;
      case 'jbMakeOb1':
        audit.jbMakeOb1 = value;
        break;
      case 'jbMakeOb2':
        audit.jbMakeOb2 = value;
        break;
      case 'jbMakeRemark':
        audit.jbMakeRemark = value;
        break;
      case 'jbTypeOb1':
        audit.jbTypeOb1 = value;
        break;
      case 'jbTypeOb2':
        audit.jbTypeOb2 = value;
        break;
      case 'jbTypeRemark':
        audit.jbTypeRemark = value;
        break;
      case 'diodeModelOb1':
        audit.diodeModelOb1 = value;
        break;
      case 'diodeModelOb2':
        audit.diodeModelOb2 = value;
        break;
      case 'diodeModelRemark':
        audit.diodeModelRemark = value;
        break;
      case 'jbPlacementOb1':
        audit.jbPlacementOb1 = value;
        break;
      case 'jbPlacementOb2':
        audit.jbPlacementOb2 = value;
        break;
      case 'jbPlacementRemark':
        audit.jbPlacementRemark = value;
        break;
      case 'jbSealantWeightsAOb1':
        audit.jbSealantWeightsAOb1 = value;
        break;
      case 'jbSealantWeightsAOb2':
        audit.jbSealantWeightsAOb2 = value;
        break;
      case 'jbSealantWeightsBOb1':
        audit.jbSealantWeightsBOb1 = value;
        break;
      case 'jbSealantWeightsBOb2':
        audit.jbSealantWeightsBOb2 = value;
        break;
      case 'jbSealantWeightsCOb1':
        audit.jbSealantWeightsCOb1 = value;
        break;
      case 'jbSealantWeightsCOb2':
        audit.jbSealantWeightsCOb2 = value;
        break;
      case 'jbSealantWeightsRemark':
        audit.jbSealantWeightsRemark = value;
        break;
      case 'solderingQualityOb1':
        audit.solderingQualityOb1 = value;
        break;
      case 'solderingQualityOb2':
        audit.solderingQualityOb2 = value;
        break;
      case 'solderingQualityRemark':
        audit.solderingQualityRemark = value;
        break;
      case 'pottingSealantMakeOb1':
        audit.pottingSealantMakeOb1 = value;
        break;
      case 'pottingSealantMakeOb2':
        audit.pottingSealantMakeOb2 = value;
        break;
      case 'pottingSealantMakeRemark':
        audit.pottingSealantMakeRemark = value;
        break;
      case 'pottingSealantTypeOb1':
        audit.pottingSealantTypeOb1 = value;
        break;
      case 'pottingSealantTypeOb2':
        audit.pottingSealantTypeOb2 = value;
        break;
      case 'pottingSealantTypeRemark':
        audit.pottingSealantTypeRemark = value;
        break;
      case 'pottingSealantExpiryOb1':
        audit.pottingSealantExpiryOb1 = value;
        break;
      case 'pottingSealantExpiryOb2':
        audit.pottingSealantExpiryOb2 = value;
        break;
      case 'pottingSealantExpiryRemark':
        audit.pottingSealantExpiryRemark = value;
        break;
      case 'curingTimeOb1':
        audit.curingTimeOb1 = value;
        break;
      case 'curingTimeOb2':
        audit.curingTimeOb2 = value;
        break;
      case 'curingTimeRemark':
        audit.curingTimeRemark = value;
        break;
      case 'pottingSealantWeightsAOb1':
        audit.pottingSealantWeightsAOb1 = value;
        break;
      case 'pottingSealantWeightsAOb2':
        audit.pottingSealantWeightsAOb2 = value;
        break;
      case 'pottingSealantWeightsBOb1':
        audit.pottingSealantWeightsBOb1 = value;
        break;
      case 'pottingSealantWeightsBOb2':
        audit.pottingSealantWeightsBOb2 = value;
        break;
      case 'pottingSealantWeightsCOb1':
        audit.pottingSealantWeightsCOb1 = value;
        break;
      case 'pottingSealantWeightsCOb2':
        audit.pottingSealantWeightsCOb2 = value;
        break;
      case 'pottingSealantWeightsRemark':
        audit.pottingSealantWeightsRemark = value;
        break;
      case 'pottingRatioAOb1':
        audit.pottingRatioAOb1 = value;
        break;
      case 'pottingRatioBOb1':
        audit.pottingRatioBOb1 = value;
        break;
      case 'pottingRatioOb1':
        audit.pottingRatioOb1 = value;
        break;
      case 'pottingRatioAOb2':
        audit.pottingRatioAOb2 = value;
        break;
      case 'pottingRatioBOb2':
        audit.pottingRatioBOb2 = value;
        break;
      case 'pottingRatioOb2':
        audit.pottingRatioOb2 = value;
        break;
      case 'pottingRatioRemark':
        audit.pottingRatioRemark = value;
        break;
      case 'cableLengthOb1':
        audit.cableLengthOb1 = value;
        break;
      case 'cableLengthOb2':
        audit.cableLengthOb2 = value;
        break;
      case 'cableLengthRemark':
        audit.cableLengthRemark = value;
        break;
      case 'visualStatusOb1':
        audit.visualStatusOb1 = value;
        break;
      case 'visualStatusOb2':
        audit.visualStatusOb2 = value;
        break;
      case 'visualStatusRemark':
        audit.visualStatusRemark = value;
        break;

      // Stage 16: Curing Line
      case 'curingTimeLineOb1':
        audit.curingTimeLineOb1 = value;
        break;
      case 'curingTimeLineOb2':
        audit.curingTimeLineOb2 = value;
        break;
      case 'curingTimeLineRemark':
        audit.curingTimeLineRemark = value;
        break;
      case 'curingTempOb1':
        audit.curingTempOb1 = value;
        break;
      case 'curingTempOb2':
        audit.curingTempOb2 = value;
        break;
      case 'curingTempRemark':
        audit.curingTempRemark = value;
        break;
      case 'curingHumidityOb1':
        audit.curingHumidityOb1 = value;
        break;
      case 'curingHumidityOb2':
        audit.curingHumidityOb2 = value;
        break;
      case 'curingHumidityRemark':
        audit.curingHumidityRemark = value;
        break;

      // Stage 17: Module Cleaning
      case 'cleaningOkOb1':
        audit.cleaningOkOb1 = value;
        break;
      case 'cleaningOkOb2':
        audit.cleaningOkOb2 = value;
        break;
      case 'cleaningOkRemark':
        audit.cleaningOkRemark = value;
        break;

      // Stage 18: Hi-Pot Testing
      case 'hipotSerialNoOb1':
        audit.hipotSerialNoOb1 = value;
        break;
      case 'hipotSerialNoOb2':
        audit.hipotSerialNoOb2 = value;
        break;
      case 'hipotSerialNoRemark':
        audit.hipotSerialNoRemark = value;
        break;
      case 'dcwOb1':
        audit.dcwOb1 = value;
        break;
      case 'dcwOb2':
        audit.dcwOb2 = value;
        break;
      case 'dcwRemark':
        audit.dcwRemark = value;
        break;
      case 'irOb1':
        audit.irOb1 = value;
        break;
      case 'irOb2':
        audit.irOb2 = value;
        break;
      case 'irRemark':
        audit.irRemark = value;
        break;
      case 'groundContinuityOb1':
        audit.groundContinuityOb1 = value;
        break;
      case 'groundContinuityOb2':
        audit.groundContinuityOb2 = value;
        break;
      case 'groundContinuityRemark':
        audit.groundContinuityRemark = value;
        break;

      // Stage 19: Post-EL Inspection
      case 'postElSerialNoOb1':
        audit.postElSerialNoOb1 = value;
        break;
      case 'postElSerialNoOb2':
        audit.postElSerialNoOb2 = value;
        break;
      case 'postElSerialNoRemark':
        audit.postElSerialNoRemark = value;
        break;
      case 'postElCurrentOb1':
        audit.postElCurrentOb1 = value;
        break;
      case 'postElCurrentOb2':
        audit.postElCurrentOb2 = value;
        break;
      case 'postElCurrentRemark':
        audit.postElCurrentRemark = value;
        break;
      case 'postElVoltageOb1':
        audit.postElVoltageOb1 = value;
        break;
      case 'postElVoltageOb2':
        audit.postElVoltageOb2 = value;
        break;
      case 'postElVoltageRemark':
        audit.postElVoltageRemark = value;
        break;
      case 'postElDefectsOb1':
        audit.postElDefectsOb1 = value;
        break;
      case 'postElDefectsOb2':
        audit.postElDefectsOb2 = value;
        break;
      case 'postElDefectsRemark':
        audit.postElDefectsRemark = value;
        break;

      // Stage 20: Sun Simulator
      case 'calibrationDateOb1':
        audit.calibrationDateOb1 = value;
        break;
      case 'calibrationDateOb2':
        audit.calibrationDateOb2 = value;
        break;
      case 'calibrationDateRemark':
        audit.calibrationDateRemark = value;
        break;
      case 'sunSerialNoOb1':
        audit.sunSerialNoOb1 = value;
        break;
      case 'sunSerialNoOb2':
        audit.sunSerialNoOb2 = value;
        break;
      case 'sunSerialNoRemark':
        audit.sunSerialNoRemark = value;
        break;
      case 'modulePowerOb1':
        audit.modulePowerOb1 = value;
        break;
      case 'modulePowerOb2':
        audit.modulePowerOb2 = value;
        break;
      case 'modulePowerRemark':
        audit.modulePowerRemark = value;
        break;
      case 'iscOb1':
        audit.iscOb1 = value;
        break;
      case 'iscOb2':
        audit.iscOb2 = value;
        break;
      case 'iscRemark':
        audit.iscRemark = value;
        break;
      case 'vocOb1':
        audit.vocOb1 = value;
        break;
      case 'vocOb2':
        audit.vocOb2 = value;
        break;
      case 'vocRemark':
        audit.vocRemark = value;
        break;
      case 'impOb1':
        audit.impOb1 = value;
        break;
      case 'impOb2':
        audit.impOb2 = value;
        break;
      case 'impRemark':
        audit.impRemark = value;
        break;
      case 'vmpOb1':
        audit.vmpOb1 = value;
        break;
      case 'vmpOb2':
        audit.vmpOb2 = value;
        break;
      case 'vmpRemark':
        audit.vmpRemark = value;
        break;
      case 'moduleTempOb1':
        audit.moduleTempOb1 = value;
        break;
      case 'moduleTempOb2':
        audit.moduleTempOb2 = value;
        break;
      case 'moduleTempRemark':
        audit.moduleTempRemark = value;
        break;
      case 'fillFactorOb1':
        audit.fillFactorOb1 = value;
        break;
      case 'fillFactorOb2':
        audit.fillFactorOb2 = value;
        break;
      case 'fillFactorRemark':
        audit.fillFactorRemark = value;
        break;
      case 'efficiencyOb1':
        audit.efficiencyOb1 = value;
        break;
      case 'efficiencyOb2':
        audit.efficiencyOb2 = value;
        break;
      case 'efficiencyRemark':
        audit.efficiencyRemark = value;
        break;
      case 'ivCurveOkOb1':
        audit.ivCurveOkOb1 = value;
        break;
      case 'ivCurveOkOb2':
        audit.ivCurveOkOb2 = value;
        break;
      case 'ivCurveOkRemark':
        audit.ivCurveOkRemark = value;
        break;

      // Stage 21: FQC
      case 'visualInspectionOb1':
        audit.visualInspectionOb1 = value;
        break;
      case 'visualInspectionOb2':
        audit.visualInspectionOb2 = value;
        break;
      case 'visualInspectionRemark':
        audit.visualInspectionRemark = value;
        break;
      case 'jbCoverFitmentOb1':
        audit.jbCoverFitmentOb1 = value;
        break;
      case 'jbCoverFitmentOb2':
        audit.jbCoverFitmentOb2 = value;
        break;
      case 'jbCoverFitmentRemark':
        audit.jbCoverFitmentRemark = value;
        break;
      case 'labelPlacementOb1':
        audit.labelPlacementOb1 = value;
        break;
      case 'labelPlacementOb2':
        audit.labelPlacementOb2 = value;
        break;
      case 'labelPlacementRemark':
        audit.labelPlacementRemark = value;
        break;
      case 'fqcDefectsOb1':
        audit.fqcDefectsOb1 = value;
        break;
      case 'fqcDefectsOb2':
        audit.fqcDefectsOb2 = value;
        break;
      case 'fqcDefectsRemark':
        audit.fqcDefectsRemark = value;
        break;

      // Stage 22: Auto Sorter & Packing
      case 'sortingStatusOb1':
        audit.sortingStatusOb1 = value;
        break;
      case 'sortingStatusOb2':
        audit.sortingStatusOb2 = value;
        break;
      case 'sortingStatusRemark':
        audit.sortingStatusRemark = value;
        break;
      case 'palletConditionOb1':
        audit.palletConditionOb1 = value;
        break;
      case 'palletConditionOb2':
        audit.palletConditionOb2 = value;
        break;
      case 'palletConditionRemark':
        audit.palletConditionRemark = value;
        break;

      // notes
      case 'frontNotesController':
        audit.frontNotesController = value;
        break;
      case 'backNotesController':
        audit.backNotesController = value;
        break;

      default:
        print('Field $fieldName not handled in update logic');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Audit Details - ${widget.audit.serialNumber}'),
        backgroundColor: Colors.blue[700],
        actions: [
          if (isAdmin && !isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _toggleEditing,
              tooltip: 'Edit Verified By',
            ),
          if (isAdmin && isEditing)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Save Changes',
            ),
          if (isAdmin && isEditing)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _cancelEditing,
              tooltip: 'Cancel',
            ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => navigateToPdfScreen(context, widget.audit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: screenWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildTitle(),
                _buildHeader(screenWidth),
                // All 22 Stages
                _buildStage1(screenWidth), SizedBox(height: 10),
                _buildStage2(screenWidth), SizedBox(height: 10),
                _buildStage3(screenWidth), SizedBox(height: 10),
                _buildStage4(screenWidth), SizedBox(height: 10),
                _buildStage5(screenWidth), SizedBox(height: 10),
                _buildStage6(screenWidth), SizedBox(height: 10),
                _buildStage7(screenWidth), SizedBox(height: 10),
                _buildStage8(screenWidth), SizedBox(height: 10),
                _buildStage9(screenWidth), SizedBox(height: 10),
                _buildStage10(screenWidth), SizedBox(height: 10),
                _buildStage11(screenWidth), SizedBox(height: 10),
                _buildStage12(screenWidth), SizedBox(height: 10),
                _buildStage13(screenWidth), SizedBox(height: 10),
                _buildStage14(screenWidth), SizedBox(height: 10),
                _buildStage15(screenWidth), SizedBox(height: 10),
                _buildStage16(screenWidth), SizedBox(height: 10),
                _buildStage17(screenWidth), SizedBox(height: 10),
                _buildStage18(screenWidth), SizedBox(height: 10),
                _buildStage19(screenWidth), SizedBox(height: 10),
                _buildStage20(screenWidth), SizedBox(height: 10),
                _buildStage21(screenWidth), SizedBox(height: 10),
                _buildStage22(screenWidth), SizedBox(height: 20),

                _buildFooter(screenWidth),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String fieldName,
    String currentValue, {
    bool isNumeric = false,
  }) {
    final isEditing = editingFields[fieldName] ?? false;

    if (isEditing && isAdmin) {
      return Container(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: fieldControllers[fieldName],
                keyboardType: isNumeric
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  isDense: true,
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.check, color: Colors.green, size: 16),
              onPressed: () => _saveFieldEdit(fieldName),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 24, minHeight: 24),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red, size: 16),
              onPressed: () => _cancelFieldEdit(fieldName),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onDoubleTap: isAdmin ? () => _enableFieldEdit(fieldName) : null,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isAdmin ? Colors.blue.withOpacity(0.3) : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(4),
            color: isAdmin ? Colors.blue.withOpacity(0.05) : Colors.grey[50],
          ),
          child: Text(
            currentValue.isNotEmpty ? currentValue : 'N/A',
            style: TextStyle(color: Colors.grey[800], fontSize: 12),
          ),
        ),
      );
    }
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 1st Row
        Table(
          border: TableBorder.all(width: 1),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              children: [
                // 1️⃣ Column 1 - Image
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4),
                  child: logoBytes != null
                      ? Image.memory(
                          logoBytes!,
                          fit: BoxFit.contain,
                          height: 50, // adjust as needed
                        )
                      : const Text('Logo not loaded'),
                ),

                // 2️⃣ Column 2 - 2 rows (centered)
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        'PAHAL SOLAR PVT. LTD.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'In-Process Audit Sheet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3️⃣ Column 3 - 3 rows (right-aligned)
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Doc No: IMS-FRM-PQC-001',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Effective Date: 11/03/2025',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text('Revision No: 00', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 🔹 2nd Row (4 Columns)
        Table(
          border: TableBorder.all(width: 1),
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(2.5),
          },
          children: [
            TableRow(
              children: [
                _buildCellFlutter('Date: ${widget.audit.auditDate}'),
                _buildCellFlutter('Shift: ${audit.shift}'),
                _buildCellFlutter('PO: ${audit.po}'),
                _buildCellFlutter('Module Type & Watt: ${audit.moduleType}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCellFlutter(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[300]),
            children: [
              _buildHeaderCell('Sr.No.'),
              _buildHeaderCell('Stage'),
              _buildHeaderCell('Type Of Inspection'),
              _buildHeaderCell('Parameters'),
              _buildHeaderCell('Observation 1'),
              _buildHeaderCell('Observation 2'),
              _buildHeaderCell('Remarks'),
            ],
          ),
        ],
      ),
    );
  }

  // Stage 1: Floor
  Widget _buildStage1(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '1',
            stage: 'Floor',
            inspectionType: 'Visual',
            parameters: 'Temp (°C) (Pre-Lam Area)',
            observation1: _buildEditableField(
              'preLamTempOb1',
              widget.audit.preLamTempOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'preLamTempOb2',
              widget.audit.preLamTempOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'preLamTempRemark',
              widget.audit.preLamTempRemark?.toString() ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Temp (°C) (Lamination Area)',
            observation1: _buildEditableField(
              'laminationTempOb1',
              widget.audit.laminationTempOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'laminationTempOb2',
              widget.audit.laminationTempOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'laminationTempRemark',
              widget.audit.laminationTempRemark?.toString() ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Humidity (Pre Lam)',
            observation1: _buildEditableField(
              'preLamHumidityOb1',
              widget.audit.preLamHumidityOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'preLamHumidityOb2',
              widget.audit.preLamHumidityOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'preLamHumidityRemark',
              widget.audit.preLamHumidityRemark?.toString() ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 2: Front Glass Loading
  Widget _buildStage2(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '2',
            stage: 'Front Glass Loading',
            inspectionType: 'Visual',
            parameters: 'Glass Make',
            observation1: _buildEditableField(
              'glassMakeOb1',
              widget.audit.glassMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'glassMakeOb2',
              widget.audit.glassMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'glassMakeRemark',
              widget.audit.glassMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Glass Pallet No.',
            observation1: _buildEditableField(
              'glassPalletNoOb1',
              widget.audit.glassPalletNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'glassPalletNoOb2',
              widget.audit.glassPalletNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'glassPalletNoRemark',
              widget.audit.glassPalletNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Glass Size (L x W x T)',
            observation1: _buildEditableField(
              'glassSizeOb1',
              widget.audit.glassSizeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'glassSizeOb2',
              widget.audit.glassSizeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'glassSizeRemark',
              widget.audit.glassSizeRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 3: Front side EVA Cutting
  Widget _buildStage3(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '3',
            stage: 'Front side EVA Cutting',
            inspectionType: 'Visual',
            parameters: 'EVA Make',
            observation1: _buildEditableField(
              'evaMakeOb1',
              widget.audit.evaMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'evaMakeOb2',
              widget.audit.evaMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'evaMakeRemark',
              widget.audit.evaMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Type',
            observation1: _buildEditableField(
              'evaTypeOb1',
              widget.audit.evaTypeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'evaTypeOb2',
              widget.audit.evaTypeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'evaTypeRemark',
              widget.audit.evaTypeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Roll No',
            observation1: _buildEditableField(
              'evaRollNoOb1',
              widget.audit.evaRollNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'evaRollNoOb2',
              widget.audit.evaRollNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'evaRollNoRemark',
              widget.audit.evaRollNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Expiry Date',
            observation1: _buildEditableField(
              'evaExpiryDateOb1',
              widget.audit.evaExpiryDateOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'evaExpiryDateOb2',
              widget.audit.evaExpiryDateOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'evaExpiryDateRemark',
              widget.audit.evaExpiryDateRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'EVA Size (L x W x T)',
            observation1: _buildEditableField(
              'evaSizeOb1',
              widget.audit.evaSizeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'evaSizeOb2',
              widget.audit.evaSizeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'evaSizeRemark',
              widget.audit.evaSizeRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 4: Stringer
  Widget _buildStage4(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '4',
            stage: 'Stringer',
            inspectionType: 'Visual',
            parameters: 'Cell Make',
            observation1: _buildEditableField(
              'cellMakeOb1',
              widget.audit.cellMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'cellMakeOb2',
              widget.audit.cellMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'cellMakeRemark',
              widget.audit.cellMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cell Efficiency (%) & Wattage',
            observation1: _buildEditableField(
              'cellEfficiencyOb1',
              '${widget.audit.cellEfficiencyOb1?.toString() ?? ''}',
            ),
            observation2: _buildEditableField(
              'cellEfficiencyOb2',
              widget.audit.cellEfficiencyOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'cellEfficiencyRemark',
              widget.audit.cellEfficiencyRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Cell Size',
            observation1: _buildEditableField(
              'cellSizeOb1',
              widget.audit.cellSizeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'cellSizeOb2',
              widget.audit.cellSizeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'cellSizeRemark',
              widget.audit.cellSizeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Cell Defect (If Any)',
            observation1: _buildEditableField(
              'cellDefectsOb1',
              widget.audit.cellDefectsOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'cellDefectsOb2',
              widget.audit.cellDefectsOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'cellDefectsRemark',
              widget.audit.cellDefectsRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cleanliness of Loading Area',
            observation1: _buildEditableField(
              'cleanlinessOb1',
              widget.audit.cleanlinessOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'cleanlinessOb2',
              widget.audit.cleanlinessOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'cleanlinessRemark',
              widget.audit.cleanlinessRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ribbon Make',
            observation1: _buildEditableField(
              'ribbonMakeOb1',
              widget.audit.ribbonMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'ribbonMakeOb2',
              widget.audit.ribbonMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'ribbonMakeRemark',
              widget.audit.ribbonMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Ribbon Size',
            observation1: _buildEditableField(
              'ribbonSizeOb1',
              widget.audit.ribbonSizeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'ribbonSizeOb2',
              widget.audit.ribbonSizeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'ribbonSizeRemark',
              widget.audit.ribbonSizeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Flux Make',
            observation1: _buildEditableField(
              'fluxMakeOb1',
              widget.audit.fluxMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'fluxMakeOb2',
              widget.audit.fluxMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'fluxMakeRemark',
              widget.audit.fluxMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Flux type',
            observation1: _buildEditableField(
              'fluxTypeOb1',
              widget.audit.fluxTypeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'fluxTypeOb2',
              widget.audit.fluxTypeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'fluxTypeRemark',
              widget.audit.fluxTypeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Flux Expiry date',
            observation1: _buildEditableField(
              'fluxExpiryDateOb1',
              widget.audit.fluxExpiryDateOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'fluxExpiryDateOb2',
              widget.audit.fluxExpiryDateOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'fluxExpiryDateRemark',
              widget.audit.fluxExpiryDateRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Soldering Temp (°C)',
            observation1: _buildEditableField(
              'solderingTempOb1',
              widget.audit.solderingTempOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'solderingTempOb2',
              widget.audit.solderingTempOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'solderingTempRemark',
              widget.audit.solderingTempRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'No. Of Working Heater',
            observation1: _buildEditableField(
              'workingHeatersOb1',
              widget.audit.workingHeatersOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'workingHeatersOb2',
              widget.audit.workingHeatersOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'workingHeatersRemark',
              widget.audit.workingHeatersRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Soldering Power',
            observation1: _buildEditableField(
              'solderingPowerOb1',
              widget.audit.solderingPowerOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'solderingPowerOb2',
              widget.audit.solderingPowerOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'solderingPowerRemark',
              widget.audit.solderingPowerRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Solder Time (Sec)',
            observation1: _buildEditableField(
              'solderTimeOb1',
              widget.audit.solderTimeOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'solderTimeOb2',
              widget.audit.solderTimeOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'solderTimeRemark',
              widget.audit.solderTimeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ribbon Alignment on Cell (OK/NOK)',
            observation1: _buildEditableField(
              'ribbonAlignmentOb1',
              widget.audit.ribbonAlignmentOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'ribbonAlignmentOb2',
              widget.audit.ribbonAlignmentOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'ribbonAlignmentRemark',
              widget.audit.ribbonAlignmentRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Head And Tail Ribbon Dimension',
            observation1: _buildEditableField(
              'ribbonDimensionsOb1',
              widget.audit.ribbonDimensionsOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'ribbonDimensionsOb2',
              widget.audit.ribbonDimensionsOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'ribbonDimensionsRemark',
              widget.audit.ribbonDimensionsRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cell to Cell Gap',
            observation1: _buildEditableField(
              'cellToCellGapOb1',
              widget.audit.cellToCellGapOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'cellToCellGapOb2',
              widget.audit.cellToCellGapOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'cellToCellGapRemark',
              widget.audit.cellToCellGapRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'String Length (L1, L2)',
            observation1: _buildEditableField(
              'stringLengthOb1',
              widget.audit.stringLengthOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'stringLengthOb2',
              widget.audit.stringLengthOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'stringLengthRemark',
              widget.audit.stringLengthRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Peel Test Result (Pass/Fail)',
            observation1: _buildEditableField(
              'peelTestResultOb1',
              widget.audit.peelTestResultOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'peelTestResultOb2',
              widget.audit.peelTestResultOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'peelTestResultRemark',
              widget.audit.peelTestResultRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'EL & Visual Inspection of String',
            observation1: _buildEditableField(
              'elInspectionOb1',
              widget.audit.elInspectionOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'elInspectionOb2',
              widget.audit.elInspectionOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'elInspectionRemark',
              widget.audit.elInspectionRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 5: Lay-up & Auto Bussing
  Widget _buildStage5(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '5',
            stage: 'Lay-up & Auto Bussing',
            inspectionType: 'Visual',
            parameters: 'Busbar Make',
            observation1: _buildEditableField(
              'busbarMakeOb1',
              widget.audit.busbarMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'busbarMakeOb2',
              widget.audit.busbarMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'busbarMakeRemark',
              widget.audit.busbarMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Busbar Size',
            observation1: _buildEditableField(
              'busbarSizeOb1',
              widget.audit.busbarSizeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'busbarSizeOb2',
              widget.audit.busbarSizeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'busbarSizeRemark',
              widget.audit.busbarSizeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cell Edge to Busbar Edge Distance',
            observation1: _buildEditableField(
              'cellToBusbarDistanceOb1',
              widget.audit.cellToBusbarDistanceOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'cellToBusbarDistanceOb2',
              widget.audit.cellToBusbarDistanceOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'cellToBusbarDistanceRemark',
              widget.audit.cellToBusbarDistanceRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'String to String Gap',
            observation1: _buildEditableField(
              'stringToStringGapOb1',
              widget.audit.stringToStringGapOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'stringToStringGapOb2',
              widget.audit.stringToStringGapOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'stringToStringGapRemark',
              widget.audit.stringToStringGapRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Top Side Gap',
            observation1: _buildEditableField(
              'topSideGapOb1',
              widget.audit.topSideGapOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'topSideGapOb2',
              widget.audit.topSideGapOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'topSideGapRemark',
              widget.audit.topSideGapRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Middle Side Gap',
            observation1: _buildEditableField(
              'middleSideGapOb1',
              widget.audit.middleSideGapOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'middleSideGapOb2',
              widget.audit.middleSideGapOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'middleSideGapRemark',
              widget.audit.middleSideGapRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Bottom Side Gap',
            observation1: _buildEditableField(
              'bottomSideGapOb1',
              widget.audit.bottomSideGapOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'bottomSideGapOb2',
              widget.audit.bottomSideGapOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'bottomSideGapRemark',
              widget.audit.bottomSideGapRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Left Side Gap',
            observation1: _buildEditableField(
              'leftSideGapOb1',
              widget.audit.leftSideGapOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'leftSideGapOb2',
              widget.audit.leftSideGapOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'leftSideGapRemark',
              widget.audit.leftSideGapRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Right Side Gap',
            observation1: _buildEditableField(
              'rightSideGapOb1',
              widget.audit.rightSideGapOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'rightSideGapOb2',
              widget.audit.rightSideGapOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'rightSideGapRemark',
              widget.audit.rightSideGapRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 6: Auto Tapping
  Widget _buildStage6(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '6',
            stage: 'Auto Tapping',
            inspectionType: 'Visual',
            parameters: 'Tap Make',
            observation1: _buildEditableField(
              'tapMakeOb1',
              widget.audit.tapMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'tapMakeOb2',
              widget.audit.tapMakeOb2 ?? '',
            ),
            remarks: _buildEditableField('', widget.audit.tapMakeRemark ?? ''),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Tap Position',
            observation1: _buildEditableField(
              'tapPositionOb1',
              widget.audit.tapPositionOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'tapPositionOb2',
              widget.audit.tapPositionOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'tapPositionRemark',
              widget.audit.tapPositionRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Tap Size',
            observation1: _buildEditableField(
              'tapSizeOb1',
              widget.audit.tapSizeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'tapSizeOb2',
              widget.audit.tapSizeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'tapSizeRemark',
              widget.audit.tapSizeRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 7: Rear side EVA Cutting
  Widget _buildStage7(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '7',
            stage: 'Rear side EVA Cutting',
            inspectionType: 'Visual',
            parameters: 'EVA Make',
            observation1: _buildEditableField(
              'rearEvaMakeOb1',
              widget.audit.rearEvaMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'rearEvaMakeOb2',
              widget.audit.rearEvaMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'rearEvaMakeRemark',
              widget.audit.rearEvaMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Type',
            observation1: _buildEditableField(
              'rearEvaTypeOb1',
              widget.audit.rearEvaTypeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'rearEvaTypeOb2',
              widget.audit.rearEvaTypeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'rearEvaTypeRemark',
              widget.audit.rearEvaTypeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Roll No',
            observation1: _buildEditableField(
              'rearEvaRollNoOb1',
              widget.audit.rearEvaRollNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'rearEvaRollNoOb2',
              widget.audit.rearEvaRollNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'rearEvaRollNoRemark',
              widget.audit.rearEvaRollNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Expiry Date',
            observation1: _buildEditableField(
              'rearEvaExpiryDateOb1',
              widget.audit.rearEvaExpiryDateOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'rearEvaExpiryDateOb2',
              widget.audit.rearEvaExpiryDateOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'rearEvaExpiryDateRemark',
              widget.audit.rearEvaExpiryDateRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'EVA Size (L x W x T)',
            observation1: _buildEditableField(
              'rearEvaSizeOb1',
              widget.audit.rearEvaSizeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'rearEvaSizeOb2',
              widget.audit.rearEvaSizeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'rearEvaSizeRemark',
              widget.audit.rearEvaSizeRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 8: Rear Side Back Sheet/Glass
  Widget _buildStage8(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '8',
            stage: 'Rear Side Back Sheet/Glass',
            inspectionType: 'Visual',
            parameters: 'Back Sheet / Glass Make',
            observation1: _buildEditableField(
              'backsheetMakeOb1',
              widget.audit.backsheetMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'backsheetMakeOb2',
              widget.audit.backsheetMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'backsheetMakeRemark',
              widget.audit.backsheetMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Back Sheet / Glass Type',
            observation1: _buildEditableField(
              'backsheetTypeOb1',
              widget.audit.backsheetTypeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'backsheetTypeOb2',
              widget.audit.backsheetTypeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'backsheetTypeRemark',
              widget.audit.backsheetTypeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Back Sheet / Glass Roll No.',
            observation1: _buildEditableField(
              'backsheetRollNoOb1',
              widget.audit.backsheetRollNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'backsheetRollNoOb2',
              widget.audit.backsheetRollNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'backsheetRollNoRemark',
              widget.audit.backsheetRollNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Back Sheet / Glass Dimension (L x W x T)',
            observation1: _buildEditableField(
              'backsheetDimensionsOb1',
              widget.audit.backsheetDimensionsOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'backsheetDimensionsOb2',
              widget.audit.backsheetDimensionsOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'backsheetDimensionsRemark',
              widget.audit.backsheetDimensionsRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 9: Logo & Barcode Fixing
  Widget _buildStage9(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '9',
            stage: 'Logo & Barcode Fixing',
            inspectionType: 'Visual',
            parameters: 'Position Verification of Logo & Barcode',
            observation1: _buildEditableField(
              'logoPositionOkOb1',
              widget.audit.logoPositionOkOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'logoPositionOkOb2',
              widget.audit.logoPositionOkOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'logoPositionOkRemark',
              widget.audit.logoPositionOkRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 10: Pre-El Inspection
  Widget _buildStage10(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '10',
            stage: 'Pre-El Inspection',
            inspectionType: 'Visual',
            parameters: 'Module Sr. Number',
            observation1: _buildEditableField(
              'preElSerialNoOb1',
              widget.audit.preElSerialNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'preElSerialNoOb2',
              widget.audit.preElSerialNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'preElSerialNoRemark',
              widget.audit.preElSerialNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Current',
            observation1: _buildEditableField(
              'preElCurrentOb1',
              widget.audit.preElCurrentOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'preElCurrentOb2',
              widget.audit.preElCurrentOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'preElCurrentRemark',
              widget.audit.preElCurrentRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Voltage',
            observation1: _buildEditableField(
              'preElVoltageOb1',
              widget.audit.preElVoltageOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'preElVoltageOb2',
              widget.audit.preElVoltageOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'preElVoltageRemark',
              widget.audit.preElVoltageRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Defects (If Any)',
            observation1: _buildEditableField(
              'preElDefectsOb1',
              widget.audit.preElDefectsOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'preElDefectsOb2',
              widget.audit.preElDefectsOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'preElDefectsRemark',
              widget.audit.preElDefectsRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 11: Auto Edge Taping
  Widget _buildStage11(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '11',
            stage: 'Auto Edge Taping',
            inspectionType: 'Visual',
            parameters: 'Visually',
            observation1: _buildEditableField(
              'edgeTapingOkOb1',
              widget.audit.edgeTapingOkOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'edgeTapingOkOb2',
              widget.audit.edgeTapingOkOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'edgeTapingOkRemark',
              widget.audit.edgeTapingOkRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 12: Lamination Process
  Widget _buildStage12(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '12',
            stage: 'Lamination Process',
            inspectionType: '',
            parameters: 'Laminator No.',
            observation1: _buildEditableField(
              'laminatorNoOb1',
              widget.audit.laminatorNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'laminatorNoOb2',
              widget.audit.laminatorNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'laminatorNoRemark',
              widget.audit.laminatorNoRemark ?? '',
            ),
          ),

          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Lamination Chamber',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [Text('Ch-01:', style: TextStyle(fontSize: 12))],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [Text('Ch-02:', style: TextStyle(fontSize: 12))],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [Text('Ch-03:', style: TextStyle(fontSize: 12))],
                  ),
                ),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [Text('Ch-01:', style: TextStyle(fontSize: 12))],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [Text('Ch-02:', style: TextStyle(fontSize: 12))],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [Text('Ch-03:', style: TextStyle(fontSize: 12))],
                  ),
                ),
              ],
            ),
            remarks: Text('-', style: TextStyle(fontSize: 12)),
          ),

          // UPDATED: Lamination Temp - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Lamination Temp (°C)',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationTempsCh01Ob1',
                        widget.audit.laminationTempsCh01Ob1?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationTempsCh02Ob1',
                        widget.audit.laminationTempsCh02Ob1?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationTempsCh03Ob1',
                        widget.audit.laminationTempsCh03Ob1?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationTempsCh01Ob2',
                        widget.audit.laminationTempsCh01Ob2?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationTempsCh02Ob2',
                        widget.audit.laminationTempsCh02Ob2?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationTempsCh03Ob2',
                        widget.audit.laminationTempsCh03Ob2?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'laminationTempsRemark',
              widget.audit.laminationTempsRemark ?? '',
            ),
          ),

          // Total vacuum time - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Total Vacuum Time',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'vacuumTimesCh01Ob1',
                        widget.audit.vacuumTimesCh01Ob1?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'vacuumTimesCh02Ob1',
                        widget.audit.vacuumTimesCh02Ob1?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'vacuumTimesCh03Ob1',
                        widget.audit.vacuumTimesCh03Ob1?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'vacuumTimesCh01Ob2',
                        widget.audit.vacuumTimesCh01Ob2?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'vacuumTimesCh02Ob2',
                        widget.audit.vacuumTimesCh02Ob2?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'vacuumTimesCh03Ob2',
                        widget.audit.vacuumTimesCh03Ob2?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'vacuumTimesRemark',
              widget.audit.vacuumTimesRemark ?? '',
            ),
          ),

          // upper vent - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Upper Vent 1',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventOneCh01Ob1',
                        widget.audit.upperventOneCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventOneCh02Ob1',
                        widget.audit.upperventOneCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventOneCh03Ob1',
                        widget.audit.upperventOneCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventOneCh01Ob2',
                        widget.audit.upperventOneCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventOneCh02Ob2',
                        widget.audit.upperventOneCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventOneCh03Ob2',
                        widget.audit.upperventOneCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'upperventOneRemark',
              widget.audit.upperventOneRemark ?? '',
            ),
          ),

          // Lamination 1 - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lamination 1',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationOneCh01Ob1',
                        widget.audit.laminationOneCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationOneCh02Ob1',
                        widget.audit.laminationOneCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationOneCh03Ob1',
                        widget.audit.laminationOneCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationOneCh01Ob2',
                        widget.audit.laminationOneCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationOneCh02Ob2',
                        widget.audit.laminationOneCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationOneCh03Ob2',
                        widget.audit.laminationOneCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'laminationOneRemark',
              widget.audit.laminationOneRemark ?? '',
            ),
          ),

          // upper vent 2 - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Upper Vent 2',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventSecCh01Ob1',
                        widget.audit.upperventSecCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventSecCh02Ob1',
                        widget.audit.upperventSecCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventSecCh03Ob1',
                        widget.audit.upperventSecCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventSecCh01Ob2',
                        widget.audit.upperventSecCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventSecCh02Ob2',
                        widget.audit.upperventSecCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventSecCh03Ob2',
                        widget.audit.upperventSecCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'upperventSecRemark',
              widget.audit.upperventSecRemark ?? '',
            ),
          ),

          // Lamination 2 - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lamination 2',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationSecCh01Ob1',
                        widget.audit.laminationSecCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationSecCh02Ob1',
                        widget.audit.laminationSecCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationSecCh03Ob1',
                        widget.audit.laminationSecCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationSecCh01Ob2',
                        widget.audit.laminationSecCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationSecCh02Ob2',
                        widget.audit.laminationSecCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationSecCh03Ob2',
                        widget.audit.laminationSecCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'laminationSecRemark',
              widget.audit.laminationSecRemark ?? '',
            ),
          ),

          // upper vent 3 - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Upper Vent 3',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventThirdCh01Ob1',
                        widget.audit.upperventThirdCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventThirdCh02Ob1',
                        widget.audit.upperventThirdCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventThirdCh03Ob1',
                        widget.audit.upperventThirdCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventThirdCh01Ob2',
                        widget.audit.upperventThirdCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventThirdCh02Ob2',
                        widget.audit.upperventThirdCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'upperventThirdCh03Ob2',
                        widget.audit.upperventThirdCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'upperventThirdRemark',
              widget.audit.upperventThirdRemark ?? '',
            ),
          ),

          // Lamination 3 - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lamination 3',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationThirdCh01Ob1',
                        widget.audit.laminationThirdCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationThirdCh02Ob1',
                        widget.audit.laminationThirdCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationThirdCh03Ob1',
                        widget.audit.laminationThirdCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationThirdCh01Ob2',
                        widget.audit.laminationThirdCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationThirdCh02Ob2',
                        widget.audit.laminationThirdCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'laminationThirdCh03Ob2',
                        widget.audit.laminationThirdCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'laminationThirdRemark',
              widget.audit.laminationThirdRemark ?? '',
            ),
          ),

          // lower vent time - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lower vent Time',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'lowerVentTimeCh01Ob1',
                        widget.audit.lowerVentTimeCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'lowerVentTimeCh02Ob1',
                        widget.audit.lowerVentTimeCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'lowerVentTimeCh03Ob1',
                        widget.audit.lowerVentTimeCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'lowerVentTimeCh01Ob2',
                        widget.audit.lowerVentTimeCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'lowerVentTimeCh02Ob2',
                        widget.audit.lowerVentTimeCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'lowerVentTimeCh03Ob2',
                        widget.audit.lowerVentTimeCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'lowerVentTimeRemark',
              widget.audit.lowerVentTimeRemark ?? '',
            ),
          ),

          // Total Cycle time - Single Row with Ch-01, Ch-02, Ch-03
          _buildDataRow(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Total Cycle Time',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'totalCycleTimeCh01Ob1',
                        widget.audit.totalCycleTimeCh01Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'totalCycleTimeCh02Ob1',
                        widget.audit.totalCycleTimeCh02Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'totalCycleTimeCh03Ob1',
                        widget.audit.totalCycleTimeCh03Ob1 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'totalCycleTimeCh01Ob2',
                        widget.audit.totalCycleTimeCh01Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'totalCycleTimeCh02Ob2',
                        widget.audit.totalCycleTimeCh02Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'totalCycleTimeCh03Ob2',
                        widget.audit.totalCycleTimeCh03Ob2 ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildEditableField(
              'totalCycleTimeRemark',
              widget.audit.totalCycleTimeRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 13: Auto Edge Trimming
  Widget _buildStage13(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '13',
            stage: 'Auto Edge Trimming',
            inspectionType: 'Visual',
            parameters: 'Physical Verification of Trimming',
            observation1: _buildEditableField(
              'trimmingOkOb1',
              widget.audit.trimmingOkOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'trimmingOkOb2',
              widget.audit.trimmingOkOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'trimmingOkRemark',
              widget.audit.trimmingOkRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 14: Framing Process
  Widget _buildStage14(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '14',
            stage: 'Framing Process',
            inspectionType: 'Visual',
            parameters: 'Module Sr. Number',
            observation1: _buildEditableField(
              'frameSerialNoOb1',
              widget.audit.frameSerialNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'frameSerialNoOb2',
              widget.audit.frameSerialNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'frameSerialNoRemark',
              widget.audit.frameSerialNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Frame Make',
            observation1: _buildEditableField(
              'frameMakeOb1',
              widget.audit.frameMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'frameMakeOb2',
              widget.audit.frameMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'frameMakeRemark',
              widget.audit.frameMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Corner Key Make',
            observation1: _buildEditableField(
              'cornerKeyMakeOb1',
              widget.audit.cornerKeyMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'cornerKeyMakeOb2',
              widget.audit.cornerKeyMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'cornerKeyMakeRemark',
              widget.audit.cornerKeyMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Profile Cut Angel',
            observation1: _buildEditableField(
              'profileCutAngleOb1',
              widget.audit.profileCutAngleOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'profileCutAngleOb2',
              widget.audit.profileCutAngleOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'profileCutAngleRemark',
              widget.audit.profileCutAngleRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Length (mm)',
            observation1: _buildEditableField(
              'frameLengthOb1',
              widget.audit.frameLengthOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'frameLengthOb2',
              widget.audit.frameLengthOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'frameLengthRemark',
              widget.audit.frameLengthRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Width (mm)',
            observation1: _buildEditableField(
              'frameWidthOb1',
              widget.audit.frameWidthOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'frameWidthOb2',
              widget.audit.frameWidthOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'frameWidthRemark',
              widget.audit.frameWidthRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Height (mm)',
            observation1: _buildEditableField(
              'frameHeightOb1',
              widget.audit.frameHeightOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'frameHeightOb2',
              widget.audit.frameHeightOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'frameHeightRemark',
              widget.audit.frameHeightRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Mounting Hole (mm)',
            observation1: _buildEditableField(
              'mountingHoleOb1',
              widget.audit.mountingHoleOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'mountingHoleOb2',
              widget.audit.mountingHoleOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'mountingHoleRemark',
              widget.audit.mountingHoleRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'X-Pitch (mm)',
            observation1: _buildEditableField(
              'xPitchOb1',
              widget.audit.xPitchOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'xPitchOb2',
              widget.audit.xPitchOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'xPitchRemark',
              widget.audit.xPitchRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Y-Pitch (mm)',
            observation1: _buildEditableField(
              'yPitchOb1',
              widget.audit.yPitchOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'yPitchOb2',
              widget.audit.yPitchOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'yPitchRemark',
              widget.audit.yPitchRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Hole Dia. (mm)',
            observation1: _buildEditableField(
              'groundHoleDiaOb1',
              widget.audit.groundHoleDiaOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'groundHoleDiaOb2',
              widget.audit.groundHoleDiaOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'groundHoleDiaRemark',
              widget.audit.groundHoleDiaRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Hole Distance from Edge (mm)',
            observation1: _buildEditableField(
              'groundHoleDistanceOb1',
              widget.audit.groundHoleDistanceOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'groundHoleDistanceOb2',
              widget.audit.groundHoleDistanceOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'groundHoleDistanceRemark',
              widget.audit.groundHoleDistanceRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Drain Hole Size (mm)',
            observation1: _buildEditableField(
              'drainHoleSizeOb1',
              widget.audit.drainHoleSizeOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'drainHoleSizeOb2',
              widget.audit.drainHoleSizeOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'drainHoleSizeRemark',
              widget.audit.drainHoleSizeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Drain Hole Distance from Edge (mm)',
            observation1: _buildEditableField(
              'drainHoleDistanceOb1',
              widget.audit.drainHoleDistanceOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'drainHoleDistanceOb2',
              widget.audit.drainHoleDistanceOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'drainHoleDistanceRemark',
              widget.audit.drainHoleDistanceRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Diagonal Length (mm)',
            observation1: _buildEditableField(
              'diagonalLengthOb1',
              widget.audit.diagonalLengthOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'diagonalLengthOb2',
              widget.audit.diagonalLengthOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'diagonalLengthRemark',
              widget.audit.diagonalLengthRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Sealant Make',
            observation1: _buildEditableField(
              'sealantMakeOb1',
              widget.audit.sealantMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'sealantMakeOb2',
              widget.audit.sealantMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'sealantMakeRemark',
              widget.audit.sealantMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Sealant Type',
            observation1: _buildEditableField(
              'sealantTypeOb1',
              widget.audit.sealantTypeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'sealantTypeOb2',
              widget.audit.sealantTypeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'sealantTypeRemark',
              widget.audit.sealantTypeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Sealant weight in Frame (gm/m)',
            observation1: _buildEditableField(
              'sealantWeightOb1',
              widget.audit.sealantWeightOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'sealantWeightOb2',
              widget.audit.sealantWeightOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'sealantWeightRemark',
              widget.audit.sealantWeightRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Scratch, Dents etc. on Frame',
            observation1: _buildEditableField(
              'frameDefectsOb1',
              widget.audit.frameDefectsOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'frameDefectsOb2',
              widget.audit.frameDefectsOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'frameDefectsRemark',
              widget.audit.frameDefectsRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 15: Junction Box Assembly
  Widget _buildStage15(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '15',
            stage: 'Junction Box Assembly',
            inspectionType: 'Visual',
            parameters: 'Module Sr. No.',
            observation1: _buildEditableField(
              'jbSerialNoOb1',
              widget.audit.jbSerialNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'jbSerialNoOb2',
              widget.audit.jbSerialNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'jbSerialNoRemark',
              widget.audit.jbSerialNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Junction Box Make',
            observation1: _buildEditableField(
              'jbMakeOb1',
              widget.audit.jbMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'jbMakeOb2',
              widget.audit.jbMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'jbMakeRemark',
              widget.audit.jbMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Junction Box Type',
            observation1: _buildEditableField(
              'jbTypeOb1',
              widget.audit.jbTypeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'jbTypeOb2',
              widget.audit.jbTypeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'jbTypeRemark',
              widget.audit.jbTypeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Diode Model No.',
            observation1: _buildEditableField(
              'diodeModelOb1',
              widget.audit.diodeModelOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'diodeModelOb2',
              widget.audit.diodeModelOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'diodeModelRemark',
              widget.audit.diodeModelRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Junction Box Placement',
            observation1: _buildEditableField(
              'jbPlacementOb1',
              widget.audit.jbPlacementOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'jbPlacementOb2',
              widget.audit.jbPlacementOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'jbPlacementRemark',
              widget.audit.jbPlacementRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Junction Box Sealant Weight A,B,C',

            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'jbSealantWeightsAOb1',
                        'A: ${widget.audit.jbSealantWeightsAOb1}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'jbSealantWeightsBOb2',
                        'B: ${widget.audit.jbSealantWeightsBOb1}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'jbSealantWeightsCOb1',
                        'C: ${widget.audit.jbSealantWeightsCOb1}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'jbSealantWeightsAOb2',
                        'A: ${widget.audit.jbSealantWeightsAOb2}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'jbSealantWeightsBOb2',
                        'B: ${widget.audit.jbSealantWeightsBOb2}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'jbSealantWeightsCOb2',
                        'C: ${widget.audit.jbSealantWeightsCOb2}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            remarks: _buildEditableField(
              'jbSealantWeightsRemark',
              widget.audit.jbSealantWeightsRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Soldering Quality of J.B.',
            observation1: _buildEditableField(
              'solderingQualityOb1',
              widget.audit.solderingQualityOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'solderingQualityOb2',
              widget.audit.solderingQualityOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'solderingQualityRemark',
              widget.audit.solderingQualityRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Make',
            observation1: _buildEditableField(
              'pottingSealantMakeOb1',
              widget.audit.pottingSealantMakeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'pottingSealantMakeOb2',
              widget.audit.pottingSealantMakeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'pottingSealantMakeRemark',
              widget.audit.pottingSealantMakeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Type',
            observation1: _buildEditableField(
              'pottingSealantTypeOb1',
              widget.audit.pottingSealantTypeOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'pottingSealantTypeOb2',
              widget.audit.pottingSealantTypeOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'pottingSealantTypeRemark',
              widget.audit.pottingSealantTypeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Expiry Date',
            observation1: _buildEditableField(
              'pottingSealantExpiryOb1',
              widget.audit.pottingSealantExpiryOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'pottingSealantExpiryOb2',
              widget.audit.pottingSealantExpiryOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'pottingSealantExpiryRemark',
              widget.audit.pottingSealantExpiryRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Curing Time (minute)',
            observation1: _buildEditableField(
              'curingTimeOb1',
              widget.audit.curingTimeOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'curingTimeOb2',
              widget.audit.curingTimeOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'curingTimeRemark',
              widget.audit.curingTimeRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Potting Sealant Weight A,B,C',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingSealantWeightsAOb1',
                        'A: ${widget.audit.pottingSealantWeightsAOb1}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingSealantWeightsBOb1',
                        'B: ${widget.audit.pottingSealantWeightsBOb1}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingSealantWeightsCOb1',
                        'C: ${widget.audit.pottingSealantWeightsCOb1}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'jbSealantWeightsAOb2',
                        'A: ${widget.audit.jbSealantWeightsAOb2}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingSealantWeightsBOb2',
                        'B: ${widget.audit.pottingSealantWeightsBOb2}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingSealantWeightsCOb2',
                        'C: ${widget.audit.pottingSealantWeightsCOb2}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            remarks: _buildEditableField(
              'pottingSealantWeightsRemark',
              widget.audit.pottingSealantWeightsRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Ratio (A:B)',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingRatioAOb1',
                        'A: ${widget.audit.pottingRatioAOb1}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingRatioBOb1',
                        'B: ${widget.audit.pottingRatioBOb1}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingRatioOb1',
                        'Ratio: ${widget.audit.pottingRatioOb1}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingRatioAOb2',
                        'A: ${widget.audit.pottingRatioAOb2}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingRatioBOb2',
                        'B: ${widget.audit.pottingRatioBOb2}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'pottingRatioOb2',
                        'Ratio: ${widget.audit.pottingRatioOb2}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            remarks: _buildEditableField(
              'pottingRatioRemark',
              widget.audit.pottingRatioRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cable Length (mm)',
            observation1: _buildEditableField(
              'cableLengthOb1',
              widget.audit.cableLengthOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'cableLengthOb2',
              widget.audit.cableLengthOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'cableLengthRemark',
              widget.audit.cableLengthRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Visual Status',
            observation1: _buildEditableField(
              'visualStatusOb1',
              widget.audit.visualStatusOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'visualStatusOb2',
              widget.audit.visualStatusOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'visualStatusRemark',
              widget.audit.visualStatusRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 16: Curing Line
  Widget _buildStage16(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '16',
            stage: 'Curing Line',
            inspectionType: 'Visual',
            parameters: 'Curing Time',
            observation1: _buildEditableField(
              'curingTimeLineOb1',
              widget.audit.curingTimeLineOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'curingTimeLineOb2',
              widget.audit.curingTimeLineOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'curingTimeLineRemark',
              widget.audit.curingTimeLineRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Temp (°C)',
            observation1: _buildEditableField(
              'curingTempOb1',
              widget.audit.curingTempOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'curingTempOb2',
              widget.audit.curingTempOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'curingTempRemark',
              widget.audit.curingTempRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Humidity (%)',
            observation1: _buildEditableField(
              'curingHumidityOb1',
              widget.audit.curingHumidityOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'curingHumidityOb2',
              widget.audit.curingHumidityOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'curingHumidityRemark',
              widget.audit.curingHumidityRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 17: Module Cleaning
  Widget _buildStage17(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '17',
            stage: 'Module Cleaning',
            inspectionType: 'Visual',
            parameters: 'Physical Verification',
            observation1: _buildEditableField(
              'cleaningOkOb1',
              widget.audit.cleaningOkOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'cleaningOkOb2',
              widget.audit.cleaningOkOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'cleaningOkRemark',
              widget.audit.cleaningOkRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 18: Hi-Pot Testing
  Widget _buildStage18(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '18',
            stage: 'Hi-Pot Testing',
            inspectionType: 'Visual',
            parameters: 'Module Sr. No.',
            observation1: _buildEditableField(
              'hipotSerialNoOb1',
              widget.audit.hipotSerialNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'hipotSerialNoOb2',
              widget.audit.hipotSerialNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'hipotSerialNoRemark',
              widget.audit.hipotSerialNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'DCW',
            observation1: _buildEditableField(
              'dcwOb1',
              widget.audit.dcwOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'dcwOb2',
              widget.audit.dcwOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'dcwRemark',
              widget.audit.dcwRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'IR',
            observation1: _buildEditableField(
              'irOb1',
              widget.audit.irOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'irOb2',
              widget.audit.irOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'irRemark',
              widget.audit.irRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Continuity',
            observation1: _buildEditableField(
              'groundContinuityOb1',
              widget.audit.groundContinuityOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'groundContinuityOb2',
              widget.audit.groundContinuityOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'groundContinuityRemark',
              widget.audit.groundContinuityRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 19: Post-El Inspection
  Widget _buildStage19(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '19',
            stage: 'Post-El Inspection',
            inspectionType: 'Visual',
            parameters: 'Module Sr. Number',
            observation1: _buildEditableField(
              'postElSerialNoOb1',
              widget.audit.postElSerialNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'postElSerialNoOb2',
              widget.audit.postElSerialNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'postElSerialNoRemark',
              widget.audit.postElSerialNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Current',
            observation1: _buildEditableField(
              'postElCurrentOb1',
              widget.audit.postElCurrentOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'postElCurrentOb2',
              widget.audit.postElCurrentOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'postElCurrentRemark',
              widget.audit.postElCurrentRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Voltage',
            observation1: _buildEditableField(
              'postElVoltageOb1',
              widget.audit.postElVoltageOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'postElVoltageOb2',
              widget.audit.postElVoltageOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'postElVoltageRemark',
              widget.audit.postElVoltageRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Defects (If Any)',
            observation1: _buildEditableField(
              'postElDefectsOb1',
              widget.audit.postElDefectsOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'postElDefectsOb2',
              widget.audit.postElDefectsOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'postElDefectsRemark',
              widget.audit.postElDefectsRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 20: Sun Simulator
  Widget _buildStage20(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '20',
            stage: 'Sun Simulator',
            inspectionType: 'Visual',
            parameters: 'Sun Simulator Calibration',
            observation1: _buildEditableField(
              'calibrationDateOb1',
              widget.audit.calibrationDateOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'calibrationDateOb2',
              widget.audit.calibrationDateOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'calibrationDateRemark',
              widget.audit.calibrationDateRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Module Sr. No.',
            observation1: _buildEditableField(
              'sunSerialNoOb1',
              widget.audit.sunSerialNoOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'sunSerialNoOb2',
              widget.audit.sunSerialNoOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'sunSerialNoRemark',
              widget.audit.sunSerialNoRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Module Power Output (W)',
            observation1: _buildEditableField(
              'modulePowerOb1',
              widget.audit.modulePowerOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'modulePowerOb2',
              widget.audit.modulePowerOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'modulePowerRemark',
              widget.audit.modulePowerRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Isc (I)',
            observation1: _buildEditableField(
              'iscOb1',
              widget.audit.iscOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'iscOb2',
              widget.audit.iscOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'iscRemark',
              widget.audit.iscRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Voc (V)',
            observation1: _buildEditableField(
              'vocOb1',
              widget.audit.vocOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'vocOb2',
              widget.audit.vocOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'vocRemark',
              widget.audit.vocRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Imp (I)',
            observation1: _buildEditableField(
              'impOb1',
              widget.audit.impOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'impOb2',
              widget.audit.impOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'impRemark',
              widget.audit.impRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Vmp (V)',
            observation1: _buildEditableField(
              'vmpOb1',
              widget.audit.vmpOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'vmpOb2',
              widget.audit.vmpOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'vmpRemark',
              widget.audit.vmpRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Module Temp (°C)',
            observation1: _buildEditableField(
              'moduleTempOb1',
              widget.audit.moduleTempOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'moduleTempOb2',
              widget.audit.moduleTempOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'moduleTempRemark',
              widget.audit.moduleTempRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Module F.F & Effi.',

            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'fillFactorOb1',
                        'F.F:: ${widget.audit.fillFactorOb1}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'efficiencyOb1',
                        'EFFI.:: ${widget.audit.efficiencyOb1}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'fillFactorOb2',
                        'F.F:: ${widget.audit.fillFactorOb2}',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditableField(
                        'efficiencyOb2',
                        'EFFI.:: ${widget.audit.efficiencyOb2}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            remarks: _buildEditableField(
              'efficiencyRemark',
              widget.audit.efficiencyRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'IV Curve (OK/NOK)',
            observation1: _buildEditableField(
              'ivCurveOkOb1',
              widget.audit.ivCurveOkOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'ivCurveOkOb2',
              widget.audit.ivCurveOkOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'ivCurveOkRemark',
              widget.audit.ivCurveOkRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 21: FQC
  Widget _buildStage21(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '21',
            stage: 'FQC',
            inspectionType: 'Visual',
            parameters: 'Visual Inspection of Module',
            observation1: _buildEditableField(
              'visualInspectionOb1',
              widget.audit.visualInspectionOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'visualInspectionOb2',
              widget.audit.visualInspectionOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'visualInspectionRemark',
              widget.audit.visualInspectionRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Fitment of JB Cover',
            observation1: _buildEditableField(
              'jbCoverFitmentOb1',
              widget.audit.jbCoverFitmentOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'jbCoverFitmentOb2',
              widget.audit.jbCoverFitmentOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'jbCoverFitmentRemark',
              widget.audit.jbCoverFitmentRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Placement of Back label & Barcode (OK/NOK)',
            observation1: _buildEditableField(
              'labelPlacementOb1',
              widget.audit.labelPlacementOb1?.toString() ?? '',
            ),
            observation2: _buildEditableField(
              'labelPlacementOb2',
              widget.audit.labelPlacementOb2?.toString() ?? '',
            ),
            remarks: _buildEditableField(
              'labelPlacementRemark',
              widget.audit.labelPlacementRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Defect (If Any)',
            observation1: _buildEditableField(
              'fqcDefectsOb1',
              widget.audit.fqcDefectsOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'fqcDefectsOb2',
              widget.audit.fqcDefectsOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'fqcDefectsRemark',
              widget.audit.fqcDefectsRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  // Stage 22: Auto Sorter & Packing
  Widget _buildStage22(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(2.0),
          6: FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRow(
            srNo: '22',
            stage: 'Auto Sorter & Packing',
            inspectionType: 'Visual',
            parameters: 'Sorting Status',
            observation1: _buildEditableField(
              'sortingStatusOb1',
              widget.audit.sortingStatusOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'sortingStatusOb2',
              widget.audit.sortingStatusOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'sortingStatusRemark',
              widget.audit.sortingStatusRemark ?? '',
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Pallet & Box Condition',
            observation1: _buildEditableField(
              'palletConditionOb1',
              widget.audit.palletConditionOb1 ?? '',
            ),
            observation2: _buildEditableField(
              'palletConditionOb2',
              widget.audit.palletConditionOb2 ?? '',
            ),
            remarks: _buildEditableField(
              'palletConditionRemark',
              widget.audit.palletConditionRemark ?? '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.0),
          3: FlexColumnWidth(1.0),
        },
        children: [
          TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('Audit Done By:'),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  widget.audit.auditorName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(padding: EdgeInsets.all(8), child: Text('Verify By:')),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  widget.audit.verifiedBy,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildDataRow({
    required String srNo,
    required String stage,
    required String inspectionType,
    required String parameters,
    required Widget observation1,
    required Widget observation2,
    required Widget remarks,
  }) {
    return TableRow(
      children: [
        _buildDataCell(Center(child: Text(srNo))),
        _buildDataCell(Text(stage)),
        _buildDataCell(Center(child: Text(inspectionType))),
        _buildDataCell(Text(parameters)),
        _buildDataCell(observation1),
        _buildDataCell(observation2),
        _buildDataCell(remarks),
      ],
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(padding: EdgeInsets.all(4), child: child);
  }

  void navigateToPdfScreen(BuildContext context, AuditForm audit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfScreen(audit: audit)),
    );
  }
}
