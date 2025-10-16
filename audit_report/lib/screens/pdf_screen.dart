import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/audit_model.dart';

class PdfScreen extends StatefulWidget {
  final AuditForm audit;

  const PdfScreen({Key? key, required this.audit}) : super(key: key);

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  late AuditForm audit;
  bool _isGenerating = false;
  Uint8List? logoBytes;

  // 🔹 Define reusable TextStyles
  final headerTextStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue900,
  );
  final subHeaderTextStyle = pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue700,
  );
  final tableHeadingTextStyle = pw.TextStyle(
    fontSize: 8,
    fontWeight: pw.FontWeight.bold,
  );
  final tableCellTextStyle = pw.TextStyle(
    fontSize: 6.5,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  @override
  void initState() {
    super.initState();
    audit = widget.audit;
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    final data = await rootBundle.load('assets/images/pahalLogo.jpg');
    setState(() {
      logoBytes = data.buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Generator - ${widget.audit.serialNumber}'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audit PDF Generation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Serial Number: ${widget.audit.serialNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Audit Date: ${widget.audit.auditDate}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Auditor: ${widget.audit.auditorName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Verified By: ${widget.audit.verifiedBy}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Generation Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '• Complete audit report with all 22 stages\n'
                      '• Professional formatting with tables\n'
                      '• All observations and remarks included\n'
                      '• Automatic save to Downloads folder',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: _isGenerating
                  ? Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[700]!,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Generating PDF...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: _generateAndSavePdf,
                      icon: Icon(Icons.picture_as_pdf, size: 28),
                      label: Text(
                        'Generate PDF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndSavePdf() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate PDF document
      final pdf = pw.Document();

      // Add pages to PDF
      await _buildPdfContent(pdf);

      // Get downloads directory
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      } else {
        downloadsDirectory = await getDownloadsDirectory();
      }

      if (downloadsDirectory != null && await downloadsDirectory.exists()) {
        // Create file name with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'audit_${widget.audit.serialNumber}_$timestamp.pdf';
        final file = File('${downloadsDirectory.path}/$fileName');

        // Save PDF to file
        await file.writeAsBytes(await pdf.save());

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved successfully to Downloads folder!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        throw Exception('Downloads directory not accessible');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _buildPdfContent(pw.Document pdf) async {
    // Load font for better text rendering
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    // Page 1:
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(10),
        build: (pw.Context context) => [
          // Header
          _buildPdfTitle(),
          pw.SizedBox(height: 10),
          _buildHeaderPdf(),
          _buildStage1Pdf(),
          _buildStage2Pdf(),
          _buildStage3Pdf(),
          _buildStage4Pdf(),
          _buildStage5Pdf(),
        ],
      ),
    );

    // Page 2:
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(10),
        build: (pw.Context context) => [
          _buildPdfTitle(),
          pw.SizedBox(height: 10),
          _buildHeaderPdf(),
          _buildStage6Pdf(),
          _buildStage7Pdf(),
          _buildStage8Pdf(),
          _buildStage9Pdf(),
          _buildStage10Pdf(),
          _buildStage11Pdf(),
          _buildStage12Pdf(),
          _buildFooterPdf(),
        ],
      ),
    );

    // Page 3:
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(10),
        build: (pw.Context context) => [
          _buildPdfTitle(),
          pw.SizedBox(height: 10),
          _buildHeaderPdf(),
          _buildStage13Pdf(),
          _buildStage14Pdf(),
          _buildStage15Pdf(),
          _buildStage16Pdf(),
          _buildStage17Pdf(),
        ],
      ),
    );

    // Page 4:
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(10),
        build: (pw.Context context) => [
          _buildPdfTitle(),
          pw.SizedBox(height: 10),
          _buildHeaderPdf(),
          _buildStage18Pdf(),
          _buildStage19Pdf(),
          _buildStage20Pdf(),
          _buildStage21Pdf(),
          _buildStage22Pdf(),
          _buildFooterPdf(),
        ],
      ),
    );
  }

  pw.Widget _buildCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: tableHeadingTextStyle.fontSize),
      ),
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 🔹 1st Row
        pw.Table(
          border: pw.TableBorder.all(width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              children: [
                // 1️⃣ Column 1 - Image
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: logoBytes != null
                      ? pw.Image(
                          pw.MemoryImage(logoBytes!),
                          fit: pw.BoxFit.contain,
                        )
                      : pw.Text('Logo not loaded'),
                ),

                // 2️⃣ Column 2 - 2 rows (empty text placeholders)
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Text('PAHAL SOLAR PVT. LTD.', style: headerTextStyle),
                      pw.Text(
                        'In-Process Audit Sheet',
                        style: subHeaderTextStyle,
                      ),
                    ],
                  ),
                ),

                // 3️⃣ Column 3 - 3 rows (right-aligned, center)
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end, // right side
                    mainAxisAlignment:
                        pw.MainAxisAlignment.center, // vertically center
                    children: [
                      pw.Text(
                        'Doc No: IMS-FRM-PQC-001',
                        style: tableCellTextStyle,
                      ),
                      pw.Text(
                        'Effective Date: 11/03/2025',
                        style: tableCellTextStyle,
                      ),
                      pw.Text('Revision No: 00', style: tableCellTextStyle),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // 🔹 2nd Row (4 Columns)
        pw.Table(
          border: pw.TableBorder.all(width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2.5),
          },
          children: [
            pw.TableRow(
              children: [
                _buildCell('Date: ${widget.audit.auditDate}'),
                _buildCell('Shift: ${widget.audit.shift}'),
                _buildCell('PO: ${widget.audit.po}'),
                _buildCell('Module Type & Watt: ${widget.audit.moduleType}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildDataRowPdf({
    required String srNo,
    required String stage,
    required String inspectionType,
    required String parameters,
    required dynamic observation1, // String or pw.Widget
    required dynamic observation2, // String or pw.Widget
    required dynamic remarks, // String or pw.Widget
  }) {
    return pw.TableRow(
      children: [
        _buildDataCellPdf(
          pw.Center(child: pw.Text(srNo, style: tableCellTextStyle)),
        ),
        _buildDataCellPdf(pw.Text(stage, style: tableCellTextStyle)),
        _buildDataCellPdf(
          pw.Center(child: pw.Text(inspectionType, style: tableCellTextStyle)),
        ),
        _buildDataCellPdf(pw.Text(parameters, style: tableCellTextStyle)),
        _buildDataCellPdf(_normalizeToWidget(observation1)),
        _buildDataCellPdf(_normalizeToWidget(observation2)),
        _buildDataCellPdf(_normalizeToWidget(remarks)),
      ],
    );
  }

  // ✅ Converts String → pw.Widget automatically
  pw.Widget _normalizeToWidget(dynamic value) {
    if (value is pw.Widget) {
      return value;
    } else if (value is String) {
      return _buildReadOnlyTextPdf(value);
    } else {
      return _buildReadOnlyTextPdf('N/A');
    }
  }

  // ✅ Default cell styling
  pw.Widget _buildDataCellPdf(pw.Widget child) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.centerLeft,
      child: child,
    );
  }

  // ✅ Default read-only text cell
  pw.Widget _buildReadOnlyTextPdf(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        text.isNotEmpty ? text : 'Not specified',
        style: pw.TextStyle(
          color: PdfColors.black,
          fontSize: tableCellTextStyle.fontSize,
        ),
      ),
    );
  }

  pw.Widget _pdfChBlock(String? ch01, String? ch02, String? ch03) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                ch01 ?? '',
                style: pw.TextStyle(fontSize: tableCellTextStyle.fontSize),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                ch02 ?? '',
                style: pw.TextStyle(fontSize: tableCellTextStyle.fontSize),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                ch03 ?? '',
                style: pw.TextStyle(fontSize: tableCellTextStyle.fontSize),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildHeaderCellPdf(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: tableHeadingTextStyle.fontSize,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildHeaderPdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey300, // same as Colors.grey[300]
            ),
            children: [
              _buildHeaderCellPdf('Sr.No.'),
              _buildHeaderCellPdf('Stage'),
              _buildHeaderCellPdf('Type Of Inspection'),
              _buildHeaderCellPdf('Parameters'),
              _buildHeaderCellPdf('Observation 1'),
              _buildHeaderCellPdf('Observation 2'),
              _buildHeaderCellPdf('Remarks'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooterPdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(1.0),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.0),
          3: pw.FlexColumnWidth(1.0),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Audit Done By:',
                  style: pw.TextStyle(fontSize: tableHeadingTextStyle.fontSize),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  widget.audit.auditorName ?? '',
                  style: pw.TextStyle(
                    fontSize: tableHeadingTextStyle.fontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Verify By:',
                  style: pw.TextStyle(fontSize: tableHeadingTextStyle.fontSize),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  widget.audit.verifiedBy ?? '',
                  style: pw.TextStyle(
                    fontSize: tableHeadingTextStyle.fontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage1Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '1',
            stage: 'Floor',
            inspectionType: 'Visual',
            parameters: 'Temp (°C)(Pre-Lam Area)',
            observation1: widget.audit.preLamTempOb1?.toString() ?? '',
            observation2: widget.audit.preLamTempOb2?.toString() ?? '',
            remarks: widget.audit.preLamTempRemark?.toString() ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Temp (°C)(Lamination Area)',
            observation1: widget.audit.laminationTempOb1?.toString() ?? '',
            observation2: widget.audit.laminationTempOb2?.toString() ?? '',
            remarks: widget.audit.laminationTempRemark?.toString() ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Humidity(Pre Lam)',
            observation1: widget.audit.preLamHumidityOb1?.toString() ?? '',
            observation2: widget.audit.preLamHumidityOb2?.toString() ?? '',
            remarks: widget.audit.preLamHumidityRemark?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage2Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '2',
            stage: 'Front Glass Loading',
            inspectionType: 'Visual',
            parameters: 'Glass Make',
            observation1: widget.audit.glassMakeOb1 ?? '',
            observation2: widget.audit.glassMakeOb2 ?? '',
            remarks: widget.audit.glassMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Glass Pallet No.',
            observation1: widget.audit.glassPalletNoOb1 ?? '',
            observation2: widget.audit.glassPalletNoOb2 ?? '',
            remarks: widget.audit.glassPalletNoRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Glass Size (L x W x T)',
            observation1: widget.audit.glassSizeOb1 ?? '',
            observation2: widget.audit.glassSizeOb2 ?? '',
            remarks: widget.audit.glassSizeRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage3Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '3',
            stage: 'Front side EVA Cutting',
            inspectionType: 'Visual',
            parameters: 'EVA Make',
            observation1: widget.audit.evaMakeOb1 ?? '',
            observation2: widget.audit.evaMakeOb2 ?? '',
            remarks: widget.audit.evaMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Type',
            observation1: widget.audit.evaTypeOb1 ?? '',
            observation2: widget.audit.evaTypeOb2 ?? '',
            remarks: widget.audit.evaTypeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Roll No',
            observation1: widget.audit.evaRollNoOb1 ?? '',
            observation2: widget.audit.evaRollNoOb2 ?? '',
            remarks: widget.audit.evaRollNoRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Expiry Date',
            observation1: widget.audit.evaExpiryDateOb1 ?? '',
            observation2: widget.audit.evaExpiryDateOb2 ?? '',
            remarks: widget.audit.evaExpiryDateRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'EVA Size (L x W x T)',
            observation1: widget.audit.evaSizeOb1 ?? '',
            observation2: widget.audit.evaSizeOb2 ?? '',
            remarks: widget.audit.evaSizeRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage4Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '4',
            stage: 'Stringer',
            inspectionType: 'Visual',
            parameters: 'Cell Make',
            observation1: widget.audit.cellMakeOb1 ?? '',
            observation2: widget.audit.cellMakeOb2 ?? '',
            remarks: widget.audit.cellMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cell Efficiency (%) & Wattage',
            observation1: widget.audit.cellEfficiencyOb1?.toString() ?? '',
            observation2: widget.audit.cellEfficiencyOb2?.toString() ?? '',
            remarks: widget.audit.cellEfficiencyRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cell Size',
            observation1: widget.audit.cellSizeOb1 ?? '',
            observation2: widget.audit.cellSizeOb2 ?? '',
            remarks: widget.audit.cellSizeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cell Defect (If Any)',
            observation1: widget.audit.cellDefectsOb1 ?? '',
            observation2: widget.audit.cellDefectsOb2 ?? '',
            remarks: widget.audit.cellDefectsRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cleanliness of Loading Area',
            observation1: widget.audit.cleanlinessOb1 ?? '',
            observation2: widget.audit.cleanlinessOb2 ?? '',
            remarks: widget.audit.cleanlinessRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ribbon Make',
            observation1: widget.audit.ribbonMakeOb1 ?? '',
            observation2: widget.audit.ribbonMakeOb2 ?? '',
            remarks: widget.audit.ribbonMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Ribbon Size',
            observation1: widget.audit.ribbonSizeOb1 ?? '',
            observation2: widget.audit.ribbonSizeOb2 ?? '',
            remarks: widget.audit.ribbonSizeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Flux Make',
            observation1: widget.audit.fluxMakeOb1 ?? '',
            observation2: widget.audit.fluxMakeOb2 ?? '',
            remarks: widget.audit.fluxMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Flux type',
            observation1: widget.audit.fluxTypeOb1 ?? '',
            observation2: widget.audit.fluxTypeOb2 ?? '',
            remarks: widget.audit.fluxTypeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Flux Expiry date',
            observation1: widget.audit.fluxExpiryDateOb1 ?? '',
            observation2: widget.audit.fluxExpiryDateOb2 ?? '',
            remarks: widget.audit.fluxExpiryDateRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Soldering Temp (°C)',
            observation1: widget.audit.solderingTempOb1?.toString() ?? '',
            observation2: widget.audit.solderingTempOb2?.toString() ?? '',
            remarks: widget.audit.solderingTempRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'No. Of Working Heater',
            observation1: widget.audit.workingHeatersOb1?.toString() ?? '',
            observation2: widget.audit.workingHeatersOb2?.toString() ?? '',
            remarks: widget.audit.workingHeatersRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Soldering Power',
            observation1: widget.audit.solderingPowerOb1?.toString() ?? '',
            observation2: widget.audit.solderingPowerOb2?.toString() ?? '',
            remarks: widget.audit.solderingPowerRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Solder Time (Sec)',
            observation1: widget.audit.solderTimeOb1?.toString() ?? '',
            observation2: widget.audit.solderTimeOb2?.toString() ?? '',
            remarks: widget.audit.solderTimeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ribbon Alignment on Cell (OK/NOK)',
            observation1: widget.audit.ribbonAlignmentOb1?.toString() ?? '',
            observation2: widget.audit.ribbonAlignmentOb2?.toString() ?? '',
            remarks: widget.audit.ribbonAlignmentRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Head And Tail Ribbon Dimension',
            observation1: widget.audit.ribbonDimensionsOb1 ?? '',
            observation2: widget.audit.ribbonDimensionsOb2 ?? '',
            remarks: widget.audit.ribbonDimensionsRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cell to Cell Gap',
            observation1: widget.audit.cellToCellGapOb1?.toString() ?? '',
            observation2: widget.audit.cellToCellGapOb2?.toString() ?? '',
            remarks: widget.audit.cellToCellGapRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'String Length (L1, L2)',
            observation1: widget.audit.stringLengthOb1 ?? '',
            observation2: widget.audit.stringLengthOb2 ?? '',
            remarks: widget.audit.stringLengthRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Peel Test Result (Pass/Fail)',
            observation1: widget.audit.peelTestResultOb1?.toString() ?? '',
            observation2: widget.audit.peelTestResultOb2?.toString() ?? '',
            remarks: widget.audit.peelTestResultRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'EL & Visual Inspection of String',
            observation1: widget.audit.elInspectionOb1?.toString() ?? '',
            observation2: widget.audit.elInspectionOb2?.toString() ?? '',
            remarks: widget.audit.elInspectionRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage5Pdf() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(1.0),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2.0),
        5: const pw.FlexColumnWidth(2.0),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        _buildDataRowPdf(
          srNo: '5',
          stage: 'Lay-up & Auto Bussing',
          inspectionType: 'Visual',
          parameters: 'Busbar Make',
          observation1: widget.audit.busbarMakeOb1 ?? '',
          observation2: widget.audit.busbarMakeOb2 ?? '',
          remarks: widget.audit.busbarMakeRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: 'Measurement',
          parameters: 'Busbar Size',
          observation1: widget.audit.busbarSizeOb1 ?? '',
          observation2: widget.audit.busbarSizeOb2 ?? '',
          remarks: widget.audit.busbarSizeRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Cell Edge to Busbar Edge Distance',
          observation1: widget.audit.cellToBusbarDistanceOb1?.toString() ?? '',
          observation2: widget.audit.cellToBusbarDistanceOb2?.toString() ?? '',
          remarks: widget.audit.cellToBusbarDistanceRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'String to String Gap',
          observation1: widget.audit.stringToStringGapOb1?.toString() ?? '',
          observation2: widget.audit.stringToStringGapOb2?.toString() ?? '',
          remarks: widget.audit.stringToStringGapRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Top Side Gap',
          observation1: widget.audit.topSideGapOb1?.toString() ?? '',
          observation2: widget.audit.topSideGapOb2?.toString() ?? '',
          remarks: widget.audit.topSideGapRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Middle Side Gap',
          observation1: widget.audit.middleSideGapOb1?.toString() ?? '',
          observation2: widget.audit.middleSideGapOb2?.toString() ?? '',
          remarks: widget.audit.middleSideGapRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Bottom Side Gap',
          observation1: widget.audit.bottomSideGapOb1?.toString() ?? '',
          observation2: widget.audit.bottomSideGapOb2?.toString() ?? '',
          remarks: widget.audit.bottomSideGapRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Left Side Gap',
          observation1: widget.audit.leftSideGapOb1?.toString() ?? '',
          observation2: widget.audit.leftSideGapOb2?.toString() ?? '',
          remarks: widget.audit.leftSideGapRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Right Side Gap',
          observation1: widget.audit.rightSideGapOb1?.toString() ?? '',
          observation2: widget.audit.rightSideGapOb2?.toString() ?? '',
          remarks: widget.audit.rightSideGapRemark ?? '',
        ),
      ],
    );
  }

  pw.Widget _buildStage6Pdf() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(1.0),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2.0),
        5: const pw.FlexColumnWidth(2.0),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        _buildDataRowPdf(
          srNo: '6',
          stage: 'Auto Tapping',
          inspectionType: 'Visual',
          parameters: 'Tap Make',
          observation1: audit.tapMakeOb1 ?? '',
          observation2: audit.tapMakeOb2 ?? '',
          remarks: audit.tapMakeRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Tap Position',
          observation1: audit.tapPositionOb1 ?? '',
          observation2: audit.tapPositionOb2 ?? '',
          remarks: audit.tapPositionRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: 'Measurement',
          parameters: 'Tap Size',
          observation1: audit.tapSizeOb1 ?? '',
          observation2: audit.tapSizeOb2 ?? '',
          remarks: audit.tapSizeRemark ?? '',
        ),
      ],
    );
  }

  pw.Widget _buildStage7Pdf() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(1.0),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2.0),
        5: const pw.FlexColumnWidth(2.0),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        _buildDataRowPdf(
          srNo: '7',
          stage: 'Rear Side EVA Cutting',
          inspectionType: 'Visual',
          parameters: 'EVA Make',
          observation1: audit.rearEvaMakeOb1 ?? '',
          observation2: audit.rearEvaMakeOb2 ?? '',
          remarks: audit.rearEvaMakeRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'EVA Type',
          observation1: audit.rearEvaTypeOb1 ?? '',
          observation2: audit.rearEvaTypeOb2 ?? '',
          remarks: audit.rearEvaTypeRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'EVA Roll No',
          observation1: audit.rearEvaRollNoOb1 ?? '',
          observation2: audit.rearEvaRollNoOb2 ?? '',
          remarks: audit.rearEvaRollNoRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'EVA Expiry Date',
          observation1: audit.rearEvaExpiryDateOb1 ?? '',
          observation2: audit.rearEvaExpiryDateOb2 ?? '',
          remarks: audit.rearEvaExpiryDateRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: 'Measurement',
          parameters: 'EVA Size (L x W x T)',
          observation1: audit.rearEvaSizeOb1 ?? '',
          observation2: audit.rearEvaSizeOb2 ?? '',
          remarks: audit.rearEvaSizeRemark ?? '',
        ),
      ],
    );
  }

  pw.Widget _buildStage8Pdf() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(1.0),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2.0),
        5: const pw.FlexColumnWidth(2.0),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        _buildDataRowPdf(
          srNo: '8',
          stage: 'Rear Side Back Sheet/Glass',
          inspectionType: 'Visual',
          parameters: 'Back Sheet / Glass Make',
          observation1: audit.backsheetMakeOb1 ?? '',
          observation2: audit.backsheetMakeOb2 ?? '',
          remarks: audit.backsheetMakeRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Back Sheet / Glass Type',
          observation1: audit.backsheetTypeOb1 ?? '',
          observation2: audit.backsheetTypeOb2 ?? '',
          remarks: audit.backsheetTypeRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: '',
          parameters: 'Back Sheet / Glass Roll No.',
          observation1: audit.backsheetRollNoOb1 ?? '',
          observation2: audit.backsheetRollNoOb2 ?? '',
          remarks: audit.backsheetRollNoRemark ?? '',
        ),
        _buildDataRowPdf(
          srNo: '',
          stage: '',
          inspectionType: 'Measurement',
          parameters: 'Back Sheet / Glass Dimension (L x W x T)',
          observation1: audit.backsheetDimensionsOb1 ?? '',
          observation2: audit.backsheetDimensionsOb2 ?? '',
          remarks: audit.backsheetDimensionsRemark ?? '',
        ),
      ],
    );
  }

  pw.Widget _buildStage9Pdf() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: pw.FlexColumnWidth(0.5),
            1: pw.FlexColumnWidth(1.0),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(1.5),
            4: pw.FlexColumnWidth(2.0),
            5: pw.FlexColumnWidth(2.0),
            6: pw.FlexColumnWidth(1.5),
          },
          children: [
            _buildDataRowPdf(
              srNo: '9',
              stage: 'Logo & Barcode Fixing',
              inspectionType: 'Visual',
              parameters: 'Position Verification of Logo & Barcode',
              observation1: audit.logoPositionOkOb1?.toString() ?? '',
              observation2: audit.logoPositionOkOb2?.toString() ?? '',
              remarks: audit.logoPositionOkRemark ?? '',
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildStage10Pdf() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: pw.FlexColumnWidth(0.5),
            1: pw.FlexColumnWidth(1.0),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(1.5),
            4: pw.FlexColumnWidth(2.0),
            5: pw.FlexColumnWidth(2.0),
            6: pw.FlexColumnWidth(1.5),
          },
          children: [
            _buildDataRowPdf(
              srNo: '10',
              stage: 'Pre-EL Inspection',
              inspectionType: 'Visual',
              parameters: 'Module Sr. Number',
              observation1: audit.preElSerialNoOb1 ?? '',
              observation2: audit.preElSerialNoOb2 ?? '',
              remarks: audit.preElSerialNoRemark ?? '',
            ),
            _buildDataRowPdf(
              srNo: '',
              stage: '',
              inspectionType: 'Measurement',
              parameters: 'Current',
              observation1: audit.preElCurrentOb1?.toString() ?? '',
              observation2: audit.preElCurrentOb2?.toString() ?? '',
              remarks: audit.preElCurrentRemark ?? '',
            ),
            _buildDataRowPdf(
              srNo: '',
              stage: '',
              inspectionType: '',
              parameters: 'Voltage',
              observation1: audit.preElVoltageOb1?.toString() ?? '',
              observation2: audit.preElVoltageOb2?.toString() ?? '',
              remarks: audit.preElVoltageRemark ?? '',
            ),
            _buildDataRowPdf(
              srNo: '',
              stage: '',
              inspectionType: 'Visual',
              parameters: 'Defects (If Any)',
              observation1: audit.preElDefectsOb1 ?? '',
              observation2: audit.preElDefectsOb2 ?? '',
              remarks: audit.preElDefectsRemark ?? '',
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildStage11Pdf() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: pw.FlexColumnWidth(0.5),
            1: pw.FlexColumnWidth(1.0),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(1.5),
            4: pw.FlexColumnWidth(2.0),
            5: pw.FlexColumnWidth(2.0),
            6: pw.FlexColumnWidth(1.5),
          },
          children: [
            _buildDataRowPdf(
              srNo: '11',
              stage: 'Auto Edge Taping',
              inspectionType: 'Visual',
              parameters: 'Visually',
              observation1: audit.edgeTapingOkOb1?.toString() ?? '',
              observation2: audit.edgeTapingOkOb2?.toString() ?? '',
              remarks: audit.edgeTapingOkRemark ?? '',
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildStage12Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '12',
            stage: 'Lamination Process',
            inspectionType: '',
            parameters: 'Laminator No.',
            observation1: widget.audit.laminatorNoOb1 ?? '',
            observation2: widget.audit.laminatorNoOb2 ?? '',
            remarks: widget.audit.laminatorNoRemark ?? '',
          ),

          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Lamination Chamber',
            observation1: Row(
              children: [
                Expanded(child: Text('Ch-01:')),
                SizedBox(width: 4),
                Expanded(child: Text('Ch-02:', style: TextStyle(fontSize: 12))),
                SizedBox(width: 4),
                Expanded(child: Text('Ch-03:', style: TextStyle(fontSize: 12))),
              ],
            ),

            observation2: Row(
              children: [
                Expanded(child: Text('Ch-01:', style: TextStyle(fontSize: 12))),
                SizedBox(width: 4),
                Expanded(child: Text('Ch-02:', style: TextStyle(fontSize: 12))),
                SizedBox(width: 4),
                Expanded(child: Text('Ch-03:', style: TextStyle(fontSize: 12))),
              ],
            ),
            remarks: Text('-', style: TextStyle(fontSize: 12)),
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Lamination Chamber',
            observation1: _pdfChBlock('CH-01', 'CH-02', 'CH-03'),
            observation2: _pdfChBlock('CH-01', 'CH-02', 'CH-03'),
            remarks: pw.Text('-'),
          ),

          // Lamination Temp (°C)
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Lamination Temp (°C)',
            observation1: _pdfChBlock(
              widget.audit.laminationTempsCh01Ob1 ?? '',
              widget.audit.laminationTempsCh02Ob1 ?? '',
              widget.audit.laminationTempsCh03Ob1 ?? '',
            ),
            observation2: _pdfChBlock(
              widget.audit.laminationTempsCh01Ob2,
              widget.audit.laminationTempsCh02Ob2,
              widget.audit.laminationTempsCh03Ob2,
            ),
            remarks: pw.Text(
              widget.audit.laminationTempsRemark ?? '',
              style: tableCellTextStyle,
            ),
          ),

          // Total Vacuum Time
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Total Vacuum Time',
            observation1: _pdfChBlock(
              widget.audit.vacuumTimesCh01Ob1,
              widget.audit.vacuumTimesCh02Ob1,
              widget.audit.vacuumTimesCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.vacuumTimesCh01Ob2,
              widget.audit.vacuumTimesCh02Ob2,
              widget.audit.vacuumTimesCh03Ob2,
            ),
            remarks: widget.audit.vacuumTimesRemark ?? '',
          ),

          // Upper Vent 1
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Upper Vent 1',
            observation1: _pdfChBlock(
              widget.audit.upperventOneCh01Ob1,
              widget.audit.upperventOneCh02Ob1,
              widget.audit.upperventOneCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.upperventOneCh01Ob2,
              widget.audit.upperventOneCh02Ob2,
              widget.audit.upperventOneCh03Ob2,
            ),
            remarks: widget.audit.upperventOneRemark ?? '',
          ),

          // Lamination 1
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lamination 1',
            observation1: _pdfChBlock(
              widget.audit.laminationOneCh01Ob1,
              widget.audit.laminationOneCh02Ob1,
              widget.audit.laminationOneCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.laminationOneCh01Ob2,
              widget.audit.laminationOneCh02Ob2,
              widget.audit.laminationOneCh03Ob2,
            ),
            remarks: widget.audit.laminationOneRemark ?? '',
          ),

          // Upper Vent 2
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Upper Vent 2',
            observation1: _pdfChBlock(
              widget.audit.upperventSecCh01Ob1,
              widget.audit.upperventSecCh02Ob1,
              widget.audit.upperventSecCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.upperventSecCh01Ob2,
              widget.audit.upperventSecCh02Ob2,
              widget.audit.upperventSecCh03Ob2,
            ),
            remarks: widget.audit.upperventSecRemark ?? '',
          ),

          // Lamination 2
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lamination 2',
            observation1: _pdfChBlock(
              widget.audit.laminationSecCh01Ob1,
              widget.audit.laminationSecCh02Ob1,
              widget.audit.laminationSecCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.laminationSecCh01Ob2,
              widget.audit.laminationSecCh02Ob2,
              widget.audit.laminationSecCh03Ob2,
            ),
            remarks: widget.audit.laminationSecRemark ?? '',
          ),

          // Upper Vent 3
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Upper Vent 3',
            observation1: _pdfChBlock(
              widget.audit.upperventThirdCh01Ob1,
              widget.audit.upperventThirdCh02Ob1,
              widget.audit.upperventThirdCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.upperventThirdCh01Ob2,
              widget.audit.upperventThirdCh02Ob2,
              widget.audit.upperventThirdCh03Ob2,
            ),
            remarks: widget.audit.upperventThirdRemark ?? '',
          ),

          // Lamination 3
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lamination 3',
            observation1: _pdfChBlock(
              widget.audit.laminationThirdCh01Ob1,
              widget.audit.laminationThirdCh02Ob1,
              widget.audit.laminationThirdCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.laminationThirdCh01Ob2,
              widget.audit.laminationThirdCh02Ob2,
              widget.audit.laminationThirdCh03Ob2,
            ),
            remarks: widget.audit.laminationThirdRemark ?? '',
          ),

          // Lower Vent Time
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Lower Vent Time',
            observation1: _pdfChBlock(
              widget.audit.lowerVentTimeCh01Ob1,
              widget.audit.lowerVentTimeCh02Ob1,
              widget.audit.lowerVentTimeCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.lowerVentTimeCh01Ob2,
              widget.audit.lowerVentTimeCh02Ob2,
              widget.audit.lowerVentTimeCh03Ob2,
            ),
            remarks: widget.audit.lowerVentTimeRemark ?? '',
          ),

          // Total Cycle Time
          _buildDataRowPdf(
            srNo: '',
            stage: 'Lamination Process',
            inspectionType: 'Visual',
            parameters: 'Total Cycle Time',
            observation1: _pdfChBlock(
              widget.audit.totalCycleTimeCh01Ob1,
              widget.audit.totalCycleTimeCh02Ob1,
              widget.audit.totalCycleTimeCh03Ob1,
            ),
            observation2: _pdfChBlock(
              widget.audit.totalCycleTimeCh01Ob2,
              widget.audit.totalCycleTimeCh02Ob2,
              widget.audit.totalCycleTimeCh03Ob2,
            ),
            remarks: widget.audit.totalCycleTimeRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage13Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '13',
            stage: 'Auto Edge Trimming',
            inspectionType: 'Visual',
            parameters: 'Physical Verification of Trimming',
            observation1: widget.audit.trimmingOkOb1?.toString() ?? '',
            observation2: widget.audit.trimmingOkOb2?.toString() ?? '',
            remarks: widget.audit.trimmingOkRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage14Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '14',
            stage: 'Framing Process',
            inspectionType: 'Visual',
            parameters: 'Module Sr. Number',
            observation1: widget.audit.frameSerialNoOb1 ?? '',
            observation2: widget.audit.frameSerialNoOb2 ?? '',
            remarks: widget.audit.frameSerialNoRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Frame Make',
            observation1: widget.audit.frameMakeOb1 ?? '',
            observation2: widget.audit.frameMakeOb2 ?? '',
            remarks: widget.audit.frameMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Corner Key Make',
            observation1: widget.audit.cornerKeyMakeOb1 ?? '',
            observation2: widget.audit.cornerKeyMakeOb2 ?? '',
            remarks: widget.audit.cornerKeyMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Profile Cut Angel',
            observation1: widget.audit.profileCutAngleOb1?.toString() ?? '',
            observation2: widget.audit.profileCutAngleOb2?.toString() ?? '',
            remarks: widget.audit.profileCutAngleRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Length (mm)',
            observation1: widget.audit.frameLengthOb1?.toString() ?? '',
            observation2: widget.audit.frameLengthOb2?.toString() ?? '',
            remarks: widget.audit.frameLengthRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Width (mm)',
            observation1: widget.audit.frameWidthOb1?.toString() ?? '',
            observation2: widget.audit.frameWidthOb2?.toString() ?? '',
            remarks: widget.audit.frameWidthRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Height (mm)',
            observation1: widget.audit.frameHeightOb1?.toString() ?? '',
            observation2: widget.audit.frameHeightOb2?.toString() ?? '',
            remarks: widget.audit.frameHeightRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Mounting Hole (mm)',
            observation1: widget.audit.mountingHoleOb1?.toString() ?? '',
            observation2: widget.audit.mountingHoleOb2?.toString() ?? '',
            remarks: widget.audit.mountingHoleRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'X-Pitch (mm)',
            observation1: widget.audit.xPitchOb1?.toString() ?? '',
            observation2: widget.audit.xPitchOb2?.toString() ?? '',
            remarks: widget.audit.xPitchRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Y-Pitch (mm)',
            observation1: widget.audit.yPitchOb1?.toString() ?? '',
            observation2: widget.audit.yPitchOb2?.toString() ?? '',
            remarks: widget.audit.yPitchRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Hole Dia. (mm)',
            observation1: widget.audit.groundHoleDiaOb1?.toString() ?? '',
            observation2: widget.audit.groundHoleDiaOb2?.toString() ?? '',
            remarks: widget.audit.groundHoleDiaRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Hole Distance from Edge (mm)',
            observation1: widget.audit.groundHoleDistanceOb1?.toString() ?? '',
            observation2: widget.audit.groundHoleDistanceOb2?.toString() ?? '',
            remarks: widget.audit.groundHoleDistanceRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Drain Hole Size (mm)',
            observation1: widget.audit.drainHoleSizeOb1?.toString() ?? '',
            observation2: widget.audit.drainHoleSizeOb2?.toString() ?? '',
            remarks: widget.audit.drainHoleSizeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Drain Hole Distance from Edge (mm)',
            observation1: widget.audit.drainHoleDistanceOb1?.toString() ?? '',
            observation2: widget.audit.drainHoleDistanceOb2?.toString() ?? '',
            remarks: widget.audit.drainHoleDistanceRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Diagonal Length (mm)',
            observation1: widget.audit.diagonalLengthOb1?.toString() ?? '',
            observation2: widget.audit.diagonalLengthOb2?.toString() ?? '',
            remarks: widget.audit.diagonalLengthRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Sealant Make',
            observation1: widget.audit.sealantMakeOb1 ?? '',
            observation2: widget.audit.sealantMakeOb2 ?? '',
            remarks: widget.audit.sealantMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Sealant Type',
            observation1: widget.audit.sealantTypeOb1 ?? '',
            observation2: widget.audit.sealantTypeOb2 ?? '',
            remarks: widget.audit.sealantTypeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Sealant weight in Frame (gm/m)',
            observation1: widget.audit.sealantWeightOb1?.toString() ?? '',
            observation2: widget.audit.sealantWeightOb2?.toString() ?? '',
            remarks: widget.audit.sealantWeightRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Scratch, Dents etc. on Frame',
            observation1: widget.audit.frameDefectsOb1 ?? '',
            observation2: widget.audit.frameDefectsOb2 ?? '',
            remarks: widget.audit.frameDefectsRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage15Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(2.0),
          6: pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '15',
            stage: 'Junction Box Assembly',
            inspectionType: 'Visual',
            parameters: 'Module Sr. No.',
            observation1: widget.audit.jbSerialNoOb1 ?? '',
            observation2: widget.audit.jbSerialNoOb2 ?? '',
            remarks: widget.audit.jbSerialNoRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Junction Box Make',
            observation1: widget.audit.jbMakeOb1 ?? '',
            observation2: widget.audit.jbMakeOb2 ?? '',
            remarks: widget.audit.jbMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Junction Box Type',
            observation1: widget.audit.jbTypeOb1 ?? '',
            observation2: widget.audit.jbTypeOb2 ?? '',
            remarks: widget.audit.jbTypeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Diode Model No.',
            observation1: widget.audit.diodeModelOb1 ?? '',
            observation2: widget.audit.diodeModelOb2 ?? '',
            remarks: widget.audit.diodeModelRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Junction Box Placement',
            observation1: widget.audit.jbPlacementOb1 ?? '',
            observation2: widget.audit.jbPlacementOb2 ?? '',
            remarks: widget.audit.jbPlacementRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Junction Box Sealant Weight A,B,C',
            observation1:
                'A:- ${widget.audit.jbSealantWeightsAOb1?.toString() ?? ''} | B:- ${widget.audit.jbSealantWeightsBOb1?.toString() ?? ''} | C:- ${widget.audit.jbSealantWeightsCOb1?.toString() ?? ''}',
            observation2:
                'A:- ${widget.audit.jbSealantWeightsAOb2?.toString() ?? ''} | B:- ${widget.audit.jbSealantWeightsBOb2?.toString() ?? ''} | C:- ${widget.audit.jbSealantWeightsCOb2?.toString() ?? ''}',
            remarks: widget.audit.jbSealantWeightsRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Soldering Quality of J.B.',
            observation1: widget.audit.solderingQualityOb1?.toString() ?? '',
            observation2: widget.audit.solderingQualityOb2?.toString() ?? '',
            remarks: widget.audit.solderingQualityRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Make',
            observation1: widget.audit.pottingSealantMakeOb1 ?? '',
            observation2: widget.audit.pottingSealantMakeOb2 ?? '',
            remarks: widget.audit.pottingSealantMakeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Type',
            observation1: widget.audit.pottingSealantTypeOb1 ?? '',
            observation2: widget.audit.pottingSealantTypeOb2 ?? '',
            remarks: widget.audit.pottingSealantTypeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Expiry Date',
            observation1: widget.audit.pottingSealantExpiryOb1 ?? '',
            observation2: widget.audit.pottingSealantExpiryOb2 ?? '',
            remarks: widget.audit.pottingSealantExpiryRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Curing Time (minute)',
            observation1: widget.audit.curingTimeOb1?.toString() ?? '',
            observation2: widget.audit.curingTimeOb2?.toString() ?? '',
            remarks: widget.audit.curingTimeRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Potting Sealant Weight A,B,C',
            observation1:
                'A:- ${widget.audit.pottingSealantWeightsAOb1?.toString() ?? ''} | B:- ${widget.audit.pottingSealantWeightsBOb1?.toString() ?? ''} | C:- ${widget.audit.pottingSealantWeightsCOb1?.toString() ?? ''}',
            observation2:
                'A:- ${widget.audit.pottingSealantWeightsAOb2?.toString() ?? ''} | B:- ${widget.audit.pottingSealantWeightsBOb2?.toString() ?? ''} | C:- ${widget.audit.pottingSealantWeightsCOb2?.toString() ?? ''}',
            remarks: widget.audit.pottingSealantWeightsRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Potting Sealant Ratio (A:B)',
            observation1:
                'A:- ${widget.audit.pottingRatioAOb1?.toString() ?? ''} | B:- ${widget.audit.pottingRatioBOb1?.toString() ?? ''} | Ratio: ${widget.audit.pottingRatioOb1?.toString() ?? 'N/A'}',
            observation2:
                'A:- ${widget.audit.pottingRatioAOb2?.toString() ?? ''} | B:- ${widget.audit.pottingRatioBOb2?.toString() ?? ''} | Ratio: ${widget.audit.pottingRatioOb2?.toString() ?? 'N/A'}',
            remarks: widget.audit.pottingRatioRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Cable Length (mm)',
            observation1: widget.audit.cableLengthOb1?.toString() ?? '',
            observation2: widget.audit.cableLengthOb2?.toString() ?? '',
            remarks: widget.audit.cableLengthRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Visual Status',
            observation1: widget.audit.visualStatusOb1?.toString() ?? '',
            observation2: widget.audit.visualStatusOb2?.toString() ?? '',
            remarks: widget.audit.visualStatusRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage16Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(2.0),
          5: const pw.FlexColumnWidth(2.0),
          6: const pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '16',
            stage: 'Curing Line',
            inspectionType: 'Visual',
            parameters: 'Curing Time',
            observation1: audit.curingTimeLineOb1?.toString() ?? '',
            observation2: audit.curingTimeLineOb2?.toString() ?? '',
            remarks: audit.curingTimeLineRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Temp (°C)',
            observation1: audit.curingTempOb1?.toString() ?? '',
            observation2: audit.curingTempOb2?.toString() ?? '',
            remarks: audit.curingTempRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Humidity (%)',
            observation1: audit.curingHumidityOb1?.toString() ?? '',
            observation2: audit.curingHumidityOb2?.toString() ?? '',
            remarks: audit.curingHumidityRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage17Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(2.0),
          5: const pw.FlexColumnWidth(2.0),
          6: const pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '17',
            stage: 'Module Cleaning',
            inspectionType: 'Visual',
            parameters: 'Physical Verification',
            observation1: audit.cleaningOkOb1?.toString() ?? '',
            observation2: audit.cleaningOkOb2?.toString() ?? '',
            remarks: audit.cleaningOkRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage18Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(2.0),
          5: const pw.FlexColumnWidth(2.0),
          6: const pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '18',
            stage: 'Hi-Pot Testing',
            inspectionType: 'Visual',
            parameters: 'Module Sr. No.',
            observation1: audit.hipotSerialNoOb1 ?? '',
            observation2: audit.hipotSerialNoOb2 ?? '',
            remarks: audit.hipotSerialNoRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'DCW',
            observation1: audit.dcwOb1?.toString() ?? '',
            observation2: audit.dcwOb2?.toString() ?? '',
            remarks: audit.dcwRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'IR',
            observation1: audit.irOb1?.toString() ?? '',
            observation2: audit.irOb2?.toString() ?? '',
            remarks: audit.irRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Ground Continuity',
            observation1: audit.groundContinuityOb1?.toString() ?? '',
            observation2: audit.groundContinuityOb2?.toString() ?? '',
            remarks: audit.groundContinuityRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage19Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(2.0),
          5: const pw.FlexColumnWidth(2.0),
          6: const pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '19',
            stage: 'Post-El Inspection',
            inspectionType: 'Visual',
            parameters: 'Module Sr. Number',
            observation1: audit.postElSerialNoOb1 ?? '',
            observation2: audit.postElSerialNoOb2 ?? '',
            remarks: audit.postElSerialNoRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Current',
            observation1: audit.postElCurrentOb1?.toString() ?? '',
            observation2: audit.postElCurrentOb2?.toString() ?? '',
            remarks: audit.postElCurrentRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Voltage',
            observation1: audit.postElVoltageOb1?.toString() ?? '',
            observation2: audit.postElVoltageOb2?.toString() ?? '',
            remarks: audit.postElVoltageRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'Defects (If Any)',
            observation1: audit.postElDefectsOb1 ?? '',
            observation2: audit.postElDefectsOb2 ?? '',
            remarks: audit.postElDefectsRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage20Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(2.0),
          5: const pw.FlexColumnWidth(2.0),
          6: const pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '20',
            stage: 'Sun Simulator',
            inspectionType: 'Visual',
            parameters: 'Sun Simulator Calibration',
            observation1: audit.calibrationDateOb1 ?? '',
            observation2: audit.calibrationDateOb2 ?? '',
            remarks: audit.calibrationDateRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Module Sr. No.',
            observation1: audit.sunSerialNoOb1 ?? '',
            observation2: audit.sunSerialNoOb2 ?? '',
            remarks: audit.sunSerialNoRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Module Power Output (W)',
            observation1: audit.modulePowerOb1?.toString() ?? '',
            observation2: audit.modulePowerOb2?.toString() ?? '',
            remarks: audit.modulePowerRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Isc (I)',
            observation1: audit.iscOb1?.toString() ?? '',
            observation2: audit.iscOb2?.toString() ?? '',
            remarks: audit.iscRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Voc (V)',
            observation1: audit.vocOb1?.toString() ?? '',
            observation2: audit.vocOb2?.toString() ?? '',
            remarks: audit.vocRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Imp (I)',
            observation1: audit.impOb1?.toString() ?? '',
            observation2: audit.impOb2?.toString() ?? '',
            remarks: audit.impRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Vmp (V)',
            observation1: audit.vmpOb1?.toString() ?? '',
            observation2: audit.vmpOb2?.toString() ?? '',
            remarks: audit.vmpRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Module Temp (°C)',
            observation1: audit.moduleTempOb1?.toString() ?? '',
            observation2: audit.moduleTempOb2?.toString() ?? '',
            remarks: audit.moduleTempRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Measurement',
            parameters: 'Module F.F & Effi.',
            observation1:
                'F.F.: ${audit.fillFactorOb1?.toString() ?? ''}   Effi.: ${audit.efficiencyOb1?.toString() ?? ''}',
            observation2:
                'F.F.: ${audit.fillFactorOb2?.toString() ?? ''}   Effi.: ${audit.efficiencyOb2?.toString() ?? ''}',
            remarks: audit.efficiencyRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: 'Visual',
            parameters: 'IV Curve (OK/NOK)',
            observation1: audit.ivCurveOkOb1?.toString() ?? '',
            observation2: audit.ivCurveOkOb2?.toString() ?? '',
            remarks: audit.ivCurveOkRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage21Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(2.0),
          5: const pw.FlexColumnWidth(2.0),
          6: const pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '21',
            stage: 'FQC',
            inspectionType: 'Visual',
            parameters: 'Visual Inspection of Module',
            observation1: audit.visualInspectionOb1?.toString() ?? '',
            observation2: audit.visualInspectionOb2?.toString() ?? '',
            remarks: audit.visualInspectionRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Fitment of JB Cover',
            observation1: audit.jbCoverFitmentOb1?.toString() ?? '',
            observation2: audit.jbCoverFitmentOb2?.toString() ?? '',
            remarks: audit.jbCoverFitmentRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Placement of Back label & Barcode (OK/NOK)',
            observation1: audit.labelPlacementOb1?.toString() ?? '',
            observation2: audit.labelPlacementOb2?.toString() ?? '',
            remarks: audit.labelPlacementRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Defect (If Any)',
            observation1: audit.fqcDefectsOb1 ?? '',
            observation2: audit.fqcDefectsOb2 ?? '',
            remarks: audit.fqcDefectsRemark ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage22Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(2.0),
          5: const pw.FlexColumnWidth(2.0),
          6: const pw.FlexColumnWidth(1.5),
        },
        children: [
          _buildDataRowPdf(
            srNo: '22',
            stage: 'Auto Sorter & Packing',
            inspectionType: 'Visual',
            parameters: 'Sorting Status',
            observation1: audit.sortingStatusOb1 ?? '',
            observation2: audit.sortingStatusOb2 ?? '',
            remarks: audit.sortingStatusRemark ?? '',
          ),
          _buildDataRowPdf(
            srNo: '',
            stage: '',
            inspectionType: '',
            parameters: 'Pallet & Box Condition',
            observation1: audit.palletConditionOb1 ?? '',
            observation2: audit.palletConditionOb2 ?? '',
            remarks: audit.palletConditionRemark ?? '',
          ),
        ],
      ),
    );
  }

  // do not delete this bracket
}
