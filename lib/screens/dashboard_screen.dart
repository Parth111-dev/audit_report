import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audit_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'audit_form_screen.dart';
import 'audit_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<AuditForm>> _auditsFuture;
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );
    setState(() {
      _auditsFuture = databaseService.getRecentAudits(10);
      _statsFuture = databaseService.getAuditStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Audit Dashboard'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
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

              // Recent Audits Section
              Row(
                children: [
                  Text(
                    'Recent Audits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  TextButton(onPressed: _loadData, child: Text('Refresh')),
                ],
              ),
              SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<AuditForm>>(
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuditFormScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildAuditsList(List<AuditForm> audits) {
    return ListView.builder(
      itemCount: audits.length,
      itemBuilder: (context, index) {
        final audit = audits[index];
        final isVerified = audit.verifiedBy.isNotEmpty;
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
              child: Icon(Icons.assignment, color: Colors.blue[700], size: 20),
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
                Text('Date: ${audit.auditDate}'),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuditDetailScreen(audit: audit),
                ),
              );
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
          _getTodayCount(stats).toString(),
          Colors.orange,
        ),
      ],
    );
  }

  int _getTodayCount(Map<String, int> stats) {
    // This is a placeholder - you should implement actual today's count logic
    return 0;
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
}
