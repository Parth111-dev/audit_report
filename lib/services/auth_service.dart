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

    // Maximum number of connection attempts
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        // Allow connections from any IP address in MongoDB Atlas Network Access settings
        // For production, use environment variables or secure storage for credentials
        const String connectionString =
            "mongodb://parthpatel685075_db_user:audit@ac-kgznvdl-shard-00-00.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-01.vyn7zkv.mongodb.net:27017,ac-kgznvdl-shard-00-02.vyn7zkv.mongodb.net:27017/audit?ssl=true&replicaSet=atlas-5bfpso-shard-0&authSource=admin&retryWrites=true&w=majority";

        // Close any existing connection before creating a new one
        if (_db != null) {
          await _db!.close();
        }

        _db = Db(connectionString);

        print(
          'Connecting to MongoDB for authentication... (Attempt ${retryCount + 1}/$maxRetries)',
        );
        await _db!.open();
        _usersCollection = _db!.collection('users');
        _isInitialized = true;

        // Create default admin user if not exists
        await _createDefaultAdmin();
        print('✅ AuthService initialized successfully');
        return; // Connection successful, exit the function
      } catch (e) {
        retryCount++;
        print(
          '❌ Error initializing AuthService (Attempt $retryCount/$maxRetries): $e',
        );
        print('Error details: ${e.toString()}');

        if (retryCount >= maxRetries) {
          print(
            '⚠️ Maximum connection attempts reached. Please check your network connection and MongoDB Atlas settings.',
          );
          throw Exception(
            'Failed to initialize AuthService after $maxRetries attempts: $e',
          );
        } else {
          // Wait before retrying (exponential backoff)
          final waitTime = Duration(seconds: retryCount * 2);
          print('Retrying in ${waitTime.inSeconds} seconds...');
          await Future.delayed(waitTime);
        }
      }
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
        // Parse the createdAt string to DateTime
        DateTime createdAtDate;
        try {
          // Try to parse the date string
          String createdAtStr = user['createdAt'];
          // Remove "localtime" suffix if present
          createdAtStr = createdAtStr.replaceAll(' localtime', '');
          // Parse using the same format used when creating the user
          createdAtDate = DateFormat('dd/MM/yyyy').parse(createdAtStr);
        } catch (e) {
          // If parsing fails, use current date as fallback
          print(
            '❌ Error parsing date: ${user['createdAt']}. Using current date instead.',
          );
          createdAtDate = DateTime.now();
        }

        _currentUser = User(
          id: user['_id'].toString(),
          username: user['username'],
          fullName: user['fullName'],
          role: user['role'],
          createdAt: createdAtDate,
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
      return users.map((user) {
        // Parse the createdAt string to DateTime
        DateTime createdAtDate;
        try {
          // Try to parse the date string
          String createdAtStr = user['createdAt'];
          // Remove "localtime" suffix if present
          createdAtStr = createdAtStr.replaceAll(' localtime', '');
          // Parse using the same format used when creating the user
          createdAtDate = DateFormat('dd/MM/yyyy').parse(createdAtStr);
        } catch (e) {
          // If parsing fails, use current date as fallback
          print(
            '❌ Error parsing date: ${user['createdAt']}. Using current date instead.',
          );
          createdAtDate = DateTime.now();
        }

        return User(
          id: user['_id'].toString(),
          username: user['username'],
          fullName: user['fullName'],
          role: user['role'],
          createdAt: createdAtDate,
        );
      }).toList();
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
