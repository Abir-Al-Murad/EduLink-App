import 'package:flutter/material.dart';

class HeroLogo extends StatelessWidget {
  const HeroLogo({
    super.key, required this.tag, required this.imagePath,
  });
  final String tag;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Hero(tag: tag,
        child: Image.asset(imagePath,height: 200,));
  }
}
