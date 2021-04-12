import 'package:camera/camera.dart';
import 'package:data_collection_app/screens/mouth_demo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/data_id_provider.dart';
import 'screens/entry_initial.dart';
import 'screens/home.dart';
import 'screens/log_in.dart';
import 'screens/sign_up.dart';
import 'screens/term_and_conditions.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  cameras = await availableCameras();

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
        title: 'Dehydration Data Collection App',
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
