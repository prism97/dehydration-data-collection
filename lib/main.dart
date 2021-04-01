import 'package:data_collection_app/providers/data_id_provider.dart';
import 'package:data_collection_app/screens/entry_initial.dart';
import 'package:data_collection_app/screens/home.dart';
import 'package:data_collection_app/screens/log_in.dart';
import 'package:data_collection_app/screens/sign_up.dart';
import 'package:data_collection_app/screens/term_and_conditions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DataIdProvider(),
        )
      ],
      child: MaterialApp(
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
          EntryInitial.id: (context) => EntryInitial(),
        },
        initialRoute: FirebaseAuth.instance != null &&
                FirebaseAuth.instance.currentUser != null
            ? Home.id
            : LogIn.id,
      ),
    );
  }
}
