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
              pw.SizedBox(height: 10),
              _buildDocumentInfo(),
              pw.SizedBox(height: 20),
              _buildSheetCuttingDetails(audit),
              pw.SizedBox(height: 20),
              _buildSheetCuttingTimeEntries(audit),
              pw.SizedBox(height: 20),
              _buildSheetCuttingFooter(audit),
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
              'PAHAL SOLAR - SHEET CUTTING AUDIT REPORT',
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
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSheetCuttingTimeEntries(SheetCuttingAuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Sheet Cutting Time Entries',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),

        // 8 AM Entries
        if (audit.eightAMevaMake != null || audit.eightAMevaFront != null)
          _buildTimeEntryTable('8:00 AM', [
            ['EVA Make', audit.eightAMevaMake ?? ''],
            ['EVA Front', audit.eightAMevaFront ?? ''],
            ['EVA Back', audit.eightAMevaBack ?? ''],
            ['PO No', audit.eightAMpoNo ?? ''],
            ['As Per PO', audit.eightAMasPrPo ?? ''],
            ['Dimension Front', audit.eightAMdimensionFront ?? ''],
            ['Dimension Back', audit.eightAMdimensionBack ?? ''],
            ['Visual Check', audit.eightAMvisualCheck ?? ''],
            ['Defect', audit.eightAMdefect ?? ''],
            ['Remark', audit.eightAMremark ?? ''],
            ['Checked By', audit.eightAMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 10 AM Entries
        if (audit.tenAMevaMake != null || audit.tenAMevaFront != null)
          _buildTimeEntryTable('10:00 AM', [
            ['EVA Make', audit.tenAMevaMake ?? ''],
            ['EVA Front', audit.tenAMevaFront ?? ''],
            ['EVA Back', audit.tenAMevaBack ?? ''],
            ['PO No', audit.tenAMpoNo ?? ''],
            ['As Per PO', audit.tenAMasPrPo ?? ''],
            ['Dimension Front', audit.tenAMdimensionFront ?? ''],
            ['Dimension Back', audit.tenAMdimensionBack ?? ''],
            ['Visual Check', audit.tenAMvisualCheck ?? ''],
            ['Defect', audit.tenAMdefect ?? ''],
            ['Remark', audit.tenAMremark ?? ''],
            ['Checked By', audit.tenAMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 12 PM Entries
        if (audit.twelvePMevaMake != null || audit.twelvePMevaFront != null)
          _buildTimeEntryTable('12:00 PM', [
            ['EVA Make', audit.twelvePMevaMake ?? ''],
            ['EVA Front', audit.twelvePMevaFront ?? ''],
            ['EVA Back', audit.twelvePMevaBack ?? ''],
            ['PO No', audit.twelvePMpoNo ?? ''],
            ['As Per PO', audit.twelvePMasPrPo ?? ''],
            ['Dimension Front', audit.twelvePMdimensionFront ?? ''],
            ['Dimension Back', audit.twelvePMdimensionBack ?? ''],
            ['Visual Check', audit.twelvePMvisualCheck ?? ''],
            ['Defect', audit.twelvePMdefect ?? ''],
            ['Remark', audit.twelvePMremark ?? ''],
            ['Checked By', audit.twelvePMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 2 PM Entries
        if (audit.twoPMevaMake != null || audit.twoPMevaFront != null)
          _buildTimeEntryTable('2:00 PM', [
            ['EVA Make', audit.twoPMevaMake ?? ''],
            ['EVA Front', audit.twoPMevaFront ?? ''],
            ['EVA Back', audit.twoPMevaBack ?? ''],
            ['PO No', audit.twoPMpoNo ?? ''],
            ['As Per PO', audit.twoPMasPrPo ?? ''],
            ['Dimension Front', audit.twoPMdimensionFront ?? ''],
            ['Dimension Back', audit.twoPMdimensionBack ?? ''],
            ['Visual Check', audit.twoPMvisualCheck ?? ''],
            ['Defect', audit.twoPMdefect ?? ''],
            ['Remark', audit.twoPMremark ?? ''],
            ['Checked By', audit.twoPMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 4 PM Entries
        if (audit.fourPMevaMake != null || audit.fourPMevaFront != null)
          _buildTimeEntryTable('4:00 PM', [
            ['EVA Make', audit.fourPMevaMake ?? ''],
            ['EVA Front', audit.fourPMevaFront ?? ''],
            ['EVA Back', audit.fourPMevaBack ?? ''],
            ['PO No', audit.fourPMpoNo ?? ''],
            ['As Per PO', audit.fourPMasPrPo ?? ''],
            ['Dimension Front', audit.fourPMdimensionFront ?? ''],
            ['Dimension Back', audit.fourPMdimensionBack ?? ''],
            ['Visual Check', audit.fourPMvisualCheck ?? ''],
            ['Defect', audit.fourPMdefect ?? ''],
            ['Remark', audit.fourPMremark ?? ''],
            ['Checked By', audit.fourPMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 6 PM Entries
        if (audit.sixPMevaMake != null || audit.sixPMevaFront != null)
          _buildTimeEntryTable('6:00 PM', [
            ['EVA Make', audit.sixPMevaMake ?? ''],
            ['EVA Front', audit.sixPMevaFront ?? ''],
            ['EVA Back', audit.sixPMevaBack ?? ''],
            ['PO No', audit.sixPMpoNo ?? ''],
            ['As Per PO', audit.sixPMasPrPo ?? ''],
            ['Dimension Front', audit.sixPMdimensionFront ?? ''],
            ['Dimension Back', audit.sixPMdimensionBack ?? ''],
            ['Visual Check', audit.sixPMvisualCheck ?? ''],
            ['Defect', audit.sixPMdefect ?? ''],
            ['Remark', audit.sixPMremark ?? ''],
            ['Checked By', audit.sixPMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 8 PM Entries
        if (audit.eightPMevaMake != null || audit.eightPMevaFront != null)
          _buildTimeEntryTable('8:00 PM', [
            ['EVA Make', audit.eightPMevaMake ?? ''],
            ['EVA Front', audit.eightPMevaFront ?? ''],
            ['EVA Back', audit.eightPMevaBack ?? ''],
            ['PO No', audit.eightPMpoNo ?? ''],
            ['As Per PO', audit.eightPMasPrPo ?? ''],
            ['Dimension Front', audit.eightPMdimensionFront ?? ''],
            ['Dimension Back', audit.eightPMdimensionBack ?? ''],
            ['Visual Check', audit.eightPMvisualCheck ?? ''],
            ['Defect', audit.eightPMdefect ?? ''],
            ['Remark', audit.eightPMremark ?? ''],
            ['Checked By', audit.eightPMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 10 PM Entries
        if (audit.tenPMevaMake != null || audit.tenPMevaFront != null)
          _buildTimeEntryTable('10:00 PM', [
            ['EVA Make', audit.tenPMevaMake ?? ''],
            ['EVA Front', audit.tenPMevaFront ?? ''],
            ['EVA Back', audit.tenPMevaBack ?? ''],
            ['PO No', audit.tenPMpoNo ?? ''],
            ['As Per PO', audit.tenPMasPrPo ?? ''],
            ['Dimension Front', audit.tenPMdimensionFront ?? ''],
            ['Dimension Back', audit.tenPMdimensionBack ?? ''],
            ['Visual Check', audit.tenPMvisualCheck ?? ''],
            ['Defect', audit.tenPMdefect ?? ''],
            ['Remark', audit.tenPMremark ?? ''],
            ['Checked By', audit.tenPMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 12 AM Entries
        if (audit.twelveAMevaMake != null || audit.twelveAMevaFront != null)
          _buildTimeEntryTable('12:00 AM', [
            ['EVA Make', audit.twelveAMevaMake ?? ''],
            ['EVA Front', audit.twelveAMevaFront ?? ''],
            ['EVA Back', audit.twelveAMevaBack ?? ''],
            ['PO No', audit.twelveAMpoNo ?? ''],
            ['As Per PO', audit.twelveAMasPrPo ?? ''],
            ['Dimension Front', audit.twelveAMdimensionFront ?? ''],
            ['Dimension Back', audit.twelveAMdimensionBack ?? ''],
            ['Visual Check', audit.twelveAMvisualCheck ?? ''],
            ['Defect', audit.twelveAMdefect ?? ''],
            ['Remark', audit.twelveAMremark ?? ''],
            ['Checked By', audit.twelveAMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 2 AM Entries
        if (audit.twoAMevaMake != null || audit.twoAMevaFront != null)
          _buildTimeEntryTable('2:00 AM', [
            ['EVA Make', audit.twoAMevaMake ?? ''],
            ['EVA Front', audit.twoAMevaFront ?? ''],
            ['EVA Back', audit.twoAMevaBack ?? ''],
            ['PO No', audit.twoAMpoNo ?? ''],
            ['As Per PO', audit.twoAMasPrPo ?? ''],
            ['Dimension Front', audit.twoAMdimensionFront ?? ''],
            ['Dimension Back', audit.twoAMdimensionBack ?? ''],
            ['Visual Check', audit.twoAMvisualCheck ?? ''],
            ['Defect', audit.twoAMdefect ?? ''],
            ['Remark', audit.twoAMremark ?? ''],
            ['Checked By', audit.twoAMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 4 AM Entries
        if (audit.fourAMevaMake != null || audit.fourAMevaFront != null)
          _buildTimeEntryTable('4:00 AM', [
            ['EVA Make', audit.fourAMevaMake ?? ''],
            ['EVA Front', audit.fourAMevaFront ?? ''],
            ['EVA Back', audit.fourAMevaBack ?? ''],
            ['PO No', audit.fourAMpoNo ?? ''],
            ['As Per PO', audit.fourAMasPrPo ?? ''],
            ['Dimension Front', audit.fourAMdimensionFront ?? ''],
            ['Dimension Back', audit.fourAMdimensionBack ?? ''],
            ['Visual Check', audit.fourAMvisualCheck ?? ''],
            ['Defect', audit.fourAMdefect ?? ''],
            ['Remark', audit.fourAMremark ?? ''],
            ['Checked By', audit.fourAMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // 6 AM Entries
        if (audit.sixAMevaMake != null || audit.sixAMevaFront != null)
          _buildTimeEntryTable('6:00 AM', [
            ['EVA Make', audit.sixAMevaMake ?? ''],
            ['EVA Front', audit.sixAMevaFront ?? ''],
            ['EVA Back', audit.sixAMevaBack ?? ''],
            ['PO No', audit.sixAMpoNo ?? ''],
            ['As Per PO', audit.sixAMasPrPo ?? ''],
            ['Dimension Front', audit.sixAMdimensionFront ?? ''],
            ['Dimension Back', audit.sixAMdimensionBack ?? ''],
            ['Visual Check', audit.sixAMvisualCheck ?? ''],
            ['Defect', audit.sixAMdefect ?? ''],
            ['Remark', audit.sixAMremark ?? ''],
            ['Checked By', audit.sixAMcheckedBy ?? ''],
          ]),

        pw.SizedBox(height: 10),

        // Final Notes
        if (audit.remarks != null || audit.note != null)
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              if (audit.remarks != null)
                _buildTableRow('Remarkssssssss', audit.remarks ?? ''),
              if (audit.note != null) _buildTableRow('Notes', audit.note ?? ''),
              if (audit.qcInnspectorName != null)
                _buildTableRow('QC Inspector', audit.qcInnspectorName ?? ''),
              if (audit.preparedBy != null)
                _buildTableRow('Prepared By', audit.preparedBy ?? ''),
              if (audit.verifyBy != null)
                _buildTableRow('Verified By', audit.verifyBy ?? ''),
              if (audit.approvedBy != null)
                _buildTableRow('Approved By', audit.approvedBy ?? ''),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildTimeEntryTable(
    String timeLabel,
    List<List<String>> data,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(timeLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Table(
          border: pw.TableBorder.all(),
          children: data.map((row) {
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    row[0],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(row[1]),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildDocumentInfo() {
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
        color: PdfColors.grey100,
      ),
      padding: pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Doc No: IMS-FRM-PQC-002',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Effective Date: $formattedDate',
                style: pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Revision No: 01',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Page: 1/1', style: pw.TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSheetCuttingFooter(SheetCuttingAuditForm audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Additional Information',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            if (audit.date != null) _buildTableRow('Date', audit.date ?? ''),
            if (audit.line != null) _buildTableRow('Line', audit.line ?? ''),
            if (audit.remarks != null)
              _buildTableRow('Remarks', audit.remarks ?? ''),
            if (audit.note != null) _buildTableRow('Notes', audit.note ?? ''),
            if (audit.qcInnspectorName != null)
              _buildTableRow('QC Inspector', audit.qcInnspectorName ?? ''),
            if (audit.preparedBy != null)
              _buildTableRow('Prepared By', audit.preparedBy ?? ''),
            if (audit.verifyBy != null)
              _buildTableRow('Verified By', audit.verifyBy ?? ''),
            if (audit.approvedBy != null)
              _buildTableRow('Approved By', audit.approvedBy ?? ''),
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
