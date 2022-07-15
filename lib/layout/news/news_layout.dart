import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udemy_flutter/Sherd/Cubit/to_do_cubit.dart';
import 'package:udemy_flutter/Sherd/components.dart';
import 'package:udemy_flutter/layout/news/cubit/cubit.dart';
import 'package:udemy_flutter/layout/news/cubit/states.dart';
import 'package:udemy_flutter/modules/Search/search_screen.dart';
import 'package:udemy_flutter/network/dio.dart';

class NewsLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => NewsCubit()
        ..getBusiness()
        ..getSports()
        ..getScience(),
      child: BlocConsumer<NewsCubit, NewsStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var cubit = NewsCubit.get(context);

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'News App',
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        navigateTo(
                          context,
                          SearchScreen(),
                        );
                      },
                      icon: Icon(Icons.search)),
                  IconButton(
                      onPressed: () {
                        cubit.changeAppMode();
                      },
                      icon: Icon(Icons.brightness_4_outlined)),
                ],
              ),
              body: cubit.screens[cubit.currentindex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentindex,
                onTap: (index) {
                  cubit.changeVottomNavBar(index);
                },
                items: cubit.bottomItems,
              ),
            );
          }),
    );
  }
}
