import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../../domain/domain.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, required this.isCurrentUserPremium});
  final bool isCurrentUserPremium;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final _log = Logger('BannerAdWidget');
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (widget.isCurrentUserPremium || _isAdLoading || _isAdLoaded) {
      return;
    }

    setState(() {
      _isAdLoading = true;
    });

    try {
      final showAdUseCase = context.read<ShowAdUseCase>();
      final adUnitId = showAdUseCase.getBannerAdUnitId();
      final adRequest = showAdUseCase.createBannerAdRequest();

      _log.info('Loading banner ad with unit ID: $adUnitId');

      final bannerAd = BannerAd(
        adUnitId: adUnitId,
        request: adRequest,
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            _log.info('Banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
                _isAdLoading = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            _log.warning('Banner ad failed to load: ${error.message}');
            ad.dispose();
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _isAdLoading = false;
                _bannerAd = null;
              });
            }
          },
          onAdOpened: (_) {
            _log.info('Banner ad opened');
          },
          onAdClosed: (_) {
            _log.info('Banner ad closed');
          },
        ),
      );
      _bannerAd = bannerAd;
      bannerAd.load();
    } catch (e) {
      _log.severe('Error loading banner ad: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
          _isAdLoading = false;
          _bannerAd = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ad yükleniyor
    if (_isAdLoading) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Ad yüklendi
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: double.infinity,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Hata durumu veya ad yüklenemedi
    // Sessizce gizle (kullanıcıya hata göstermiyoruz)
    return const SizedBox.shrink();
  }
}
