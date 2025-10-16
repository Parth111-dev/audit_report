import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/sheet_cutting_audit_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../widgets/dynamic_audit_form.dart';
import 'pdf_screen.dart';

class SheetCuttingFormScreen extends StatefulWidget {
  @override
  _SheetCuttingFormScreenState createState() => _SheetCuttingFormScreenState();
}

class _SheetCuttingFormScreenState extends State<SheetCuttingFormScreen> {
  late SheetCuttingAuditForm _auditForm;
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
    _auditForm = SheetCuttingAuditForm(
      serialNumber: 'SC-${DateTime.now().millisecondsSinceEpoch}',
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

    // Initialize controllers for sheet cutting specific fields
    _controllers['materialType'] = TextEditingController();
    _controllers['sheetThickness'] = TextEditingController();
    _controllers['cutDimensions'] = TextEditingController();
    _controllers['edgeQuality'] = TextEditingController();
    _controllers['surfaceFinish'] = TextEditingController();
    _controllers['cutAccuracy'] = TextEditingController();
    _controllers['operatorName'] = TextEditingController();
    _controllers['machineId'] = TextEditingController();
    _controllers['batchNumber'] = TextEditingController();
    _controllers['defectCount'] = TextEditingController();
    _controllers['remarks'] = TextEditingController();
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
      case 'materialType':
        _auditForm.materialType = value;
        break;
      case 'sheetThickness':
        _auditForm.sheetThickness = value;
        break;
      case 'cutDimensions':
        _auditForm.cutDimensions = value;
        break;
      case 'edgeQuality':
        _auditForm.edgeQuality = value;
        break;
      case 'surfaceFinish':
        _auditForm.surfaceFinish = value;
        break;
      case 'cutAccuracy':
        _auditForm.cutAccuracy = value;
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
      case 'defectCount':
        _auditForm.defectCount = value;
        break;
      case 'remarks':
        _auditForm.remarks = value;
        break;
      case 'passFailStatus':
        _auditForm.passFailStatus = value;
        break;
    }
  }

  // Update all form fields from controllers before saving
  void _updateFormFromControllers() {
    _controllers.forEach((fieldName, controller) {
      _updateField(fieldName, controller.text);
    });
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

      // Ensure all form fields are updated from controllers
      _updateFormFromControllers();

      // Save to database
      await databaseService.saveAudit(_auditForm.toMap());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audit saved successfully')));

      // Generate PDF
      final pdf = await PdfService.generateSheetCuttingPdf(
        _auditForm,
        logoBytes,
      );

      // Navigate to PDF preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfScreen(
            pdf: pdf,
            fileName: 'Sheet_Cutting_Audit_${_auditForm.serialNumber}.pdf',
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
        'title': 'Material Information',
        'fields': [
          {'name': 'materialType', 'label': 'Material Type', 'type': 'text'},
          {
            'name': 'sheetThickness',
            'label': 'Sheet Thickness (mm)',
            'type': 'text',
          },
          {
            'name': 'cutDimensions',
            'label': 'Cut Dimensions (mm)',
            'type': 'text',
          },
        ],
      },
      {
        'title': 'Quality Assessment',
        'fields': [
          {
            'name': 'edgeQuality',
            'label': 'Edge Quality',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'surfaceFinish',
            'label': 'Surface Finish',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'cutAccuracy',
            'label': 'Cut Accuracy',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
        ],
      },
      {
        'title': 'Process Information',
        'fields': [
          {'name': 'operatorName', 'label': 'Operator Name', 'type': 'text'},
          {'name': 'machineId', 'label': 'Machine ID', 'type': 'text'},
          {'name': 'batchNumber', 'label': 'Batch Number', 'type': 'text'},
        ],
      },
      {
        'title': 'Final Assessment',
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
        title: Text('Sheet Cutting Inspection'),
        backgroundColor: Colors.blue[700],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : DynamicAuditForm(
              auditForm: _auditForm,
              controllers: _controllers,
              onFieldChanged: _updateField,
              formTitle: 'Sheet Cutting Inspection Form',
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
