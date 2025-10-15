// services/audit_service.dart
import 'package:flutter/foundation.dart';
import '../models/audit_model.dart';
import 'database_service.dart';

class AuditService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  Future<bool> updateAudit(AuditForm audit) async {
    try {
      await _databaseService.updateAudit(audit);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error updating audit: $e');
      return false;
    }
  }


  Future<AuditForm?> getAuditById(String id) async {
    try {
      final audits = await _databaseService.getAudits();
      return audits.firstWhere(
        (audit) => audit.id == id,
        orElse: () => throw Exception('Audit not found'),
      );
    } catch (e) {
      print('❌ Error fetching audit by ID: $e');
      return null;
    }
  }

  void disposeService() {
    // Future cleanup logic if needed
    super.dispose();
  }
}
