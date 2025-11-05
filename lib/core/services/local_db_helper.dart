import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:universityclassroommanagement/features/profile/data/models/user_model.dart';

import '../../features/classroom/data/models/class_room_model.dart';

class LocalDbHelper {
  LocalDbHelper._();
  static LocalDbHelper getInstance() {
    return LocalDbHelper._();
  }

  static final String Table_users = 'users';
  static final String COLUMN_UID = 'uid';
  static final String COLUMN_NAME = 'name';
  static final String COLUMN_EMAIL = 'email';
  static final String COLUMN_PHOTOURL = 'photoUrl';
  static final String COLUMN_FCMTOKEN = 'fcmToken';
  static final String COLUMN_JOINED_CLASSES = 'joinedClasses';
  static final String COLUMN_LASTLOGIN = 'lastLogin';


  static final String TABLE_CLASSES = 'classes';

  static final String COLUMN_CLASS_ID = 'id';
  static final String COLUMN_CLASS_NAME = 'name';
  static final String COLUMN_SUBJECT = 'subject';
  static final String COLUMN_CREATED_BY = 'createdBy';
  static final String COLUMN_CREATED_AT = 'createdAt';
  static final String COLUMN_STUDENTS = 'students';
  static final String COLUMN_ADMINS = 'admins';


  Database? myDB;

  Future<Database> getDB() async {
    if (myDB != null) {
      return myDB!;
    } else {
      myDB = await openDB();
      return myDB!;
    }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dpPath = join(appDir.path, 'eduLink.db');

    return await openDatabase(
      dpPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE $Table_users(
        $COLUMN_UID TEXT PRIMARY KEY,
        $COLUMN_NAME TEXT NOT NULL,
        $COLUMN_EMAIL TEXT NOT NULL,
        $COLUMN_PHOTOURL TEXT NOT NULL,
        $COLUMN_FCMTOKEN TEXT,
        $COLUMN_JOINED_CLASSES TEXT,
        $COLUMN_LASTLOGIN INTEGER
      )
    ''');

        await db.execute('''
      CREATE TABLE $TABLE_CLASSES(
        $COLUMN_CLASS_ID TEXT PRIMARY KEY,
        $COLUMN_CLASS_NAME TEXT NOT NULL,
        $COLUMN_SUBJECT TEXT NOT NULL,
        $COLUMN_CREATED_BY TEXT NOT NULL,
        $COLUMN_CREATED_AT INTEGER NOT NULL,
        $COLUMN_STUDENTS TEXT,
        $COLUMN_ADMINS TEXT
      )
    ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Create classes table if upgrading from version 1
          await db.execute('''
        CREATE TABLE IF NOT EXISTS $TABLE_CLASSES(
          $COLUMN_CLASS_ID TEXT PRIMARY KEY,
          $COLUMN_CLASS_NAME TEXT NOT NULL,
          $COLUMN_SUBJECT TEXT NOT NULL,
          $COLUMN_CREATED_BY TEXT NOT NULL,
          $COLUMN_CREATED_AT INTEGER NOT NULL,
          $COLUMN_STUDENTS TEXT,
          $COLUMN_ADMINS TEXT
        )
      ''');
        }
      },
    );


  }
  Future<bool> addUser({required UserModel model}) async {
    try {
      final db = await getDB();

      // Convert joinedClasses to JSON string
      String joinedClassesJson = jsonEncode(model.joinedClasses);

      // Convert lastLogin Timestamp to milliseconds
      int lastLoginMillis = model.lastLogin?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;

      int rowEffected = await db.insert(
        Table_users,
        {
          COLUMN_UID: model.uid,
          COLUMN_NAME: model.name,
          COLUMN_EMAIL: model.email,
          COLUMN_PHOTOURL: model.photoUrl,
          COLUMN_FCMTOKEN: model.fcmToken,
          COLUMN_JOINED_CLASSES: joinedClassesJson,
          COLUMN_LASTLOGIN: lastLoginMillis,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('User added in auth');

      return rowEffected > 0;
    } catch (e) {
      debugPrint("Error adding user: $e");
      return false;
    }
  }
  Future<UserModel?> getUser() async {
    try {
      final db = await getDB();

      final result = await db.query(
        Table_users);

      if (result.isNotEmpty) {
        final map = result.first;

        // Parse joinedClasses JSON string back to List<String>
        List<String> joinedClasses = [];
        if (map[COLUMN_JOINED_CLASSES] != null) {
          joinedClasses = List<String>.from(jsonDecode(map[COLUMN_JOINED_CLASSES] as String));
        }

        // Parse lastLogin from milliseconds
        Timestamp? lastLogin;
        if (map[COLUMN_LASTLOGIN] != null) {
          lastLogin = Timestamp.fromMillisecondsSinceEpoch(map[COLUMN_LASTLOGIN] as int);
        }

        return UserModel(
          uid: map[COLUMN_UID] as String,
          name: map[COLUMN_NAME] as String,
          email: map[COLUMN_EMAIL] as String,
          photoUrl: map[COLUMN_PHOTOURL] as String,
          fcmToken: map[COLUMN_FCMTOKEN] as String,
          joinedClasses: joinedClasses,
          lastLogin: lastLogin,
        );
      } else {
        print('user not found , local db clear');
        return null; // User not found
      }
    } catch (e) {
      debugPrint("Error getting user: $e");
      return null;
    }
  }

  Future<void> addClassRoom({required ClassRoomModel model}) async {
    try {
      final db = await getDB();
      String studentsJson = jsonEncode(model.students);
      String adminsJson = jsonEncode(model.admins);
      int createdAtMillis = model.createdAt.millisecondsSinceEpoch;
      await db.insert(
        TABLE_CLASSES,
        {
          COLUMN_CLASS_ID: model.id,
          COLUMN_CLASS_NAME: model.name,
          COLUMN_SUBJECT: model.subject,
          COLUMN_CREATED_BY: model.createdBy,
          COLUMN_CREATED_AT: createdAtMillis,
          COLUMN_STUDENTS: studentsJson,
          COLUMN_ADMINS: adminsJson,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint("✅ Class inserted successfully: ${model.name}");
    } catch (e) {
      debugPrint("❌ Error adding class: $e");
    }
  }

  Future<List<ClassRoomModel>> getAllClasses() async {
    try {
      final db = await getDB();

      // Query all rows from classes table
      final result = await db.query(TABLE_CLASSES);

      if (result.isNotEmpty) {
        // Map each row to ClassRoomModel
        return result.map((map) {
          // Decode students list
          List<String> students = [];
          if (map[COLUMN_STUDENTS] != null) {
            students = List<String>.from(jsonDecode(map[COLUMN_STUDENTS] as String));
          }

          // Decode admins list
          List<String> admins = [];
          if (map[COLUMN_ADMINS] != null) {
            admins = List<String>.from(jsonDecode(map[COLUMN_ADMINS] as String));
          }

          // Parse createdAt from milliseconds
          Timestamp createdAt = Timestamp.fromMillisecondsSinceEpoch(map[COLUMN_CREATED_AT] as int);

          return ClassRoomModel(
            id: map[COLUMN_CLASS_ID] as String,
            name: map[COLUMN_CLASS_NAME] as String,
            subject: map[COLUMN_SUBJECT] as String,
            createdBy: map[COLUMN_CREATED_BY] as String,
            createdAt: createdAt,
            students: students,
            admins: admins,
          );
        }).toList();
      } else {
        debugPrint("⚠️ No classes found in local DB");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Error getting classes: $e");
      return [];
    }
  }


}
