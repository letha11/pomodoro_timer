import 'package:flutter/material.dart';

import 'styled_switch.dart';

class TitleSwitch extends StatelessWidget {
  const TitleSwitch({
    super.key,
    required this.title,
    required this.onToggle,
  });

  final String title;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        StyledSwitch(
          onToggle: onToggle,
        ),
      ],
    );
  }
}
