import 'package:final_audit/models/audit_model.dart';
import 'package:final_audit/services/audit_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/audit_form_screen.dart';
import 'screens/audit_detail_screen.dart';
import 'screens/user_management_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final AuditService _auditService = AuditService();

  bool _isConnecting = true;
  bool _connectionError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isConnecting = true;
      _connectionError = false;
      _errorMessage = "";
    });

    try {
      // Check internet connectivity first
      bool hasInternet = await _checkInternetConnectivity();
      if (!hasInternet) {
        setState(() {
          _isConnecting = false;
          _connectionError = true;
          _errorMessage =
              "No internet connection. Please check your network settings.";
        });
        print('❌ No internet connection. Please check your network settings.');
        return;
      }

      // Check if MongoDB Atlas is reachable
      bool canReachMongoDB = await _canReachMongoDB();
      if (!canReachMongoDB) {
        setState(() {
          _isConnecting = false;
          _connectionError = true;
          _errorMessage =
              "Cannot reach database server. The service might be down or blocked by your network.";
        });
        print(
          '❌ Cannot reach MongoDB Atlas. The service might be down or blocked by your network.',
        );
        return;
      }

      await _authService.initialize();
      await _databaseService.connect();

      setState(() {
        _isConnecting = false;
        _connectionError = false;
      });

      print('✅ All services initialized successfully');
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _connectionError = true;
        _errorMessage = "Error connecting to database: ${e.toString()}";
      });
      print('❌ Error initializing services: $e');
    }
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );
      return response.statusCode == 200;
    } catch (e) {
      print('Internet connectivity check failed: $e');
      return false;
    }
  }

  Future<bool> _canReachMongoDB() async {
    try {
      // Try to reach MongoDB Atlas domain
      // Note: This only checks if the domain is reachable, not if authentication works
      final response = await http
          .get(Uri.parse('https://cloud.mongodb.com'))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('MongoDB connection timeout');
            },
          );
      return response.statusCode == 200;
    } catch (e) {
      print('MongoDB connectivity check failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<DatabaseService>.value(value: _databaseService),
        ChangeNotifierProvider<AuditService>.value(value: _auditService),
      ],
      child: MaterialApp(
        title: 'Solar Panel Audit System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: _buildHomeScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/audit-form': (context) => AuditFormScreen(),
          '/audit-detail': (context) {
            final audit =
                ModalRoute.of(context)!.settings.arguments as AuditForm;
            return AuditDetailScreen(audit: audit);
          },
          '/user-management': (context) => UserManagementScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Widget _buildHomeScreen() {
    // Show loading or error screen if needed
    if (_isConnecting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Connecting to database...'),
            ],
          ),
        ),
      );
    }

    if (_connectionError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 20),
              Text(
                'Connection Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(_errorMessage, textAlign: TextAlign.center),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _initializeServices,
                    child: Text('Retry Connection'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/connection-test');
                    },
                    child: Text('Run Diagnostics'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Normal flow - check if logged in
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoggedIn) {
          return DashboardScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  @override
  void dispose() {
    _authService.dispose();
    _databaseService.dispose();
    _auditService.dispose();
    super.dispose();
  }
}
