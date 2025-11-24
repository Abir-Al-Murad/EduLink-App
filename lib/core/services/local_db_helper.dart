import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/classroom/data/models/class_room_model.dart';
import '../../features/my class/data/models/user_model.dart';
import '../../features/notice/data/models/notice_model.dart';
import '../../features/routine/data/models/routine_model.dart';
import '../../features/task/data/model/task_model.dart';

class LocalDbHelper {
  LocalDbHelper._();
  static final LocalDbHelper _instance = LocalDbHelper._();
  factory LocalDbHelper() => _instance;

  static LocalDbHelper getInstance() => _instance;

  //User Table
  static final String Table_users = 'users';
  static final String COLUMN_UID = 'uid';
  static final String COLUMN_NAME = 'name';
  static final String COLUMN_EMAIL = 'email';
  static final String COLUMN_PHOTOURL = 'photoUrl';
  static final String COLUMN_FCMTOKEN = 'fcmToken';
  static final String COLUMN_JOINED_CLASSES = 'joinedClasses';
  static final String COLUMN_LASTLOGIN = 'lastLogin';

  //Class Table
  static final String TABLE_CLASSES = 'classes';
  static final String COLUMN_CLASS_ID = 'id';
  static final String COLUMN_CLASS_NAME = 'name';
  static final String COLUMN_SUBJECT = 'subject';
  static final String COLUMN_CREATED_BY = 'createdBy';
  static final String COLUMN_CREATED_AT = 'createdAt';
  static final String COLUMN_STUDENTS = 'students';
  static final String COLUMN_ADMINS = 'admins';

  //Tasks Table
  static final String TABLE_TASKS = 'tasks';
  static final String COLUMN_TASK_ID = 'task_id';
  static final String COLUMN_CLASS_ID_FK = 'class_id';
  static final String COLUMN_TITLE = 'title';
  static final String COLUMN_DESCRIPTION = 'description';
  static final String COLUMN_DEADLINE = 'deadline';
  static final String COLUMN_COMPLETED_BY = 'completedBy';
  static final String COLUMN_ASSIGNED_DATE = 'assignedDate';

  //Routine Table
  static final String TABLE_ROUTINE = 'routine';
  static final String COLUMN_COURSE = 'course';
  static final String COLUMN_ROOM = 'room';
  static final String COLUMN_TEACHER = 'teacher';
  static final String COLUMN_TIME = 'time';
  static final String COLUMN_DAY = 'day';
  static final String COLUMN_CLASS_ID_ROUTINE = 'class_id';
  static final String COLUMN_ROUTINE_ID = 'routine_id';

