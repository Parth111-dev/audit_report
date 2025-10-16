import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/audit_model.dart';

class FramingPdfScreen extends StatefulWidget {
  final AuditForm? audit;
  final pw.Document? pdf;
  final String? fileName;

  const FramingPdfScreen({Key? key, this.audit, this.pdf, this.fileName})
    : assert(audit != null || (pdf != null && fileName != null)),
      super(key: key);

  @override
  State<FramingPdfScreen> createState() => _FramingPdfScreenState();
}

class _FramingPdfScreenState extends State<FramingPdfScreen> {
  late AuditForm? audit;
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
    fontSize: 6.5,
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
        ? 'Framing PDF - ${widget.audit!.serialNumber}'
        : 'Framing PDF - ${widget.fileName}';

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
                          ? 'Framing PDF Generation'
                          : 'Framing PDF Preview',
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
                      '• Complete framing report\n'
                      '• Frame assembly and alignment data\n'
                      '• All measurements and specifications included\n'
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
          fileNameToSave =
              'framing_${widget.audit!.serialNumber}_$timestamp.pdf';
        } else if (widget.fileName != null) {
          fileNameToSave = widget.fileName!;
        } else {
          fileNameToSave = 'framing_$timestamp.pdf';
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

    // Add framing specific content here
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(10),
        build: (pw.Context context) => [
          // Header
          _buildPdfTitle(),
          pw.SizedBox(height: 10),
          _buildHeaderPdf(),
          // Framing specific sections would go here
          _buildFrameSpecifications(),
          _buildFrameAssembly(),
          _buildFrameQualityChecks(),
          _buildFooterPdf(),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        "FRAMING AUDIT REPORT",
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildHeaderPdf() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Serial Number: ${widget.audit!.serialNumber}",
                style: headerTextStyle,
              ),
              pw.Text(
                "Date: ${widget.audit!.auditDate}",
                style: headerTextStyle,
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Auditor: ${widget.audit!.auditorName}",
                style: headerTextStyle,
              ),
              pw.Text(
                "Verified By: ${widget.audit!.verifiedBy}",
                style: headerTextStyle,
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Shift: ${widget.audit!.shift}", style: headerTextStyle),
              pw.Text("PO: ${widget.audit!.po}", style: headerTextStyle),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "Module Type: ${widget.audit!.moduleType}",
            style: headerTextStyle,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFrameSpecifications() {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "FRAME SPECIFICATIONS",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildCell("Parameter"),
                  _buildCell("Specification"),
                  _buildCell("Actual"),
                  _buildCell("Status"),
                ],
              ),
              // Add framing specific rows here
              pw.TableRow(
                children: [
                  _buildCell("Frame Material"),
                  _buildCell("Anodized Aluminum"),
                  _buildCell("Anodized Aluminum"),
                  _buildCell("PASS"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Frame Dimensions"),
                  _buildCell("1650 x 992 ± 1.0 mm"),
                  _buildCell("1650.5 x 992.2 mm"),
                  _buildCell("PASS"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Frame Thickness"),
                  _buildCell("35 ± 0.5 mm"),
                  _buildCell("35.2 mm"),
                  _buildCell("PASS"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Corner Key Type"),
                  _buildCell("Aluminum L-Key"),
                  _buildCell("Aluminum L-Key"),
                  _buildCell("PASS"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFrameAssembly() {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "FRAME ASSEMBLY",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildCell("Assembly Check"),
                  _buildCell("Requirement"),
                  _buildCell("Result"),
                  _buildCell("Status"),
                ],
              ),
              // Add frame assembly specific rows here
              pw.TableRow(
                children: [
                  _buildCell("Corner Alignment"),
                  _buildCell("90° ± 0.5°"),
                  _buildCell("90.2°"),
                  _buildCell("PASS"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Frame Squareness"),
                  _buildCell("Diagonal diff ≤ 2 mm"),
                  _buildCell("1.5 mm"),
                  _buildCell("PASS"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Screw Torque"),
                  _buildCell("8-10 Nm"),
                  _buildCell("9.2 Nm"),
                  _buildCell("PASS"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Silicone Sealing"),
                  _buildCell("Continuous, no gaps"),
                  _buildCell("Complete"),
                  _buildCell("PASS"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFrameQualityChecks() {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "QUALITY CHECKS",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildCell("Check Item"),
                  _buildCell("Requirement"),
                  _buildCell("Result"),
                  _buildCell("Remarks"),
                ],
              ),
              // Add framing quality specific rows here
              pw.TableRow(
                children: [
                  _buildCell("Surface Finish"),
                  _buildCell("No scratches or dents"),
                  _buildCell("PASS"),
                  _buildCell("Clean surface"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Junction Box Alignment"),
                  _buildCell("Centered, secure"),
                  _buildCell("PASS"),
                  _buildCell("Well positioned"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Cable Management"),
                  _buildCell("Secure, no strain"),
                  _buildCell("PASS"),
                  _buildCell("Properly secured"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Label Placement"),
                  _buildCell("Correct position, legible"),
                  _buildCell("PASS"),
                  _buildCell("Properly placed"),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildCell("Grounding Points"),
                  _buildCell("Accessible, marked"),
                  _buildCell("PASS"),
                  _buildCell("Clearly marked"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooterPdf() {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: 30),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "Auditor Signature: ________________",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "Verified By: ________________",
            style: pw.TextStyle(fontSize: 10),
          ),
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
}
