import 'package:amplify_api/amplify_api.dart';
import 'package:bloc/bloc.dart';
import 'package:social_media/data_repository.dart';

import 'auth/auth_credentials.dart';
import 'auth/auth_repository.dart';
import 'models/User.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;
  final DataRepository dataRepo;

  User get currentUser => (state as Authenticated).user;
  User? get selectedUser => (state as Authenticated).selectedUser;
  bool get isCurrentUserSelected =>
      selectedUser == null || currentUser.id == selectedUser!.id;

  SessionCubit({required this.authRepo, required this.dataRepo})
      : super(UnknownSessionState()) {
    attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    try {
      final userId = await authRepo.attemptAutoLogin();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      User? user = await dataRepo.getUserById(userId);

      ///этого не должно происходить, но на всякий случай сделано
      if (user == null) {
        user = await dataRepo.createUser(
          userId: userId,

          ///generic username
          username: 'User-${UUID()}',
        );
      }
      emit(Authenticated(user: user));
    } on Exception {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());

  void showSession(AuthCredentials credentials) async {
    try {
      User? user = await dataRepo.getUserById(credentials.userId!);

      if (user == null) {
        user = await dataRepo.createUser(
          userId: credentials.userId!,
          username: credentials.username,
          email: credentials.email,
        );
      }

      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void signOut() {
    authRepo.signOut();
    emit(Unauthenticated());
  }
}
