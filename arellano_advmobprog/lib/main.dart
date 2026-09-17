//packages
import "package:flutter/material.dart";
import "package:flutter/services.dart";
// ignore: unused_import
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:provider/provider.dart";

import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';

//screens
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([ DeviceOrientation.portraitUp]).then ((

    _,
  ) async {
    await dotenv.load(fileName: "assets/.env");
    runApp(const ArellanoAdvMobProg());
  });
}

class ArellanoAdvMobProg extends StatelessWidget {
  const ArellanoAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider()..loadCartFromApi(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
        final themeModel = context.watch<ThemeProvider>();


        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeModel.lightTheme,
          darkTheme: themeModel.darkTheme,
          themeMode: themeModel.isDark
              ? ThemeMode.dark
              : ThemeMode.light,
          title: 'E-Commerce App',
          initialRoute: '/',

          routes: {
            '/': (context) =>
                const SplashScreen(),

            '/signin': (context) =>
              const SigninScreen(),

            '/home': (context) =>
                const HomeScreen(),

            '/settings': (context) =>
                const SettingsScreen(),
          },

        );
      },
      ),
    );
  }
}
    
  
        