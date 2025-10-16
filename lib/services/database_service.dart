import 'package:final_audit/models/cell_cutting_audit_model.dart';
import 'package:final_audit/models/framing_audit_model.dart';
import 'package:final_audit/models/sheet_cutting_audit_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/material.dart';
import '../models/audit_model.dart';
import '../models/base_audit_model.dart';
import '../models/audit_form_factory.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for filtering periods
enum FilterPeriod { all, today, thisWeek, thisMonth, custom }

// Enum for connection types
enum ConnectionType { local, cloud }

class DatabaseService with ChangeNotifier {
  Db? _db;
  DbCollection? _auditsCollection;
  bool _isConnected = false;
  ConnectionType _currentConnectionType = ConnectionType.cloud;

  // Local MongoDB server configuration
  // This should be the IP address of your MongoDB server on your local network
  // Default MongoDB port is 27017
  static const String _localMongoHost =
      "192.168.1.100"; // Change this to your local MongoDB server IP
  static const int _localMongoPort = 27017;
  static const String _localMongoUser =
      "audituser"; // Change to your local MongoDB username
  static const String _localMongoPassword =
      "auditpassword"; // Change to your local MongoDB password
  static const String _localMongoDbName = "audit";

  // Cloud MongoDB configuration (MongoDB Atlas)
  static const String _cloudConnectionString =
      "mongodb://parthpatel685075_db_user:audit@ac-kgznvdl-shard-00-00.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-01.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-02.vyn7zkv.mongodb.net:27017/audit?ssl=true&replicaSet=atlas-5bfpso-shard-0&authSource=admin&retryWrites=true&w=majority";

  // Get the connection string based on the current connection type
  String get _connectionString {
    switch (_currentConnectionType) {
      case ConnectionType.local:
        return "mongodb://$_localMongoUser:$_localMongoPassword@$_localMongoHost:$_localMongoPort/$_localMongoDbName";
      case ConnectionType.cloud:
        return _cloudConnectionString;
    }
  }

  // Check if we're on a local network that can access our local MongoDB server
  Future<bool> _isOnLocalNetwork() async {
    try {
      // First check if we have a network connection
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // If we're on WiFi or Ethernet, try to ping the local MongoDB server
      if (connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.ethernet) {
        // Try to connect to the local MongoDB server with a short timeout
        final socket = await Socket.connect(
          _localMongoHost,
          _localMongoPort,
          timeout: Duration(seconds: 2),
        );
        socket.destroy();
        return true;
      }

      return false;
    } catch (e) {
      print('Not on local network or local MongoDB server not available: $e');
      return false;
    }
  }

