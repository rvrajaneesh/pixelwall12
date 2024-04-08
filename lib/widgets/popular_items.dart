import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper_updated_app/utils/snacbar.dart';
import '../cards/grid_card.dart';
import '../models/content_model.dart';

class PopularItems extends StatefulWidget {

  const PopularItems({Key? key}) : super(key: key);

  @override
  State<PopularItems> createState() => _PopularItemsState();
}

class _PopularItemsState extends State<PopularItems> with AutomaticKeepAliveClientMixin {



  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<ContentModel> _data = [];
  final List<DocumentSnapshot> _snap = [];

  @override
  void initState() {
    controller = ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<void> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firestore
          .collection('contents')
          .orderBy('loves', descending: true)
          .limit(10)
          .get();
    } else {
      data = await firestore
          .collection('contents')
          .orderBy('loves', descending: true)
          .startAfter([_lastVisible!['loves']])
          .limit(10)
          .get();
    }

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

  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
    super.dispose();
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
    super.build(context);
    return Column(
        children: [
          Expanded(
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              controller: controller,
              itemCount: _data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < _data.length) {
                  final ContentModel d = _data[index];
                  return GridCard(d: d, heroTag: 'popular-${d.timestamp}',);
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
      );
  }



  @override
  bool get wantKeepAlive => true;
  
}