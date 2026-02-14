import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

/// Native Advanced (template) reklam widget'ı. Flow vb. ekranlarda kullanılır.
/// Premium kullanıcıya reklam göstermez.
class FlowNativeAd extends StatefulWidget {
  const FlowNativeAd({super.key, required this.isCurrentUserPremium});
  final bool isCurrentUserPremium;

  @override
  State<FlowNativeAd> createState() => _FlowNativeAdState();
}

class _FlowNativeAdState extends State<FlowNativeAd> {
  final _log = Logger('NativeAdWidget');
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  AdMobService? _admobService;
  ShowAdUseCase? _showAdUseCase;

  void _onAdMobInitialized() {
    _admobService?.isInitialized.removeListener(_onAdMobInitialized);
    if (mounted) _loadAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_admobService == null) {
      _admobService = context.read<AdMobService>();
      _showAdUseCase = context.read<ShowAdUseCase>();
      if (!widget.isCurrentUserPremium) {
        if (_admobService!.isInitialized.value) {
          _loadAd();
        } else {
          _admobService!.isInitialized.addListener(_onAdMobInitialized);
        }
      }
    }
  }

  Future<void> _loadAd() async {
    if (widget.isCurrentUserPremium || _isAdLoading || _isAdLoaded) return;
    final showAdUseCase = _showAdUseCase;
    if (showAdUseCase == null) return;

    setState(() => _isAdLoading = true);

    try {
      final result = await showAdUseCase.loadNativeAd();
      if (!mounted) return;
      switch (result) {
        case Ok():
          setState(() {
            _nativeAd = result.asOk.value;
            _isAdLoaded = true;
            _isAdLoading = false;
          });
          break;
        case Error():
          _log.warning('Native ad load failed: ${result.asError.error}');
          setState(() {
            _isAdLoaded = false;
            _isAdLoading = false;
            _nativeAd = null;
          });
          break;
      }
    } catch (e) {
      _log.severe('Error loading native ad: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
          _isAdLoading = false;
          _nativeAd = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _admobService?.isInitialized.removeListener(_onAdMobInitialized);
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final adHeight = responsive.isSmallScreen
        ? 250.0
        : responsive.isMediumScreen
        ? 270.0
        : 320.0;
    final adWidth = responsive.isSmallScreen
        ? responsive.screenWidth * 0.9
        : responsive.screenWidth * 0.8;
    if (widget.isCurrentUserPremium) return const SizedBox.shrink();

    if (_isAdLoading) {
      return const SizedBox(
        height: 320,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_isAdLoaded && _nativeAd != null) {
      return SizedBox(
        width: adWidth,
        height: adHeight,
        child: AdWidget(ad: _nativeAd!),
      );
    }

    return const SizedBox.shrink();
  }
}
