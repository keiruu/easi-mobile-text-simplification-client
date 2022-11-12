import 'package:easi/history_ui.dart';
import 'package:easi/navigation.dart';
import 'package:easi/screens/registration_screen.dart';
import 'package:easi/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splashscreen/splashscreen.dart';
import 'internet_not_available.dart';
import 'profile.dart';
import 'package:easi/screens/login_screen.dart';
import 'auth_service.dart';

// void main() => runApp(MyApp());
void main() async {
  // Transparent status bar
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<InternetConnectionStatus>(
      initialData: InternetConnectionStatus.connected,
      create: (_) {
        return InternetConnectionChecker().onStatusChange;
      },
      child: MultiProvider(
        providers: [Provider<AuthService>(create: (_) => AuthService())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Inter',
              scaffoldBackgroundColor: Color(0xFFF6F6F8)),
          home: SplashScreen(
            useLoader: true,
            seconds: 4,
            navigateAfterSeconds: MyHomePage(),
            photoSize: 40,
            image: Image.asset(
              'assets/logo.png',
              height: 200,
              width: 200,
            ),
            backgroundColor: Colors.white,
          ),
          // initialRoute: '/',
          // routes: {
          //   '/': (context) => Wrapper(),
          //   '/login': (context) => LoginScreen(),
          //   '/register': (context) => RegistrationScreen(),
          //   '/profile': (context) => Profile(
          //         userKey: '',
          //       ),
          //   '/history': (context) => HistoryUI(),
          // },
        ),
      )
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  // Bottom navigation screen options
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
         Provider.of<InternetConnectionStatus>(context) ==
                    InternetConnectionStatus.disconnected ? Visibility(
          visible: Provider.of<InternetConnectionStatus>(context) ==
              InternetConnectionStatus.disconnected,
          child: const InternetNotAvailable(),
        ) : Wrapper()
      ],
    );
  }
}
