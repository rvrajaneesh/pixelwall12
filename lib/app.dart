import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'blocs/ads_bloc.dart';
import 'blocs/bookmark_bloc.dart';
import 'blocs/data_bloc.dart';
import 'blocs/internet_bloc.dart';
import 'blocs/sign_in_bloc.dart';
import 'blocs/userdata_bloc.dart';
import 'pages/home.dart';
import 'pages/welcome.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<DataBloc>(
            create: (context) => DataBloc(),
          ),
          ChangeNotifierProvider<SignInBloc>(
            create: (context) => SignInBloc(),
          ),
          ChangeNotifierProvider<UserBloc>(
            create: (context) => UserBloc(),
          ),
          ChangeNotifierProvider<BookmarkBloc>(
            create: (context) => BookmarkBloc(),
          ),
          ChangeNotifierProvider<InternetBloc>(
            create: (context) => InternetBloc(),
          ),
          ChangeNotifierProvider<AdsBloc>(
            create: (context) => AdsBloc(),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              //fontFamily: 'Poppins',
              textTheme: GoogleFonts.poppinsTextTheme(),
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
                color: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
              ),
            ),
            home: const MyApp1()));
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return sb.isSignedIn == false && sb.guestUser == false
        ? const WelcomePage()
        : const HomePage();
  }
}
