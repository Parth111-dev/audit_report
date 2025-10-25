import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/sheet_cutting_audit_model.dart';
import '../services/pdf_service.dart';

class SheetCuttingPdfScreen extends StatefulWidget {
  final SheetCuttingAuditForm? audit;
  final pw.Document? pdf;
  final String? fileName;

  const SheetCuttingPdfScreen({Key? key, this.audit, this.pdf, this.fileName})
    : assert(audit != null || (pdf != null && fileName != null)),
      super(key: key);

  @override
  State<SheetCuttingPdfScreen> createState() => _SheetCuttingPdfScreenState();
}

class _SheetCuttingPdfScreenState extends State<SheetCuttingPdfScreen> {
  late SheetCuttingAuditForm? audit;
  late pw.Document? pdfDocument;
  late String? fileName;
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
    fontSize: 8,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  @override
  void initState() {
    super.initState();
    audit = widget.audit;
    pdfDocument = widget.pdf;
    fileName = widget.fileName;
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
    final String title = widget.audit != null
        ? 'PDF Generator - ${widget.audit!.serialNumber}'
        : 'PDF Preview - ${widget.fileName}';

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.blue[700]),
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
                      widget.audit != null
                          ? 'Audit PDF Generation'
                          : 'PDF Preview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (widget.audit != null) ...[
                      Text(
                        'Serial Number: ${widget.audit!.serialNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Audit Date: ${widget.audit!.auditDate}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Auditor: ${widget.audit!.auditorName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Verified By: ${widget.audit!.verifiedBy}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else if (widget.fileName != null) ...[
                      Text(
                        'File Name: ${widget.fileName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Generated: ${DateTime.now().toString().substring(0, 16)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
      // Use existing PDF document or generate a new one
      final pdf = widget.pdf ?? pw.Document();

      // Add pages to PDF if we're generating a new one from audit data
      if (widget.audit != null && widget.pdf == null) {
        await _buildPdfContent(pdf);
      }

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
        final String fileNameToSave;

        if (widget.audit != null) {
          fileNameToSave = 'audit_${widget.audit!.serialNumber}_$timestamp.pdf';
        } else if (widget.fileName != null) {
          fileNameToSave = widget.fileName!;
        } else {
          fileNameToSave = 'audit_$timestamp.pdf';
        }

        final file = File('${downloadsDirectory.path}/$fileNameToSave');

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
    // This method is only called when we need to generate a PDF from audit data
    // If we already have a PDF document (widget.pdf), we don't need to call this method

    if (widget.audit == null) {
      // If there's no audit data, we can't build the PDF content
      return;
    }

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
          _buildStage6Pdf(),
          _buildStage7Pdf(),
          _buildStage8Pdf(),
          _buildStage9Pdf(),
          _buildStage10Pdf(),
          _buildStage11Pdf(),
          _buildStage12Pdf(),
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
    if (widget.audit == null) {
      // If there's no audit data, return a simple title
      return pw.Container(
        alignment: pw.Alignment.center,
        child: pw.Text(
          "PDF Preview",
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
      );
    }

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
                _buildCell('Date: ${widget.audit!.auditDate}'),
                _buildCell('Shift: ${widget.audit!.shift}'),
                _buildCell('PO: ${widget.audit!.po}'),
                _buildCell('Module Type & Watt: ${widget.audit!.moduleType}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildDataRowPdf({
    required String srNo,
    required String sampleObservedTime,
    required String EVA_MAKE_FRONT_BACK,
    required String EVA_TYPE_FRONT,
    required String EVA_TYPE_BACK,
    required String PO_NO,
    required String DIMENSION_FRONT,
    required String DIMENSION_BACK,
    required String VISUAL_CHECK_OK_NOK,
    required String DEFECTS_IF_ANY,
    required String REMARKS,
    required dynamic Checked_By, // String or pw.Widget
  }) {
    return pw.TableRow(
      children: [
        _buildDataCellPdf(
          pw.Center(child: pw.Text(srNo, style: tableCellTextStyle)),
        ),
        _buildDataCellPdf(
          pw.Text(sampleObservedTime, style: tableCellTextStyle),
        ),
        _buildDataCellPdf(
          pw.Center(
            child: pw.Text(EVA_MAKE_FRONT_BACK, style: tableCellTextStyle),
          ),
        ),
        _buildDataCellPdf(pw.Text(EVA_TYPE_FRONT, style: tableCellTextStyle)),
        _buildDataCellPdf(pw.Text(EVA_TYPE_BACK, style: tableCellTextStyle)),
        _buildDataCellPdf(pw.Text(PO_NO, style: tableCellTextStyle)),
        _buildDataCellPdf(pw.Text(DIMENSION_FRONT, style: tableCellTextStyle)),
        _buildDataCellPdf(pw.Text(DIMENSION_BACK, style: tableCellTextStyle)),
        _buildDataCellPdf(
          pw.Text(VISUAL_CHECK_OK_NOK, style: tableCellTextStyle),
        ),
        _buildDataCellPdf(pw.Text(DEFECTS_IF_ANY, style: tableCellTextStyle)),
        _buildDataCellPdf(pw.Text(REMARKS, style: tableCellTextStyle)),
        _buildDataCellPdf(_normalizeToWidget(Checked_By)),
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
    if (widget.audit == null) {
      // If there's no audit data, return an empty container
      return pw.Container();
    }

    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey300, // same as Colors.grey[300]
            ),
            children: [
              _buildHeaderCellPdf('Sr.No.'),
              _buildHeaderCellPdf('Sample Observed Time'),
              _buildHeaderCellPdf('EVA MAKE (FRONT&BACK)'),
              _buildHeaderCellPdf('EVA TYPE FRONT'),
              _buildHeaderCellPdf('EVA TYPE BACK'),
              _buildHeaderCellPdf('PO  NO.'),
              _buildHeaderCellPdf('DIMENSIONS (L x W) FRONT'),
              _buildHeaderCellPdf('DIMENSIONS (L x W) BACK'),
              _buildHeaderCellPdf('Visual Check(OK / NOK)'),
              _buildHeaderCellPdf('Defects (if any)'),
              _buildHeaderCellPdf('Remarks'),
              _buildHeaderCellPdf('Checked By'),
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
                  widget.audit!.auditorName ?? '',
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
                  widget.audit!.verifiedBy ?? '',
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
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '1',
            sampleObservedTime: '8:00 AM',
            EVA_MAKE_FRONT_BACK: widget.audit!.eightAMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.eightAMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.eightAMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.eightAMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.eightAMdimensionFront?.toString() ?? '',
            DIMENSION_BACK:
                widget.audit!.eightAMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.eightAMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.eightAMdefect?.toString() ?? '',
            REMARKS: widget.audit!.eightAMremark?.toString() ?? '',
            Checked_By: widget.audit!.eightAMcheckedBy?.toString() ?? '',
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
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '2',
            sampleObservedTime: '10:00 AM',
            EVA_MAKE_FRONT_BACK: widget.audit!.tenAMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.tenAMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.tenAMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.tenAMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.tenAMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.tenAMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.tenAMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.tenAMdefect?.toString() ?? '',
            REMARKS: widget.audit!.tenAMremark?.toString() ?? '',
            Checked_By: widget.audit!.tenAMcheckedBy?.toString() ?? '',
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
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '3',
            sampleObservedTime: '12:00 PM',
            EVA_MAKE_FRONT_BACK: widget.audit!.twelvePMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.twelvePMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.twelvePMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.twelvePMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.twelvePMdimensionFront?.toString() ?? '',
            DIMENSION_BACK:
                widget.audit!.twelvePMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.twelvePMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.twelvePMdefect?.toString() ?? '',
            REMARKS: widget.audit!.twelvePMremark?.toString() ?? '',
            Checked_By: widget.audit!.twelvePMcheckedBy?.toString() ?? '',
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
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '4',
            sampleObservedTime: '2:00 PM',
            EVA_MAKE_FRONT_BACK: widget.audit!.twoPMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.twoPMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.twoPMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.twoPMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.twoPMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.twoPMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.twoPMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.twoPMdefect?.toString() ?? '',
            REMARKS: widget.audit!.twoPMremark?.toString() ?? '',
            Checked_By: widget.audit!.twoPMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage5Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '5',
            sampleObservedTime: '4:00 PM',
            EVA_MAKE_FRONT_BACK: widget.audit!.fourPMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.fourPMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.fourPMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.fourPMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.fourPMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.fourPMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.fourPMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.fourPMdefect?.toString() ?? '',
            REMARKS: widget.audit!.fourPMremark?.toString() ?? '',
            Checked_By: widget.audit!.fourPMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage6Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '6',
            sampleObservedTime: '6:00 PM',
            EVA_MAKE_FRONT_BACK: widget.audit!.sixPMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.sixPMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.sixPMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.sixPMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.sixPMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.sixPMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.sixPMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.sixPMdefect?.toString() ?? '',
            REMARKS: widget.audit!.sixPMremark?.toString() ?? '',
            Checked_By: widget.audit!.sixPMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage7Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '7',
            sampleObservedTime: '8:00 PM',
            EVA_MAKE_FRONT_BACK: widget.audit!.eightPMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.eightPMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.eightPMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.eightPMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.eightPMdimensionFront?.toString() ?? '',
            DIMENSION_BACK:
                widget.audit!.eightPMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.eightPMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.eightPMdefect?.toString() ?? '',
            REMARKS: widget.audit!.eightPMremark?.toString() ?? '',
            Checked_By: widget.audit!.eightPMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage8Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '8',
            sampleObservedTime: '10:00 PM',
            EVA_MAKE_FRONT_BACK: widget.audit!.tenPMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.tenPMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.tenPMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.tenPMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.tenPMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.tenPMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.tenPMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.tenPMdefect?.toString() ?? '',
            REMARKS: widget.audit!.tenPMremark?.toString() ?? '',
            Checked_By: widget.audit!.tenPMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage9Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '9',
            sampleObservedTime: '12:00 AM',
            EVA_MAKE_FRONT_BACK: widget.audit!.twelveAMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.twelveAMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.twelveAMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.twelveAMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.twelveAMdimensionFront?.toString() ?? '',
            DIMENSION_BACK:
                widget.audit!.twelveAMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.twelveAMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.twelveAMdefect?.toString() ?? '',
            REMARKS: widget.audit!.twelveAMremark?.toString() ?? '',
            Checked_By: widget.audit!.twelveAMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage10Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '10',
            sampleObservedTime: '2:00 AM',
            EVA_MAKE_FRONT_BACK: widget.audit!.twoAMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.twoAMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.twoAMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.twoAMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.twoAMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.twoAMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.twoAMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.twoAMdefect?.toString() ?? '',
            REMARKS: widget.audit!.twoAMremark?.toString() ?? '',
            Checked_By: widget.audit!.twoAMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage11Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '11',
            sampleObservedTime: '4:00 AM',
            EVA_MAKE_FRONT_BACK: widget.audit!.fourAMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.fourAMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.fourAMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.fourAMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.fourAMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.fourAMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.fourAMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.fourAMdefect?.toString() ?? '',
            REMARKS: widget.audit!.fourAMremark?.toString() ?? '',
            Checked_By: widget.audit!.fourAMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStage12Pdf() {
    return pw.Container(
      width: double.infinity,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(1.0),
          2: pw.FlexColumnWidth(2.5),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(2.0),
          5: pw.FlexColumnWidth(0.8),
          6: pw.FlexColumnWidth(2.0),
          7: pw.FlexColumnWidth(2.0),
          8: pw.FlexColumnWidth(1.0),
          9: pw.FlexColumnWidth(1.5),
          10: pw.FlexColumnWidth(1.5),
          11: pw.FlexColumnWidth(1.8),
        },
        children: [
          _buildDataRowPdf(
            srNo: '12',
            sampleObservedTime: '6:00 AM',
            EVA_MAKE_FRONT_BACK: widget.audit!.sixAMevaMake ?? '',
            EVA_TYPE_FRONT: widget.audit!.sixAMevaFront ?? '',
            EVA_TYPE_BACK: widget.audit!.sixAMevaBack?.toString() ?? '',
            PO_NO: widget.audit!.sixAMpoNo?.toString() ?? '',
            DIMENSION_FRONT:
                widget.audit!.sixAMdimensionFront?.toString() ?? '',
            DIMENSION_BACK: widget.audit!.sixAMdimensionBack?.toString() ?? '',
            VISUAL_CHECK_OK_NOK:
                widget.audit!.sixAMvisualCheck?.toString() ?? '',
            DEFECTS_IF_ANY: widget.audit!.sixAMdefect?.toString() ?? '',
            REMARKS: widget.audit!.sixAMremark?.toString() ?? '',
            Checked_By: widget.audit!.sixAMcheckedBy?.toString() ?? '',
          ),
        ],
      ),
    );
  }
}
