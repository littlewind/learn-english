import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final bool isLoading;
  final IconData icon;
  final double iconRadius;
  final double padding;
  final Color backgroundColor;
  final Color iconColor;

  CustomIcon(
      {@required this.icon,
      this.iconRadius = 40,
      this.padding = 8,
      this.backgroundColor = Colors.teal,
      this.iconColor = Colors.white,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Container(
            width: iconRadius + padding,
            height: iconRadius + padding,
            color: Color(0x20000000),
          ),
        ),
        isLoading
            ? CircularProgressIndicator()
            : ClipOval(
                child: Container(
                  color: backgroundColor,
                  child: Icon(
                    icon,
                    size: iconRadius,
                    color: iconColor,
                  ),
                ),
              ),
      ],
    );
  }
}
