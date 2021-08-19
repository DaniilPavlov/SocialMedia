import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/comments/comments_view.dart';
import 'package:social_media/profile/profile_view.dart';

import 'home_navigator_cubit.dart';
import 'home_view.dart';

class HomeNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeNavigatorCubit(),
      child: BlocBuilder<HomeNavigatorCubit, HomeNavigatorState>(
          builder: (context, state) {
        return Navigator(
          pages: [
            MaterialPage(child: (HomeView())),
            if (state == HomeNavigatorState.profile)
              MaterialPage(child: ProfileView()),
            if (state == HomeNavigatorState.comments)
              MaterialPage(child: CommentsView())
          ],
          onPopPage: (route, result) {
            ///должно решить проблему с pop
            context.read<HomeNavigatorCubit>().showHome();
            return route.didPop(result);
          },
        );
      }),
    );
  }
}
