import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:wallpaper_updated_app/blocs/sign_in_bloc.dart';
import '../configs/config.dart';
import '../pages/bookmark.dart';
import '../pages/catagories.dart';
import '../pages/explore.dart';
import '../pages/welcome.dart';
import '../utils/next_screen.dart';
import 'package:provider/provider.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var textCtrl = TextEditingController();

  final List title = [
    'Categories',
    'Explore',
    'Saved Items',
    'About App',
    'Rate & Review'
  ];

  final List icons = [
    FontAwesomeIcons.dashcube,
    FontAwesomeIcons.solidCompass,
    FontAwesomeIcons.solidHeart,
    FontAwesomeIcons.info,
    FontAwesomeIcons.star
  ];

  Future openLogoutDialog(context1) async {
    showDialog(
        context: context1,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Logout?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: const Text('Do you really want to Logout from the app?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  final sb = context.read<SignInBloc>();
                  Navigator.pop(context);
                  await sb.userSignout()
                      .then((_) => nextScreenReplace(context, const WelcomePage()));
                },
              ),
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  aboutAppDialog() {
    showDialog(
        context: context,
        builder: (BuildContext coontext) {
          return AboutDialog(
            applicationVersion: Config().appVersion,
            applicationName: Config().appName,
            applicationIcon: Image(
              height: 40,
              width: 40,
              image: AssetImage(Config().appIcon),
            ),
            applicationLegalese: 'Designed & Developed By\nMRB Lab',
          );
        });
  }

  void handleRating() {
    LaunchReview.launch(
        androidAppId: Config().packageName, iOSAppId: null, writeReview: true);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 50, left: 0),
                alignment: Alignment.center,
                height: 150,
                child: Text(
                  Config().hashTag.toUpperCase(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: title.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: SizedBox(
                        height: 45,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                icons[index],
                                color: Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(title[index],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (index == 0) {
                          nextScreeniOS(context, const CatagoryPage());
                        } else if (index == 1) {
                          nextScreeniOS(context, const ExplorePage());
                        } else if (index == 2) {
                          nextScreeniOS(context, FavouritePage(userUID: context.read<SignInBloc>().uid));
                        } else if (index == 3) {
                          aboutAppDialog();
                        } else if (index == 4) {
                          handleRating();
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                ),
              ),
              Column(
                children: [
                  !context.watch<SignInBloc>().isSignedIn
                      ? Container()
                      : Column(
                          children: [
                            const Divider(),
                            InkWell(
                              child: SizedBox(
                                height: 45,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Row(
                                    children: const <Widget>[
                                      Icon(
                                        Icons.logout,
                                        color: Colors.grey,
                                        size: 25,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text('Logout',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                openLogoutDialog(context);
                              },
                            ),
                          ],
                        ),
                ],
              ),
            ],
          )),
    );
  }
}
