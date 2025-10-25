import 'package:final_audit/widgets/date_field.dart';
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
  // late SheetCuttingAuditForm _sheetCuttingauditForm;
  bool _isLoading = false;
  final Map<String, TextEditingController> _controllers = {};
  Uint8List? logoBytes;
  var selectedShift;

  final _auditorNameController = TextEditingController();

  final SheetCuttingAuditForm _sheetCuttingauditForm = SheetCuttingAuditForm(
    serialNumber: 'SC-${DateTime.now().millisecondsSinceEpoch}',
    auditDate: DateTime.now().toIso8601String(),
    shift: '',
    po: '',
    moduleType: '',
    createdAt: DateTime.now().toIso8601String(),
    auditorName: '',
    verifiedBy: '',
  );

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadLogo();
  }

  void _initializeForm() {
    // Initialize controllers for all fields
    _controllers['serialNumber'] = TextEditingController(
      text: _sheetCuttingauditForm.serialNumber,
    );
    _controllers['auditorName'] = TextEditingController();
    _controllers['verifiedBy'] = TextEditingController();

    // Set auditor name from current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser != null) {
        _controllers['auditorName']!.text = authService.currentUser!.fullName;
        _sheetCuttingauditForm.auditorName = authService.currentUser!.fullName;
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
      // Base audit form fields
      case 'serialNumber':
        _sheetCuttingauditForm.serialNumber = value;
        break;
      case 'auditDate':
        _sheetCuttingauditForm.auditDate = value;
        break;
      case 'auditorName':
        _sheetCuttingauditForm.auditorName = value;
        break;
      case 'verifiedBy':
        _sheetCuttingauditForm.verifiedBy = value;
        break;
      case 'shift':
        // This updates the shift in BaseAuditForm
        _sheetCuttingauditForm.shift = value;
        break;
      case 'po':
        _sheetCuttingauditForm.po = value;
        break;
      case 'moduleType':
        _sheetCuttingauditForm.moduleType = value;
        break;

      // Framing specific fields
      case 'date':
        _sheetCuttingauditForm.date = value;
        break;
      case 'line':
        _sheetCuttingauditForm.line = value;
        break;
      case 'remarks':
        _sheetCuttingauditForm.remarks = value;
        break;
      case 'note':
        _sheetCuttingauditForm.note = value;
        break;
      case 'qcInnspectorName':
        _sheetCuttingauditForm.qcInnspectorName = value;
        break;
      case 'preparedBy':
        _sheetCuttingauditForm.preparedBy = value;
        break;
      case 'verifyBy':
        _sheetCuttingauditForm.verifyBy = value;
        break;
      case 'approvedBy':
        _sheetCuttingauditForm.approvedBy = value;
        break;

      // Time-specific fields
      case 'eightAMevaMake':
        _sheetCuttingauditForm.eightAMevaMake = value;
        break;
      case 'eightAMevaFront':
        _sheetCuttingauditForm.eightAMevaFront = value;
        break;
      case 'eightAMevaBack':
        _sheetCuttingauditForm.eightAMevaBack = value;
        break;
      case 'eightAMpoNo':
        _sheetCuttingauditForm.eightAMpoNo = value;
        break;
      case 'eightAMasPrPo':
        _sheetCuttingauditForm.eightAMasPrPo = value;
        break;
      case 'eightAMdimensionFront':
        _sheetCuttingauditForm.eightAMdimensionFront = value;
        break;
      case 'eightAMdimensionBack':
        _sheetCuttingauditForm.eightAMdimensionBack = value;
        break;
      case 'eightAMvisualCheck':
        _sheetCuttingauditForm.eightAMvisualCheck = value;
        break;
      case 'eightAMdefect':
        _sheetCuttingauditForm.eightAMdefect = value;
        break;
      case 'eightAMremark':
        _sheetCuttingauditForm.eightAMremark = value;
        break;
      case 'eightAMcheckedBy':
        _sheetCuttingauditForm.eightAMcheckedBy = value;
        break;

      // Add cases for all other time slots
      case 'tenAMevaMake':
        _sheetCuttingauditForm.tenAMevaMake = value;
        break;
      case 'tenAMevaFront':
        _sheetCuttingauditForm.tenAMevaFront = value;
        break;
      case 'tenAMevaBack':
        _sheetCuttingauditForm.tenAMevaBack = value;
        break;
      case 'tenAMpoNo':
        _sheetCuttingauditForm.tenAMpoNo = value;
        break;
      case 'tenAMdimensionFront':
        _sheetCuttingauditForm.tenAMdimensionFront = value;
        break;
      case 'tenAMdimensionBack':
        _sheetCuttingauditForm.tenAMdimensionBack = value;
        break;
      case 'tenAMvisualCheck':
        _sheetCuttingauditForm.tenAMvisualCheck = value;
        break;
      case 'tenAMdefect':
        _sheetCuttingauditForm.tenAMdefect = value;
        break;
      case 'tenAMremark':
        _sheetCuttingauditForm.tenAMremark = value;
        break;
      case 'tenAMcheckedBy':
        _sheetCuttingauditForm.tenAMcheckedBy = value;
        break;

      // Add cases for all other fields as needed
      default:
        print('Field $fieldName not found in form');
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
      await databaseService.saveAudit(_sheetCuttingauditForm.toMap());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audit saved successfully')));

      // Generate PDF
      final pdf = await PdfService.generateSheetCuttingPdf(
        _sheetCuttingauditForm,
        logoBytes,
      );

      // Navigate to PDF preview
      Navigator.pushReplacementNamed(context, '/dashboard');
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
                // Column 1: Date Picker
                DateField(
                  initialValue: null, // Default to today
                  onChanged: (value) {
                    // value is selected date in dd/MM/yyyy format
                    print('Selected date: $value');
                    _sheetCuttingauditForm.auditDate = value!;
                  },
                ),

                // Column 2: Shift Radio Buttons
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['A', 'B', 'C', 'D'].map((shift) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: shift,
                            groupValue: selectedShift,
                            onChanged: (value) {
                              setState(() {
                                selectedShift = value!;
                                print('selectedShift: $selectedShift');
                                _sheetCuttingauditForm.shift = selectedShift;
                                print(
                                  'SheetCuttingAudit Form Shift: ${_sheetCuttingauditForm.shift}',
                                );
                              });
                            },
                          ),
                          Text(shift),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                // Column 3: PO (placeholder) 'PO:',
                _buildTextField(
                  labelText: 'PO:',
                  onChanged: (value) {
                    print(' PO Changed: $value');
                    _sheetCuttingauditForm.po = value;
                  },
                ),

                // Column 4: Module Type & Watt (placeholder) 'Module Type & Watt:'
                _buildTextField(
                  labelText: 'Module Type & Watt: ',
                  onChanged: (value) {
                    print(' Module Type Changed: $value');
                    _sheetCuttingauditForm.moduleType = value;
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    String? hintText,
    String? labelText,
    required Function(String) onChanged,
  }) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        hintText: hintText,
        labelText: labelText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('IMS-FRM-PQC-001 IN-PROCESS AUDIT SHEET'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
          IconButton(icon: Icon(Icons.picture_as_pdf), onPressed: _generatePdf),
          IconButton(icon: Icon(Icons.print), onPressed: _printForm),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildTitle(),
                      SizedBox(height: 20),
                      // Header - Full Width Table
                      _buildHeader(screenWidth),
                      // SampleObservedTime 1: Floor
                      _buildStage1(screenWidth),
                      SizedBox(height: 10),

                      // Stage 2: Front Glass Loading
                      _buildStage2(screenWidth),
                      SizedBox(height: 10),

                      // Stage 3: Front side EVA Cutting
                      _buildStage3(screenWidth),
                      SizedBox(height: 10),

                      // Stage 4: Stringer
                      _buildStage4(screenWidth),
                      SizedBox(height: 10),

                      // Stage 5: Lay-up & Auto Bussing
                      _buildStage5(screenWidth),
                      SizedBox(height: 10),

                      // Stage 6: Auto Tapping
                      _buildStage6(screenWidth),
                      SizedBox(height: 10),

                      // Stage 7: Rear side EVA Cutting
                      _buildStage7(screenWidth),
                      SizedBox(height: 10),

                      // Stage 8: Rear Side Back Sheet/Glass
                      _buildStage8(screenWidth),
                      SizedBox(height: 10),

                      // Stage 9: Logo & Barcode Fixing
                      _buildStage9(screenWidth),
                      SizedBox(height: 10),

                      // Stage 10: Pre-El Inspection
                      _buildStage10(screenWidth),
                      SizedBox(height: 10),

                      // Stage 11: Auto Edge Taping
                      _buildStage11(screenWidth),
                      SizedBox(height: 10),

                      // Stage 12: Lamination Process
                      _buildStage12(screenWidth),
                      SizedBox(height: 10),

                      // Notes
                      _buildNotes(
                        screenWidth,
                        _sheetCuttingauditForm.note ?? '',
                      ),
                      SizedBox(height: 20),

                      // Front End Footer
                      _buildFooter(screenWidth),
                      SizedBox(height: 10),
                      // Stage 13: Auto Edge Trimming
                      SizedBox(height: 20),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
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
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[300]),
            children: [
              _buildHeaderCell('Sr.No.'),
              _buildHeaderCell('Sample Observed Time'),
              _buildHeaderCell('EVA MAKE (FRONT&BACK)'),
              _buildHeaderCell('EVA TYPE FRONT'),
              _buildHeaderCell('EVA TYPE BACK'),
              _buildHeaderCell('PO  NO.'),
              _buildHeaderCell('DIMENSIONS (L x W) FRONT'),
              _buildHeaderCell('DIMENSIONS (L x W) BACK'),
              _buildHeaderCell('Visual Check(OK / NOK)'),
              _buildHeaderCell('Defects (if any)'),
              _buildHeaderCell('Remarks'),
              _buildHeaderCell('Checked By'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for building table cells
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

  // Stage 1: Floor - UPDATED with centered inspection type
  Widget _buildStage1(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '1',
            sampleObservedTime: '8.00 AM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightAMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stage 2: Front Glass Loading - UPDATED
  Widget _buildStage2(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '2',
            sampleObservedTime: '10.00 AM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenAMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stage 3: Front side EVA Cutting - UPDATED
  Widget _buildStage3(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '3',
            sampleObservedTime: '12.00 PM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twelvePMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stage 4: Stringer - UPDATED
  Widget _buildStage4(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '4',
            sampleObservedTime: '2.00 PM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.twoPMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stage 5: Lay-up & Auto Bussing - UPDATED
  Widget _buildStage5(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '5',
            sampleObservedTime: '4.00 PM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.fourPMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage6(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '6',
            sampleObservedTime: '6.00 PM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.sixPMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage7(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '7',
            sampleObservedTime: '8.00 PM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.eightPMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage8(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '8',
            sampleObservedTime: '10.00 PM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMevaMake = value;
              },
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMevaFront = value;
              },
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMevaBack = value;
              },
            ),
            pono: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMpoNo = value;
              },
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMdimensionFront = value;
              },
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMdimensionBack = value;
              },
            ),
            visualCheck: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMvisualCheck = value;
              },
            ),
            defect: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMdefect = value;
              },
            ),
            remark: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMremark = value;
              },
            ),
            checkedBy: _buildTextField(
              onChanged: (value) {
                _sheetCuttingauditForm.tenPMcheckedBy = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage9(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '9',
            sampleObservedTime: '12.00 AM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMevaMake = value,
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMevaFront = value,
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMevaBack = value,
            ),
            pono: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.twelveAMpoNo = value,
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMdimensionFront = value,
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMdimensionBack = value,
            ),
            visualCheck: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMvisualCheck = value,
            ),
            defect: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMdefect = value,
            ),
            remark: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMremark = value,
            ),
            checkedBy: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twelveAMcheckedBy = value.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage10(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '10',
            sampleObservedTime: '2.00 AM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.twoAMevaMake = value,
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twoAMevaFront = value,
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.twoAMevaBack = value,
            ),
            pono: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.twoAMpoNo = value,
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twoAMdimensionFront = value,
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twoAMdimensionBack = value,
            ),
            visualCheck: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twoAMvisualCheck = value,
            ),
            defect: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.twoAMdefect = value,
            ),
            remark: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.twoAMremark = value,
            ),
            checkedBy: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.twoAMcheckedBy = value.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage11(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '11',
            sampleObservedTime: '4.00 AM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.fourAMevaMake = value,
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.fourAMevaFront = value,
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.fourAMevaBack = value,
            ),
            pono: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.fourAMpoNo = value,
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.fourAMdimensionFront = value,
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.fourAMdimensionBack = value,
            ),
            visualCheck: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.fourAMvisualCheck = value,
            ),
            defect: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.fourAMdefect = value,
            ),
            remark: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.fourAMremark = value,
            ),
            checkedBy: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.fourAMcheckedBy = value.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage12(double screenWidth) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(2.0),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(0.8),
          6: FlexColumnWidth(2.0),
          7: FlexColumnWidth(2.0),
          8: FlexColumnWidth(1.0),
          9: FlexColumnWidth(1.5),
          10: FlexColumnWidth(1.5),
          11: FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRow(
            srNo: '12',
            sampleObservedTime: '6.00 AM',
            evaMAKEFRONTAndBACK: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.sixAMevaMake = value,
            ),
            evaTypeFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.sixAMevaFront = value,
            ),
            evaTypeBack: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.sixAMevaBack = value,
            ),
            pono: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.sixAMpoNo = value,
            ),
            dimensionsFront: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.sixAMdimensionFront = value,
            ),
            dimensionsBack: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.sixAMdimensionBack = value,
            ),
            visualCheck: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.sixAMvisualCheck = value,
            ),
            defect: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.sixAMdefect = value,
            ),
            remark: _buildTextField(
              onChanged: (value) => _sheetCuttingauditForm.sixAMremark = value,
            ),
            checkedBy: _buildTextField(
              onChanged: (value) =>
                  _sheetCuttingauditForm.sixAMcheckedBy = value.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(padding: EdgeInsets.all(4), child: child);
  }

  TableRow _buildDataRow({
    required String srNo,
    required String sampleObservedTime,
    required Widget evaMAKEFRONTAndBACK,
    required Widget evaTypeFront,
    required Widget evaTypeBack,
    required Widget pono,
    required Widget dimensionsFront,
    required Widget dimensionsBack,
    required Widget visualCheck,
    required Widget defect,
    required Widget remark,
    required Widget checkedBy,
  }) {
    return TableRow(
      children: [
        _buildDataCell(Center(child: Text(srNo))),
        _buildDataCell(Text(sampleObservedTime)),
        _buildDataCell(evaMAKEFRONTAndBACK), // Centered inspection type
        _buildDataCell(evaTypeFront),
        _buildDataCell(evaTypeBack),
        _buildDataCell(pono),
        _buildDataCell(dimensionsFront),
        _buildDataCell(dimensionsBack),
        _buildDataCell(visualCheck),
        _buildDataCell(defect),
        _buildDataCell(remark),
        _buildDataCell(checkedBy),
      ],
    );
  }

  Widget _buildNotes(double screenWidth, String controller) {
    return Container(
      width: screenWidth,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {0: FlexColumnWidth(1.0)},
        children: [
          TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: _buildTextField(
                  hintText: 'Enter notes',
                  onChanged: (value) {
                    _sheetCuttingauditForm.note = value;
                  },
                ),
              ),
            ],
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
                child: TextField(
                  controller: _auditorNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabled: false,
                    hintText: 'Enter name',
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(8), child: Text('Verify By:')),
              Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabled: false,
                    // hintText: 'Enter name',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _saveForm,
          icon: Icon(Icons.save),
          label: Text('SAVE AUDIT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: _generatePdf,
          icon: Icon(Icons.picture_as_pdf),
          label: Text('GENERATE PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: _printForm,
          icon: Icon(Icons.print),
          label: Text('PRINT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    );
  }

  void _generatePdf() async {
    try {
      final pdfFile = await PdfService.generateSheetCuttingPdf(
        _sheetCuttingauditForm,
        logoBytes,
      );

      // Navigate to PDF preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfScreen(
            pdf: pdfFile,
            fileName:
                'Sheet_Cutting_Audit_${_sheetCuttingauditForm.serialNumber}.pdf',
          ),
        ),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF generated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    }
  }

  void _printForm() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Print functionality coming soon!')));
  }
}
