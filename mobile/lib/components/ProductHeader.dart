import 'package:flutter/material.dart';
import 'ProductLogo.dart';

class ProductHeader extends StatelessWidget {
  const ProductHeader({ Key? key }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        ProductLogo(size: 60),
        Text(
          ' NLocker',
          style: TextStyle(
              fontSize: 40
          ),
        )
      ],
    );
  }
}
