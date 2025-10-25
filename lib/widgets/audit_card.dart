import 'package:flutter/material.dart';
import '../models/audit_model.dart';

class AuditCard extends StatelessWidget {
  final AuditForm audit;

  const AuditCard({Key? key, required this.audit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  audit.serialNumber,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Auditor: ${audit.auditorName}'),
            SizedBox(height: 4),
            Text('Date: ${audit.auditDate}'),
            SizedBox(height: 4),
            Text('Verified by: ${audit.verifiedBy}'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, size: 20),
                  onPressed: () {
                    // Generate PDF
                  },
                ),
                IconButton(
                  icon: Icon(Icons.print, size: 20),
                  onPressed: () {
                    // Print
                  },
                ),
                IconButton(
                  icon: Icon(Icons.visibility, size: 20),
                  onPressed: () {
                    // View details
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
