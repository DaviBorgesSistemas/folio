import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:folio/core/app_fonts.dart';
import 'package:folio/core/app_images.dart';
import 'package:folio/widgets/glass.dart';

/// Cabeçalho da marca: ícone em vidro (36 x 36) e o nome "FOLIO".
/// É um AppBar de verdade, então respeita a barra de status do sistema.
class FolioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FolioAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 24,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: GlassBox(
              radius: 12,
              innerHighlight: true,
              child: Center(
                child: SvgPicture.asset(
                  AppImages.albumOutline,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
          const Text(
            'FOLIO',
            style: TextStyle(
              fontWeight: AppFonts.extraBold,
              fontSize: 20,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
