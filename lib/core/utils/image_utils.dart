import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageUtils {
  static const importIcon = 'assets/images/import.svg';
  static const playIcon = 'assets/images/play.svg';
  static const pauseIcon = 'assets/images/pause.svg';
  static const stopIcon = 'assets/images/stop.svg';
  static const settingIcon = 'assets/images/setting.svg';

  static const backgroundImage = 'assets/images/bg.png';

  static precacheImages(BuildContext context) {
    const images = [
      backgroundImage,
    ];

    for (final image in images) {
      precacheImage(Image.asset(image).image, context);
    }
  }
  static precacheSvgImages() {
    const images = [
      importIcon,
      playIcon,
      pauseIcon,
      stopIcon,
      settingIcon,
    ];

    for (final image in images) {
      final loader = SvgAssetLoader(image);
      svg.cache
          .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }
  }
}
