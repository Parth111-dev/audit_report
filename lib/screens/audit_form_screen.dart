import 'dart:typed_data';

import 'package:final_audit/services/auth_service.dart';
import 'package:final_audit/widgets/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/audit_model.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';

class AuditFormScreen extends StatefulWidget {
  @override
  _AuditFormScreenState createState() => _AuditFormScreenState();
}

class _AuditFormScreenState extends State<AuditFormScreen> {
  final AuditForm _auditForm = AuditForm(
    serialNumber: 'AUDIT-${DateTime.now().millisecondsSinceEpoch}',
    auditDate: DateTime.now().toIso8601String(),
    shift: '',
    po: '',
    moduleType: '',
    createdAt: DateTime.now().toIso8601String(),
    auditorName: '',
    verifiedBy: '',
  );

  bool _isLoading = false;
  final _auditorNameController = TextEditingController();
  Uint8List? logoBytes;
  String selectedShift = ''; // Default shift

  @override
  void initState() {
    super.initState();
    _loadLogo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser != null) {
        _auditorNameController.text = authService.currentUser!.fullName;
        _auditForm.auditorName = authService.currentUser!.fullName;
      }

      _auditForm.auditDate = DateTime.now().toIso8601String();
    });

    _auditorNameController.addListener(() {
      _auditForm.auditorName = _auditorNameController.text;
    });
  }

  Future<void> _loadLogo() async {
    final data = await rootBundle.load('assets/images/pahalLogo.jpg');
    setState(() {
      logoBytes = data.buffer.asUint8List();
    });
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
                      // Stage 1: Floor
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
                        _auditForm.frontNotesController ?? '',
                      ),
                      SizedBox(height: 20),

                      // Front End Footer
                      _buildFooter(screenWidth),
                      SizedBox(height: 10),
                      // Stage 13: Auto Edge Trimming
                      _buildStage13(screenWidth),
                      SizedBox(height: 10),

                      // Stage 14: Framing Process
                      _buildStage14(screenWidth),
                      SizedBox(height: 10),

                      // Stage 15: Junction Box Assembly
                      _buildStage15(screenWidth),
                      SizedBox(height: 10),

                      // Stage 16: Curing Line
                      _buildStage16(screenWidth),
                      SizedBox(height: 10),

                      // Stage 17: Module Cleaning
                      _buildStage17(screenWidth),
                      SizedBox(height: 10),

                      // Stage 18: Hi-Pot Testing
                      _buildStage18(screenWidth),
                      SizedBox(height: 10),

                      // Stage 19: Post-El Inspection
                      _buildStage19(screenWidth),
                      SizedBox(height: 10),

                      // Stage 20: Sun Simulator
                      _buildStage20(screenWidth),
                      SizedBox(height: 10),

                      // Stage 21: FQC
                      _buildStage21(screenWidth),
                      SizedBox(height: 10),

                      // Stage 22: Auto Sorter & Packing
                      _buildStage22(screenWidth),
                      SizedBox(height: 20),

                      //notes
                      _buildNotes(
                        screenWidth,
                        _auditForm.backNotesController ?? '',
                      ),
                      SizedBox(height: 20),
                      // Footer
                      _buildFooter(screenWidth),
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
        // Table(
        //   border: TableBorder.all(width: 1),
        //   columnWidths: const {
        //     0: FlexColumnWidth(1.5),
        //     1: FlexColumnWidth(1.5),
        //     2: FlexColumnWidth(1.5),
        //     3: FlexColumnWidth(2.5),
        //   },
        //   children: [
        //     TableRow(
        //       children: [
        //         _buildCellFlutter('Date:'),
        //         _buildCellFlutter('Shift:'),
        //         _buildCellFlutter('PO:'),
        //         _buildCellFlutter('Module Type & Watt:'),
        //       ],
        //     ),
        //   ],
        // ),
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
                    _auditForm.auditDate = value!;
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
                                _auditForm.shift = selectedShift;
                                print('Audit Form Shift: ${_auditForm.shift}');
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
                    _auditForm.po = value;
                  },
                ),

                // Column 4: Module Type & Watt (placeholder) 'Module Type & Watt:'
                _buildTextField(
                  labelText: 'Module Type & Watt: ',
                  onChanged: (value) {
                    print(' Module Type Changed: $value');
                    _auditForm.moduleType = value;
                  },
                ),
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

  // Stage 1: Floor - UPDATED with centered inspection type
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.preLamTempOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.preLamTempOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) =>
                  _auditForm.preLamTempRemark = value.toString(),
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: 'Floor',
            inspectionType: 'Visual', // BLANK for subsequent rows
            parameters: 'Temp (°C) (Lamination Area)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.laminationTempOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) =>
                  _auditForm.laminationTempOb2 = value.toString(),
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.laminationTempRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: 'Floor',
            inspectionType: 'Visual', // BLANK for subsequent rows
            parameters: 'Humidity (Pre Lam)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.preLamHumidityOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.preLamHumidityOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.preLamHumidityRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.glassMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.glassMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.glassMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Glass Pallet No.',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.glassPalletNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.glassPalletNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.glassPalletNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Only show when different
            parameters: 'Glass Size (L x W x T)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.glassSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.glassSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.glassSizeRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.evaMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.evaMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.evaMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'EVA Type',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.evaTypeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.evaTypeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.evaTypeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'EVA Roll No',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.evaRollNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.evaRollNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.evaRollNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'EVA Expiry Date',
            observation1: DateField(
              onChanged: (value) => _auditForm.evaExpiryDateOb1 = value,
              initialValue: _auditForm.evaExpiryDateOb1,
            ),
            observation2: DateField(
              onChanged: (value) => _auditForm.evaExpiryDateOb2 = value,
              initialValue: _auditForm.evaExpiryDateOb2,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.evaExpiryDateRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Only show when different
            parameters: 'EVA Size (L x W x T)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.evaSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.evaSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.evaSizeRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cellMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cellMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cellMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Cell Efficiency (%) & Wattage',
            observation1: _buildTextField(
              onChanged: (value) {
                _auditForm.cellEfficiencyOb1 = value;
              },
            ),
            observation2: _buildTextField(
              onChanged: (value) {
                _auditForm.cellEfficiencyOb2 = value;
              },
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cellEfficiencyRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Different type
            parameters: 'Cell Size',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cellSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cellSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cellSizeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual', // Same type but new section
            parameters: 'Cell Defect (If Any)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cellDefectsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cellDefectsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cellDefectsRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Cleanliness of Loading Area',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cleanlinessOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cleanlinessOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cleanlinessRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Ribbon Make',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.ribbonMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.ribbonMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.ribbonMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Different type
            parameters: 'Ribbon Size',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.ribbonSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.ribbonSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.ribbonSizeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual', // New section
            parameters: 'Flux Make',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.fluxMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.fluxMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.fluxMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Flux type',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.fluxTypeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.fluxTypeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.fluxTypeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Flux Expiry date',
            observation1: DateField(
              onChanged: (value) => _auditForm.fluxExpiryDateOb1 = value,
              initialValue: _auditForm.fluxExpiryDateOb1,
            ),
            observation2: DateField(
              onChanged: (value) => _auditForm.fluxExpiryDateOb2 = value,
              initialValue: _auditForm.fluxExpiryDateOb2,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.fluxExpiryDateRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Soldering Temp (°C)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.solderingTempOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.solderingTempOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.solderingTempRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'No. Of Working Heater',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.workingHeatersOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.workingHeatersOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.workingHeatersRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Soldering Power',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.solderingPowerOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.solderingPowerOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.solderingPowerRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Solder Time (Sec)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.solderTimeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.solderTimeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.solderTimeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Visual)
            parameters: 'Ribbon Alignment on Cell (OK/NOK)',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.ribbonAlignmentOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.ribbonAlignmentOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.ribbonAlignmentRemark = value,
            ),
          ),

          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Different type
            parameters: 'Head And Tail Ribbon Dimension',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.ribbonDimensionsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.ribbonDimensionsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.ribbonDimensionsRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Cell to Cell Gap',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cellToCellGapOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cellToCellGapOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cellToCellGapRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'String Length (L1, L2)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.stringLengthOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.stringLengthOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.stringLengthRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Peel Test Result (Pass/Fail)',
            observation1: _buildDropdownField([
              'Pass',
              'Fail',
            ], (value) => _auditForm.peelTestResultOb1 = value),
            observation2: _buildDropdownField([
              'Pass',
              'Fail',
            ], (value) => _auditForm.peelTestResultOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.peelTestResultRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual', // New section
            parameters: 'EL & Visual Inspection of String',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.elInspectionOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.elInspectionOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.elInspectionRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.busbarMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.busbarMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.busbarMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Different type
            parameters: 'Busbar Size',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.busbarSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.busbarSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.busbarSizeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Cell Edge to Busbar Edge Distance',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cellToBusbarDistanceOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cellToBusbarDistanceOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) =>
                  _auditForm.cellToBusbarDistanceRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'String to String Gap',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.stringToStringGapOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.stringToStringGapOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.stringToStringGapRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Top Side Gap',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.topSideGapOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.topSideGapOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.topSideGapRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Middle Side Gap',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.middleSideGapOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.middleSideGapOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.middleSideGapRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Bottom Side Gap',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.bottomSideGapOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.bottomSideGapOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.bottomSideGapRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Left Side Gap',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.leftSideGapOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.leftSideGapOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.leftSideGapRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK (continuing Measurement)
            parameters: 'Right Side Gap',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.rightSideGapOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.rightSideGapOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.rightSideGapRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.tapMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.tapMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.tapMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Tap Position',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.tapPositionOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.tapPositionOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.tapPositionRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Different type
            parameters: 'Tap Size',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.tapSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.tapSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.tapSizeRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'EVA Type',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaTypeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaTypeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaTypeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'EVA Roll No',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaRollNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaRollNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaRollNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'EVA Expiry Date',
            observation1: DateField(
              onChanged: (value) => _auditForm.rearEvaExpiryDateOb1 = value,
              initialValue: _auditForm.rearEvaExpiryDateOb1,
            ),
            observation2: DateField(
              onChanged: (value) => _auditForm.rearEvaExpiryDateOb2 = value,
              initialValue: _auditForm.rearEvaExpiryDateOb2,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaExpiryDateRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement', // Different type
            parameters: 'EVA Size (L x W x T)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.rearEvaSizeRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.backsheetMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.backsheetMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.backsheetMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Back Sheet / Glass Type',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.backsheetTypeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.backsheetTypeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.backsheetTypeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Back Sheet / Glass Roll No.',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.backsheetRollNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.backsheetRollNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.backsheetRollNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Back Sheet / Glass Dimension (L x W x T)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.backsheetDimensionsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.backsheetDimensionsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) =>
                  _auditForm.backsheetDimensionsRemark = value,
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
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.logoPositionOkOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.logoPositionOkOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.logoPositionOkRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.preElSerialNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.preElSerialNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.preElSerialNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Current',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.preElCurrentOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.preElCurrentOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.preElCurrentRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Voltage',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.preElVoltageOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.preElVoltageOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.preElVoltageRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Defects (If Any)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.preElDefectsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.preElDefectsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.preElDefectsRemark = value,
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
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.edgeTapingOkOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.edgeTapingOkOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.edgeTapingOkRemark = value,
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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.laminatorNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.laminatorNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.laminatorNoRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.laminationTempsCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationTempsCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationTempsCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.laminationTempsCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationTempsCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationTempsCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.laminationTempsRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.vacuumTimesCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.vacuumTimesCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.vacuumTimesCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.vacuumTimesCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.vacuumTimesCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.vacuumTimesCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.vacuumTimesRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.upperventOneCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.upperventOneCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.upperventOneCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.upperventOneCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.upperventOneCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.upperventOneCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.upperventOneRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.laminationOneCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationOneCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationOneCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.laminationOneCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationOneCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationOneCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.laminationOneRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.upperventSecCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.upperventSecCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.upperventSecCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.upperventSecCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.upperventSecCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.upperventSecCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.upperventSecRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.laminationSecCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationSecCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationSecCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.laminationSecCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationSecCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationSecCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.laminationSecRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.upperventThirdCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.upperventThirdCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.upperventThirdCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.upperventThirdCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.upperventThirdCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.upperventThirdCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.upperventThirdRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.laminationThirdCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationThirdCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.laminationThirdCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.laminationThirdCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationThirdCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.laminationThirdCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.laminationThirdRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.lowerVentTimeCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.lowerVentTimeCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.lowerVentTimeCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.lowerVentTimeCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.lowerVentTimeCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.lowerVentTimeCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.lowerVentTimeRemark = value,
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
                      _buildCompactTextField((value) {
                        _auditForm.totalCycleTimeCh01Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.totalCycleTimeCh02Ob1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField((value) {
                        _auditForm.totalCycleTimeCh03Ob1 = value;
                      }),
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
                      _buildCompactTextField(
                        (value) => _auditForm.totalCycleTimeCh01Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.totalCycleTimeCh02Ob2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactTextField(
                        (value) => _auditForm.totalCycleTimeCh03Ob2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.totalCycleTimeRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.trimmingOkOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.trimmingOkOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.trimmingOkRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.frameSerialNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.frameSerialNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.frameSerialNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Frame Make',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.frameMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.frameMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.frameMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Corner Key Make',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cornerKeyMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cornerKeyMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cornerKeyMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Profile Cut Angel',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.profileCutAngleOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.profileCutAngleOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.profileCutAngleRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Length (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.frameLengthOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.frameLengthOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.frameLengthRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Width (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.frameWidthOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.frameWidthOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.frameWidthRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Height (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.frameHeightOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.frameHeightOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.frameHeightRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Mounting Hole (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.mountingHoleOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.mountingHoleOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.mountingHoleRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'X-Pitch (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.xPitchOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.xPitchOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.xPitchRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Y-Pitch (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.yPitchOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.yPitchOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.yPitchRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Hole Dia. (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.groundHoleDiaOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.groundHoleDiaOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.groundHoleDiaRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Hole Distance from Edge (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.groundHoleDistanceOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.groundHoleDistanceOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.groundHoleDistanceRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Drain Hole Size (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.drainHoleSizeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.drainHoleSizeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.drainHoleSizeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Drain Hole Distance from Edge (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.drainHoleDistanceOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.drainHoleDistanceOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.drainHoleDistanceRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Diagonal Length (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.diagonalLengthOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.diagonalLengthOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.diagonalLengthRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Sealant Make',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.sealantMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.sealantMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.sealantMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Sealant Type',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.sealantTypeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.sealantTypeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.sealantTypeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Sealant weight in Frame (gm/m)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.sealantWeightOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.sealantWeightOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.sealantWeightRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Scratch, Dents etc. on Frame',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.scratchDentsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.scratchDentsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.scratchDentsRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Defects (If Any)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.frameDefectsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.frameDefectsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.frameDefectsRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.jbSerialNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.jbSerialNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.jbSerialNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Junction Box Make',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.jbMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.jbMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.jbMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Junction Box Type',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.jbTypeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.jbTypeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.jbTypeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Diode Model No.',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.diodeModelOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.diodeModelOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.diodeModelRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Junction Box Placement',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.jbPlacementOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.jbPlacementOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.jbPlacementRemark = value,
            ),
          ),
          // UPDATED: Junction Box Sealant Weight - Single Row with A, B, C
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Junction Box Sealant Weight A, B, C',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('A:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.jbSealantWeightsAOb1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('B:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.jbSealantWeightsBOb1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('C:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.jbSealantWeightsCOb1 = value;
                      }),
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
                      Text('A:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.jbSealantWeightsAOb2 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('B:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.jbSealantWeightsBOb2 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('C:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.jbSealantWeightsCOb2 = value;
                      }),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.jbSealantWeightsRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Soldering Quality of J.B.',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.solderingQualityOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.solderingQualityOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.solderingQualityRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Potting Sealant Make',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.pottingSealantMakeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.pottingSealantMakeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.pottingSealantMakeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Potting Sealant Type',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.pottingSealantTypeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.pottingSealantTypeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.pottingSealantTypeRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Potting Sealant Expiry Date',
            observation1: DateField(
              onChanged: (value) => _auditForm.pottingSealantExpiryOb1 = value,
              initialValue: _auditForm.pottingSealantExpiryOb1,
            ),
            observation2: DateField(
              onChanged: (value) => _auditForm.pottingSealantExpiryOb2 = value,
              initialValue: _auditForm.pottingSealantExpiryOb2,
            ),
            remarks: _buildTextField(
              onChanged: (value) =>
                  _auditForm.pottingSealantExpiryRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Curing Time (minute)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.curingTimeOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.curingTimeOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.curingTimeRemark = value,
            ),
          ),
          // UPDATED: Potting Sealant Weight - Single Row with A, B, C
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Potting Sealant Weight A, B, C',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('A:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingSealantWeightsAOb1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('B:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingSealantWeightsBOb1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('C:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingSealantWeightsCOb1 = value;
                      }),
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
                      Text('A:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingSealantWeightsAOb2 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('B:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingSealantWeightsBOb2 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('C:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingSealantWeightsCOb2 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) =>
                  _auditForm.pottingSealantWeightsRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Potting Sealant Ratio (A:B) Ratio',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('A:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingRatioAOb1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('B:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingRatioBOb1 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('Ratio:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingRatioOb1 = value;
                      }),
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
                      Text('A:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingRatioAOb2 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('B:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingRatioBOb2 = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      Text('Ratio:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField((value) {
                        _auditForm.pottingRatioOb2 = value;
                      }),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.pottingRatioRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Cable Length (mm)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.cableLengthOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.cableLengthOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cableLengthRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Visual Status',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.visualStatusOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.visualStatusOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.visualStatusRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.curingTimeLineOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.curingTimeLineOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.curingTimeLineRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Temp (°C)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.curingTempOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.curingTempOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.curingTempRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Humidity (%)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.curingHumidityOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.curingHumidityOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.curingHumidityRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.cleaningOkOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.cleaningOkOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.cleaningOkRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.hipotSerialNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.hipotSerialNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.hipotSerialNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'DCW',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.dcwOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.dcwOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.dcwRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'IR',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.irOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.irOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.irRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Continuity',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.groundContinuityOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.groundContinuityOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.groundContinuityRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.postElSerialNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.postElSerialNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.postElSerialNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Current',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.postElCurrentOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.postElCurrentOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.postElCurrentRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Voltage',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.postElVoltageOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.postElVoltageOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.postElVoltageRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Defects (If Any)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.postElDefectsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.postElDefectsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.postElDefectsRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: DateField(
              onChanged: (value) => _auditForm.calibrationDateOb1 = value,
              initialValue: _auditForm.calibrationDateOb1,
            ),
            observation2: DateField(
              onChanged: (value) => _auditForm.calibrationDateOb2 = value,
              initialValue: _auditForm.calibrationDateOb2,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.calibrationDateRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Module Sr. No.',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.sunSerialNoOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.sunSerialNoOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.sunSerialNoRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Module Power Output (W)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.modulePowerOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.modulePowerOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.modulePowerRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Isc (I)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.iscOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.iscOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.iscRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Voc (V)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.vocOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.vocOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.vocRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Imp (I)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.impOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.impOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.impRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Vmp (V)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.vmpOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.vmpOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.vmpRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Module Temp (°C)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.moduleTempOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.moduleTempOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.moduleTempRemark = value,
            ),
          ),
          // UPDATED: Module F.F & Effi. - Single Row with F.F. and Effi.
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '', // BLANK
            parameters: 'Module F.F & Effi.',
            observation1: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('F.F.:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField(
                        (value) => _auditForm.fillFactorOb1 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Text('Effi.:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField(
                        (value) => _auditForm.efficiencyOb1 = value,
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
                      Text('F.F.:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField(
                        (value) => _auditForm.fillFactorOb2 = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Text('Effi.:', style: TextStyle(fontSize: 12)),
                      _buildCompactTextField(
                        (value) => _auditForm.efficiencyOb2 = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.efficiencyRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'IV Curve (OK/NOK)',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.ivCurveOkOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.ivCurveOkOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.ivCurveOkRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.visualInspectionOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.visualInspectionOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.visualInspectionRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Fitment of JB Cover',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.jbCoverFitmentOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.jbCoverFitmentOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.jbCoverFitmentRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Placement of Back label & Barcode (OK/NOK)',
            observation1: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.labelPlacementOb1 = value),
            observation2: _buildDropdownField([
              'OK',
              'NOK',
            ], (value) => _auditForm.labelPlacementOb2 = value),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.labelPlacementRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Defect (If Any)',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.fqcDefectsOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.fqcDefectsOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.fqcDefectsRemark = value,
            ),
          ),
        ],
      ),
    );
  }

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
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.sortingStatusOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.sortingStatusOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.sortingStatusRemark = value,
            ),
          ),
          _buildDataRow(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Pallet & Box Condition',
            observation1: _buildTextField(
              onChanged: (value) => _auditForm.palletConditionOb1 = value,
            ),
            observation2: _buildTextField(
              onChanged: (value) => _auditForm.palletConditionOb2 = value,
            ),
            remarks: _buildTextField(
              onChanged: (value) => _auditForm.palletConditionRemark = value,
            ),
          ),
        ],
      ),
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
                  onChanged: (value) => controller = value,
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

  Widget _buildDataCell(Widget child) {
    return Padding(padding: EdgeInsets.all(4), child: child);
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
        _buildDataCell(
          Center(child: Text(inspectionType)),
        ), // Centered inspection type
        _buildDataCell(Text(parameters)),
        _buildDataCell(observation1),
        _buildDataCell(observation2),
        _buildDataCell(remarks),
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

  Widget _buildCompactTextField(Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        // isDense: true,
      ),
      style: TextStyle(fontSize: 12),
    );
  }

  Widget _buildDropdownField(List<String> options, Function(String) onChanged) {
    String selectedValue = options.first;
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      items: options.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        print('DropDown value: $value');
        if (value != null) {
          onChanged(value);
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  // Form actions
  void _saveForm() async {
    if (_auditForm.auditDate.isEmpty) {
      _auditForm.auditDate = DateTime.now().toIso8601String();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService().saveAudit(_auditForm);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audit saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to dashboard after a short delay
      await Future.delayed(Duration(milliseconds: 1500));

      // Use pushReplacement to go to dashboard and remove form from stack
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving audit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generatePdf() async {
    try {
      final pdfFile = await PdfService.generatePdf(_auditForm);
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

  @override
  void dispose() {
    _auditorNameController.dispose();
    // _verifiedByController.dispose();
    super.dispose();
  }
}
