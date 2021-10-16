import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'providers/temp_variables_provider.dart';
import 'screens/welcome/welcome_screen.dart';
import 'setup/setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Setup.instance.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TempVariables()),
    ],
    child: ConnectivityAppWrapper(
      app: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WelcomeScreen(), 
        title: "Read and Learn",
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          primaryColorLight: kPrimaryLightColor,
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    ),
  ));
}