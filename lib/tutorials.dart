import 'package:flutter/material.dart';
import 'package:memoka/tools/world_position.dart';

class Tutorials {
  static Widget getMainTutorialOverlay(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: OverlayMainTutorial(context: context),
        ),
        Positioned(
            top: (size.width / 2 - 10) * 193 / 264 + 10 + 10,
            left: 15 + 10,
            width: size.width / 2 - 30,
            height: ((size.width / 3 - 10) * 193 / 264),
            child: Image.asset('assets/tutorial/add.png')),
        Positioned(
            right: 41,
            bottom: size.height * 0.03,
            width: size.width * 0.6,
            child: Image.asset('assets/tutorial/setting.png'))
      ],
    );
  }

  static Widget getMemocaTutorialOverlay(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: OverlayMemocaTutorial(context: context),
        ),
        Positioned(
            left: size.width * 0.1,
            right: size.width / 2,
            top: 56 - 3,
            child: Image.asset('assets/tutorial/straight.png')),
        Positioned(
            left: size.width * 0.55,
            right: size.width * 0.05,
            top: 56 - 3,
            child: Image.asset('assets/tutorial/shuffle.png')),
        Positioned(
            left: size.width * 0.2,
            right: size.width * 0.24,
            top: size.width * 0.65 * 1.4 / 2,
            child: Image.asset('assets/tutorial/first_page.png')),
        Positioned(
            left: size.width * 0.15,
            right: size.width * 0.25,
            top: size.height * 0.5,
            child: Image.asset('assets/tutorial/tab.png')),
        Positioned(
            left: size.width * 0.15,
            right: size.width * 0.15,
            top: size.height * 0.6,
            child: Image.asset('assets/tutorial/swap.png')),
        Positioned(
            left: size.width * 0.45,
            right: size.width * 0.2,
            top: size.height * 0.8,
            child: Image.asset('assets/tutorial/add_voca.png')),
        Positioned(
            left: size.width * 0.35,
            right: size.width * 0.25,
            top: size.height * 0.33,
            child: Image.asset('assets/tutorial/remove_voca.png'))
      ],
    );
  }
}

class OverlayMainTutorial extends CustomPainter {
  BuildContext context;
  OverlayMainTutorial({required this.context});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            ..addOval(Rect.fromCircle(
                center: Offset(size.width - 41, size.height - 41), radius: 35))
            ..addRRect(RRect.fromLTRBR(
                15,
                15,
                // WorldPosition.offsetMemocaCover(context).dx,
                size.width / 2 - 10 + 5,
                (size.width / 2 - 10) * 193 / 264 + 10,
                const Radius.circular(15)))
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class OverlayMemocaTutorial extends CustomPainter {
  BuildContext context;
  OverlayMemocaTutorial({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            //정방향
            ..addOval(Rect.fromCircle(
                center: Offset(size.width / 2, 56 / 2), radius: 56 / 2 - 5))
            //셔플
            ..addOval(Rect.fromCircle(
                center: Offset((size.width * 2 / 3 + size.width) / 2, 56 / 2),
                radius: 56 / 2 - 5))
            // 첫페이지
            ..addOval(Rect.fromCircle(
                center: Offset(
                    size.width * 0.85,
                    (size.height + 56 - 10) / 2 -
                        size.width * 0.7 * 1.4 / 2 -
                        25),
                radius: size.width * 0.12))
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
