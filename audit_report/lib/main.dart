import 'package:final_audit/models/audit_model.dart';
import 'package:final_audit/services/audit_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _authService.initialize();
      await _databaseService.connect();
      print('✅ All services initialized successfully');
    } catch (e) {
      print('❌ Error initializing services: $e');
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
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.isLoggedIn) {
              return DashboardScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/audit-form': (context) => AuditFormScreen(),
          '/audit-detail': (context) {
            final audit = ModalRoute.of(context)!.settings.arguments as AuditForm;
            return AuditDetailScreen(audit: audit);
          },
          '/user-management': (context) => UserManagementScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
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