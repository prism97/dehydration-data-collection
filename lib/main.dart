import 'package:data_collection_app/screens/home.dart';
import 'package:data_collection_app/screens/log_in.dart';
import 'package:data_collection_app/screens/sign_up.dart';
import 'package:data_collection_app/screens/term_and_conditions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      routes: {
        TermsAndConditions.id: (context) => TermsAndConditions(),
        SignUp.id: (context) => SignUp(),
        LogIn.id: (context) => LogIn(),
        Home.id: (context) => Home(),
      },
      initialRoute: SignUp.id,
    );
  }
}
