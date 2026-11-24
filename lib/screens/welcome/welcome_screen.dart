import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/widgets/folio_app_bar.dart';
import 'package:folio/widgets/glass.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FolioAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 46),
            child: GlassBox(padding: EdgeInsets.all(16),child: Column(
              children: [
                Row(children: [
                  Icon(Icons.folder_outlined,size: 20,),SizedBox(width: 8),Text('WhatsApp',style: TextStyle(fontSize: 16,color: AppColors.text,fontWeight: FontWeight.bold,),)
                ,Spacer(),Text('1500',style: TextStyle(fontSize: 14,color: AppColors.muted),)],)
              ],
            )),
          )
        ],
      ),
    );
  }
}
