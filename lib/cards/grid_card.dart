import 'package:flutter/material.dart';
import 'package:wallpaper_updated_app/models/content_model.dart';
import 'package:wallpaper_updated_app/utils/next_screen.dart';
import '../configs/config.dart';
import '../pages/details.dart';
import '../widgets/cached_image.dart';

class GridCard extends StatelessWidget {
  const GridCard({Key? key, required this.d, required this.heroTag}) : super(key: key);

  final ContentModel d;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: <Widget>[
          Hero(tag: heroTag, child: cachedImage(d.imagelUrl)),
          Positioned(
            bottom: 30,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Config().hashTag,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  d.category!,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                )
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 20,
            child: Row(
              children: [
                Icon(Icons.favorite,
                    color: Colors.white.withOpacity(0.5), size: 25),
                Text(
                  d.loves.toString(),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        nextScreen(context, DetailsPage(heroTag: heroTag, d: d));
      },
    );
  }
}
