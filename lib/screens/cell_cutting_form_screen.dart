import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cell_cutting_audit_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../widgets/dynamic_audit_form.dart';
import 'pdf_screen.dart';

class CellCuttingFormScreen extends StatefulWidget {
  @override
  _CellCuttingFormScreenState createState() => _CellCuttingFormScreenState();
}

class _CellCuttingFormScreenState extends State<CellCuttingFormScreen> {
  late CellCuttingAuditForm _auditForm;
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
    _auditForm = CellCuttingAuditForm(
      serialNumber: 'CC-${DateTime.now().millisecondsSinceEpoch}',
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

    // Initialize controllers for cell cutting specific fields
    _controllers['cellType'] = TextEditingController();
    _controllers['cellEfficiency'] = TextEditingController();
    _controllers['cellDimensions'] = TextEditingController();
    _controllers['busbarAlignment'] = TextEditingController();
    _controllers['solderQuality'] = TextEditingController();
    _controllers['visualInspection'] = TextEditingController();
    _controllers['electricalOutput'] = TextEditingController();
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
      case 'cellType':
        _auditForm.cellType = value;
        break;
      case 'cellEfficiency':
        _auditForm.cellEfficiency = value;
        break;
      case 'cellDimensions':
        _auditForm.cellDimensions = value;
        break;
      case 'busbarAlignment':
        _auditForm.busbarAlignment = value;
        break;
      case 'solderQuality':
        _auditForm.solderQuality = value;
        break;
      case 'visualInspection':
        _auditForm.visualInspection = value;
        break;
      case 'electricalOutput':
        _auditForm.electricalOutput = value;
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
      final pdf = await PdfService.generateCellCuttingPdf(
        _auditForm,
        logoBytes,
      );

      // Navigate to PDF preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfScreen(
            pdf: pdf,
            fileName: 'Cell_Cutting_Audit_${_auditForm.serialNumber}.pdf',
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
        'title': 'Cell Information',
        'fields': [
          {'name': 'cellType', 'label': 'Cell Type', 'type': 'text'},
          {
            'name': 'cellEfficiency',
            'label': 'Cell Efficiency (%)',
            'type': 'text',
          },
          {
            'name': 'cellDimensions',
            'label': 'Cell Dimensions (mm)',
            'type': 'text',
          },
        ],
      },
      {
        'title': 'Quality Assessment',
        'fields': [
          {
            'name': 'busbarAlignment',
            'label': 'Busbar Alignment',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'solderQuality',
            'label': 'Solder Quality',
            'type': 'dropdown',
            'options': ['Excellent', 'Good', 'Fair', 'Poor'],
          },
          {
            'name': 'visualInspection',
            'label': 'Visual Inspection',
            'type': 'dropdown',
            'options': ['Pass', 'Fail'],
          },
          {
            'name': 'electricalOutput',
            'label': 'Electrical Output (W)',
            'type': 'text',
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
        title: Text('Cell Cutting Inspection'),
        backgroundColor: Colors.blue[700],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : DynamicAuditForm(
              auditForm: _auditForm,
              controllers: _controllers,
              onFieldChanged: _updateField,
              formTitle: 'Cell Cutting Inspection Form',
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
