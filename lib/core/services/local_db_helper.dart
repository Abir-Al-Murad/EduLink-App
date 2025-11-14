import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/classroom/data/models/class_room_model.dart';
import '../../features/notice/data/models/notice_model.dart';
import '../../features/profile/data/models/user_model.dart';
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
      version: 1,
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
        await db.execute('''
  CREATE TABLE $TABLE_TASKS(
    $COLUMN_TASK_ID TEXT PRIMARY KEY,
    $COLUMN_TITLE TEXT NOT NULL,
    $COLUMN_DESCRIPTION TEXT,
    $COLUMN_DEADLINE TEXT,
    $COLUMN_ASSIGNED_DATE TEXT,
    $COLUMN_COMPLETED_BY TEXT,
    $COLUMN_CLASS_ID_FK TEXT
  )
''');

        await db.execute('''
          CREATE TABLE $TABLE_ROUTINE(
          $COLUMN_COURSE TEXT NOT NULL,
          $COLUMN_ROOM TEXT,
          $COLUMN_TEACHER TEXT,
          $COLUMN_TIME TEXT,
          $COLUMN_CLASS_ID_ROUTINE TEXT,
          $COLUMN_DAY TEXT,
          $COLUMN_ROUTINE_ID TEXT PRIMARY KEY
          )
        ''');

        await db.execute(
          '''CREATE TABLE $TABLE_NOTICE (
              $COLUMN_NOTICE_ID TEXT PRIMARY KEY,
              $COLUMN_NOTICE_CLASS_ID TEXT,
              $COLUMN_NOTICE_TITLE TEXT NOT NULL,
              $COLUMN_NOTICE_DESCRIPTION TEXT,
              $COLUMN_NOTICE_CREATED_AT INTEGER
          )'''
        );
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

      final result = await db.query(Table_users);

      if (result.isNotEmpty) {
        final map = result.first;

        // Parse joinedClasses JSON string back to List<String>
        List<String> joinedClasses = [];
        if (map[COLUMN_JOINED_CLASSES] != null) {
          joinedClasses = List<String>.from(
            jsonDecode(map[COLUMN_JOINED_CLASSES] as String),
          );
        }

        // Parse lastLogin from milliseconds
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
      await db.insert(TABLE_CLASSES, {
        COLUMN_CLASS_ID: model.id,
        COLUMN_CLASS_NAME: model.name,
        COLUMN_SUBJECT: model.subject,
        COLUMN_CREATED_BY: model.createdBy,
        COLUMN_CREATED_AT: createdAtMillis,
        COLUMN_STUDENTS: studentsJson,
        COLUMN_ADMINS: adminsJson,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

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
            students = List<String>.from(
              jsonDecode(map[COLUMN_STUDENTS] as String),
            );
          }

          // Decode admins list
          List<String> admins = [];
          if (map[COLUMN_ADMINS] != null) {
            admins = List<String>.from(
              jsonDecode(map[COLUMN_ADMINS] as String),
            );
          }

          // Parse createdAt from milliseconds
          Timestamp createdAt = Timestamp.fromMillisecondsSinceEpoch(
            map[COLUMN_CREATED_AT] as int,
          );
          debugPrint("✅ Imported From LocalDB - ${map[COLUMN_CLASS_NAME]}");
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
  Future<ClassRoomModel?>getClass(String classID)async{
    try{
      final db =await getDB();
      final res =await db.query(TABLE_CLASSES,where: "$COLUMN_CLASS_ID = ?",whereArgs:[classID]);
      return ClassRoomModel.fromFireStore(res.first,res.first[COLUMN_CLASS_ID].toString());
    }catch(e){
      return null;
    }
  }

  Future<void> clear() async {
    final db = await getDB();
    await db.delete(TABLE_TASKS);
  }

  Future<void> insertTask(TaskModel task, String classId) async {
    try {
      final db = await getDB();
      debugPrint(
        "🔍 Inserting task: id=${task.id}, title=${task.title}, classId=$classId",
      );
      await db.insert(TABLE_TASKS, {
        COLUMN_CLASS_ID_FK: classId,
        COLUMN_TITLE: task.title,
        COLUMN_TASK_ID: task.id,
        COLUMN_DESCRIPTION: task.description,
        COLUMN_DEADLINE: task.deadline.millisecondsSinceEpoch,
        COLUMN_ASSIGNED_DATE: task.assignedDate?.millisecondsSinceEpoch,
        COLUMN_COMPLETED_BY: task.completedBy != null
            ? jsonEncode(task.completedBy)
            : null,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint("✅ Task inserted: ${task.title}");
    } catch (e) {
      debugPrint("❌ Error inserting task: $e");
    }
  }

  Future<List<TaskModel>> getAllTasks(String classId) async {
    try {
      final db = await getDB();
      final result = await db.query(
        TABLE_TASKS,
        where: '$COLUMN_CLASS_ID_FK = ?',
        whereArgs: [classId],
      );
      return result.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("❌ Error getting tasks: $e");
      return [];
    }
  }

  Future<void> insertRoutine(RoutineModel model, String classDocId,String day,String id) async {
    try {
      final db = await getDB();

      // Create a map with all data
      Map<String, dynamic> data = model.toFireStore();
      data[COLUMN_CLASS_ID_ROUTINE] = classDocId;
      data[COLUMN_DAY] = day;
      data[COLUMN_ROUTINE_ID] = id;


      await db.insert(
          TABLE_ROUTINE,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace
      );

      debugPrint("✅ Routine inserted: ${model.course} for $classDocId for day ${data[COLUMN_DAY]}");
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

      debugPrint("🔍 Found ${data.length} routines for $day from local DB");

      return data.map((e) => RoutineModel.fromFireStore(e)).toList();
    } catch (e) {
      debugPrint("❌ Fetching Routine Failed: $e");
      return [];
    }
  }


  Future<void> insertNotice(NoticeModel model,String classId)async{
    try{
      final db =await getDB();
      Map<String,dynamic> data = model.toMap();
      data[COLUMN_NOTICE_ID] = model.id;
      data[COLUMN_NOTICE_CLASS_ID] = classId;
      db.insert(TABLE_NOTICE, data,conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint("Successfully  Notice - ${model.title} inserted");
    }catch(e){
      debugPrint("Notice Insertion failed");
    }
  }

  Future<List<NoticeModel>> getAllNotice(String classId) async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      TABLE_NOTICE,
      where: '$COLUMN_NOTICE_CLASS_ID = ?',
      whereArgs: [classId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return NoticeModel.fromMap(maps[i]);
    });
  }

}
