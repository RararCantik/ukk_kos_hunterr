// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  // --- Singleton Pattern ---
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --- Inisialisasi Database ---
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kos_app.db');
    return await openDatabase(
      path,
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, 
      onConfigure: _onConfigure,
    );
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE reviews ADD COLUMN owner_reply TEXT');
    }
  }
  
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // --- Pembuatan Tabel ---
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL CHECK(role IN ('owner', 'society'))
      )
    ''');

    await db.execute('''
      CREATE TABLE kos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT,
        price_per_month INTEGER NOT NULL,
        gender TEXT CHECK(gender IN ('male', 'female', 'all')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE kos_image (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kos_id INTEGER NOT NULL,
        file TEXT NOT NULL,
        FOREIGN KEY (kos_id) REFERENCES kos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE kos_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kos_id INTEGER NOT NULL,
        facility TEXT NOT NULL,
        FOREIGN KEY (kos_id) REFERENCES kos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kos_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        comment TEXT,
        owner_reply TEXT, -- <-- TAMBAHKAN KOLOM INI
        FOREIGN KEY (kos_id) REFERENCES kos(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kos_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        status TEXT NOT NULL CHECK(status IN ('pending', 'accept', 'reject')) DEFAULT 'pending',
        FOREIGN KEY (kos_id) REFERENCES kos(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD: users ---
  
  // Create
  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.fail);
  }

  // Read (by ID)
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  
  // Read (by Email)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  
  // Read (by Email and Password for Login)
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users', 
      where: 'email = ? AND password = ?', 
      whereArgs: [email, password]
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }


  // Update
  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }
  
  // Delete
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD: kos ---

  // Create
  Future<int> createKos(Map<String, dynamic> kos) async {
    final db = await database;
    return await db.insert('kos', kos);
  }

  // Read (by ID)
  Future<Map<String, dynamic>?> getKos(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('kos', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Read (All with filter)
  Future<List<Map<String, dynamic>>> getAllKos({String? gender}) async {
    final db = await database;
    if (gender != null && gender.isNotEmpty) {
      return await db.query('kos', where: 'gender = ?', whereArgs: [gender.toLowerCase()]);
    } else {
      return await db.query('kos');
    }
  }

  // Read (by Owner)
  Future<List<Map<String, dynamic>>> getKosByOwner(int userId) async {
    final db = await database;
    return await db.query('kos', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Update
  Future<int> updateKos(int id, Map<String, dynamic> kos) async {
    final db = await database;
    return await db.update('kos', kos, where: 'id = ?', whereArgs: [id]);
  }

  // Delete
  Future<int> deleteKos(int id) async {
    final db = await database;
    return await db.delete('kos', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD: kos_image ---
  
  // Create
  Future<int> addKosImage(Map<String, dynamic> image) async {
    final db = await database;
    return await db.insert('kos_image', image);
  }

  // Read (by kos_id)
  Future<List<Map<String, dynamic>>> getImagesForKos(int kosId) async {
    final db = await database;
    return await db.query('kos_image', where: 'kos_id = ?', whereArgs: [kosId]);
  }
  
  // Delete
  Future<int> deleteKosImage(int id) async {
    final db = await database;
    return await db.delete('kos_image', where: 'id = ?', whereArgs: [id]);
  }
  
  // Delete by kos_id
  Future<int> deleteImagesForKos(int kosId) async {
    final db = await database;
    return await db.delete('kos_image', where: 'kos_id = ?', whereArgs: [kosId]);
  }

  // --- CRUD: kos_facilities ---
  
  // Create
  Future<int> addKosFacility(Map<String, dynamic> facility) async {
    final db = await database;
    return await db.insert('kos_facilities', facility);
  }

  // Read (by kos_id)
  Future<List<Map<String, dynamic>>> getFacilitiesForKos(int kosId) async {
    final db = await database;
    return await db.query('kos_facilities', where: 'kos_id = ?', whereArgs: [kosId]);
  }
  
  // Delete
  Future<int> deleteKosFacility(int id) async {
    final db = await database;
    return await db.delete('kos_facilities', where: 'id = ?', whereArgs: [id]);
  }
  
  // Delete by kos_id
  Future<int> deleteFacilitiesForKos(int kosId) async {
    final db = await database;
    return await db.delete('kos_facilities', where: 'kos_id = ?', whereArgs: [kosId]);
  }


  // --- CRUD: reviews ---
  
  // Create
  Future<int> addReview(Map<String, dynamic> review) async {
    final db = await database;
    return await db.insert('reviews', review);
  }

  // Read (by kos_id)
  Future<List<Map<String, dynamic>>> getReviewsForKos(int kosId) async {
    final db = await database;
    return await db.query('reviews', where: 'kos_id = ?', whereArgs: [kosId]);
  }
  
  // Delete
  Future<int> deleteReview(int id) async {
    final db = await database;
    return await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }

  // -balasan owner
  Future<int> updateOwnerReply(int reviewId, String reply) async {
    final db = await database;
    return await db.update(
      'reviews',
      {'owner_reply': reply},
      where: 'id = ?',
      whereArgs: [reviewId],
    );
  }
  
  // --- CRUD: books (Bookings) ---
  
  // Create
  Future<int> createBooking(Map<String, dynamic> booking) async {
    final db = await database;
    return await db.insert('books', booking);
  }

  // Read (by user_id)
  Future<List<Map<String, dynamic>>> getBookingsForUser(int userId) async {
    final db = await database;
    return await db.query('books', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Read (by owner_id, via join) 
  Future<List<Map<String, dynamic>>> getBookingsForOwner(int ownerUserId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT b.*, k.name as kos_name
      FROM books b
      JOIN kos k ON b.kos_id = k.id
      WHERE k.user_id = ?
    ''', [ownerUserId]);
  }
  
  // Update (misal: update status)
  Future<int> updateBookingStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'books', 
      {'status': status}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }
  
  // Delete
  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  // --- FUNGSI JOIN / KOMPOSIT ---

  // Mengambil review untuk kos DAN nama user yang mereview
  Future<List<Map<String, dynamic>>> getCompositeReviewsForKos(int kosId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT r.id, r.comment, r.owner_reply, u.name as user_name
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      WHERE r.kos_id = ?
    ''', [kosId]);
  }

  // Mengambil booking untuk society DAN nama kos yang dibooking
  Future<List<Map<String, dynamic>>> getCompositeBookingsForUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT b.*, k.name as kos_name
      FROM books b
      JOIN kos k ON b.kos_id = k.id
      WHERE b.user_id = ?
    ''', [userId]);
  }

  // Mengambil booking untuk owner DAN nama kos & nama user (DENGAN FILTER TANGGAL)
  Future<List<Map<String, dynamic>>> getCompositeBookingsForOwner(
    int ownerUserId, {
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;
    
    // Query dasar
    String query = '''
      SELECT b.*, k.name as kos_name, u.name as user_name
      FROM books b
      JOIN kos k ON b.kos_id = k.id
      JOIN users u ON b.user_id = u.id
      WHERE k.user_id = ?
    ''';
    
    // List untuk argumen query
    List<dynamic> args = [ownerUserId];

    // Tambahkan filter tanggal jika ada
    if (startDate != null && startDate.isNotEmpty) {
      // Asumsi format 'YYYY-MM-DD'
      query += ' AND b.start_date >= ?';
      args.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      // Asumsi format 'YYYY-MM-DD'
      // Kita gunakan '... 23:59:59' agar mencakup semua di tanggal akhir
      query += ' AND b.start_date <= ?';
      args.add('$endDate 23:59:59');
    }

    // Tambahkan urutan
    query += ' ORDER BY b.start_date DESC';

    return await db.rawQuery(query, args);
  }
}