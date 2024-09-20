import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';
import 'package:iccm_eu_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ToggleIsDarkModeListTile extends ToggleButtonListTile {

  ToggleIsDarkModeListTile({
    super.key,
    required BuildContext context})
  : super (
    value: Provider.of<ThemeProvider>(context, listen: true).isDarkMode,
    onChanged: (value) {
      Provider.of<ThemeProvider>(context, listen: false).saveTheme(value);
    },
    title: 'Dark Mode',
    toggleTitle: 'Theme',
  );
}
