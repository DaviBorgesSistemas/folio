import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/app_images.dart';
import 'package:folio/screens/welcome/widget/founded_images_tile.dart';
import 'package:folio/widgets/app_snack_bar.dart';
import 'package:folio/widgets/folio_app_bar.dart';
import 'package:folio/widgets/glass.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> _allow(BuildContext context) async {
    final state = await PhotoManager.requestPermissionExtend();
    // Depois de um await, a tela pode já ter saído: confira antes de usar o context.
    if (!context.mounted) return;
    if (state.hasAccess) {
      AppSnackBar.show(
        context,
        'Acesso às fotos liberado',
        type: AppSnackBarType.success,
      );
    } else {
      AppSnackBar.show(
        context,
        'Sem acesso às fotos',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FolioAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoundedImagesTile(),
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Suas fotos,\nseparadas por pasta',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.93,
                color: Color(0XFFE3E1E9),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'O Folio lê as imagens do seu celular e mostra cada pasta em um só lugar.',
              style: TextStyle(fontSize: 16, color: Color(0XFFC7C5D0)),
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _row('Encontra todas as pastas com imagens'),
                const SizedBox(height: 12),
                _row('Mostra quantas imagens há em cada uma'),
                const SizedBox(height: 12),
                _row('Não apaga nem move nada sem você pedir'),
              ],
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PrimaryButton(
              label: 'Permitir acesso às fotos',
              icon: Icons.photo_library_outlined,
              onPressed: () => _allow(context),
            ),
          ),
          SizedBox(height: 8),
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PrimaryButton.transparent(
              label: 'Agora não',
              onPressed: () => _allow(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0XFFBFC2FF).withValues(alpha: 0.15),
          ),
          child: Icon(Icons.check, size: 12, color: Color(0XFFBFC2FF)),
        ),
        SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 16, color: Color(0XFFE3E1E9))),
      ],
    );
  }
}
