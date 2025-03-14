import 'package:flutter/material.dart';

class BottomBarItem extends StatelessWidget {
  final Widget inActiveItem;
  final Widget activeItem;
  final String itemLabel;

  BottomBarItem({
    required this.inActiveItem,
    required this.activeItem,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          inActiveItem,
          activeItem,
          Text(itemLabel),
        ],
      ),
    );
  }
}
