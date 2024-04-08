import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {

  String? category;
  String? imagelUrl;
  int? loves;
  String? timestamp;

  ContentModel({
    
    this.category,
    this.imagelUrl,
    this.loves,
    this.timestamp,
    
  });


  factory ContentModel.fromFirestore(DocumentSnapshot snapshot){
    Map d = snapshot.data() as Map<dynamic, dynamic>;
    return ContentModel(
      category: d['category'],
      imagelUrl: d['image url'],
      loves: d['loves'],
      timestamp: d['timestamp'],


    );
  }
}