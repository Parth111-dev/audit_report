import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/audit_model.dart';

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
}
