import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallpaper_updated_app/configs/config.dart';

class AdsBloc extends ChangeNotifier {

  @override
  void dispose() {
    disposeAdmobInterstitialAd();      //admob
    //destroyFbAd();                       //fb
    super.dispose();                     
  }


  //admob Ads -------Start--------

  bool _admobAdLoaded = false;
  bool get admobAdLoaded => _admobAdLoaded;

  InterstitialAd? interstitialAdAdmob;

  void createAdmobInterstitialAd() {

    InterstitialAd.load(
        adUnitId: Config().admobInterstitialAdId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            interstitialAdAdmob = ad;
            _admobAdLoaded = true;
            notifyListeners();
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            interstitialAdAdmob = null;
            _admobAdLoaded = false;
            notifyListeners();
            loadAdmobInterstitialAd();
          },
        ));
  }



  void showInterstitialAdAdmob() {
    if(interstitialAdAdmob != null){

      interstitialAdAdmob!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        interstitialAdAdmob = null;
        _admobAdLoaded = false;
        notifyListeners();
        loadAdmobInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        interstitialAdAdmob = null;
        _admobAdLoaded = false;
        notifyListeners();
        loadAdmobInterstitialAd();
      },
      );
      interstitialAdAdmob!.show();
      interstitialAdAdmob = null;
      notifyListeners();
    }
  }



  Future loadAdmobInterstitialAd() async {
    if(_admobAdLoaded == false){
      createAdmobInterstitialAd();
    }
  }

  

  Future disposeAdmobInterstitialAd() async {
    interstitialAdAdmob?.dispose();
    notifyListeners();
  }

  // admob ads --------- end --------






  //fb ads ----------- start ----------

  // bool _fbadloaded = false;
  // bool get fbadloaded => _fbadloaded;


  // Future loadFbAd() async{
  //   FacebookInterstitialAd.loadInterstitialAd(
  //     placementId: Config().facebookInterstitialAdId,
  //     listener: (result, value) {
  //       print(result);
  //       if (result == InterstitialAdResult.LOADED){
  //         _fbadloaded = true;
  //         print('ads loaded');
  //         notifyListeners();
  //       }else if(result == InterstitialAdResult.DISMISSED && value["invalidated"] == true){
  //         _fbadloaded = false;
  //         print('ads dismissed');
  //         loadFbAd();
  //         notifyListeners();
  //       }
          
  //     }
  //   );
  // }



  // Future showFbAdd() async{
  //   if(_fbadloaded == true){
  //     await FacebookInterstitialAd.showInterstitialAd();
  //     _fbadloaded = false;
  //     notifyListeners();
  //   }
    
  // }



  // Future destroyFbAd() async{
  //   if (_fbadloaded == true) {
  //     FacebookInterstitialAd.destroyInterstitialAd();
  //     _fbadloaded = false;
  //     notifyListeners();
  //   }
  // }




  //fb ads ----------- end ----------


}
