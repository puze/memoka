import 'package:flutter/material.dart';
import 'package:memoka/tools/theme_colors.dart';

class CreditsRoute extends StatelessWidget {
  const CreditsRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: ThemeColors.backgroundColor,
        body: Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.asset('assets/moca_icon/credits.png')),
        ),
      ),
    );
  }
}
