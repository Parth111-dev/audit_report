import 'dart:typed_data';
import 'dart:io';
import 'package:final_audit/screens/pdf_screen.dart';
import 'package:final_audit/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sheet_cutting_audit_model.dart';
import '../models/audit_model.dart';
import '../services/auth_service.dart';
import '../services/audit_service.dart';
import '../services/pdf_service.dart';
import 'sheet_cutting_pdf_screen.dart';

class SheetCuttingDetailScreen extends StatefulWidget {
  final SheetCuttingAuditForm audit;

  const SheetCuttingDetailScreen({Key? key, required this.audit})
    : super(key: key);

  @override
  State<SheetCuttingDetailScreen> createState() =>
      _SheetCuttingDetailScreenState();
}

class _SheetCuttingDetailScreenState extends State<SheetCuttingDetailScreen> {
  late SheetCuttingAuditForm audit;
  bool isAdmin = false;
  bool isEditing = false;
  bool _isInitialized = false;
  bool _isSaving = false;
  Uint8List? logoBytes;

  // Expansion state for time slots
  Map<String, bool> expandedSlots = {
    'eightAM': false,
    'tenAM': false,
    'twelvePM': false,
    'twoPM': false,
    'fourPM': false,
    'sixPM': false,
    'eightPM': false,
    'tenPM': false,
    'twelveAM': false,
    'twoAM': false,
    'fourAM': false,
    'sixAM': false,
  };

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
    _loadLogo();
    _initializeFieldControllers();
  }

  void _initializeFieldControllers() {
    // Initialize controllers for all audit fields
    fieldControllers['serialNumber'] = TextEditingController(
      text: audit.serialNumber,
    );
    fieldControllers['auditDate'] = TextEditingController(
      text: audit.auditDate,
    );
    fieldControllers['auditorName'] = TextEditingController(
      text: audit.auditorName,
    );
    fieldControllers['verifiedBy'] = TextEditingController(
      text: audit.verifiedBy,
    );
    fieldControllers['shift'] = TextEditingController(text: audit.shift);
    fieldControllers['po'] = TextEditingController(text: audit.po);
    fieldControllers['moduleType'] = TextEditingController(
      text: audit.moduleType,
    );

    // Common fields
    fieldControllers['date'] = TextEditingController(text: audit.date ?? '');
    fieldControllers['line'] = TextEditingController(text: audit.line ?? '');
    fieldControllers['remarks'] = TextEditingController(
      text: audit.remarks ?? '',
    );
    fieldControllers['note'] = TextEditingController(text: audit.note ?? '');
    fieldControllers['qcInnspectorName'] = TextEditingController(
      text: audit.qcInnspectorName ?? '',
    );
    fieldControllers['preparedBy'] = TextEditingController(
      text: audit.preparedBy ?? '',
    );
    fieldControllers['verifyBy'] = TextEditingController(
      text: audit.verifyBy ?? '',
    );
    fieldControllers['approvedBy'] = TextEditingController(
      text: audit.approvedBy ?? '',
    );

    // Initialize all time entry fields...
    // [Keep all the field controller initialization from your original code]
    fieldControllers['eightAMevaMake'] = TextEditingController(
      text: audit.eightAMevaMake ?? '',
    );
    fieldControllers['eightAMevaFront'] = TextEditingController(
      text: audit.eightAMevaFront ?? '',
    );
    fieldControllers['eightAMevaBack'] = TextEditingController(
      text: audit.eightAMevaBack ?? '',
    );
    fieldControllers['eightAMpoNo'] = TextEditingController(
      text: audit.eightAMpoNo ?? '',
    );
    fieldControllers['eightAMasPrPo'] = TextEditingController(
      text: audit.eightAMasPrPo ?? '',
    );
    fieldControllers['eightAMdimensionFront'] = TextEditingController(
      text: audit.eightAMdimensionFront ?? '',
    );
    fieldControllers['eightAMdimensionBack'] = TextEditingController(
      text: audit.eightAMdimensionBack ?? '',
    );
    fieldControllers['eightAMvisualCheck'] = TextEditingController(
      text: audit.eightAMvisualCheck ?? '',
    );
    fieldControllers['eightAMdefect'] = TextEditingController(
      text: audit.eightAMdefect ?? '',
    );
    fieldControllers['eightAMremark'] = TextEditingController(
      text: audit.eightAMremark ?? '',
    );
    fieldControllers['eightAMcheckedBy'] = TextEditingController(
      text: audit.eightAMcheckedBy ?? '',
    );

    // 10 AM time entry fields
    fieldControllers['tenAMevaMake'] = TextEditingController(
      text: audit.tenAMevaMake ?? '',
    );
    fieldControllers['tenAMevaFront'] = TextEditingController(
      text: audit.tenAMevaFront ?? '',
    );
    fieldControllers['tenAMevaBack'] = TextEditingController(
      text: audit.tenAMevaBack ?? '',
    );
    fieldControllers['tenAMpoNo'] = TextEditingController(
      text: audit.tenAMpoNo ?? '',
    );
    fieldControllers['tenAMasPrPo'] = TextEditingController(
      text: audit.tenAMasPrPo ?? '',
    );
    fieldControllers['tenAMdimensionFront'] = TextEditingController(
      text: audit.tenAMdimensionFront ?? '',
    );
    fieldControllers['tenAMdimensionBack'] = TextEditingController(
      text: audit.tenAMdimensionBack ?? '',
    );
    fieldControllers['tenAMvisualCheck'] = TextEditingController(
      text: audit.tenAMvisualCheck ?? '',
    );
    fieldControllers['tenAMdefect'] = TextEditingController(
      text: audit.tenAMdefect ?? '',
    );
    fieldControllers['tenAMremark'] = TextEditingController(
      text: audit.tenAMremark ?? '',
    );
    fieldControllers['tenAMcheckedBy'] = TextEditingController(
      text: audit.tenAMcheckedBy ?? '',
    );

    // 12 PM time entry fields
    fieldControllers['twelvePMevaMake'] = TextEditingController(
      text: audit.twelvePMevaMake ?? '',
    );
    fieldControllers['twelvePMevaFront'] = TextEditingController(
      text: audit.twelvePMevaFront ?? '',
    );
    fieldControllers['twelvePMevaBack'] = TextEditingController(
      text: audit.twelvePMevaBack ?? '',
    );
    fieldControllers['twelvePMpoNo'] = TextEditingController(
      text: audit.twelvePMpoNo ?? '',
    );
    fieldControllers['twelvePMasPrPo'] = TextEditingController(
      text: audit.twelvePMasPrPo ?? '',
    );
    fieldControllers['twelvePMdimensionFront'] = TextEditingController(
      text: audit.twelvePMdimensionFront ?? '',
    );
    fieldControllers['twelvePMdimensionBack'] = TextEditingController(
      text: audit.twelvePMdimensionBack ?? '',
    );
    fieldControllers['twelvePMvisualCheck'] = TextEditingController(
      text: audit.twelvePMvisualCheck ?? '',
    );
    fieldControllers['twelvePMdefect'] = TextEditingController(
      text: audit.twelvePMdefect ?? '',
    );
    fieldControllers['twelvePMremark'] = TextEditingController(
      text: audit.twelvePMremark ?? '',
    );
    fieldControllers['twelvePMcheckedBy'] = TextEditingController(
      text: audit.twelvePMcheckedBy ?? '',
    );

    // 2 PM time entry fields
    fieldControllers['twoPMevaMake'] = TextEditingController(
      text: audit.twoPMevaMake ?? '',
    );
    fieldControllers['twoPMevaFront'] = TextEditingController(
      text: audit.twoPMevaFront ?? '',
    );
    fieldControllers['twoPMevaBack'] = TextEditingController(
      text: audit.twoPMevaBack ?? '',
    );
    fieldControllers['twoPMpoNo'] = TextEditingController(
      text: audit.twoPMpoNo ?? '',
    );
    fieldControllers['twoPMasPrPo'] = TextEditingController(
      text: audit.twoPMasPrPo ?? '',
    );
    fieldControllers['twoPMdimensionFront'] = TextEditingController(
      text: audit.twoPMdimensionFront ?? '',
    );
    fieldControllers['twoPMdimensionBack'] = TextEditingController(
      text: audit.twoPMdimensionBack ?? '',
    );
    fieldControllers['twoPMvisualCheck'] = TextEditingController(
      text: audit.twoPMvisualCheck ?? '',
    );
    fieldControllers['twoPMdefect'] = TextEditingController(
      text: audit.twoPMdefect ?? '',
    );
    fieldControllers['twoPMremark'] = TextEditingController(
      text: audit.twoPMremark ?? '',
    );
    fieldControllers['twoPMcheckedBy'] = TextEditingController(
      text: audit.twoPMcheckedBy ?? '',
    );

    // 4 PM time entry fields
    fieldControllers['fourPMevaMake'] = TextEditingController(
      text: audit.fourPMevaMake ?? '',
    );
    fieldControllers['fourPMevaFront'] = TextEditingController(
      text: audit.fourPMevaFront ?? '',
    );
    fieldControllers['fourPMevaBack'] = TextEditingController(
      text: audit.fourPMevaBack ?? '',
    );
    fieldControllers['fourPMpoNo'] = TextEditingController(
      text: audit.fourPMpoNo ?? '',
    );
    fieldControllers['fourPMasPrPo'] = TextEditingController(
      text: audit.fourPMasPrPo ?? '',
    );
    fieldControllers['fourPMdimensionFront'] = TextEditingController(
      text: audit.fourPMdimensionFront ?? '',
    );
    fieldControllers['fourPMdimensionBack'] = TextEditingController(
      text: audit.fourPMdimensionBack ?? '',
    );
    fieldControllers['fourPMvisualCheck'] = TextEditingController(
      text: audit.fourPMvisualCheck ?? '',
    );
    fieldControllers['fourPMdefect'] = TextEditingController(
      text: audit.fourPMdefect ?? '',
    );
    fieldControllers['fourPMremark'] = TextEditingController(
      text: audit.fourPMremark ?? '',
    );
    fieldControllers['fourPMcheckedBy'] = TextEditingController(
      text: audit.fourPMcheckedBy ?? '',
    );

    // 6 PM time entry fields
    fieldControllers['sixPMevaMake'] = TextEditingController(
      text: audit.sixPMevaMake ?? '',
    );
    fieldControllers['sixPMevaFront'] = TextEditingController(
      text: audit.sixPMevaFront ?? '',
    );
    fieldControllers['sixPMevaBack'] = TextEditingController(
      text: audit.sixPMevaBack ?? '',
    );
    fieldControllers['sixPMpoNo'] = TextEditingController(
      text: audit.sixPMpoNo ?? '',
    );
    fieldControllers['sixPMasPrPo'] = TextEditingController(
      text: audit.sixPMasPrPo ?? '',
    );
    fieldControllers['sixPMdimensionFront'] = TextEditingController(
      text: audit.sixPMdimensionFront ?? '',
    );
    fieldControllers['sixPMdimensionBack'] = TextEditingController(
      text: audit.sixPMdimensionBack ?? '',
    );
    fieldControllers['sixPMvisualCheck'] = TextEditingController(
      text: audit.sixPMvisualCheck ?? '',
    );
    fieldControllers['sixPMdefect'] = TextEditingController(
      text: audit.sixPMdefect ?? '',
    );
    fieldControllers['sixPMremark'] = TextEditingController(
      text: audit.sixPMremark ?? '',
    );
    fieldControllers['sixPMcheckedBy'] = TextEditingController(
      text: audit.sixPMcheckedBy ?? '',
    );

    // 8 PM time entry fields
    fieldControllers['eightPMevaMake'] = TextEditingController(
      text: audit.eightPMevaMake ?? '',
    );
    fieldControllers['eightPMevaFront'] = TextEditingController(
      text: audit.eightPMevaFront ?? '',
    );
    fieldControllers['eightPMevaBack'] = TextEditingController(
      text: audit.eightPMevaBack ?? '',
    );
    fieldControllers['eightPMpoNo'] = TextEditingController(
      text: audit.eightPMpoNo ?? '',
    );
    fieldControllers['eightPMasPrPo'] = TextEditingController(
      text: audit.eightPMasPrPo ?? '',
    );
    fieldControllers['eightPMdimensionFront'] = TextEditingController(
      text: audit.eightPMdimensionFront ?? '',
    );
    fieldControllers['eightPMdimensionBack'] = TextEditingController(
      text: audit.eightPMdimensionBack ?? '',
    );
    fieldControllers['eightPMvisualCheck'] = TextEditingController(
      text: audit.eightPMvisualCheck ?? '',
    );
    fieldControllers['eightPMdefect'] = TextEditingController(
      text: audit.eightPMdefect ?? '',
    );
    fieldControllers['eightPMremark'] = TextEditingController(
      text: audit.eightPMremark ?? '',
    );
    fieldControllers['eightPMcheckedBy'] = TextEditingController(
      text: audit.eightPMcheckedBy ?? '',
    );

    // 10 PM time entry fields
    fieldControllers['tenPMevaMake'] = TextEditingController(
      text: audit.tenPMevaMake ?? '',
    );
    fieldControllers['tenPMevaFront'] = TextEditingController(
      text: audit.tenPMevaFront ?? '',
    );
    fieldControllers['tenPMevaBack'] = TextEditingController(
      text: audit.tenPMevaBack ?? '',
    );
    fieldControllers['tenPMpoNo'] = TextEditingController(
      text: audit.tenPMpoNo ?? '',
    );
    fieldControllers['tenPMasPrPo'] = TextEditingController(
      text: audit.tenPMasPrPo ?? '',
    );
    fieldControllers['tenPMdimensionFront'] = TextEditingController(
      text: audit.tenPMdimensionFront ?? '',
    );
    fieldControllers['tenPMdimensionBack'] = TextEditingController(
      text: audit.tenPMdimensionBack ?? '',
    );
    fieldControllers['tenPMvisualCheck'] = TextEditingController(
      text: audit.tenPMvisualCheck ?? '',
    );
    fieldControllers['tenPMdefect'] = TextEditingController(
      text: audit.tenPMdefect ?? '',
    );
    fieldControllers['tenPMremark'] = TextEditingController(
      text: audit.tenPMremark ?? '',
    );
    fieldControllers['tenPMcheckedBy'] = TextEditingController(
      text: audit.tenPMcheckedBy ?? '',
    );

    // 12 AM time entry fields
    fieldControllers['twelveAMevaMake'] = TextEditingController(
      text: audit.twelveAMevaMake ?? '',
    );
    fieldControllers['twelveAMevaFront'] = TextEditingController(
      text: audit.twelveAMevaFront ?? '',
    );
    fieldControllers['twelveAMevaBack'] = TextEditingController(
      text: audit.twelveAMevaBack ?? '',
    );
    fieldControllers['twelveAMpoNo'] = TextEditingController(
      text: audit.twelveAMpoNo ?? '',
    );
    fieldControllers['twelveAMasPrPo'] = TextEditingController(
      text: audit.twelveAMasPrPo ?? '',
    );
    fieldControllers['twelveAMdimensionFront'] = TextEditingController(
      text: audit.twelveAMdimensionFront ?? '',
    );
    fieldControllers['twelveAMdimensionBack'] = TextEditingController(
      text: audit.twelveAMdimensionBack ?? '',
    );
    fieldControllers['twelveAMvisualCheck'] = TextEditingController(
      text: audit.twelveAMvisualCheck ?? '',
    );
    fieldControllers['twelveAMdefect'] = TextEditingController(
      text: audit.twelveAMdefect ?? '',
    );
    fieldControllers['twelveAMremark'] = TextEditingController(
      text: audit.twelveAMremark ?? '',
    );
    fieldControllers['twelveAMcheckedBy'] = TextEditingController(
      text: audit.twelveAMcheckedBy ?? '',
    );

    // 2 AM time entry fields
    fieldControllers['twoAMevaMake'] = TextEditingController(
      text: audit.twoAMevaMake ?? '',
    );
    fieldControllers['twoAMevaFront'] = TextEditingController(
      text: audit.twoAMevaFront ?? '',
    );
    fieldControllers['twoAMevaBack'] = TextEditingController(
      text: audit.twoAMevaBack ?? '',
    );
    fieldControllers['twoAMpoNo'] = TextEditingController(
      text: audit.twoAMpoNo ?? '',
    );
    fieldControllers['twoAMasPrPo'] = TextEditingController(
      text: audit.twoAMasPrPo ?? '',
    );
    fieldControllers['twoAMdimensionFront'] = TextEditingController(
      text: audit.twoAMdimensionFront ?? '',
    );
    fieldControllers['twoAMdimensionBack'] = TextEditingController(
      text: audit.twoAMdimensionBack ?? '',
    );
    fieldControllers['twoAMvisualCheck'] = TextEditingController(
      text: audit.twoAMvisualCheck ?? '',
    );
    fieldControllers['twoAMdefect'] = TextEditingController(
      text: audit.twoAMdefect ?? '',
    );
    fieldControllers['twoAMremark'] = TextEditingController(
      text: audit.twoAMremark ?? '',
    );
    fieldControllers['twoAMcheckedBy'] = TextEditingController(
      text: audit.twoAMcheckedBy ?? '',
    );

    // 4 AM time entry fields
    fieldControllers['fourAMevaMake'] = TextEditingController(
      text: audit.fourAMevaMake ?? '',
    );
    fieldControllers['fourAMevaFront'] = TextEditingController(
      text: audit.fourAMevaFront ?? '',
    );
    fieldControllers['fourAMevaBack'] = TextEditingController(
      text: audit.fourAMevaBack ?? '',
    );
    fieldControllers['fourAMpoNo'] = TextEditingController(
      text: audit.fourAMpoNo ?? '',
    );
    fieldControllers['fourAMasPrPo'] = TextEditingController(
      text: audit.fourAMasPrPo ?? '',
    );
    fieldControllers['fourAMdimensionFront'] = TextEditingController(
      text: audit.fourAMdimensionFront ?? '',
    );
    fieldControllers['fourAMdimensionBack'] = TextEditingController(
      text: audit.fourAMdimensionBack ?? '',
    );
    fieldControllers['fourAMvisualCheck'] = TextEditingController(
      text: audit.fourAMvisualCheck ?? '',
    );
    fieldControllers['fourAMdefect'] = TextEditingController(
      text: audit.fourAMdefect ?? '',
    );
    fieldControllers['fourAMremark'] = TextEditingController(
      text: audit.fourAMremark ?? '',
    );
    fieldControllers['fourAMcheckedBy'] = TextEditingController(
      text: audit.fourAMcheckedBy ?? '',
    );

    // 6 AM time entry fields
    fieldControllers['sixAMevaMake'] = TextEditingController(
      text: audit.sixAMevaMake ?? '',
    );
    fieldControllers['sixAMevaFront'] = TextEditingController(
      text: audit.sixAMevaFront ?? '',
    );
    fieldControllers['sixAMevaBack'] = TextEditingController(
      text: audit.sixAMevaBack ?? '',
    );
    fieldControllers['sixAMpoNo'] = TextEditingController(
      text: audit.sixAMpoNo ?? '',
    );
    fieldControllers['sixAMasPrPo'] = TextEditingController(
      text: audit.sixAMasPrPo ?? '',
    );
    fieldControllers['sixAMdimensionFront'] = TextEditingController(
      text: audit.sixAMdimensionFront ?? '',
    );
    fieldControllers['sixAMdimensionBack'] = TextEditingController(
      text: audit.sixAMdimensionBack ?? '',
    );
    fieldControllers['sixAMvisualCheck'] = TextEditingController(
      text: audit.sixAMvisualCheck ?? '',
    );
    fieldControllers['sixAMdefect'] = TextEditingController(
      text: audit.sixAMdefect ?? '',
    );
    fieldControllers['sixAMremark'] = TextEditingController(
      text: audit.sixAMremark ?? '',
    );
    fieldControllers['sixAMcheckedBy'] = TextEditingController(
      text: audit.sixAMcheckedBy ?? '',
    );

    // Initialize editing state for all fields
    fieldControllers.keys.forEach((key) {
      editingFields[key] = false;
      originalValues[key] = fieldControllers[key]!.text;
    });
  }

  Future<void> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/images/pahalLogo.jpg');
      setState(() {
        logoBytes = data.buffer.asUint8List();
      });
    } catch (e) {
      print('Error loading logo: $e');
    }
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
    bool userIsAdmin = authService.currentUser?.role == 'Admin';
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
      final newValue = fieldControllers[fieldName]?.text ?? '';
      _updateAuditField(fieldName, newValue);

      final auditService = Provider.of<AuditService>(context, listen: false);
      final auditForm = AuditForm(
        id: audit.id,
        serialNumber: audit.serialNumber,
        auditDate: audit.auditDate,
        auditorName: audit.auditorName,
        verifiedBy: audit.verifiedBy,
        shift: audit.shift,
        po: audit.po,
        moduleType: audit.moduleType,
        createdAt: audit.createdAt,
      );

      final success = await auditService.updateAudit(auditForm);

      if (success) {
        setState(() {
          editingFields[fieldName] = false;
          originalValues[fieldName] = newValue;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Field updated successfully!'),
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

  void _updateAuditField(String fieldName, String value) {
    // [Keep all the update logic from your original code]
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
      case 'date':
        audit.date = value;
        break;
      case 'line':
        audit.line = value;
        break;
      case 'remarks':
        audit.remarks = value;
        break;
      case 'note':
        audit.note = value;
        break;
      case 'qcInnspectorName':
        audit.qcInnspectorName = value;
        break;
      case 'preparedBy':
        audit.preparedBy = value;
        break;
      case 'verifyBy':
        audit.verifyBy = value;
        break;
      case 'approvedBy':
        audit.approvedBy = value;
        break;

      // 8 AM fields
      case 'eightAMevaMake':
        audit.eightAMevaMake = value;
        break;
      case 'eightAMevaFront':
        audit.eightAMevaFront = value;
        break;
      case 'eightAMevaBack':
        audit.eightAMevaBack = value;
        break;
      case 'eightAMpoNo':
        audit.eightAMpoNo = value;
        break;
      case 'eightAMasPrPo':
        audit.eightAMasPrPo = value;
        break;
      case 'eightAMdimensionFront':
        audit.eightAMdimensionFront = value;
        break;
      case 'eightAMdimensionBack':
        audit.eightAMdimensionBack = value;
        break;
      case 'eightAMvisualCheck':
        audit.eightAMvisualCheck = value;
        break;
      case 'eightAMdefect':
        audit.eightAMdefect = value;
        break;
      case 'eightAMremark':
        audit.eightAMremark = value;
        break;
      case 'eightAMcheckedBy':
        audit.eightAMcheckedBy = value;
        break;

      // 10 AM fields
      case 'tenAMevaMake':
        audit.tenAMevaMake = value;
        break;
      case 'tenAMevaFront':
        audit.tenAMevaFront = value;
        break;
      case 'tenAMevaBack':
        audit.tenAMevaBack = value;
        break;
      case 'tenAMpoNo':
        audit.tenAMpoNo = value;
        break;
      case 'tenAMasPrPo':
        audit.tenAMasPrPo = value;
        break;
      case 'tenAMdimensionFront':
        audit.tenAMdimensionFront = value;
        break;
      case 'tenAMdimensionBack':
        audit.tenAMdimensionBack = value;
        break;
      case 'tenAMvisualCheck':
        audit.tenAMvisualCheck = value;
        break;
      case 'tenAMdefect':
        audit.tenAMdefect = value;
        break;
      case 'tenAMremark':
        audit.tenAMremark = value;
        break;
      case 'tenAMcheckedBy':
        audit.tenAMcheckedBy = value;
        break;

      // 12 PM fields
      case 'twelvePMevaMake':
        audit.twelvePMevaMake = value;
        break;
      case 'twelvePMevaFront':
        audit.twelvePMevaFront = value;
        break;
      case 'twelvePMevaBack':
        audit.twelvePMevaBack = value;
        break;
      case 'twelvePMpoNo':
        audit.twelvePMpoNo = value;
        break;
      case 'twelvePMasPrPo':
        audit.twelvePMasPrPo = value;
        break;
      case 'twelvePMdimensionFront':
        audit.twelvePMdimensionFront = value;
        break;
      case 'twelvePMdimensionBack':
        audit.twelvePMdimensionBack = value;
        break;
      case 'twelvePMvisualCheck':
        audit.twelvePMvisualCheck = value;
        break;
      case 'twelvePMdefect':
        audit.twelvePMdefect = value;
        break;
      case 'twelvePMremark':
        audit.twelvePMremark = value;
        break;
      case 'twelvePMcheckedBy':
        audit.twelvePMcheckedBy = value;
        break;

      // 2 PM fields
      case 'twoPMevaMake':
        audit.twoPMevaMake = value;
        break;
      case 'twoPMevaFront':
        audit.twoPMevaFront = value;
        break;
      case 'twoPMevaBack':
        audit.twoPMevaBack = value;
        break;
      case 'twoPMpoNo':
        audit.twoPMpoNo = value;
        break;
      case 'twoPMasPrPo':
        audit.twoPMasPrPo = value;
        break;
      case 'twoPMdimensionFront':
        audit.twoPMdimensionFront = value;
        break;
      case 'twoPMdimensionBack':
        audit.twoPMdimensionBack = value;
        break;
      case 'twoPMvisualCheck':
        audit.twoPMvisualCheck = value;
        break;
      case 'twoPMdefect':
        audit.twoPMdefect = value;
        break;
      case 'twoPMremark':
        audit.twoPMremark = value;
        break;
      case 'twoPMcheckedBy':
        audit.twoPMcheckedBy = value;
        break;

      // 4 PM fields
      case 'fourPMevaMake':
        audit.fourPMevaMake = value;
        break;
      case 'fourPMevaFront':
        audit.fourPMevaFront = value;
        break;
      case 'fourPMevaBack':
        audit.fourPMevaBack = value;
        break;
      case 'fourPMpoNo':
        audit.fourPMpoNo = value;
        break;
      case 'fourPMasPrPo':
        audit.fourPMasPrPo = value;
        break;
      case 'fourPMdimensionFront':
        audit.fourPMdimensionFront = value;
        break;
      case 'fourPMdimensionBack':
        audit.fourPMdimensionBack = value;
        break;
      case 'fourPMvisualCheck':
        audit.fourPMvisualCheck = value;
        break;
      case 'fourPMdefect':
        audit.fourPMdefect = value;
        break;
      case 'fourPMremark':
        audit.fourPMremark = value;
        break;
      case 'fourPMcheckedBy':
        audit.fourPMcheckedBy = value;
        break;

      // 6 PM fields
      case 'sixPMevaMake':
        audit.sixPMevaMake = value;
        break;
      case 'sixPMevaFront':
        audit.sixPMevaFront = value;
        break;
      case 'sixPMevaBack':
        audit.sixPMevaBack = value;
        break;
      case 'sixPMpoNo':
        audit.sixPMpoNo = value;
        break;
      case 'sixPMasPrPo':
        audit.sixPMasPrPo = value;
        break;
      case 'sixPMdimensionFront':
        audit.sixPMdimensionFront = value;
        break;
      case 'sixPMdimensionBack':
        audit.sixPMdimensionBack = value;
        break;
      case 'sixPMvisualCheck':
        audit.sixPMvisualCheck = value;
        break;
      case 'sixPMdefect':
        audit.sixPMdefect = value;
        break;
      case 'sixPMremark':
        audit.sixPMremark = value;
        break;
      case 'sixPMcheckedBy':
        audit.sixPMcheckedBy = value;
        break;

      // 8 PM fields
      case 'eightPMevaMake':
        audit.eightPMevaMake = value;
        break;
      case 'eightPMevaFront':
        audit.eightPMevaFront = value;
        break;
      case 'eightPMevaBack':
        audit.eightPMevaBack = value;
        break;
      case 'eightPMpoNo':
        audit.eightPMpoNo = value;
        break;
      case 'eightPMasPrPo':
        audit.eightPMasPrPo = value;
        break;
      case 'eightPMdimensionFront':
        audit.eightPMdimensionFront = value;
        break;
      case 'eightPMdimensionBack':
        audit.eightPMdimensionBack = value;
        break;
      case 'eightPMvisualCheck':
        audit.eightPMvisualCheck = value;
        break;
      case 'eightPMdefect':
        audit.eightPMdefect = value;
        break;
      case 'eightPMremark':
        audit.eightPMremark = value;
        break;
      case 'eightPMcheckedBy':
        audit.eightPMcheckedBy = value;
        break;

      // 10 PM fields
      case 'tenPMevaMake':
        audit.tenPMevaMake = value;
        break;
      case 'tenPMevaFront':
        audit.tenPMevaFront = value;
        break;
      case 'tenPMevaBack':
        audit.tenPMevaBack = value;
        break;
      case 'tenPMpoNo':
        audit.tenPMpoNo = value;
        break;
      case 'tenPMasPrPo':
        audit.tenPMasPrPo = value;
        break;
      case 'tenPMdimensionFront':
        audit.tenPMdimensionFront = value;
        break;
      case 'tenPMdimensionBack':
        audit.tenPMdimensionBack = value;
        break;
      case 'tenPMvisualCheck':
        audit.tenPMvisualCheck = value;
        break;
      case 'tenPMdefect':
        audit.tenPMdefect = value;
        break;
      case 'tenPMremark':
        audit.tenPMremark = value;
        break;
      case 'tenPMcheckedBy':
        audit.tenPMcheckedBy = value;
        break;

      // 12 AM fields
      case 'twelveAMevaMake':
        audit.twelveAMevaMake = value;
        break;
      case 'twelveAMevaFront':
        audit.twelveAMevaFront = value;
        break;
      case 'twelveAMevaBack':
        audit.twelveAMevaBack = value;
        break;
      case 'twelveAMpoNo':
        audit.twelveAMpoNo = value;
        break;
      case 'twelveAMasPrPo':
        audit.twelveAMasPrPo = value;
        break;
      case 'twelveAMdimensionFront':
        audit.twelveAMdimensionFront = value;
        break;
      case 'twelveAMdimensionBack':
        audit.twelveAMdimensionBack = value;
        break;
      case 'twelveAMvisualCheck':
        audit.twelveAMvisualCheck = value;
        break;
      case 'twelveAMdefect':
        audit.twelveAMdefect = value;
        break;
      case 'twelveAMremark':
        audit.twelveAMremark = value;
        break;
      case 'twelveAMcheckedBy':
        audit.twelveAMcheckedBy = value;
        break;

      // 2 AM fields
      case 'twoAMevaMake':
        audit.twoAMevaMake = value;
        break;
      case 'twoAMevaFront':
        audit.twoAMevaFront = value;
        break;
      case 'twoAMevaBack':
        audit.twoAMevaBack = value;
        break;
      case 'twoAMpoNo':
        audit.twoAMpoNo = value;
        break;
      case 'twoAMasPrPo':
        audit.twoAMasPrPo = value;
        break;
      case 'twoAMdimensionFront':
        audit.twoAMdimensionFront = value;
        break;
      case 'twoAMdimensionBack':
        audit.twoAMdimensionBack = value;
        break;
      case 'twoAMvisualCheck':
        audit.twoAMvisualCheck = value;
        break;
      case 'twoAMdefect':
        audit.twoAMdefect = value;
        break;
      case 'twoAMremark':
        audit.twoAMremark = value;
        break;
      case 'twoAMcheckedBy':
        audit.twoAMcheckedBy = value;
        break;

      // 4 AM fields
      case 'fourAMevaMake':
        audit.fourAMevaMake = value;
        break;
      case 'fourAMevaFront':
        audit.fourAMevaFront = value;
        break;
      case 'fourAMevaBack':
        audit.fourAMevaBack = value;
        break;
      case 'fourAMpoNo':
        audit.fourAMpoNo = value;
        break;
      case 'fourAMasPrPo':
        audit.fourAMasPrPo = value;
        break;
      case 'fourAMdimensionFront':
        audit.fourAMdimensionFront = value;
        break;
      case 'fourAMdimensionBack':
        audit.fourAMdimensionBack = value;
        break;
      case 'fourAMvisualCheck':
        audit.fourAMvisualCheck = value;
        break;
      case 'fourAMdefect':
        audit.fourAMdefect = value;
        break;
      case 'fourAMremark':
        audit.fourAMremark = value;
        break;
      case 'fourAMcheckedBy':
        audit.fourAMcheckedBy = value;
        break;

      // 6 AM fields
      case 'sixAMevaMake':
        audit.sixAMevaMake = value;
        break;
      case 'sixAMevaFront':
        audit.sixAMevaFront = value;
        break;
      case 'sixAMevaBack':
        audit.sixAMevaBack = value;
        break;
      case 'sixAMpoNo':
        audit.sixAMpoNo = value;
        break;
      case 'sixAMasPrPo':
        audit.sixAMasPrPo = value;
        break;
      case 'sixAMdimensionFront':
        audit.sixAMdimensionFront = value;
        break;
      case 'sixAMdimensionBack':
        audit.sixAMdimensionBack = value;
        break;
      case 'sixAMvisualCheck':
        audit.sixAMvisualCheck = value;
        break;
      case 'sixAMdefect':
        audit.sixAMdefect = value;
        break;
      case 'sixAMremark':
        audit.sixAMremark = value;
        break;
      case 'sixAMcheckedBy':
        audit.sixAMcheckedBy = value;
        break;
    }
  }

  Future<void> _saveAuditChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      // Auto-fill verifiedBy with admin's name
      if (authService.currentUser != null) {
        audit.verifiedBy = authService.currentUser!.fullName;
        fieldControllers['verifiedBy']?.text =
            authService.currentUser!.fullName;
      }

      // Update all fields from controllers
      fieldControllers.forEach((fieldName, controller) {
        _updateAuditField(fieldName, controller.text);
      });

      // Save to database
      await databaseService.updateAudit(audit);

      // Clear all editing states
      setState(() {
        editingFields.updateAll((key, value) => false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Audit saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Error saving audit: $e'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _regeneratePdf() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Navigate to PDF screen which will handle PDF generation and display
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SheetCuttingPdfScreen(audit: audit),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening PDF screen: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Modern UI Components
  Widget _buildModernField(
    String fieldName,
    String label, {
    bool isMultiline = false,
  }) {
    final isEditing = editingFields[fieldName] ?? false;
    final controller = fieldControllers[fieldName];
    final value = controller?.text ?? '';

    if (controller == null) return SizedBox.shrink();

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
              Spacer(),
              if (isAdmin && !isEditing)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _enableFieldEdit(fieldName),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.blue[300]!,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: isMultiline ? 4 : 1,
                )
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    value.isEmpty ? 'Not specified' : value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value.isEmpty
                          ? Colors.grey[400]
                          : Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
          if (isEditing) SizedBox(height: 12),
          if (isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _cancelFieldEdit(fieldName),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _saveFieldEdit(fieldName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 2,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeEntryCard(String title, String timePrefix) {
    final hasData = _hasTimeSlotData(timePrefix);

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key(timePrefix),
          initiallyExpanded: expandedSlots[timePrefix] ?? false,
          onExpansionChanged: (expanded) {
            setState(() {
              expandedSlots[timePrefix] = expanded;
            });
          },
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasData
                    ? [Colors.blue[400]!, Colors.blue[600]!]
                    : [Colors.grey[300]!, Colors.grey[400]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (hasData)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green[700],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Filled',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Row 1: EVA fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}evaMake',
                          'EVA Make',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}evaFront',
                          'EVA Front',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}evaBack',
                          'EVA Back',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Row 2: PO fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineField('${timePrefix}poNo', 'PO No'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Row 3: Dimension fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}dimensionFront',
                          'Dim Front',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}dimensionBack',
                          'Dim Back',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Row 4: Check fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}visualCheck',
                          'Visual Check',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}defect',
                          'Defect',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Row 5: Remark and Checked By
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}remark',
                          'Remark',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInlineField(
                          '${timePrefix}checkedBy',
                          'Checked By',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasTimeSlotData(String timePrefix) {
    final fields = [
      '${timePrefix}evaMake',
      '${timePrefix}evaFront',
      '${timePrefix}evaBack',
      '${timePrefix}poNo',
      '${timePrefix}asPrPo',
      '${timePrefix}dimensionFront',
      '${timePrefix}dimensionBack',
      '${timePrefix}visualCheck',
      '${timePrefix}defect',
      '${timePrefix}remark',
      '${timePrefix}checkedBy',
    ];

    for (var field in fields) {
      final controller = fieldControllers[field];
      if (controller != null && controller.text.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Widget _buildInlineField(String fieldName, String label) {
    final controller = fieldControllers[fieldName];
    final value = controller?.text ?? '';
    final isFieldEditing = editingFields[fieldName] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onDoubleTap: isAdmin ? () => _enableFieldEdit(fieldName) : null,
          child: isFieldEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: 12),
                  onSubmitted: (_) => _saveFieldEdit(fieldName),
                )
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: value.isEmpty ? Colors.white : Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value.isEmpty
                          ? Colors.grey[300]!
                          : Colors.blue[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value.isEmpty ? '-' : value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: value.isEmpty
                                ? FontWeight.normal
                                : FontWeight.w500,
                            color: value.isEmpty
                                ? Colors.grey[400]
                                : Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin && !value.isEmpty)
                        Icon(Icons.edit, size: 12, color: Colors.grey[400]),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCompactField(
    String fieldName,
    String label, {
    double width = 0.3,
  }) {
    final controller = fieldControllers[fieldName];
    final value = controller?.text ?? '';

    return Container(
      width: MediaQuery.of(context).size.width * width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: value.isEmpty
                  ? Colors.grey[50]
                  : Colors.blue[50]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value.isEmpty ? Colors.grey[300]! : Colors.blue[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w500,
                color: value.isEmpty ? Colors.grey[400] : Colors.grey[800],
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shadowColor: Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForTitle(title),
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Audit Information':
        return Icons.info_outline;
      case 'Notes and Remarks':
        return Icons.note_outlined;
      case 'Signatures':
        return Icons.assignment_ind_outlined;
      default:
        return Icons.fact_check_outlined;
    }
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Sheet Cutting Audit Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[700]!, Colors.blue[900]!],
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              onPressed: () => navigateToPdfScreen(context, audit),
              tooltip: 'Generate PDF',
            ),
          ),
        ],
      ),
      body: _isSaving
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[600]!,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Generating PDF...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              color: Colors.grey[100],
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Card(
                      elevation: 6,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue[600]!, Colors.blue[800]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.assignment_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sheet Cutting Audit',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Serial: ${audit.serialNumber}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Shift',
                            audit.shift,
                            Icons.schedule_rounded,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Module',
                            audit.moduleType,
                            Icons.widgets_rounded,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Line',
                            audit.line ?? 'N/A',
                            Icons.linear_scale_rounded,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Audit Information - Compact
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Audit Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInlineField(
                                    'auditDate',
                                    'Audit Date',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField(
                                    'auditorName',
                                    'Auditor',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField(
                                    'verifiedBy',
                                    'Verified By',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInlineField('shift', 'Shift'),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField('po', 'PO Number'),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField(
                                    'moduleType',
                                    'Module Type',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInlineField('date', 'Date'),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField('line', 'Line'),
                                ),
                                SizedBox(width: 8),
                                Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Time Entries Section Header with Expand/Collapse All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Inspection Timeline (12 Slots)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  expandedSlots.updateAll((key, value) => true);
                                });
                              },
                              icon: Icon(Icons.unfold_more_rounded, size: 18),
                              label: Text('Expand All'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  expandedSlots.updateAll(
                                    (key, value) => false,
                                  );
                                });
                              },
                              icon: Icon(Icons.unfold_less_rounded, size: 18),
                              label: Text('Collapse All'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildTimeEntryCard('8:00 AM Inspection', 'eightAM'),
                    _buildTimeEntryCard('10:00 AM Inspection', 'tenAM'),
                    _buildTimeEntryCard('12:00 PM Inspection', 'twelvePM'),
                    _buildTimeEntryCard('2:00 PM Inspection', 'twoPM'),
                    _buildTimeEntryCard('4:00 PM Inspection', 'fourPM'),
                    _buildTimeEntryCard('6:00 PM Inspection', 'sixPM'),
                    _buildTimeEntryCard('8:00 PM Inspection', 'eightPM'),
                    _buildTimeEntryCard('10:00 PM Inspection', 'tenPM'),
                    _buildTimeEntryCard('12:00 AM Inspection', 'twelveAM'),
                    _buildTimeEntryCard('2:00 AM Inspection', 'twoAM'),
                    _buildTimeEntryCard('4:00 AM Inspection', 'fourAM'),
                    _buildTimeEntryCard('6:00 AM Inspection', 'sixAM'),

                    SizedBox(height: 24),

                    // Divider
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Additional Information',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Notes and Remarks - Compact
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note_outlined,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Notes & Remarks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInlineField('note', 'Note'),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField(
                                    'remarks',
                                    'Remarks',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Signatures - Compact
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.assignment_ind_outlined,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Signatures',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInlineField(
                                    'qcInnspectorName',
                                    'QC Inspector',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField(
                                    'preparedBy',
                                    'Prepared By',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInlineField(
                                    'verifyBy',
                                    'Verified By',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildInlineField(
                                    'approvedBy',
                                    'Approved By',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Admin Notice
                    if (isAdmin)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[50]!,
                              Colors.blue[100]!.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue[300]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Access',
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tap on edit icons to modify fields.',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      floatingActionButton: isAdmin
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: _saveAuditChanges,
                  backgroundColor: Colors.green[600],
                  heroTag: 'save',
                  elevation: 6,
                  icon: Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                FloatingActionButton.extended(
                  onPressed: _regeneratePdf,
                  backgroundColor: Colors.blue[700],
                  heroTag: 'pdf',
                  elevation: 6,
                  icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                  label: Text(
                    'Generate PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            )
          : FloatingActionButton.extended(
              onPressed: _regeneratePdf,
              backgroundColor: Colors.blue[700],
              elevation: 6,
              icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              label: Text(
                'Generate PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    fieldControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void navigateToPdfScreen(BuildContext context, SheetCuttingAuditForm audit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SheetCuttingPdfScreen(audit: audit),
      ),
    );
  }
}
