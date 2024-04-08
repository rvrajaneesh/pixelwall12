import 'package:flutter/material.dart';
import 'package:wallpaper_updated_app/configs/config.dart';
import 'package:wallpaper_updated_app/widgets/new_items.dart';
import 'package:wallpaper_updated_app/widgets/popular_items.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              TabBar(
                controller: tabController,
                labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
                tabs: const <Widget>[
                  Tab(
                    child: Text(Config.popularItemsName),
                  ),
                  Tab(
                    child: Text(
                      Config.newItemsName,
                    ),
                  )
                ],
                labelColor: Colors.black,
                indicatorColor: Colors.grey[900],
                unselectedLabelColor: Colors.grey,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: BackButton(),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const <Widget>[
                PopularItems(),
                NewItems(
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
