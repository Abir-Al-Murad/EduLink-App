import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:universityclassroommanagement/features/profile/data/models/user_model.dart';

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
      },
      version: 1,
    );

    }
  Future<bool> addUser({required UserModel model}) async {
    try {
      final db = await getDB();

      // Convert joinedClasses to JSON string
      String joinedClassesJson = jsonEncode(model.joinedClasses ?? []);

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


}
