import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_updated_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_updated_app/cards/grid_card.dart';
import 'package:wallpaper_updated_app/models/content_model.dart';
import 'package:wallpaper_updated_app/pages/empty_page.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({Key? key, required this.userUID}) : super(key: key);
  final String? userUID;

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  
  
  


  Future<List> _getData (List bookmarkedList)async {
    debugPrint('main list: ${bookmarkedList.length}]');

    List d = [];
    if(bookmarkedList.length <= 10){
      await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: bookmarkedList)
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
      });

    }else if(bookmarkedList.length > 10){

      int size = 10;
      var chunks = [];

      for(var i = 0; i< bookmarkedList.length; i+= size){    
        var end = (i+size<bookmarkedList.length)?i+size:bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
        });
      });

    }else if(bookmarkedList.length > 20){

      int size = 10;
      var chunks = [];

      for(var i = 0; i< bookmarkedList.length; i+= size){    
        var end = (i+size<bookmarkedList.length)?i+size:bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
        });
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[2])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
        });
      });

    }
    
    return d;
    
  }






  @override
  Widget build(BuildContext context) {

    const String collectionName = 'users';
    const String snapText = 'loved items';


    return Scaffold(
      appBar: AppBar(title: const Text('Saved Items', style: TextStyle(color: Colors.black),)),
      body: context.read<SignInBloc>().guestUser == true || widget.userUID == null
      ? const EmptyPage(
          icon: FontAwesomeIcons.heart,
          title: 'No wallpapers found.\n Sign in to access this feature',
        ) 
      : StreamBuilder(
          stream: FirebaseFirestore.instance.collection(collectionName).doc(widget.userUID!).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snap) {
            if (!snap.hasData) return const CircularProgressIndicator();
            
            List bookamrkedList = snap.data[snapText];
            return FutureBuilder(
              future: _getData(bookamrkedList),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }else if(!snapshot.hasData){
                  return const EmptyPage(icon: FontAwesomeIcons.heart,title: 'No wallpapers found',);
                }else if (snapshot.hasError){
                  return const Center(child: Text('Error'),);
                }else{
                  return _buildList(snapshot);
                } 
                  
              });
            },
        
          ),
    );
  }



  Widget _buildList(snapshot) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        final ContentModel d = snapshot.data[index];
        return GridCard(d: d, heroTag: 'bookmark-${d.timestamp}',);
      },
      staggeredTileBuilder: (int index) => StaggeredTile.count(2, index.isEven ? 4 : 3),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(15),
    );
  }
}
