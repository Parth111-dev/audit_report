import 'package:final_audit/models/base_audit_model.dart';
import 'package:final_audit/screens/cell_cutting_form_screen.dart';
import 'package:final_audit/screens/framing_form_screen.dart';
import 'package:final_audit/screens/sheet_cutting_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audit_model.dart';
import '../models/sheet_cutting_audit_model.dart';
import '../models/cell_cutting_audit_model.dart';
import '../models/framing_audit_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'audit_form_screen.dart';
import 'audit_detail_screen.dart';
import 'sheet_cutting_detail_screen.dart';
import 'cell_cutting_detail_screen.dart';
import 'framing_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> _auditsFuture;
  late Future<Map<String, int>> _statsFuture;
  FilterPeriod _currentFilter = FilterPeriod.all;
  String _filterLabel = "All Reports";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Date range filter
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isDateRangeActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );
    setState(() {
      if (_searchQuery.isNotEmpty) {
        // If there's a search query, use search function
        _auditsFuture = databaseService.searchAudits(_searchQuery);
      } else if (_isDateRangeActive && _startDate != null && _endDate != null) {
        // If date range is active, use date range filter
        _auditsFuture = databaseService.getAuditsByDateRange(
          _startDate!,
          _endDate!,
        );
      } else if (_currentFilter == FilterPeriod.all) {
        // If no filter and no search, show recent audits
        _auditsFuture = databaseService.getRecentAudits(10);
      } else {
        // If filter is applied but no search, show filtered audits
        _auditsFuture = databaseService.getFilteredAudits(_currentFilter);
      }
      _statsFuture = databaseService.getAuditStatistics();
    });
  }

  void _changeFilter(FilterPeriod period) {
    setState(() {
      _currentFilter = period;
      // Clear search when changing filter
      _searchQuery = "";
      _searchController.clear();

      // Clear date range when changing filter
      if (period != FilterPeriod.custom) {
        _isDateRangeActive = false;
        _startDate = null;
        _endDate = null;
      }

      switch (period) {
        case FilterPeriod.all:
          _filterLabel = "All Reports";
          break;
        case FilterPeriod.today:
          _filterLabel = "Today's Reports";
          break;
        case FilterPeriod.thisWeek:
          _filterLabel = "This Week's Reports";
          break;
        case FilterPeriod.thisMonth:
          _filterLabel = "This Month's Reports";
          break;
        case FilterPeriod.custom:
          _showDateRangePicker();
          return; // Don't load data yet, wait for date picker
      }
    });
    _loadData();
  }

  // Show date range picker
  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _isDateRangeActive = true;
        _filterLabel =
            "Custom: ${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}";
        _currentFilter = FilterPeriod.custom;
      });
      _loadData();
    } else {
      // If user cancels, revert to All Reports
      setState(() {
        _currentFilter = FilterPeriod.all;
        _filterLabel = "All Reports";
        _isDateRangeActive = false;
        _startDate = null;
        _endDate = null;
      });
      _loadData();
    }
  }

  // Format date as dd/MM/yyyy
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _filterLabel = "Search Results";
        _currentFilter = FilterPeriod.all; // Reset filter when searching
        _isDateRangeActive = false; // Clear date range when searching
        _startDate = null;
        _endDate = null;
      } else {
        _filterLabel = "All Reports";
      }
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final databaseService = Provider.of<DatabaseService>(context);
    final connectionStatus = databaseService.getConnectionStatus();
    final isLocalConnection =
        connectionStatus['connectionType'] == ConnectionType.local;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Audit Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[700]!, Colors.blue[900]!],
            ),
          ),
        ),
        actions: [
          // Database connection indicator
          Tooltip(
            message: 'Connected to: ${connectionStatus['serverAddress']}',
            child: TextButton.icon(
              icon: Icon(
                isLocalConnection ? Icons.lan : Icons.cloud,
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                isLocalConnection ? 'Local' : 'Cloud',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              onPressed: () {
                _showConnectionDialog(context, databaseService);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.person_rounded),
              onPressed: () {
                Navigator.pushNamed(context, '/user-management');
              },
              tooltip: 'User Management',
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          return Future.delayed(Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[600]!, Colors.blue[800]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.waving_hand_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            authService.currentUser?.fullName ?? 'User',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Statistics Section
              FutureBuilder<Map<String, int>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingStats();
                  } else if (snapshot.hasError) {
                    return _buildErrorStats(snapshot.error.toString());
                  } else if (snapshot.hasData) {
                    return _buildStatsCards(snapshot.data!);
                  } else {
                    return _buildNoDataStats();
                  }
                },
              ),
              SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search by serial number, auditor, or module type',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.blue[600],
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  onChanged: _performSearch,
                ),
              ),

              SizedBox(height: 20),

              // Recent Audits Section with Filter
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _filterLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // Filter dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<FilterPeriod>(
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Filter',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: _changeFilter,
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<FilterPeriod>(
                          value: FilterPeriod.all,
                          child: Row(
                            children: [
                              Icon(
                                Icons.all_inclusive,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 8),
                              Text('All Reports'),
                            ],
                          ),
                        ),
                        PopupMenuItem<FilterPeriod>(
                          value: FilterPeriod.today,
                          child: Row(
                            children: [
                              Icon(
                                Icons.today_rounded,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 8),
                              Text('Today'),
                            ],
                          ),
                        ),
                        PopupMenuItem<FilterPeriod>(
                          value: FilterPeriod.thisWeek,
                          child: Row(
                            children: [
                              Icon(
                                Icons.date_range_rounded,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 8),
                              Text('This Week'),
                            ],
                          ),
                        ),
                        PopupMenuItem<FilterPeriod>(
                          value: FilterPeriod.thisMonth,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 8),
                              Text('This Month'),
                            ],
                          ),
                        ),
                        PopupMenuItem<FilterPeriod>(
                          value: FilterPeriod.custom,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 8),
                              Text('Custom Date Range'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              FutureBuilder<List<dynamic>>(
                future: _auditsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // Sort by date descending (latest first)
                    final sortedAudits = snapshot.data!
                      ..sort((a, b) {
                        DateTime dateA = DateTime.parse(a.createdAt);
                        DateTime dateB = DateTime.parse(b.createdAt);
                        return dateB.compareTo(dateA); // latest first
                      });
                    return _buildAuditsList(sortedAudits);
                  } else if (snapshot.hasError) {
                    return _buildErrorAudits(snapshot.error.toString());
                  } else {
                    return _buildNoAudits();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showFormSelectionMenu(context);
        },
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Audit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 6,
      ),
    );
  }

  Widget _buildAuditsList(List<dynamic> audits) {
    return Column(
      children: audits.map((audit) {
        final isVerified = audit.verifiedBy.isNotEmpty;

        // Determine form type from serial number prefix or formType property
        String formType = 'standard';
        if (audit.serialNumber.startsWith('SC-')) {
          formType = 'sheet_cutting';
        } else if (audit.serialNumber.startsWith('CC-')) {
          formType = 'cell_cutting';
        } else if (audit.serialNumber.startsWith('FR-')) {
          formType = 'framing';
        }

        // Set icon based on form type
        IconData formIcon = Icons.assignment;
        if (formType == 'sheet_cutting') {
          formIcon = Icons.content_cut;
        } else if (formType == 'cell_cutting') {
          formIcon = Icons.grid_on;
        } else if (formType == 'framing') {
          formIcon = Icons.crop_square;
        }

        return Card(
          margin: EdgeInsets.only(bottom: 14),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              print('form-type $formType');
              // Navigate to the appropriate detail screen based on form type
              if (formType == 'sheet_cutting') {
                // Load the full audit data with proper type
                final databaseService = Provider.of<DatabaseService>(
                  context,
                  listen: false,
                );
                try {
                  // Check if audit.id is null and handle it
                  if (audit.id == null) {
                    print(
                      '⚠️ Warning: audit.id is null for ${audit.serialNumber}',
                    );
                    throw Exception('Audit ID is null. Cannot load details.');
                  }

                  print('🔍 Getting audit by ID: ${audit.id}');
                  final fullAudit = await databaseService.getAuditById(
                    audit.id.toString(),
                  );

                  print('Loaded audit type: ${fullAudit.runtimeType}');

                  if (fullAudit is SheetCuttingAuditForm) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SheetCuttingDetailScreen(audit: fullAudit),
                      ),
                    );
                  } else {
                    // Try to convert to SheetCuttingAuditForm if it's a Map
                    try {
                      SheetCuttingAuditForm convertedAudit;
                      if (fullAudit is Map<String, dynamic>) {
                        convertedAudit = SheetCuttingAuditForm.fromjson(
                          fullAudit,
                        );
                      } else {
                        // Try to convert from the audit's toMap/toJson method
                        final auditMap = fullAudit is AuditForm
                            ? fullAudit.toJson()
                            : (fullAudit is BaseAuditForm
                                  ? fullAudit.toMap()
                                  : null);

                        if (auditMap != null) {
                          convertedAudit = SheetCuttingAuditForm.fromjson(
                            auditMap,
                          );
                        } else {
                          throw Exception(
                            'Cannot convert audit to SheetCuttingAuditForm',
                          );
                        }
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SheetCuttingDetailScreen(audit: convertedAudit),
                        ),
                      );
                    } catch (conversionError) {
                      print('❌ Error converting audit: $conversionError');
                      // Fallback: Show error or standard detail screen
                      _showErrorDialog(
                        context,
                        'Error loading Sheet Cutting audit details. Please check the data format.\n\nError: $conversionError',
                      );
                    }
                  }
                } catch (e) {
                  print('❌ Error loading audit: $e');
                  _showErrorDialog(
                    context,
                    'Error loading audit details. Please try again.\n\nError: $e',
                  );
                }
              } else if (formType == 'cell_cutting') {
                final databaseService = Provider.of<DatabaseService>(
                  context,
                  listen: false,
                );

                try {
                  // Check if audit.id is null and handle it
                  if (audit.id == null) {
                    print(
                      '⚠️ Warning: audit.id is null for ${audit.serialNumber}',
                    );
                    throw Exception('Audit ID is null. Cannot load details.');
                  }

                  print('🔍 Getting audit by ID: ${audit.id}');
                  final fullAudit = await databaseService.getAuditById(
                    audit.id.toString(),
                  );

                  print('Loaded audit type: ${fullAudit.runtimeType}');

                  if (fullAudit is CellCuttingAuditForm) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CellCuttingDetailScreen(audit: fullAudit),
                      ),
                    );
                  } else {
                    // Try to convert to CellCuttingAuditForm if it's a Map
                    try {
                      CellCuttingAuditForm convertedAudit;
                      if (fullAudit is Map<String, dynamic>) {
                        convertedAudit = CellCuttingAuditForm.fromMap(
                          fullAudit,
                        );
                      } else {
                        // Try to convert from the audit's toMap/toJson method
                        final auditMap = fullAudit is AuditForm
                            ? fullAudit.toJson()
                            : (fullAudit is BaseAuditForm
                                  ? fullAudit.toMap()
                                  : null);

                        if (auditMap != null) {
                          convertedAudit = CellCuttingAuditForm.fromMap(
                            auditMap,
                          );
                        } else {
                          throw Exception(
                            'Cannot convert audit to CellCuttingAuditForm',
                          );
                        }
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CellCuttingDetailScreen(audit: convertedAudit),
                        ),
                      );
                    } catch (conversionError) {
                      print('❌ Error converting audit: $conversionError');
                      _showErrorDialog(
                        context,
                        'Error loading Cell Cutting audit details. Please check the data format.\n\nError: $conversionError',
                      );
                    }
                  }
                } catch (e) {
                  print('❌ Error loading audit: $e');
                  _showErrorDialog(
                    context,
                    'Error loading audit details. Please try again.\n\nError: $e',
                  );
                }
              } else if (formType == 'framing') {
                final databaseService = Provider.of<DatabaseService>(
                  context,
                  listen: false,
                );

                try {
                  // Check if audit.id is null and handle it
                  if (audit.id == null) {
                    print(
                      '⚠️ Warning: audit.id is null for ${audit.serialNumber}',
                    );
                    throw Exception('Audit ID is null. Cannot load details.');
                  }

                  print('🔍 Getting audit by ID: ${audit.id}');
                  final fullAudit = await databaseService.getAuditById(
                    audit.id.toString(),
                  );

                  if (fullAudit is FramingAuditForm) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FramingDetailScreen(
                          audit: fullAudit as FramingAuditForm,
                        ),
                      ),
                    );
                  } else {
                    // Try to convert to FramingAuditForm if it's a Map
                    try {
                      FramingAuditForm convertedAudit;
                      if (fullAudit is Map<String, dynamic>) {
                        convertedAudit = FramingAuditForm.fromMap(fullAudit);
                      } else {
                        // Try to convert from the audit's toMap/toJson method
                        final auditMap = fullAudit is AuditForm
                            ? fullAudit.toJson()
                            : (fullAudit is BaseAuditForm
                                  ? fullAudit.toMap()
                                  : null);

                        if (auditMap != null) {
                          convertedAudit = FramingAuditForm.fromMap(auditMap);
                        } else {
                          throw Exception(
                            'Cannot convert audit to FramingAuditForm',
                          );
                        }
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FramingDetailScreen(audit: convertedAudit),
                        ),
                      );
                    } catch (conversionError) {
                      print('❌ Error converting audit: $conversionError');
                      _showErrorDialog(
                        context,
                        'Error loading Framing audit details. Please check the data format.\n\nError: $conversionError',
                      );
                    }
                  }
                } catch (e) {
                  print('❌ Error loading audit: $e');
                  _showErrorDialog(
                    context,
                    'Error loading audit details. Please try again.\n\nError: $e',
                  );
                }
              } else {
                // Default to standard audit detail screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuditDetailScreen(audit: audit),
                  ),
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: formType == 'sheet_cutting'
                            ? [Colors.blue[400]!, Colors.blue[700]!]
                            : formType == 'cell_cutting'
                            ? [Colors.green[400]!, Colors.green[700]!]
                            : formType == 'framing'
                            ? [Colors.orange[400]!, Colors.orange[700]!]
                            : [Colors.purple[400]!, Colors.purple[700]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (formType == 'sheet_cutting'
                                      ? Colors.blue
                                      : formType == 'cell_cutting'
                                      ? Colors.green
                                      : formType == 'framing'
                                      ? Colors.orange
                                      : Colors.purple)
                                  .withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(formIcon, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audit.serialNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey[800],
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                audit.auditorName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              audit.createdAt,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? Colors.green[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isVerified
                                  ? Colors.green[200]!
                                  : Colors.orange[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVerified
                                    ? Icons.verified_rounded
                                    : Icons.pending_rounded,
                                size: 14,
                                color: isVerified
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                              SizedBox(width: 4),
                              Text(
                                isVerified ? 'Verified' : 'Pending',
                                style: TextStyle(
                                  color: isVerified
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCardPlaceholder()),
        SizedBox(width: 16),
        Expanded(child: _buildStatCardPlaceholder()),
        SizedBox(width: 16),
        Expanded(child: _buildStatCardPlaceholder()),
      ],
    );
  }

  Widget _buildStatCardPlaceholder() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 60, height: 16, color: Colors.grey[300]),
            SizedBox(height: 8),
            Container(width: 40, height: 24, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStats(String error) {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error loading statistics',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('No statistics available')),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, int> stats) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isAdmin = authService.currentUser?.role == 'Admin';

    // For admin users, show 4 cards in 1 row
    if (isAdmin) {
      return Row(
        children: [
          _buildStatCard(
            'Total Audits',
            stats['total']?.toString() ?? '0',
            Colors.blue,
            Icons.assignment_rounded,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'This Month',
            stats['thisMonth']?.toString() ?? '0',
            Colors.green,
            Icons.calendar_month_rounded,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Today',
            stats['today']?.toString() ?? '0',
            Colors.orange,
            Icons.today_rounded,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Pending',
            stats['pendingVerification']?.toString() ?? '0',
            Colors.red,
            Icons.pending_actions_rounded,
          ),
        ],
      );
    } else {
      // For regular users, show 3 cards
      return Row(
        children: [
          _buildStatCard(
            'Total Audits',
            stats['total']?.toString() ?? '0',
            Colors.blue,
            Icons.assignment_rounded,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'This Month',
            stats['thisMonth']?.toString() ?? '0',
            Colors.green,
            Icons.calendar_month_rounded,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Today',
            stats['today']?.toString() ?? '0',
            Colors.orange,
            Icons.today_rounded,
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorAudits(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Error loading audits', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildNoAudits() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No audits found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to create your first audit',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showFormSelectionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Select Audit Form Type',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Choose the type of inspection you want to perform',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                  _buildFormTypeCard(
                    context,
                    'Sheet Cutting Inspection',
                    'Inspect sheet cutting process',
                    Icons.content_cut_rounded,
                    Colors.blue,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SheetCuttingFormScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormTypeCard(
                    context,
                    'Cell Cutting Inspection',
                    'Inspect cell cutting process',
                    Icons.grid_on_rounded,
                    Colors.green,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CellCuttingFormScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormTypeCard(
                    context,
                    'Framing Inspection',
                    'Inspect framing process',
                    Icons.crop_square_rounded,
                    Colors.orange,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FramingFormScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFormTypeCard(
                    context,
                    'Standard Audit Form',
                    'General audit inspection',
                    Icons.assignment_rounded,
                    Colors.purple,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuditFormScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildFormTypeCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.8), color],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  void _filterByFormType(String formType) {
    setState(() {
      _filterLabel = formType == 'sheet_cutting'
          ? 'Sheet Cutting Reports'
          : formType == 'cell_cutting'
          ? 'Cell Cutting Reports'
          : formType == 'framing'
          ? 'Framing Reports'
          : 'All Reports';

      // Clear search when changing filter
      _searchQuery = "";
      _searchController.clear();

      // Clear date range when changing filter
      _isDateRangeActive = false;
      _startDate = null;
      _endDate = null;
    });

    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );
    setState(() {
      _auditsFuture = databaseService.getAuditsByFormType(formType);
    });
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              authService.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Show dialog to manage database connection
  void _showConnectionDialog(
    BuildContext context,
    DatabaseService databaseService,
  ) async {
    final connectionStatus = databaseService.getConnectionStatus();
    final isLocalConnection =
        connectionStatus['connectionType'] == ConnectionType.local;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  isLocalConnection ? Icons.lan : Icons.cloud,
                  color: Colors.blue[700],
                ),
                SizedBox(width: 8),
                Text('Database Connection'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Connection:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Type: ${isLocalConnection ? 'Local Network' : 'Cloud (MongoDB Atlas)'}',
                ),
                Text('Server: ${connectionStatus['serverAddress']}'),
                Text(
                  'Status: ${connectionStatus['isConnected'] ? 'Connected' : 'Disconnected'}',
                ),
                SizedBox(height: 16),
                Text(
                  'Connection Options:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Local Connection: Only devices on your local network can access the database.',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  'Cloud Connection: Access your database from anywhere with internet.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final results = await databaseService.testBothConnections();

                  if (!mounted) return;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Connection Test Results'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Connection: ${results[ConnectionType.local]! ? '✅ Available' : '❌ Not Available'}',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cloud Connection: ${results[ConnectionType.cloud]! ? '✅ Available' : '❌ Not Available'}',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Test Connections'),
              ),
              TextButton(
                onPressed: () async {
                  await databaseService.toggleConnectionType();
                  Navigator.pop(context);
                  _loadData(); // Reload data with new connection
                },
                child: Text(
                  'Switch to ${isLocalConnection ? 'Cloud' : 'Local'}',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
      ],
    ),
  );
}
