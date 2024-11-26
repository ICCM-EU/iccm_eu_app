import 'package:flutter/material.dart';

class ToggleButtonListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String toggleTitle;

  const ToggleButtonListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.toggleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return  SwitchListTile(
      title: Text(title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.black,
      activeTrackColor: Colors.grey[800]!.withOpacity(0.4),
      inactiveThumbColor: Colors.grey[300]!.withOpacity(0.4),
      inactiveTrackColor: Colors.grey[700]!.withOpacity(0.4),
      splashRadius: 28,
      contentPadding: EdgeInsets.zero,//symmetric(horizontal: 16.0),
    );
  }
}