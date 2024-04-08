import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:wallpaper_updated_app/pages/login.dart';
import 'package:wallpaper_updated_app/utils/next_screen.dart';
import '../blocs/sign_in_bloc.dart';
import '../utils/snacbar.dart';
import '../widgets/privacy_info.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _loginController = RoundedLoadingButtonController();

  final TextEditingController _nameCtlr = TextEditingController();
  final TextEditingController _emailCtlr = TextEditingController();
  final TextEditingController _passCtlr = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obsecureText = true;
  IconData lockIcon = CupertinoIcons.eye_slash_fill;

  _onSuffixIconPressed() {
    if (_obsecureText == true) {
      setState(() {
        _obsecureText = false;
        lockIcon = CupertinoIcons.eye_fill;
      });
    } else {
      setState(() {
        _obsecureText = true;
        lockIcon = CupertinoIcons.eye_slash_fill;
      });
    }
  }

  _handleAfterSignupGoogle() {
    Future.delayed(const Duration(milliseconds: 1000)).then((f) {
      nextScreenCloseOthers(context, const HomePage());
    });
  }

  _handleSignUpWithEmail() async {
    final sb = context.read<SignInBloc>();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _loginController.start();
      await sb
          .signUpWithEmail(
              _nameCtlr.text, _emailCtlr.text.trim(), _passCtlr.text)
          .then((_) {
        if (sb.hasError == true) {
          openSnackbar(context, 'Something is wrong. Please try again.');
          _loginController.reset();
        } else {
          sb.getTimestamp().then((value) => sb
              .saveToFirebase()
              .then((value) => sb.increaseUserCount())
              .then((value) => sb.guestSignout())
              .then((value) => sb
                  .saveDataToSP()
                  .then((value) => sb.setSignIn().then((value) {
                        _loginController.success();
                        _handleAfterSignupGoogle();
                      }))));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.grey[900],
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
              const SizedBox(
                height: 20,
              ),
              Container(
                color: Colors.white,
                child: TextFormField(
                  controller: _nameCtlr,
                  validator: (value) {
                    if (value!.isEmpty) return "Name can't be empty!";
                    return null;
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Full Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _nameCtlr.clear)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                color: Colors.white,
                child: TextFormField(
                  controller: _emailCtlr,
                  validator: (value) {
                    if (value!.isEmpty) return "Email can't be empty!";
                    return null;
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _emailCtlr.clear)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                color: Colors.white,
                child: TextFormField(
                  obscureText: _obsecureText,
                  controller: _passCtlr,
                  validator: (value) {
                    if (value!.isEmpty) return "Password can't be empty!";
                    return null;
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: IconButton(
                          onPressed: _onSuffixIconPressed,
                          icon: Icon(lockIcon))),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              RoundedLoadingButton(
                animateOnTap: false,
                borderRadius: 5,
                controller: _loginController,
                onPressed: () => _handleSignUpWithEmail(),
                width: MediaQuery.of(context).size.width * 1.0,
                color: Theme.of(context).primaryColor,
                elevation: 0,
                child: Wrap(
                  children: const [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                        child: Text(
                          'Login',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () =>
                            nextScreenReplace(context, const LoginPage())),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Center(child: PrivacyInfo())
            ],
          ),
        ),
      ),
    );
  }
}
