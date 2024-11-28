import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/screens/about_screen.dart';
import 'package:myanmar_hymns/src/screens/main_screen.dart';
import 'package:myanmar_hymns/src/screens/song_list_screen.dart';
import 'package:myanmar_hymns/src/screens/song_screen.dart';
import 'package:myanmar_hymns/src/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BaseModel>(
          create: (BuildContext context) => BaseModel(),
        )
      ],
      child: const RoutesProvider(),
    );
  }
}

class RoutesProvider extends StatelessWidget {
  const RoutesProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myanmar Hymns',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(255, 133, 27, 1),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromRGBO(246, 239, 209, 1),
      ),
      // ignore: prefer_const_literals_to_create_immutables
      routes: <String, WidgetBuilder>{
        '/': (context) => const SplashScreen(
              title: 'Splash Screen',
            ),
        '/main': (context) => const MainScreen(),
        '/song-list': (context) => const SongListScreen(),
        '/song': (context) => SongScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}
