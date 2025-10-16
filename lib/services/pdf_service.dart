import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/audit_model.dart';
import '../models/sheet_cutting_audit_model.dart';
import '../models/cell_cutting_audit_model.dart';
import '../models/framing_audit_model.dart';

class PdfService {
  static Future<pw.Document> generatePdf(AuditForm audit) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(audit),
              pw.SizedBox(height: 20),
              _buildAuditDetails(audit),
              pw.SizedBox(height: 20),
              _buildStageDetails(audit),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(AuditForm audit) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SOLAR PANEL AUDIT REPORT',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Serial Number: ${audit.serialNumber}'),
            pw.Text('Audit Date: ${audit.auditDate}'),
          ],
        ),
        pw.Container(width: 80, height: 80, child: pw.FlutterLogo()),
      ],
    );
  }

  static pw.Widget _buildAuditDetails(AuditForm audit) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Auditor Name'),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(audit.auditorName),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Verified By'),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(audit.verifiedBy),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildStageDetails(AuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Stage Details',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        // Add stage-specific details here
        _buildStageTable('Floor Conditions', [
          ['Pre-Lam Temperature', '${audit.preLamTempOb1}°C'],
          ['Lamination Temperature', '${audit.laminationTempOb1}°C'],
          ['Pre-Lam Humidity', '${audit.preLamHumidityOb1}%'],
        ]),
        // Continue for all stages...
      ],
    );
  }

  static pw.Widget _buildStageTable(String stageName, List<List<String>> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(stageName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Table(
          border: pw.TableBorder.all(),
          children: data.map((row) {
            return pw.TableRow(
              children: row.map((cell) {
                return pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(cell),
                );
              }).toList(),
            );
          }).toList(),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Generate PDF for Sheet Cutting Audit
  static Future<pw.Document> generateSheetCuttingPdf(
    SheetCuttingAuditForm audit,
    Uint8List? logoBytes,
  ) async {
    final pdf = pw.Document();
    final logo = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSheetCuttingHeader(audit, logo),
              pw.SizedBox(height: 20),
              _buildSheetCuttingDetails(audit),
              pw.SizedBox(height: 20),
              _buildSheetCuttingQualityAssessment(audit),
              pw.SizedBox(height: 20),
              _buildSheetCuttingFinalAssessment(audit),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildSheetCuttingHeader(
    SheetCuttingAuditForm audit,
    pw.ImageProvider? logo,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SHEET CUTTING AUDIT REPORT',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Serial Number: ${audit.serialNumber}'),
            pw.Text('Audit Date: ${audit.auditDate}'),
          ],
        ),
        logo != null
            ? pw.Container(width: 80, height: 80, child: pw.Image(logo))
            : pw.Container(width: 80, height: 80, child: pw.FlutterLogo()),
      ],
    );
  }

  static pw.Widget _buildSheetCuttingDetails(SheetCuttingAuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'General Information',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Auditor Name', audit.auditorName),
            _buildTableRow('Verified By', audit.verifiedBy),
            _buildTableRow('Shift', audit.shift),
            _buildTableRow('PO Number', audit.po),
            _buildTableRow('Module Type', audit.moduleType),
            _buildTableRow('Material Type', audit.materialType),
            _buildTableRow('Sheet Thickness', audit.sheetThickness),
            _buildTableRow('Cut Dimensions', audit.cutDimensions),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSheetCuttingQualityAssessment(
    SheetCuttingAuditForm audit,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Quality Assessment',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Edge Quality', audit.edgeQuality),
            _buildTableRow('Surface Finish', audit.surfaceFinish),
            _buildTableRow('Cut Accuracy', audit.cutAccuracy),
            _buildTableRow('Operator Name', audit.operatorName),
            _buildTableRow('Machine ID', audit.machineId),
            _buildTableRow('Batch Number', audit.batchNumber),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSheetCuttingFinalAssessment(
    SheetCuttingAuditForm audit,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Final Assessment',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Defect Count', audit.defectCount),
            _buildTableRow('Pass/Fail Status', audit.passFailStatus),
            _buildTableRow('Remarks', audit.remarks),
          ],
        ),
      ],
    );
  }

  // Generate PDF for Cell Cutting Audit
  static Future<pw.Document> generateCellCuttingPdf(
    CellCuttingAuditForm audit,
    Uint8List? logoBytes,
  ) async {
    final pdf = pw.Document();
    final logo = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildCellCuttingHeader(audit, logo),
              pw.SizedBox(height: 20),
              _buildCellCuttingDetails(audit),
              pw.SizedBox(height: 20),
              _buildCellCuttingQualityAssessment(audit),
              pw.SizedBox(height: 20),
              _buildCellCuttingFinalAssessment(audit),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildCellCuttingHeader(
    CellCuttingAuditForm audit,
    pw.ImageProvider? logo,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CELL CUTTING AUDIT REPORT',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Serial Number: ${audit.serialNumber}'),
            pw.Text('Audit Date: ${audit.auditDate}'),
          ],
        ),
        logo != null
            ? pw.Container(width: 80, height: 80, child: pw.Image(logo))
            : pw.Container(width: 80, height: 80, child: pw.FlutterLogo()),
      ],
    );
  }

  static pw.Widget _buildCellCuttingDetails(CellCuttingAuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'General Information',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Auditor Name', audit.auditorName),
            _buildTableRow('Verified By', audit.verifiedBy),
            _buildTableRow('Shift', audit.shift),
            _buildTableRow('PO Number', audit.po),
            _buildTableRow('Module Type', audit.moduleType),
            _buildTableRow('Cell Type', audit.cellType),
            _buildTableRow('Cell Efficiency', audit.cellEfficiency),
            _buildTableRow('Cell Dimensions', audit.cellDimensions),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCellCuttingQualityAssessment(
    CellCuttingAuditForm audit,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Quality Assessment',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Busbar Alignment', audit.busbarAlignment),
            _buildTableRow('Solder Quality', audit.solderQuality),
            _buildTableRow('Visual Inspection', audit.visualInspection),
            _buildTableRow('Electrical Output', audit.electricalOutput),
            _buildTableRow('Operator Name', audit.operatorName),
            _buildTableRow('Machine ID', audit.machineId),
            _buildTableRow('Batch Number', audit.batchNumber),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCellCuttingFinalAssessment(
    CellCuttingAuditForm audit,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Final Assessment',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Defect Count', audit.defectCount),
            _buildTableRow('Pass/Fail Status', audit.passFailStatus),
            _buildTableRow('Remarks', audit.remarks),
          ],
        ),
      ],
    );
  }

  // Generate PDF for Framing Audit
  static Future<pw.Document> generateFramingPdf(
    FramingAuditForm audit,
    Uint8List? logoBytes,
  ) async {
    final pdf = pw.Document();
    final logo = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildFramingHeader(audit, logo),
              pw.SizedBox(height: 20),
              _buildFramingDetails(audit),
              pw.SizedBox(height: 20),
              _buildFramingQualityAssessment(audit),
              pw.SizedBox(height: 20),
              _buildFramingFinalAssessment(audit),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildFramingHeader(
    FramingAuditForm audit,
    pw.ImageProvider? logo,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FRAMING AUDIT REPORT',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Serial Number: ${audit.serialNumber}'),
            pw.Text('Audit Date: ${audit.auditDate}'),
          ],
        ),
        logo != null
            ? pw.Container(width: 80, height: 80, child: pw.Image(logo))
            : pw.Container(width: 80, height: 80, child: pw.FlutterLogo()),
      ],
    );
  }

  static pw.Widget _buildFramingDetails(FramingAuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'General Information',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Auditor Name', audit.auditorName),
            _buildTableRow('Verified By', audit.verifiedBy),
            _buildTableRow('Shift', audit.shift),
            _buildTableRow('PO Number', audit.po),
            _buildTableRow('Module Type', audit.moduleType),
            _buildTableRow('Frame Type', audit.frameType),
            _buildTableRow('Frame Material', audit.frameMaterial),
            _buildTableRow('Frame Dimensions', audit.frameDimensions),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFramingQualityAssessment(FramingAuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Quality Assessment',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Corner Joint Quality', audit.cornerJointQuality),
            _buildTableRow('Sealant Application', audit.sealantApplication),
            _buildTableRow('Frame Flatness', audit.frameFlatness),
            _buildTableRow(
              'Mounting Hole Alignment',
              audit.mountingHoleAlignment,
            ),
            _buildTableRow(
              'Grounding Hole Quality',
              audit.groundingHoleQuality,
            ),
            _buildTableRow('Surface Finish', audit.surfaceFinish),
            _buildTableRow('Visual Inspection', audit.visualInspection),
            _buildTableRow('Dimensional Accuracy', audit.dimensionalAccuracy),
            _buildTableRow('Operator Name', audit.operatorName),
            _buildTableRow('Machine ID', audit.machineId),
            _buildTableRow('Batch Number', audit.batchNumber),
            _buildTableRow('Torque Readings', audit.torqueReadings),
            _buildTableRow('Sealant Batch Number', audit.sealantBatchNumber),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFramingFinalAssessment(FramingAuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Final Assessment',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Defect Count', audit.defectCount),
            _buildTableRow('Pass/Fail Status', audit.passFailStatus),
            _buildTableRow('Remarks', audit.remarks),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(label)),
        pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(value)),
      ],
    );
  }
}
