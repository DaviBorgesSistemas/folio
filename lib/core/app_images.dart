import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Imagens em PNG, JPG, WebP etc. (os SVGs ficam em `AppSvg`). Cada arquivo
/// também precisa estar listado em `assets:` no `pubspec.yaml`.
///
/// ```dart
/// AppImages.asset(AppImages.bg1, fit: BoxFit.cover)
/// ```
class AppImages {
  static const _images = 'assets/images';

  static const bg1 = '$_images/bg1.png';
  static const bg2 = '$_images/bg2.png';
  static const bg3 = '$_images/bg3.png';
  static const bg4 = '$_images/bg4.png';
  static const bg5 = '$_images/bg5.png';
  static const bg6 = '$_images/bg6.png';
  static const folioIcon ='assets/icons/folio-icon-foreground.png';

  static const backgrounds = [bg1, bg2, bg3, bg4, bg5, bg6];

  static Widget asset(
    String path, {
    double? size,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    return Image.asset(
      path,
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      color: color,
    );
  }
}

class AppSvg {
  static const _icons = 'assets/icons';

  static const folioMark = '$_icons/folio-mark.svg';
  static const albumOutline = '$_icons/album-outline.svg';
  static const iconTransparent ='$_icons/folio-transparent-icon.svg';


  /// `size` define largura e altura juntas; `width`/`height` têm prioridade.
  /// `color` pinta o desenho inteiro de uma cor só.
  static Widget asset(
    String path, {
    double? size,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return SvgPicture.asset(
      path,
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