  // Get the user's preferred connection type from shared preferences
  Future<ConnectionType> _getPreferredConnectionType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferLocalConnection =
          prefs.getBool('preferLocalConnection') ?? false;
      return preferLocalConnection
          ? ConnectionType.local
          : ConnectionType.cloud;
    } catch (e) {
      print('Error getting preferred connection type: $e');
      return ConnectionType.cloud; // Default to cloud if there's an error
    }
  }

  // Set the user's preferred connection type
  Future<void> setPreferredConnectionType(ConnectionType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        'preferLocalConnection',
        type == ConnectionType.local,
      );
      // Reconnect with the new connection type
      await disconnect();
      _currentConnectionType = type;
      await connect();
    } catch (e) {
      print('Error setting preferred connection type: $e');
    }
  }

  Future<void> connect() async {
    // Maximum number of connection attempts
    const int maxRetries = 3;
    int retryCount = 0;

    // Determine which connection type to use
    final preferredConnectionType = await _getPreferredConnectionType();
    final isOnLocalNetwork = await _isOnLocalNetwork();

    // Use local connection if preferred and available, otherwise use cloud
    _currentConnectionType =
        (preferredConnectionType == ConnectionType.local && isOnLocalNetwork)
        ? ConnectionType.local
        : ConnectionType.cloud;

    print(
      'Using ${_currentConnectionType == ConnectionType.local ? "LOCAL" : "CLOUD"} MongoDB connection',
    );

    while (retryCount < maxRetries) {
      try {
        // Close any existing connection before creating a new one
        if (_db != null) {
          await _db!.close();
        }

        // Create a new database connection with the appropriate connection string
        _db = Db(_connectionString);

        print(
          'Connecting to MongoDB (${_currentConnectionType.toString().split('.').last})... (Attempt ${retryCount + 1}/$maxRetries)',
        );
        await _db!.open();
        _auditsCollection = _db!.collection('audits');
        _isConnected = true;
        print(
          '✅ MongoDB Connected successfully to ${_currentConnectionType.toString().split('.').last} server',
        );
        return; // Connection successful, exit the function
      } catch (e) {
        retryCount++;
        print(
          '❌ MongoDB Connection Failed (Attempt $retryCount/$maxRetries): $e',
        );
        print('Error details: ${e.toString()}');

        // If local connection failed, try cloud connection
        if (_currentConnectionType == ConnectionType.local && retryCount == 1) {
          print('Local connection failed, trying cloud connection...');
          _currentConnectionType = ConnectionType.cloud;
          continue; // Skip the wait and retry immediately with cloud connection
        }

        if (retryCount >= maxRetries) {
          print(
            '⚠️ Maximum connection attempts reached. Please check your network connection and MongoDB settings.',
          );
          _isConnected = false;
        } else {
          // Wait before retrying (exponential backoff)
          final waitTime = Duration(seconds: retryCount * 2);
          print('Retrying in ${waitTime.inSeconds} seconds...');
          await Future.delayed(waitTime);
        }
      }
    }
  }

  Future<void> saveAudit(dynamic audit) async {
    if (!_isConnected) await connect();

    try {
      // Handle AuditForm, BaseAuditForm, and Map<String, dynamic> types
      Map<String, dynamic> dataToInsert;
      String serialNumber;

      if (audit is AuditForm) {
        dataToInsert = audit.toJson();
        serialNumber = audit.serialNumber;
      } else if (audit is BaseAuditForm) {
        dataToInsert = audit.toMap();
        serialNumber = audit.serialNumber;
      } else if (audit is Map<String, dynamic>) {
        dataToInsert = audit;
        serialNumber = audit['serialNumber'] ?? 'Unknown';
      } else {
        throw Exception('Unsupported audit type: ${audit.runtimeType}');
      }

      await _auditsCollection!.insert(dataToInsert);
      notifyListeners(); // This will refresh the dashboard
      print('✅ Audit saved: $serialNumber');
    } catch (e) {
      print('❌ Error saving audit: $e');
      throw Exception('Failed to save audit: $e');
    }
  }

  // Get audits by form type
  Future<List<dynamic>> getAuditsByFormType(String formType) async {
    if (!_isConnected) await connect();

    try {
      final query = formType == 'all' ? {} : {'formType': formType};
      final data = await _auditsCollection!.find(query).toList();
      final audits = data.map((item) => _createAuditFromMap(item)).toList();

      // Sort by date (newest first)
      audits.sort((a, b) {
        String aDate = '';
        String bDate = '';

        if (a is BaseAuditForm) {
          aDate = a.auditDate;
        } else if (a is AuditForm) {
          aDate = a.auditDate;
        }

        if (b is BaseAuditForm) {
          bDate = b.auditDate;
        } else if (b is AuditForm) {
          bDate = b.auditDate;
        }

        return bDate.compareTo(aDate);
      });
      print('✅ Fetched ${audits.length} audits with formType: $formType');
      return audits;
    } catch (e) {
      print('❌ Error getting audits by form type: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAudits() async {
    if (!_isConnected) await connect();

    try {
      final data = await _auditsCollection!.find().toList();
      final audits = data.map((item) => _createAuditFromMap(item)).toList();

      // Sort by date (newest first)
      audits.sort((a, b) {
        String aDate = '';
        String bDate = '';

        if (a is BaseAuditForm) {
          aDate = a.auditDate;
        } else if (a is AuditForm) {
          aDate = a.auditDate;
        }

        if (b is BaseAuditForm) {
          bDate = b.auditDate;
        } else if (b is AuditForm) {
          bDate = b.auditDate;
        }

        return bDate.compareTo(aDate);
      });
      print('✅ Fetched ${audits.length} audits');
      return audits;
    } catch (e) {
      print('❌ Error getting audits: $e');
      return [];
    }
  }

  Future<List<dynamic>> getRecentAudits(int limit) async {
    final allAudits = await getAudits();
    return allAudits.take(limit).toList();
  }

  Future<Map<String, int>> getAuditStatistics() async {
    final allAudits = await getAudits();

    // Get today's audits
    final todayAudits = _filterAuditsByDate(allAudits, FilterPeriod.today);

    // Get this week's audits
    final thisWeekAudits = _filterAuditsByDate(
      allAudits,
      FilterPeriod.thisWeek,
    );

    // Get this month's audits
    final thisMonthAudits = _filterAuditsByDate(
      allAudits,
      FilterPeriod.thisMonth,
    );

    // Get pending verification count
    final pendingVerification = allAudits
        .where((audit) => audit.verifiedBy.isEmpty)
        .length;

    // Get counts by report type
    final sheetCuttingAudits = allAudits
        .where((audit) => audit.moduleType == 'Sheet Cutting')
        .length;

    final cellCuttingAudits = allAudits
        .where((audit) => audit.moduleType == 'Cell Cutting')
        .length;

    final framingAudits = allAudits
        .where((audit) => audit.moduleType == 'Framing')
        .length;

    return {
      'total': allAudits.length,
      'today': todayAudits.length,
      'thisWeek': thisWeekAudits.length,
      'thisMonth': thisMonthAudits.length,
      'pendingVerification': pendingVerification,
      'sheetCutting': sheetCuttingAudits,
      'cellCutting': cellCuttingAudits,
      'framing': framingAudits,
    };
  }

  // Filter audits by date period
  List<dynamic> _filterAuditsByDate(
    List<dynamic> audits,
    FilterPeriod period, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return audits.where((audit) {
      try {
        // Parse the createdAt date
        final createdAt = DateTime.parse(audit.createdAt);

        switch (period) {
          case FilterPeriod.today:
            // Check if the audit was created today
            final auditDate = DateTime(
              createdAt.year,
              createdAt.month,
              createdAt.day,
            );
            return auditDate.isAtSameMomentAs(today);

          case FilterPeriod.thisWeek:
            // Check if the audit was created this week
            // Get the start of the week (Monday)
            final startOfWeek = today.subtract(
              Duration(days: today.weekday - 1),
            );
            return createdAt.isAfter(
              startOfWeek.subtract(Duration(seconds: 1)),
            );

          case FilterPeriod.thisMonth:
            // Check if the audit was created this month
            final startOfMonth = DateTime(now.year, now.month, 1);
            return createdAt.isAfter(
              startOfMonth.subtract(Duration(seconds: 1)),
            );

          case FilterPeriod.custom:
            // Custom date range filter
            if (startDate != null && endDate != null) {
              // Add one day to endDate to include the entire end day
              final adjustedEndDate = endDate.add(Duration(days: 1));
              return createdAt.isAfter(
                    startDate.subtract(Duration(seconds: 1)),
                  ) &&
                  createdAt.isBefore(adjustedEndDate);
            }
            return true;

          default:
            return true;
        }
      } catch (e) {
        print('❌ Error parsing date: ${audit.createdAt}');
        return false;
      }
    }).toList();
  }

  // Get filtered audits
  Future<List<dynamic>> getFilteredAudits(
    FilterPeriod period, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allAudits = await getAudits();
    return _filterAuditsByDate(
      allAudits,
      period,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Get audits by date range
  Future<List<dynamic>> getAuditsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allAudits = await getAudits();
    return _filterAuditsByDate(
      allAudits,
      FilterPeriod.custom,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Search audits by serial number
  Future<List<dynamic>> searchAudits(String query) async {
    final allAudits = await getAudits();
    if (query.isEmpty) {
      return allAudits;
    }

    // Convert query to lowercase for case-insensitive search
    final lowercaseQuery = query.toLowerCase();

    return allAudits.where((audit) {
      // Search in serial number
      final serialMatch = audit.serialNumber.toLowerCase().contains(
        lowercaseQuery,
      );

      // Search in auditor name
      final auditorMatch = audit.auditorName.toLowerCase().contains(
        lowercaseQuery,
      );

      // Search in module type
      final moduleMatch = audit.moduleType.toLowerCase().contains(
        lowercaseQuery,
      );

      return serialMatch || auditorMatch || moduleMatch;
    }).toList();
  }

  Future<void> updateAudit(dynamic audit) async {
    if (!_isConnected) await connect();

    try {
      // Step 1: Convert id to ObjectId safely
      late ObjectId objectId;
      dynamic auditId = audit is AuditForm
          ? audit.id
          : (audit is BaseAuditForm ? audit.id : null);

      if (auditId == null) {
        throw Exception('Invalid audit: missing ID');
      }

      if (auditId is String) {
        String cleanId = auditId
            .toString()
            .replaceAll('ObjectId("', '')
            .replaceAll('")', '')
            .replaceAll('ObjectId(', '')
            .replaceAll(')', '');
        objectId = ObjectId.fromHexString(cleanId);
      } else if (auditId is ObjectId) {
        objectId = auditId;
      } else {
        throw Exception('Invalid audit ID format');
      }

      // Step 2: Convert to JSON/Map and clean
      final updateData = audit is AuditForm
          ? audit.toJson()
          : (audit is BaseAuditForm
                ? audit.toMap()
                : (audit is Map<String, dynamic>
                      ? audit
                      : throw Exception('Unsupported audit type')));
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
        String serialNumber = '';
        String verifiedBy = '';

        if (audit is AuditForm) {
          serialNumber = audit.serialNumber;
          verifiedBy = audit.verifiedBy;
        } else if (audit is BaseAuditForm) {
          serialNumber = audit.serialNumber;
          verifiedBy = audit.verifiedBy;
        } else if (audit is Map<String, dynamic>) {
          serialNumber = audit['serialNumber'] ?? 'Unknown';
          verifiedBy = audit['verifiedBy'] ?? '';
        }

        print('✅ Audit updated successfully: $serialNumber');
        print('new verifyer: $verifiedBy');
      } else {
        print('⚠️ No document was modified. ID might not exist.');
        throw Exception('Audit not found or not modified');
      }
    } catch (e) {
      print('❌ Error updating audit: $e');
      throw Exception('Failed to update audit: $e');
    }
  }

  Future<bool> testConnection({ConnectionType? type}) async {
    try {
      // Use the specified connection type or the current one
      final connectionType = type ?? _currentConnectionType;
      String connectionString;

      // Get the appropriate connection string
      if (connectionType == ConnectionType.local) {
        connectionString =
            "mongodb://$_localMongoUser:$_localMongoPassword@$_localMongoHost:$_localMongoPort/$_localMongoDbName";
      } else {
        connectionString = _cloudConnectionString;
      }

      print(
        'Testing connection to ${connectionType.toString().split('.').last} MongoDB...',
      );
      final testDb = Db(connectionString);
      await testDb.open();

      // Try a simple operation
      final collections = await testDb.getCollectionNames();
      print('Available collections: $collections');

      // Close the test connection
      await testDb.close();

      print(
        '✅ Connection test successful for ${connectionType.toString().split('.').last} MongoDB',
      );
      return true;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // Test both connection types and return the results
  Future<Map<ConnectionType, bool>> testBothConnections() async {
    final localResult = await testConnection(type: ConnectionType.local);
    final cloudResult = await testConnection(type: ConnectionType.cloud);

    return {
      ConnectionType.local: localResult,
      ConnectionType.cloud: cloudResult,
    };
  }

  Future<void> disconnect() async {
    if (_db != null) await _db!.close();
    _isConnected = false;
  }

  // Get the current connection status
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected,
      'connectionType': _currentConnectionType,
      'serverAddress': _currentConnectionType == ConnectionType.local
          ? _localMongoHost
          : 'MongoDB Atlas Cloud',
    };
  }

  // Toggle between local and cloud connection
  Future<void> toggleConnectionType() async {
    final newType = _currentConnectionType == ConnectionType.local
        ? ConnectionType.cloud
        : ConnectionType.local;

    await setPreferredConnectionType(newType);
    notifyListeners();
  }

  // Add this method to create appropriate audit form types based on serial number
  Object _createAuditFromMap(Map<String, dynamic> map) {
    final serialNumber = map['serialNumber']?.toString() ?? '';
    
    // Add debugging to see what data we're getting from database
    print('🔍 Database data for ${serialNumber}: ${map.keys.toList()}');
    print('🔍 Sample values: serialNumber=${map['serialNumber']}, auditDate=${map['auditDate']}, createdAt=${map['createdAt']}');

    try {
      if (serialNumber.startsWith('SC-')) {
        return SheetCuttingAuditForm.fromMap(map);
      } else if (serialNumber.startsWith('CC-')) {
        return CellCuttingAuditForm.fromMap(map);
      } else if (serialNumber.startsWith('FR-')) {
        return FramingAuditForm.fromMap(map);
      } else {
        return AuditForm.fromJson(map);
      }
    } catch (e) {
      print('❌ Error creating audit from map: $e');
      print('❌ Map data: $map');
      rethrow;
    }
  }

  // Add method to get specific audit by ID
  Future<dynamic> getAuditById(String id) async {
    if (!_isConnected) await connect();

    try {
      // Step 1: Convert id to ObjectId safely
      late ObjectId objectId;
      String cleanId = id
          .toString()
          .replaceAll('ObjectId("', '')
          .replaceAll('")', '')
          .replaceAll('ObjectId(', '')
          .replaceAll(')', '');
      objectId = ObjectId.fromHexString(cleanId);

      final data = await _auditsCollection!.findOne(where.id(objectId));

      if (data != null) {
        return _createAuditFromMap(data);
      } else {
        throw Exception('Audit not found');
      }
    } catch (e) {
      print('❌ Error getting audit by ID: $e');
      throw Exception('Failed to get audit: $e');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