  //Notice Table
  static final String TABLE_NOTICE = 'notice';
  static final String COLUMN_NOTICE_DESCRIPTION = 'description';
  static final String COLUMN_NOTICE_TITLE = 'title';
  static final String COLUMN_NOTICE_CREATED_AT = 'createdAt';
  static final String COLUMN_NOTICE_ID = 'notice_id';
  static final String COLUMN_NOTICE_CLASS_ID = 'notice_class_id';

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
      version: 2, // ⚠️ CHANGED FROM 1 TO 2 - This triggers onUpgrade
      onCreate: (db, version) async {
        debugPrint("🔨 Creating database tables...");

        // Users Table
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
        debugPrint("✅ Users table created");

        // Classes Table
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
        debugPrint("✅ Classes table created");

        // Tasks Table - FIXED VERSION
        await db.execute('''
          CREATE TABLE $TABLE_TASKS(
            $COLUMN_TASK_ID TEXT PRIMARY KEY,
            $COLUMN_CLASS_ID_FK TEXT NOT NULL,
            $COLUMN_TITLE TEXT NOT NULL,
            $COLUMN_DESCRIPTION TEXT,
            $COLUMN_DEADLINE INTEGER,
            $COLUMN_ASSIGNED_DATE INTEGER,
            $COLUMN_COMPLETED_BY TEXT,
            FOREIGN KEY ($COLUMN_CLASS_ID_FK) REFERENCES $TABLE_CLASSES($COLUMN_CLASS_ID)
          )
        ''');
        debugPrint("✅ Tasks table created");

        // Routine Table
        await db.execute('''
          CREATE TABLE $TABLE_ROUTINE(
            $COLUMN_ROUTINE_ID TEXT PRIMARY KEY,
            $COLUMN_CLASS_ID_ROUTINE TEXT NOT NULL,
            $COLUMN_COURSE TEXT NOT NULL,
            $COLUMN_ROOM TEXT,
            $COLUMN_TEACHER TEXT,
            $COLUMN_TIME TEXT,
            $COLUMN_DAY TEXT NOT NULL,
            FOREIGN KEY ($COLUMN_CLASS_ID_ROUTINE) REFERENCES $TABLE_CLASSES($COLUMN_CLASS_ID)
          )
        ''');
        debugPrint("✅ Routine table created");

        // Notice Table
        await db.execute('''
          CREATE TABLE $TABLE_NOTICE (
            $COLUMN_NOTICE_ID TEXT PRIMARY KEY,
            $COLUMN_NOTICE_CLASS_ID TEXT NOT NULL,
            $COLUMN_NOTICE_TITLE TEXT NOT NULL,
            $COLUMN_NOTICE_DESCRIPTION TEXT,
            $COLUMN_NOTICE_CREATED_AT INTEGER,
            FOREIGN KEY ($COLUMN_NOTICE_CLASS_ID) REFERENCES $TABLE_CLASSES($COLUMN_CLASS_ID)
          )
        ''');
        debugPrint("✅ Notice table created");

        debugPrint("🎉 All tables created successfully!");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        debugPrint("🔄 Upgrading database from v$oldVersion to v$newVersion");

        if (oldVersion < 2) {
          // Drop old tasks table if exists
          await db.execute('DROP TABLE IF EXISTS $TABLE_TASKS');
          debugPrint("🗑️ Dropped old tasks table");

          // Recreate tasks table with proper schema
          await db.execute('''
            CREATE TABLE $TABLE_TASKS(
              $COLUMN_TASK_ID TEXT PRIMARY KEY,
              $COLUMN_CLASS_ID_FK TEXT NOT NULL,
              $COLUMN_TITLE TEXT NOT NULL,
              $COLUMN_DESCRIPTION TEXT,
              $COLUMN_DEADLINE INTEGER,
              $COLUMN_ASSIGNED_DATE INTEGER,
              $COLUMN_COMPLETED_BY TEXT,
              FOREIGN KEY ($COLUMN_CLASS_ID_FK) REFERENCES $TABLE_CLASSES($COLUMN_CLASS_ID)
            )
          ''');
          debugPrint("✅ Tasks table recreated with proper schema");

          // Create other tables if they don't exist
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

          await db.execute('''
            CREATE TABLE IF NOT EXISTS $TABLE_ROUTINE(
              $COLUMN_ROUTINE_ID TEXT PRIMARY KEY,
              $COLUMN_CLASS_ID_ROUTINE TEXT NOT NULL,
              $COLUMN_COURSE TEXT NOT NULL,
              $COLUMN_ROOM TEXT,
              $COLUMN_TEACHER TEXT,
              $COLUMN_TIME TEXT,
              $COLUMN_DAY TEXT NOT NULL,
              FOREIGN KEY ($COLUMN_CLASS_ID_ROUTINE) REFERENCES $TABLE_CLASSES($COLUMN_CLASS_ID)
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS $TABLE_NOTICE (
              $COLUMN_NOTICE_ID TEXT PRIMARY KEY,
              $COLUMN_NOTICE_CLASS_ID TEXT NOT NULL,
              $COLUMN_NOTICE_TITLE TEXT NOT NULL,
              $COLUMN_NOTICE_DESCRIPTION TEXT,
              $COLUMN_NOTICE_CREATED_AT INTEGER,
              FOREIGN KEY ($COLUMN_NOTICE_CLASS_ID) REFERENCES $TABLE_CLASSES($COLUMN_CLASS_ID)
            )
          ''');

          debugPrint("✅ Database upgrade completed!");
        }
      },
    );
  }

  Future<bool> addUser({required UserModel model}) async {
    try {
      final db = await getDB();
      String joinedClassesJson = jsonEncode(model.joinedClasses);
      int lastLoginMillis =
          model.lastLogin?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch;

      int rowEffected = await db.insert(Table_users, {
        COLUMN_UID: model.uid,
        COLUMN_NAME: model.name,
        COLUMN_EMAIL: model.email,
        COLUMN_PHOTOURL: model.photoUrl,
        COLUMN_FCMTOKEN: model.fcmToken,
        COLUMN_JOINED_CLASSES: joinedClassesJson,
        COLUMN_LASTLOGIN: lastLoginMillis,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint('✅ User added successfully');

      return rowEffected > 0;
    } catch (e) {
      debugPrint("❌ Error adding user: $e");
      return false;
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final db = await getDB();
      final result = await db.query(Table_users);

      if (result.isNotEmpty) {
        final map = result.first;
        List<String> joinedClasses = [];
        if (map[COLUMN_JOINED_CLASSES] != null) {
          joinedClasses = List<String>.from(
            jsonDecode(map[COLUMN_JOINED_CLASSES] as String),
          );
        }

        Timestamp? lastLogin;
        if (map[COLUMN_LASTLOGIN] != null) {
          lastLogin = Timestamp.fromMillisecondsSinceEpoch(
            map[COLUMN_LASTLOGIN] as int,
          );
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
        debugPrint('⚠️ User not found in local DB');
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error getting user: $e");
      return null;
    }
  }

  Future<void> addClassRoom({required ClassRoomModel model}) async {
    try {
      final db = await getDB();
      String studentsJson = jsonEncode(model.students);
      String adminsJson = jsonEncode(model.admins);
      int createdAtMillis = model.createdAt.millisecondsSinceEpoch;

      await db.insert(TABLE_CLASSES, {
        COLUMN_CLASS_ID: model.id,
        COLUMN_CLASS_NAME: model.name,
        COLUMN_SUBJECT: model.subject,
        COLUMN_CREATED_BY: model.createdBy,
        COLUMN_CREATED_AT: createdAtMillis,
        COLUMN_STUDENTS: studentsJson,
        COLUMN_ADMINS: adminsJson,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      debugPrint("✅ Class inserted: ${model.name}");
    } catch (e) {
      debugPrint("❌ Error adding class: $e");
    }
  }

  Future<List<ClassRoomModel>> getAllClasses() async {
    try {
      final db = await getDB();
      final result = await db.query(TABLE_CLASSES);

      if (result.isNotEmpty) {
        return result.map((map) {
          List<String> students = [];
          if (map[COLUMN_STUDENTS] != null) {
            students = List<String>.from(
              jsonDecode(map[COLUMN_STUDENTS] as String),
            );
          }

          List<String> admins = [];
          if (map[COLUMN_ADMINS] != null) {
            admins = List<String>.from(
              jsonDecode(map[COLUMN_ADMINS] as String),
            );
          }

          Timestamp createdAt = Timestamp.fromMillisecondsSinceEpoch(
            map[COLUMN_CREATED_AT] as int,
          );

          debugPrint("✅ Loaded class from DB: ${map[COLUMN_CLASS_NAME]}");

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

  Future<ClassRoomModel?> getClass(String classID) async {
    try {
      final db = await getDB();
      final res = await db.query(
          TABLE_CLASSES,
          where: "$COLUMN_CLASS_ID = ?",
          whereArgs: [classID]
      );

      if (res.isNotEmpty) {
        final map = res.first;

        List<String> students = [];
        if (map[COLUMN_STUDENTS] != null) {
          students = List<String>.from(
            jsonDecode(map[COLUMN_STUDENTS] as String),
          );
        }

        List<String> admins = [];
        if (map[COLUMN_ADMINS] != null) {
          admins = List<String>.from(
            jsonDecode(map[COLUMN_ADMINS] as String),
          );
        }

        Timestamp createdAt = Timestamp.fromMillisecondsSinceEpoch(
          map[COLUMN_CREATED_AT] as int,
        );

        debugPrint("✅ Found class: ${map[COLUMN_CLASS_NAME]}");

        return ClassRoomModel(
          id: map[COLUMN_CLASS_ID] as String,
          name: map[COLUMN_CLASS_NAME] as String,
          subject: map[COLUMN_SUBJECT] as String,
          createdBy: map[COLUMN_CREATED_BY] as String,
          createdAt: createdAt,
          students: students,
          admins: admins,
        );
      } else {
        debugPrint('⚠️ Class not found: $classID');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting class: $e');
      return null;
    }
  }

  Future<void> clear() async {
    final db = await getDB();
    await db.delete(TABLE_TASKS);
    debugPrint("🗑️ All tasks cleared");
  }

  Future<void> insertTask(TaskModel task, String classId) async {
    try {
      final db = await getDB();

      debugPrint("🔍 Inserting task: ${task.title} for class: $classId");

      await db.insert(TABLE_TASKS, {
        COLUMN_TASK_ID: task.id,
        COLUMN_CLASS_ID_FK: classId,
        COLUMN_TITLE: task.title,
        COLUMN_DESCRIPTION: task.description,
        COLUMN_DEADLINE: task.deadline.millisecondsSinceEpoch,
        COLUMN_ASSIGNED_DATE: task.assignedDate?.millisecondsSinceEpoch,
        COLUMN_COMPLETED_BY: task.completedBy.isNotEmpty
            ? jsonEncode(task.completedBy)
            : null,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      debugPrint("✅ Task inserted: ${task.title}");
    } catch (e) {
      debugPrint("❌ Error inserting task: $e");
      rethrow;
    }
  }

  Future<List<TaskModel>> getAllTasks(String classId) async {
    try {
      final db = await getDB();
      final result = await db.query(
        TABLE_TASKS,
        where: '$COLUMN_CLASS_ID_FK = ?',
        whereArgs: [classId],
        orderBy: '$COLUMN_DEADLINE ASC',
      );

      debugPrint("✅ Found ${result.length} tasks for class: $classId");

      return result.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("❌ Error getting tasks: $e");
      return [];
    }
  }

  Future<void> insertRoutine(RoutineModel model, String classDocId, String day, String id) async {
    try {
      final db = await getDB();

      Map<String, dynamic> data = model.toFireStore();
      data[COLUMN_ROUTINE_ID] = id;
      data[COLUMN_CLASS_ID_ROUTINE] = classDocId;
      data[COLUMN_DAY] = day;

      await db.insert(
          TABLE_ROUTINE,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace
      );

      debugPrint("✅ Routine inserted: ${model.course} for $day");
    } catch (e) {
      debugPrint("❌ Error inserting routine: $e");
    }
  }

  Future<List<RoutineModel>> getRoutine(String classDocID, String day) async {
    try {
      final db = await getDB();

      final data = await db.query(
        TABLE_ROUTINE,
        where: "$COLUMN_CLASS_ID_ROUTINE = ? AND $COLUMN_DAY = ?",
        whereArgs: [classDocID, day],
      );

      debugPrint("✅ Found ${data.length} routines for $day");

      return data.map((e) => RoutineModel.fromFireStore(e)).toList();
    } catch (e) {
      debugPrint("❌ Error fetching routine: $e");
      return [];
    }
  }

  Future<void> insertNotice(NoticeModel model, String classId) async {
    try {
      final db = await getDB();
      Map<String, dynamic> data = model.toMap();
      data[COLUMN_NOTICE_ID] = model.id;
      data[COLUMN_NOTICE_CLASS_ID] = classId;

      await db.insert(
          TABLE_NOTICE,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace
      );

      debugPrint("✅ Notice inserted: ${model.title}");
    } catch (e) {
      debugPrint("❌ Notice insertion failed: $e");
    }
  }

  Future<List<NoticeModel>> getAllNotice(String classId) async {
    try {
      final db = await getDB();
      final List<Map<String, dynamic>> maps = await db.query(
        TABLE_NOTICE,
        where: '$COLUMN_NOTICE_CLASS_ID = ?',
        whereArgs: [classId],
        orderBy: '$COLUMN_NOTICE_CREATED_AT DESC',
      );

      debugPrint("✅ Found ${maps.length} notices for class: $classId");

      return List.generate(maps.length, (i) {
        return NoticeModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint("❌ Error getting notices: $e");
      return [];
    }
  }

  // Optional: Helper method to delete entire database (for testing)
  Future<void> deleteDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dpPath = join(appDir.path, 'eduLink.db');
    await databaseFactory.deleteDatabase(dpPath);
    myDB = null;
    debugPrint("🗑️ Database deleted completely");
  }
}