import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/app_images.dart';
import 'package:folio/widgets/glass.dart';

class FoundedImagesTile extends StatelessWidget {

  const FoundedImagesTile({ super.key });

   @override
   Widget build(BuildContext context) {
       return Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 46),
                child: GlassBox(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 20,
                            color: Color(0XFFBFC2FF),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '1500',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: [
                          for (final path in AppImages.backgrounds)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AppImages.asset(path, fit: BoxFit.cover),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -12,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    color: Color(0XFFBFC2FF),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_special_rounded,color: Color(0XFF4A4E83),),
                      SizedBox(width: 6),
                      Text('8 pastas encontradas',style: TextStyle(color: Color(0XFF4A4E83),fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}