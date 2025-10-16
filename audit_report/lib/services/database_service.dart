import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/material.dart';
import '../models/audit_model.dart';

class DatabaseService with ChangeNotifier {
  Db? _db;
  DbCollection? _auditsCollection;
  bool _isConnected = false;

  Future<void> connect() async {
    try {
      // MongoDB Atlas connection - mongo_dart doesn't support mongodb+srv://
      // Using direct connection to Atlas cluster with resolved SRV records
      _db = Db(
        "mongodb://parthpatel685075_db_user:audit@ac-kgznvdl-shard-00-00.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-01.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-02.vyn7zkv.mongodb.net:27017/audit?ssl=true&replicaSet=atlas-5bfpso-shard-0&authSource=admin&retryWrites=true&w=majority",
      );

      print('DB: $_db');
      await _db!.open();
      _auditsCollection = _db!.collection('audits');
      _isConnected = true;
      print('✅ MongoDB Connected successfully');
    } catch (e) {
      print('❌ MongoDB Connection Failed: $e');
      _isConnected = false;
    }
  }

  Future<void> saveAudit(AuditForm audit) async {
    if (!_isConnected) await connect();

    try {
      await _auditsCollection!.insert(audit.toJson());
      notifyListeners(); // This will refresh the dashboard
      print('✅ Audit saved: ${audit.serialNumber}');
    } catch (e) {
      print('❌ Error saving audit: $e');
      throw Exception('Failed to save audit: $e');
    }
  }

  Future<List<AuditForm>> getAudits() async {
    if (!_isConnected) await connect();
    print('data: ${_auditsCollection!.find().toList()}');
    try {
      final data = await _auditsCollection!.find().toList();
      final audits = data.map((item) => AuditForm.fromJson(item)).toList();
      print('data: $data');
      print('audits: $audits');
      // Sort by date (newest first)
      audits.sort((a, b) => b.auditDate.compareTo(a.auditDate));
      print('✅ Fetched ${audits.length} audits');
      return audits;
    } catch (e) {
      print('${_auditsCollection}');
      print('❌ Error getting audits: $e');
      return [];
    }
  }

  Future<List<AuditForm>> getRecentAudits(int limit) async {
    final allAudits = await getAudits();
    return allAudits.take(limit).toList();
  }

  Future<Map<String, int>> getAuditStatistics() async {
    final allAudits = await getAudits();

    return {'total': allAudits.length};
  }

  Future<void> updateAudit(AuditForm audit) async {
    if (!_isConnected) await connect();

    try {
      // Step 1: Convert id to ObjectId safely
      late ObjectId objectId;
      if (audit.id is String) {
        String cleanId = audit.id
            .toString()
            .replaceAll('ObjectId("', '')
            .replaceAll('")', '')
            .replaceAll('ObjectId(', '')
            .replaceAll(')', '');
        objectId = ObjectId.fromHexString(cleanId);
      } else if (audit.id is ObjectId) {
        objectId = audit.id;
      } else {
        throw Exception('Invalid audit ID format');
      }

      // Step 2: Convert to JSON and clean
      final updateData = audit.toJson();
      updateData.remove('_id');

      // Step 3: Build modifier manually
      final modifier = modify;
      updateData.forEach((key, value) {
        modifier.set(key, value);
      });

      // Step 4: Update in MongoDB
      final result = await _auditsCollection!.updateOne(
        where.id(objectId),
        modifier,
      );

      // Step 5: Log result
      if (result.isSuccess) {
        print('✅ Audit updated successfully: ${audit.serialNumber}');
        print('new verifyer: ${audit.verifiedBy}');
      } else {
        print('⚠️ No document was modified. ID might not exist.');
        throw Exception('Audit not found or not modified');
      }
    } catch (e) {
      print('❌ Error updating audit: $e');
      throw Exception('Failed to update audit: $e');
    }
  }

  Future<void> disconnect() async {
    if (_db != null) await _db!.close();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
