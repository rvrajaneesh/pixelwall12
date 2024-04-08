import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInBloc extends ChangeNotifier {


  SignInBloc() {
    checkSignIn();
    checkGuestUser();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _guestUser = false;
  bool get guestUser => _guestUser;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _name;
  String? get name => _name;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? timestamp;




  

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googlSignIn.signIn();
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final User userDetails = (await _firebaseAuth.signInWithCredential(credential)).user!;

        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _uid = userDetails.uid;

        _hasError = false;
        notifyListeners();
      } catch (e) {
        _hasError = true;
        _errorCode = e.toString();
        notifyListeners();
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future signInWithEmail (String email, String password)async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((UserCredential? userCredential){
      if(userCredential != null){
        _uid  = userCredential.user!.uid;
        _hasError = false;
        notifyListeners();
      }else{
        _hasError = true;
        notifyListeners();
      }
    }).catchError((e){
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    });
  }

  Future signUpWithEmail (String name, String email, String password)async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).then((UserCredential? userCredential){
      if(userCredential != null){
        _uid  = userCredential.user!.uid;
        _email = userCredential.user!.email;
        _name = userCredential.user!.displayName ?? name;
        _imageUrl = null;
        _hasError = false;
        notifyListeners();
      }else{
        _hasError = true;
        notifyListeners();
      }
    }).catchError((e){
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    });
  }

  Future<bool> checkUserExists() async {
    DocumentSnapshot snap = await firestore.collection('users').doc(_uid).get();
    if(snap.exists){
      debugPrint('User Exists');
      return true;
    }else{
      debugPrint('new user');
      return false;
    }
  }



  Future saveToFirebase() async {
    final DocumentReference ref = firestore.collection('users').doc(uid);
    await ref.set({
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'timestamp': timestamp,
      'loved items': []
    });
  }

  Future getTimestamp() async {
    DateTime now = DateTime.now();
    // ignore: no_leading_underscores_for_local_identifiers
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    timestamp = _timestamp;
  }

  Future saveDataToSP() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.setString('name', _name!);
    await sharedPreferences.setString('email', _email!);
    await sharedPreferences.setString('image url', _imageUrl ?? 'null');
    await sharedPreferences.setString('uid', _uid!);
  }

  Future getUserDatafromSP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    
    _name = sp.getString('name');
    _email = sp.getString('email');
    _uid = sp.getString('uid');
    _imageUrl = sp.getString('image url');
    notifyListeners();
  }




  Future getUserDataFromFirebase(uid) async {
    await firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snap) {
      _uid = snap['uid'];
      _name = snap['name'];
      _email = snap['email'];
      _imageUrl = snap['image url'];
      debugPrint("name: $_name, Image Url: $imageUrl ");
    });
    notifyListeners();
  }





  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed in') ?? false;
    notifyListeners();
  }

  Future userSignout() async {
    await _firebaseAuth.signOut().catchError((e)=> debugPrint(e.toString()));
    if(_imageUrl != null){
      await _googlSignIn.signOut();
    }
    _isSignedIn = false;
    _guestUser = false;
    await clearAllData();
    notifyListeners();
  }

  Future setGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest user', true);
    _guestUser = true;
    notifyListeners();
  }

  void checkGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _guestUser = sp.getBool('guest user') ?? false;
    notifyListeners();
  }

  Future clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  Future guestSignout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest user', false);
    _guestUser = false;
    notifyListeners();
  }


  Future<int> getTotalUsersCount () async {
    const String fieldName = 'count';
    final DocumentReference ref = firestore.collection('item_count').doc('users_count');
      DocumentSnapshot snap = await ref.get();
      if(snap.exists == true){
        int itemCount = snap[fieldName] ?? 0;
        return itemCount;
      }
      else{
        await ref.set({
          fieldName : 0
        });
        return 0;
      }
  }


  Future increaseUserCount () async {
    await getTotalUsersCount()
    .then((int documentCount)async {
      await firestore.collection('item_count')
      .doc('users_count')
      .update({
        'count' : documentCount + 1
      });
    });
  }


  
}
