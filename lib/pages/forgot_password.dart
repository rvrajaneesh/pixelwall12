
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/snacbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {

  var formKey = GlobalKey<FormState>();
  var emailCtrl = TextEditingController();
  late String _email;



  void handleSubmit (){
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();
      _resetPassword(_email);
    }
  }



  Future<void> _resetPassword(String email) async {
    final FirebaseAuth auth = FirebaseAuth.instance; 

    try{
      await auth.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      openSnackbar(context, 'An email has been sent to $email. Go to that link & reset your password.');

    } catch(error){
      openSnackbar(context, error.toString());
      
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[900],),
          onPressed: ()=> Navigator.pop(context),
        ),
      ),
        body: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Reset Your Password', style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w700
                )),
                const SizedBox(
                  height: 50,
                ),
                
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'username@mail.com',
                    labelText: 'Email'
                    
                  
                    
                  ),
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value){
                    if (value!.isEmpty) return "Email can't be empty";
                    return null;
                  },
                  onChanged: (String value){
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                const SizedBox(height: 80,),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) => Theme.of(context).primaryColor)
                    ),
                    child: const Text('Submit', style: TextStyle(
                      fontSize: 16,
                    ),),
                    onPressed: (){
                      handleSubmit();
                  }),
                ),
                const SizedBox(height: 50,),
                ],
              ),
            ),
        ),
      
    );
  }
}