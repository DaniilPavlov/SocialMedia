import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/session_cubit.dart';

import 'amplifyconfiguration.dart';
import 'app_navigator.dart';
import 'auth/auth_repository.dart';
import 'data_repository.dart';
import 'loagind_view.dart';
import 'models/ModelProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: _isAmplifyConfigured
            ? MultiRepositoryProvider(
                providers: [
                  RepositoryProvider(create: (context) => AuthRepository()),
                  RepositoryProvider(create: (context) => DataRepository())
                ],
                child: BlocProvider(
                  create: (context) => SessionCubit(
                    authRepo: context.read<AuthRepository>(),
                    dataRepo: context.read<DataRepository>(),
                  ),
                  child: AppNavigator(),
                ),
              )
            : LoadingView());
  }

  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
        AmplifyAPI(),
      ]);

      await Amplify.configure(amplifyconfig);

      setState(() => _isAmplifyConfigured = true);
    } catch (e) {
      print(e);
    }
  }
}
