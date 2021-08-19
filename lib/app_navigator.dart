import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/BottomNavView/bottom_nav_bar_view.dart';
import 'package:social_media/profile/profile_view.dart';
import 'package:social_media/session_cubit.dart';
import 'auth/auth_cubit.dart';
import 'auth/auth_navigator.dart';
import 'loading_view.dart';
import 'session_state.dart';

class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(builder: (context, state) {
      return Navigator(
        pages: [
          // Show loading screen
          if (state is UnknownSessionState) MaterialPage(child: LoadingView()),

          // Show auth flow
          if (state is Unauthenticated)
            MaterialPage(
              child: BlocProvider(
                create: (context) =>
                    AuthCubit(sessionCubit: context.read<SessionCubit>()),
                child: AuthNavigator(),
              ),
            ),

          // Show session flow
          if (state is Authenticated) MaterialPage(child: BottomNavBarView())
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
