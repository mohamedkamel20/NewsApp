import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udemy_flutter/layout/news/cubit/states.dart';
import 'package:udemy_flutter/network/dio.dart';
import 'package:udemy_flutter/network/local/cache_helper.dart';
import 'package:udemy_flutter/news_models/business.dart';
import 'package:udemy_flutter/news_models/science.dart';

import 'package:udemy_flutter/news_models/sports.dart';

class NewsCubit extends Cubit<NewsStates> {
  NewsCubit() : super(NewsinitialState());

  static NewsCubit get(context) => BlocProvider.of(context);

  int currentindex = 0;
  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Busniess'),
    BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Sports'),
    BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Science'),
  ];
  List<Widget> screens = [
    BusinessScreen(),
    SportsScreen(),
    ScienceScreen(),
  ];
  void changeVottomNavBar(int index) {
    currentindex = index;
    // if (index == 1) {
    //   getSports();
    // } else
    //   getScience();
    emit(NewsBottomState());
  }

  List<dynamic> business = [];
  void getBusiness() {
    emit(NewsGetBusniessLoadingState());
    DioHelper.getDate(
      url: 'v2/top-headlines',
      query: {
        'country': 'eg',
        'category': 'business',
        'apiKey': '946a309eddf548448dd480ff5c140f6f',
      },
    )
        .then((value) => {
              // print(value.data['articles'][0]['title']),
              business = value.data['articles'],
              print(business[0]['title']),
              emit(NewsGetBusniessSuccessState())
            })
        .catchError((error) {
      print(error.toString());
      emit(NewsGetBusniessErrorState(error.toString()));
    });
  }

  List<dynamic> sports = [];
  void getSports() {
    emit(NewsGetSportsLoadingState());

    if (sports.length == 0) {
      DioHelper.getDate(
        url: 'v2/top-headlines',
        query: {
          'country': 'eg',
          'category': 'sports',
          'apiKey': '946a309eddf548448dd480ff5c140f6f',
        },
      )
          .then((value) => {
                // print(value.data['articles'][0]['title']),
                sports = value.data['articles'],
                print(sports[0]['title']),
                emit(NewsGetSportsSuccessState())
              })
          .catchError((error) {
        print(error.toString());
        emit(NewsGetSportsErrorState(error.toString()));
      });
    } else {
      emit(NewsGetSportsSuccessState());
    }
  }

  List<dynamic> science = [];
  void getScience() {
    emit(NewsGetScienceLoadingState());
    if (science.length == 0) {
      DioHelper.getDate(
        url: 'v2/top-headlines',
        query: {
          'country': 'eg',
          'category': 'science',
          'apiKey': '946a309eddf548448dd480ff5c140f6f',
        },
      )
          .then((value) => {
                // print(value.data['articles'][0]['title']),
                science = value.data['articles'],
                print(science[0]['title']),
                emit(NewsGetScienceSuccessState())
              })
          .catchError((error) {
        print(error.toString());
        emit(NewsGetScienceErrorState(error.toString()));
      });
    } else {
      emit(NewsGetScienceSuccessState());
    }
  }

  List<dynamic> search = [];
  void getsearch(String value) {
    emit(NewsGetSearchLoadingState());

    search = [];
    if (science.length == 0) {
      DioHelper.getDate(
        url: 'v2/everything',
        query: {
          'q': '$value',
          'apiKey': '946a309eddf548448dd480ff5c140f6f',
        },
      )
          .then((value) => {
                // print(value.data['articles'][0]['title']),
                search = value.data['articles'],
                print(search[0]['title']),
                emit(NewsGetSearchSuccessState())
              })
          .catchError((error) {
        print(error.toString());
        emit(NewsGetSearchErrorState(error.toString()));
      });
    } else {
      emit(NewsGetSearchSuccessState());
    }
  }

  bool isDark = false;

  void changeAppMode({bool fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
      emit(AppChangeMode());
    } else {
      isDark = !isDark;
      CacheHelper.putData(key: 'isDark', value: isDark)
          .then((value) => {emit(AppChangeMode())});
    }
  }
}

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }
}
