import 'package:flutter/material.dart';
import 'package:learn_english/util/constant.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onPressed;

  ActionButton({@required this.icon, @required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(
                width: 8.0,
              ),
              Text(
                label,
                style: kTextStyleDefault,
              ),
            ],
          ),
        ),
      ),
      onTap: onPressed,
    );
  }
}