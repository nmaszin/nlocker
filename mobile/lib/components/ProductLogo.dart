import 'package:flutter/material.dart';

class ProductLogo extends StatelessWidget {
  final double size;

  const ProductLogo({ Key? key, required this.size }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          'assets/images/nmaszin.png',
          width: size,
        )
    );
  }
}
