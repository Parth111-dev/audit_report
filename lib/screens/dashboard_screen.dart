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
      appBar: AppBar(
        title: Text('Audit Dashboard'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
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
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/user-management');
            },
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome, ${authService.currentUser?.fullName ?? 'User'}!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),

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
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by serial number, auditor, or module type',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                onChanged: _performSearch,
              ),

              SizedBox(height: 16),

              // Recent Audits Section with Filter
              Row(
                children: [
                  Text(
                    _filterLabel,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  // Filter dropdown
                  PopupMenuButton<FilterPeriod>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list),
                        SizedBox(width: 4),
                        Text('Filter'),
                      ],
                    ),
                    onSelected: _changeFilter,
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<FilterPeriod>(
                        value: FilterPeriod.all,
                        child: Text('All Reports'),
                      ),
                      PopupMenuItem<FilterPeriod>(
                        value: FilterPeriod.today,
                        child: Text('Today'),
                      ),
                      PopupMenuItem<FilterPeriod>(
                        value: FilterPeriod.thisWeek,
                        child: Text('This Week'),
                      ),
                      PopupMenuItem<FilterPeriod>(
                        value: FilterPeriod.thisMonth,
                        child: Text('This Month'),
                      ),
                      PopupMenuItem<FilterPeriod>(
                        value: FilterPeriod.custom,
                        child: Text('Custom Date Range'),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: _loadData,
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 16),
                        SizedBox(width: 4),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _auditsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
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
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return _buildAuditsList(snapshot.data!);
                    } else {
                      return _buildNoAudits();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFormSelectionMenu(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildAuditsList(List<dynamic> audits) {
    return ListView.builder(
      itemCount: audits.length,
      itemBuilder: (context, index) {
        final audit = audits[index];
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
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(formIcon, color: Colors.blue[700], size: 20),
            ),
            title: Text(
              audit.serialNumber,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Auditor: ${audit.auditorName}'),
                Text('Date: ${audit.createdAt}'),
                Text(
                  isVerified
                      ? 'Verified by: ${audit.verifiedBy}'
                      : 'Pending Verification',
                  style: TextStyle(
                    color: isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
                        convertedAudit = SheetCuttingAuditForm.fromMap(
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
                          convertedAudit = SheetCuttingAuditForm.fromMap(
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
          ),
        );
      },
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

    // For admin users, show 4 cards including pending verification
    if (isAdmin) {
      return Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                'Total Audits',
                stats['total']?.toString() ?? '0',
                Colors.blue,
              ),
              SizedBox(width: 16),
              _buildStatCard(
                'This Month',
                stats['thisMonth']?.toString() ?? '0',
                Colors.green,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Today',
                stats['today']?.toString() ?? '0',
                Colors.orange,
              ),
              SizedBox(width: 16),
              _buildStatCard(
                'Pending Verification',
                stats['pendingVerification']?.toString() ?? '0',
                Colors.red,
              ),
            ],
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
          ),
          SizedBox(width: 16),
          _buildStatCard(
            'This Month',
            stats['thisMonth']?.toString() ?? '0',
            Colors.green,
          ),
          SizedBox(width: 16),
          _buildStatCard(
            'Today',
            stats['today']?.toString() ?? '0',
            Colors.orange,
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Audit Form Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.content_cut, color: Colors.blue[700]),
                  ),
                  title: Text('Sheet Cutting Inspection'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SheetCuttingFormScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.grid_on, color: Colors.green[700]),
                  ),
                  title: Text('Cell Cutting Inspection'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CellCuttingFormScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Icon(Icons.border_outer, color: Colors.orange[700]),
                  ),
                  title: Text('Framing Inspection'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FramingFormScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Icon(Icons.assignment, color: Colors.purple[700]),
                  ),
                  title: Text('Standard Audit Form'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuditFormScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
