import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import 'package:wallpaper_updated_app/pages/login.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../configs/config.dart';
import '../pages/home.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';

class WelcomePage extends StatefulWidget {
  
  const WelcomePage({Key? key, this.closeDialog}) : super(key: key);

  final bool? closeDialog;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {


  final RoundedLoadingButtonController _googleBtn = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _emailBtn = RoundedLoadingButtonController();


  handleGuestUser() async {
    final sb = context.read<SignInBloc>();
    await sb.setGuestUser().then((_){
      if(widget.closeDialog == null || widget.closeDialog == false){
        Future.delayed(const Duration(milliseconds: 500))
        .then((value) => nextScreenReplace(context, const HomePage()));
      }else{
        Navigator.pop(context);
      }
    });
  }



  Future handleGoogleSignIn() async {
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      // ignore: use_build_context_synchronously
      openSnackbar(context, 'Check your internet connection!');
    } else {
      await sb.signInWithGoogle().then((_) {
        if (sb.hasError == true) {
          openSnackbar(context, 'Something is wrong. Please try again.');
          _googleBtn.reset();
        } else {
          sb.checkUserExists().then((isUserExisted) async {
            if (isUserExisted) {
              await sb.getUserDataFromFirebase(sb.uid)
              .then((value) => sb.guestSignout())
              .then((value) => sb.saveDataToSP()
              .then((value) => sb.setSignIn()
              .then((value) {
                _googleBtn.success();
                handleAfterSignupGoogle();
              })));
            } else {
              sb.getTimestamp()
              .then((value) => sb.saveToFirebase()
              .then((value) => sb.increaseUserCount())
              .then((value) => sb.guestSignout())
              .then((value) => sb.saveDataToSP()
              .then((value) => sb.setSignIn()
              .then((value) {
                _googleBtn.success();
                handleAfterSignupGoogle();
            }))));
            }
          });
        }
      });
    }
  }



  handleAfterSignupGoogle() {
    Future.delayed(const Duration(milliseconds: 1000)).then((f) {
      if(widget.closeDialog == null || widget.closeDialog == false){
        nextScreenReplace(context, const HomePage());
      }else{
        Navigator.pop(context);
      }
    });
  }

  _onEmailPressed (){
    nextScreen(context, const LoginPage());
  }
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          actions: [

            widget.closeDialog == null || widget.closeDialog == false ?
            TextButton(
                onPressed: () {
                  handleGuestUser();
                },
                child: const Text('Skip'))
            : Container()
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 90, left: 40, right: 40, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                        image: AssetImage(Config().splashIcon),
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Welcome to ${Config().appName}!',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Explore thousands of free wallpapers for your phone and set them as your Lockscreen or HomeScreen anytime you want.',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),
                Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.70,
                          child: RoundedLoadingButton(
                            controller: _googleBtn,
                            onPressed: () => handleGoogleSignIn(),
                            width: MediaQuery.of(context).size.width * 0.80,
                            color: Colors.blueAccent,
                            elevation: 0,
                            borderRadius: 25,
                            child: Wrap(
                              children: const [
                                Icon(
                                  FontAwesomeIcons.google,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'Sign In with Google',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15,),
                        SizedBox(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.70,
                          child: RoundedLoadingButton(
                            animateOnTap: false,
                            controller: _emailBtn,
                            onPressed: () => _onEmailPressed(),
                            width: MediaQuery.of(context).size.width * 0.80,
                            color: Colors.deepPurple,
                            elevation: 0,
                            borderRadius: 25,
                            child: Wrap(
                              children: const [
                                Icon(
                                  FontAwesomeIcons.envelope,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'Continue with Email',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),



                      ],
                    ))
              ],
            ),
          ),
        ));
  }

  
}
