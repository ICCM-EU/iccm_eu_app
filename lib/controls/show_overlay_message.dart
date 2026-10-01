import 'package:flutter/material.dart';

void showOverlayMessage(BuildContext context, String message, {Color? backgroundColor}) {
  final overlayState = Overlay.of(context);
  final theme = Theme.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: backgroundColor != null ? Colors.white : theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: backgroundColor != null ? Colors.white : theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);

  // Remove the overlay after 5 seconds
  Future.delayed(const Duration(seconds: 5), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}