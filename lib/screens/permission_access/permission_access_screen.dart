import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/app_images.dart';
import 'package:folio/widgets/glass.dart';
import 'package:folio/widgets/primary_button.dart';

class PermissionAccessScreen extends StatelessWidget {
  const PermissionAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop(); // fecha o app
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
          child: Column(
            children: [
              GlassBox(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Icon(Icons.arrow_back),
                        Text(
                          'Permissões',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        AppSvg.asset(AppSvg.iconTransparent, size: 44),
                        Text(
                          'Folio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0XFF292A31),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          Flexible(
                            child: Text(
                              'Acesso para gerenciar todos os arquivos',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          // Só visual: parece um switch, mas não é interativo.
                          Container(
                            width: 48,
                            height: 28,
                            padding: const EdgeInsets.all(3),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.onAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Text(
                    'Habilite a permissão de acesso a todos os arquivos para explorar o Folio!',
                    style: TextStyle(
                      fontSize: 26,
                      letterSpacing: -0.78,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'A permissão de Acesso a Todos os Arquivos é necessária para acessar fotos e vídeos no seu dispositivo. Conceda esta permissão ao Folio para assegurar o uso normal do app.',
                    style: TextStyle(fontSize: 16, color: AppColors.muted),
                  ),
                  SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Vá agora',
                    onPressed: () {},
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PrimaryButton.transparent(
                      label: 'Sobre esta permissão',
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(height: 56),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
