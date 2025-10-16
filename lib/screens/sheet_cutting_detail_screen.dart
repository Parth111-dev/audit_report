import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/sheet_cutting_audit_model.dart';
import '../models/audit_model.dart';
import '../services/auth_service.dart';
import '../services/audit_service.dart';
import '../services/pdf_service.dart';
import 'pdf_screen.dart';

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

    // Sheet cutting specific fields
    fieldControllers['materialType'] = TextEditingController(
      text: audit.materialType,
    );
    fieldControllers['sheetThickness'] = TextEditingController(
      text: audit.sheetThickness,
    );
    fieldControllers['cutDimensions'] = TextEditingController(
      text: audit.cutDimensions,
    );
    fieldControllers['edgeQuality'] = TextEditingController(
      text: audit.edgeQuality,
    );
    fieldControllers['surfaceFinish'] = TextEditingController(
      text: audit.surfaceFinish,
    );
    fieldControllers['cutAccuracy'] = TextEditingController(
      text: audit.cutAccuracy,
    );
    fieldControllers['operatorName'] = TextEditingController(
      text: audit.operatorName,
    );
    fieldControllers['machineId'] = TextEditingController(
      text: audit.machineId,
    );
    fieldControllers['batchNumber'] = TextEditingController(
      text: audit.batchNumber,
    );
    fieldControllers['defectCount'] = TextEditingController(
      text: audit.defectCount,
    );
    fieldControllers['remarks'] = TextEditingController(text: audit.remarks);
    fieldControllers['passFailStatus'] = TextEditingController(
      text: audit.passFailStatus,
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
    // Check if current user is admin
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
      // Update the audit object with new value
      final newValue = fieldControllers[fieldName]?.text ?? '';
      _updateAuditField(fieldName, newValue);

      // Save to database
      final auditService = Provider.of<AuditService>(context, listen: false);
      // Convert SheetCuttingAuditForm to AuditForm for compatibility with AuditService
      final auditForm = AuditForm(
        id: audit.id,
        serialNumber: audit.serialNumber,
        auditDate: audit.auditDate,
        auditorName: audit.auditorName,
        verifiedBy: audit.verifiedBy,
        shift: audit.shift,
        po: audit.po,
        moduleType: audit.moduleType,
        createdAt: audit.createdAt, // createdAt is already a String in the model
      );

      final success = await auditService.updateAudit(auditForm);

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
      case 'materialType':
        audit.materialType = value;
        break;
      case 'sheetThickness':
        audit.sheetThickness = value;
        break;
      case 'cutDimensions':
        audit.cutDimensions = value;
        break;
      case 'edgeQuality':
        audit.edgeQuality = value;
        break;
      case 'surfaceFinish':
        audit.surfaceFinish = value;
        break;
      case 'cutAccuracy':
        audit.cutAccuracy = value;
        break;
      case 'operatorName':
        audit.operatorName = value;
        break;
      case 'machineId':
        audit.machineId = value;
        break;
      case 'batchNumber':
        audit.batchNumber = value;
        break;
      case 'defectCount':
        audit.defectCount = value;
        break;
      case 'remarks':
        audit.remarks = value;
        break;
      case 'passFailStatus':
        audit.passFailStatus = value;
        break;
    }
  }

  Future<void> _regeneratePdf() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Generate PDF
      final pdf = await PdfService.generateSheetCuttingPdf(audit, logoBytes);

      // Navigate to PDF preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfScreen(
            pdf: pdf,
            fileName: 'Sheet_Cutting_Audit_${audit.serialNumber}.pdf',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildEditableField(String fieldName, String label) {
    final isEditing = editingFields[fieldName] ?? false;
    final controller = fieldControllers[fieldName];

    if (controller == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: fieldName == 'remarks' ? 3 : 1,
                  )
                : Text(controller.text),
          ),
          if (isAdmin)
            Expanded(
              flex: 1,
              child: isEditing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _saveFieldEdit(fieldName),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _cancelFieldEdit(fieldName),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _enableFieldEdit(fieldName),
                    ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sheet Cutting Audit Details'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _regeneratePdf,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sheet Cutting Audit',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildEditableField('serialNumber', 'Serial Number'),
                          _buildEditableField('auditDate', 'Audit Date'),
                          _buildEditableField('auditorName', 'Auditor'),
                          _buildEditableField('verifiedBy', 'Verified By'),
                          _buildEditableField('shift', 'Shift'),
                          _buildEditableField('po', 'PO Number'),
                          _buildEditableField('moduleType', 'Module Type'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Material Information
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Material Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildEditableField('materialType', 'Material Type'),
                          _buildEditableField(
                            'sheetThickness',
                            'Sheet Thickness (mm)',
                          ),
                          _buildEditableField(
                            'cutDimensions',
                            'Cut Dimensions (mm)',
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Quality Assessment
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quality Assessment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildEditableField('edgeQuality', 'Edge Quality'),
                          _buildEditableField(
                            'surfaceFinish',
                            'Surface Finish',
                          ),
                          _buildEditableField('cutAccuracy', 'Cut Accuracy'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Process Information
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Process Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildEditableField('operatorName', 'Operator Name'),
                          _buildEditableField('machineId', 'Machine ID'),
                          _buildEditableField('batchNumber', 'Batch Number'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Final Assessment
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Final Assessment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildEditableField('defectCount', 'Defect Count'),
                          _buildEditableField(
                            'passFailStatus',
                            'Pass/Fail Status',
                          ),
                          _buildEditableField('remarks', 'Remarks'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    fieldControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
