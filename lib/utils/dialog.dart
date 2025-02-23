import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_updated_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_updated_app/configs/config.dart';
import 'package:wallpaper_updated_app/pages/welcome.dart';
import 'package:wallpaper_updated_app/utils/next_screen.dart';

void openDialog(context, title, message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          title: Text(title),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'))
          ],
        );
      });
}

showUserInfo(context, name, email, imageUrl) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 0, right: 0, top: 40, bottom: 0),
          content: SizedBox(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: imageUrl == 'null' 
                          ? DecorationImage(image: AssetImage(Config().guestAvatar))
                          : DecorationImage(image: CachedNetworkImageProvider(imageUrl))
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Hi $name,',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'You have alredy signed in with\n$email',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade900),
                  ),
                  const Spacer(),
                  InkWell(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.blueAccent,
                      child: const Text(
                        'Ok, Got It',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              )),
        );
      });
}



showGuestUserInfo(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 0, right: 0, top: 40, bottom: 0),
          content: SizedBox(
              height: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: !context.watch<SignInBloc>().isSignedIn || context.watch<SignInBloc>().imageUrl == null
                                  ? DecorationImage(image: AssetImage(Config().guestAvatar))
                                  : DecorationImage(image: CachedNetworkImageProvider(context.watch<SignInBloc>().imageUrl!))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Hi there,',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text(
                      "You didn't sign in with ${Config().appName} yet. Sign in to unlock likes and save feature.\nDo you want to sign in now?",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade900),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            color: Colors.blueAccent,
                            child: const Text(
                              'Yes, Now',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            nextScreenPopup(context, const WelcomePage(closeDialog: true,));
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            color: Colors.blue[400],
                            child: const Text(
                              'Maybe Later',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        );
      });
}
