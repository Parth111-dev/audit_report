import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class User {
  String id;
  String username;
  String fullName;
  String role;
  DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });
}

class AuthService with ChangeNotifier {
  Db? _db;
  DbCollection? _usersCollection;
  User? _currentUser;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // _db = Db("mongodb://192.168.70.50:27017/solar_audit");
      // MongoDB Atlas connection - mongo_dart doesn't support mongodb+srv://
      // Using direct connection to Atlas cluster with resolved SRV records
      _db = Db(
        "mongodb://parthpatel685075_db_user:audit@ac-kgznvdl-shard-00-00.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-01.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-02.vyn7zkv.mongodb.net:27017/audit?ssl=true&replicaSet=atlas-5bfpso-shard-0&authSource=admin&retryWrites=true&w=majority",
      );

      await _db!.open();
      _usersCollection = _db!.collection('users');
      _isInitialized = true;

      // Create default admin user if not exists
      await _createDefaultAdmin();
      print('✅ AuthService initialized successfully');
    } catch (e) {
      print('❌ Error initializing AuthService: $e');
      throw Exception('Failed to initialize AuthService: $e');
    }
  }

  Future<void> _createDefaultAdmin() async {
    try {
      final adminExists = await _usersCollection!.findOne({
        'username': 'admin',
      });

      if (adminExists == null) {
        final now = DateTime.now();
        final formatter = DateFormat('dd/MM/yyyy');
        final formattedDate = '${formatter.format(now)} localtime';

        await _usersCollection!.insert({
          'username': 'admin',
          'password': 'admin123', // In production, hash this password
          'fullName': 'System Administrator',
          'role': 'Admin',
          'createdAt': formattedDate,
        });
        print('✅ Default admin user created');
      }
    } catch (e) {
      print('❌ Error creating default admin: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    if (!_isInitialized) await initialize();

    try {
      final user = await _usersCollection!.findOne({
        'username': username,
        'password': password, // In production, use password hashing
      });

      if (user != null) {
        _currentUser = User(
          id: user['_id'].toString(),
          username: user['username'],
          fullName: user['fullName'],
          role: user['role'],
          createdAt: user['createdAt'],
        );
        notifyListeners();
        print('✅ User logged in: ${_currentUser!.username}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }

  Future<bool> createUser(
    String username,
    String password,
    String fullName,
    String role,
  ) async {
    if (!_isInitialized) await initialize();

    try {
      // Check if username already exists
      final existingUser = await _usersCollection!.findOne({
        'username': username,
      });

      if (existingUser != null) {
        print('❌ Username already exists: $username');
        return false;
      }

      final now = DateTime.now();
      final formatter = DateFormat('dd/MM/yyyy');
      final formattedDate = '${formatter.format(now)} localtime';

      await _usersCollection!.insert({
        'username': username,
        'password': password, // In production, hash this password
        'fullName': fullName,
        'role': role,
        'createdAt': formattedDate,
      });

      print('✅ User created successfully: $username');
      return true;
    } catch (e) {
      print('❌ Create user error: $e');
      return false;
    }
  }

  Future<List<User>> getUsers() async {
    if (!_isInitialized) await initialize();

    try {
      final users = await _usersCollection!.find().toList();
      return users
          .map(
            (user) => User(
              id: user['_id'].toString(),
              username: user['username'],
              fullName: user['fullName'],
              role: user['role'],
              createdAt: user['createdAt'],
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
    print('✅ User logged out');
  }

  Future<void> disconnect() async {
    if (_db != null) {
      await _db!.close();
      _isInitialized = false;
      print('✅ AuthService disconnected');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
