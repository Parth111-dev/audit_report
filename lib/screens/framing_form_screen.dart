import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/framing_audit_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../widgets/dynamic_audit_form.dart';
import 'pdf_screen.dart';

class FramingFormScreen extends StatefulWidget {
  @override
  _FramingFormScreenState createState() => _FramingFormScreenState();
}

class _FramingFormScreenState extends State<FramingFormScreen> {
  late FramingAuditForm _auditForm;
  bool _isLoading = false;
  final Map<String, TextEditingController> _controllers = {};
  Uint8List? logoBytes;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadLogo();
  }

  void _initializeForm() {
    _auditForm = FramingAuditForm(
      serialNumber: 'FR-${DateTime.now().millisecondsSinceEpoch}',
      auditDate: DateTime.now().toIso8601String(),
      shift: '',
      po: '',
      moduleType: '',
      createdAt: DateTime.now().toIso8601String(),
      auditorName: '',
      verifiedBy: '',
    );

    // Initialize controllers for all fields
    _controllers['serialNumber'] = TextEditingController(
      text: _auditForm.serialNumber,
    );
    _controllers['auditorName'] = TextEditingController();
    _controllers['verifiedBy'] = TextEditingController();
    _controllers['shift'] = TextEditingController();
    _controllers['po'] = TextEditingController();
    _controllers['moduleType'] = TextEditingController();

    // Initialize controllers for framing specific fields
    _controllers['frameType'] = TextEditingController();
    _controllers['frameMaterial'] = TextEditingController();
    _controllers['frameDimensions'] = TextEditingController();
    _controllers['cornerJointQuality'] = TextEditingController();
    _controllers['sealantApplication'] = TextEditingController();
    _controllers['frameFlatness'] = TextEditingController();
    _controllers['mountingHoleAlignment'] = TextEditingController();
    _controllers['groundingHoleQuality'] = TextEditingController();
    _controllers['surfaceFinish'] = TextEditingController();
    _controllers['visualInspection'] = TextEditingController();
    _controllers['dimensionalAccuracy'] = TextEditingController();
    _controllers['operatorName'] = TextEditingController();
    _controllers['machineId'] = TextEditingController();
    _controllers['batchNumber'] = TextEditingController();
    _controllers['torqueReadings'] = TextEditingController();
    _controllers['sealantBatchNumber'] = TextEditingController();
    _controllers['remarks'] = TextEditingController();
    _controllers['defectCount'] = TextEditingController();
    _controllers['passFailStatus'] = TextEditingController();

    // Set auditor name from current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser != null) {
        _controllers['auditorName']!.text = authService.currentUser!.fullName;
        _auditForm.auditorName = authService.currentUser!.fullName;
      }
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

  void _updateField(String fieldName, String value) {
    // Use reflection to set the field value
    switch (fieldName) {
      case 'serialNumber':
        _auditForm.serialNumber = value;
        break;
      case 'auditDate':
        _auditForm.auditDate = value;
        break;
      case 'auditorName':
        _auditForm.auditorName = value;
        break;
      case 'verifiedBy':
        _auditForm.verifiedBy = value;
        break;
      case 'shift':
        _auditForm.shift = value;
        break;
      case 'po':
        _auditForm.po = value;
        break;
      case 'moduleType':
        _auditForm.moduleType = value;
        break;
      case 'frameType':
        _auditForm.frameType = value;
        break;
      case 'frameMaterial':
        _auditForm.frameMaterial = value;
        break;
      case 'frameDimensions':
        _auditForm.frameDimensions = value;
        break;
      case 'cornerJointQuality':
        _auditForm.cornerJointQuality = value;
        break;
      case 'sealantApplication':
        _auditForm.sealantApplication = value;
        break;
      case 'frameFlatness':
        _auditForm.frameFlatness = value;
        break;
      case 'mountingHoleAlignment':
        _auditForm.mountingHoleAlignment = value;
        break;
      case 'groundingHoleQuality':
        _auditForm.groundingHoleQuality = value;
        break;
      case 'surfaceFinish':
        _auditForm.surfaceFinish = value;
        break;
      case 'visualInspection':
        _auditForm.visualInspection = value;
        break;
      case 'dimensionalAccuracy':
        _auditForm.dimensionalAccuracy = value;
        break;
      case 'operatorName':
        _auditForm.operatorName = value;
        break;
      case 'machineId':
        _auditForm.machineId = value;
        break;
      case 'batchNumber':
        _auditForm.batchNumber = value;
        break;
      case 'torqueReadings':
        _auditForm.torqueReadings = value;
        break;
      case 'sealantBatchNumber':
        _auditForm.sealantBatchNumber = value;
        break;
      case 'remarks':
        _auditForm.remarks = value;
        break;
      case 'defectCount':
        _auditForm.defectCount = value;
        break;
      case 'passFailStatus':
        _auditForm.passFailStatus = value;
        break;
    }
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );
      await databaseService.saveAudit(_auditForm.toMap());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audit saved successfully')));

      // Generate PDF
      final pdf = await PdfService.generateFramingPdf(_auditForm, logoBytes);

      // Navigate to PDF preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfScreen(
            pdf: pdf,
            fileName: 'Framing_Audit_${_auditForm.serialNumber}.pdf',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving audit: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formFields = [
      {
        'title': 'Frame Information',
        'fields': [
          {'name': 'frameType', 'label': 'Frame Type', 'type': 'text'},
          {'name': 'frameMaterial', 'label': 'Frame Material', 'type': 'text'},
          {
            'name': 'frameDimensions',
            'label': 'Frame Dimensions (mm)',
            'type': 'text',
          },
        ],
      },
      {
        'title': 'Assembly Quality',
        'fields': [
          {
            'name': 'cornerJointQuality',
            'label': 'Corner Joint Quality',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'sealantApplication',
            'label': 'Sealant Application',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'frameFlatness',
            'label': 'Frame Flatness',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'mountingHoleAlignment',
            'label': 'Mounting Hole Alignment',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'groundingHoleQuality',
            'label': 'Grounding Hole Quality',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'surfaceFinish',
            'label': 'Surface Finish',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
        ],
      },
      {
        'title': 'Inspection Details',
        'fields': [
          {
            'name': 'visualInspection',
            'label': 'Visual Inspection Result',
            'type': 'dropdown',
            'options': ['Pass', 'Fail'],
          },
          {
            'name': 'dimensionalAccuracy',
            'label': 'Dimensional Accuracy',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {'name': 'operatorName', 'label': 'Operator Name', 'type': 'text'},
          {'name': 'machineId', 'label': 'Machine ID', 'type': 'text'},
          {'name': 'batchNumber', 'label': 'Batch Number', 'type': 'text'},
        ],
      },
      {
        'title': 'Technical Measurements',
        'fields': [
          {
            'name': 'torqueReadings',
            'label': 'Torque Readings (Nm)',
            'type': 'text',
          },
          {
            'name': 'sealantBatchNumber',
            'label': 'Sealant Batch Number',
            'type': 'text',
          },
        ],
      },
      {
        'title': 'Quality Assessment',
        'fields': [
          {'name': 'defectCount', 'label': 'Defect Count', 'type': 'number'},
          {
            'name': 'passFailStatus',
            'label': 'Pass/Fail Status',
            'type': 'dropdown',
            'options': ['Pass', 'Fail'],
          },
          {'name': 'remarks', 'label': 'Remarks', 'type': 'multiline'},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Framing Inspection'),
        backgroundColor: Colors.blue[700],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : DynamicAuditForm(
              auditForm: _auditForm,
              controllers: _controllers,
              onFieldChanged: _updateField,
              formTitle: 'Framing Inspection Form',
              formFields: formFields,
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Cancel'),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Save & Generate PDF'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
