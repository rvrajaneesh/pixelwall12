import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_updated_app/models/content_model.dart';

class DataBloc extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  
  List<ContentModel> _alldata = [];
  List<ContentModel> get alldata => _alldata;

  final List<DocumentSnapshot> _snap = [];


  final List _categories = [];
  List get categories => _categories;

  final List<bool> descending = [true, false];
  final List<String> orderBy = ['loves', 'category', 'timestamp', 'image url'];

  
  
  

  getData() async {
    _alldata.clear();
    _snap.clear();
    // ignore: no_leading_underscores_for_local_identifiers
    final bool _descending = descending.randomItem();
    // ignore: no_leading_underscores_for_local_identifiers
    final String _orderBy = orderBy.randomItem();

    QuerySnapshot snapshot = await firestore.collection('contents').orderBy(_orderBy, descending: _descending).limit(10).get();
    List rawData = snapshot.docs;
    rawData.shuffle();
    rawData.take(5).forEach((element)=> _snap.add(element));
    _alldata = _snap.map((e) => ContentModel.fromFirestore(e)).toList();
    notifyListeners();
  }


  Future getCategories ()async{
    QuerySnapshot snap = await firestore.collection('categories').get();
    var x = snap.docs;
    
    _categories.clear();

    for (var f in x) {
      _categories.add(f);
    }
    notifyListeners();
  }


 
}


extension RandomListItem<T> on List<T> {
  T randomItem() {
    return this[Random().nextInt(length)];
  }
}
