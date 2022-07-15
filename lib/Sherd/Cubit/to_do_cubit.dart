import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udemy_flutter/Sherd/Cubit/to_do_states.dart';
import 'package:udemy_flutter/layout/news/cubit/states.dart';
import 'package:udemy_flutter/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:udemy_flutter/modules/done_tasks/done_tasks_screen.dart';
import 'package:udemy_flutter/modules/new_tasks/new_tasks_screen.dart';
import 'package:udemy_flutter/network/local/cache_helper.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppinitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> tittles = ['New Tasks ', 'Done Tasks ', 'Archived Tasks'];

  void changeindex(int index) {
    currentIndex = index;
    emit(AppchangeBottomNavbarrState());
  }

  Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDB() {
    openDatabase(
      'task.db',
      version: 1,
      onCreate: (database, version) {
        print(' database created ');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT , status TEXT)')
            .then((value) {
          print('created table');
        }).catchError((error) {
          print("Error when creating database ${error.toString()}");
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('open database');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabse({
    @required String title,
    @required String time,
    @required String date,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks (title,date,time,status) VALUES("$title","$date"  , "$time" , " NEW " )')
          .then((value) {
        print('$value inserted successfuly');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error) {
        print("Error when inserting database ${error.toString()}");
      });
      return null;
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];

    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'NEW') {
          newTasks.add(element);
        } else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateData({
    @required String status,
    @required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    @required int id,
  }) async {
    database
      ..rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
        getDataFromDatabase(database);
        emit(AppDeleteDatabaseState());
      });
  }

  bool isBottonSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
  }) {
    isBottonSheetShown = isShow;
    fabIcon = icon;
    emit(AppchangeBottomSheetState());
  }

  bool isDark = false;

  void changeAppMode() {
    isDark = !isDark;
    CacheHelper.putData(key: 'isDark', value: isDark)
        .then((value) => {emit(AppChangeModeState())});
  }
}

// void createDB() async {
//   database = await openDatabase(
//     'task.db',
//     version: 1,
//     onCreate: (database, version) {
//       print(' database created ');
//       database
//           .execute(
//               'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT , status TEXT)')
//           .then((value) {
//         print('created table');
//       }).catchError((error) {
//         print("Error when creating database ${error.toString()}");
//       });
//     },
//     onOpen: (database) {
//       getDataFromDatabase(database).then((value) {
//         // setState(() {
//         //   tasks = value;
//         // });
//       });
//       print('open database');
//     },
//   );
// }

// Future insertToDatabse({
//   @required String title,
//   @required String time,
//   @required String date,
// }) async {
//   return await database.transaction((txn) {
//     txn
//         .rawInsert(
//             'INSERT INTO tasks (title,date,time,status) VALUES("$title","$date"  , "$time" , " NEW " )')
//         .then((value) {
//       print('$value inserted successfuly');
//     }).catchError((error) {
//       print("Error when inserting database ${error.toString()}");
//     });
//     return null;
//   });
// }

// Future<List<Map>> getDataFromDatabase(database) async {
//   return await database.rawQuery('SELECT * FROM tasks');
// }
