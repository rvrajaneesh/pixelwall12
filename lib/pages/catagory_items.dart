import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper_updated_app/cards/grid_card.dart';
import 'package:wallpaper_updated_app/models/content_model.dart';
import 'package:wallpaper_updated_app/utils/snacbar.dart';

class CatagoryItem extends StatefulWidget {
  final String? title;
  final String? selectedCatagory;
  const CatagoryItem({Key? key, required this.title, this.selectedCatagory})
      : super(key: key);

  @override
  State<CatagoryItem> createState() => _CatagoryItemState();
}

class _CatagoryItemState extends State<CatagoryItem> {

  @override
  void initState() {
    controller = ScrollController()..addListener(_scrollListener);
    _isLoading = true;
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
    super.dispose();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<ContentModel> _data = [];
  final List<DocumentSnapshot> _snap = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firestore
          .collection('contents')
          .where('category', isEqualTo: widget.selectedCatagory)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    } else
      // ignore: curly_braces_in_flow_control_structures
      data = await firestore
          .collection('contents')
          .where('category', isEqualTo: widget.selectedCatagory)
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible!['timestamp']])
          .limit(10)
          .get();

    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => ContentModel.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() => _isLoading = false);
      // ignore: use_build_context_synchronously
      openSnackbar(context, 'No more contents!');
    }
    return;
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.title!,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              controller: controller,
              itemCount: _data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < _data.length) {
                  final ContentModel d = _data[index];
                  return GridCard(d: d, heroTag: 'category-${d.timestamp}',);
                }
                return Center(
                  child: Opacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    child: const SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: CupertinoActivityIndicator()),
                  ),
                );
              },
              staggeredTileBuilder: (int index) => StaggeredTile.count(2, index.isEven ? 4 : 3),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(15),
            ),
          ),
        ],
      ),
    );
  }
}
