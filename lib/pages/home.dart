import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_updated_app/blocs/ads_bloc.dart';
import 'package:wallpaper_updated_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_updated_app/cards/feature_card.dart';
import 'package:wallpaper_updated_app/utils/dialog.dart';
import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../configs/config.dart';
import '../pages/bookmark.dart';
import '../pages/catagories.dart';
import '../pages/explore.dart';
import '../pages/internet.dart';
import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //-------admob--------
  Future initAdmobAd() async{
    await MobileAds.instance.initialize()
    .then((value) => context.read<AdsBloc>().loadAdmobInterstitialAd()); 
  }



  //------fb-------
  // Future initFbAd() async {
  //   await FacebookAudienceNetwork.init()
  //   .then((value) => context.read<AdsBloc>().loadFbAd());
  // }



  Future getData() async {
    Future.delayed(const Duration(milliseconds: 0)).then((f) {
      final sb = context.read<SignInBloc>();
      final db = context.read<DataBloc>();

      sb.getUserDatafromSP()
      .then((value) => db.getData())
      .then((value) => db.getCategories());
    });
  }





  @override
  void initState() {
    super.initState();
    initOnesignal();
    getData();

    initAdmobAd();          //-------admob--------
    //initFbAd();             //-------fb--------
  }



  initOnesignal (){
    OneSignal.shared.setAppId(Config().onesignalAppId);
  }



  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();

    return ib.hasInternet == false
        ? const NoInternetPage()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            endDrawer: const DrawerWidget(),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      height: 70,
                      child: Row(
                        children: <Widget>[
                          Text(
                            Config().appName,
                            style: const TextStyle(
                                fontSize: 27,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          InkWell(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: !context.watch<SignInBloc>().isSignedIn || context.watch<SignInBloc>().imageUrl == null || context.watch<SignInBloc>().imageUrl == 'null'
                                  ? DecorationImage(image: AssetImage(Config().guestAvatar))
                                  : DecorationImage(image: CachedNetworkImageProvider(context.watch<SignInBloc>().imageUrl!))),
                            ),
                            onTap: () {
                              !sb.isSignedIn
                                  ? showGuestUserInfo(context)
                                  : showUserInfo(context, sb.name, sb.email, sb.imageUrl);
                            },
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          IconButton(
                            icon: const Icon(
                              //steam
                              FontAwesomeIcons.barsStaggered,
                              size: 23,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                          )
                        ],
                      )),
                  
                  const FeatureCard(),
                  const Spacer(),
                  Container(
                    height: 50,
                    width: w * 0.80,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.dashcube,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CatagoryPage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidCompass,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ExplorePage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidHeart,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavouritePage(userUID: context.read<SignInBloc>().uid)));
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          );
  }
}
