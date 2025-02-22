import 'package:flutter/material.dart';
import 'package:icar/src/core/app.dart';

class Tips {
  static void customizedToast(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw Exception('[toast] No valid context found for Toast.');
    }
    final colorScheme = Theme.of(context).colorScheme;
    final overlayState = Overlay.of(context, rootOverlay: true);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.9,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 5.0),
                ]),
            child: Text(
              message,
              style: TextStyle(
                  color: colorScheme.onErrorContainer, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }

  static void snackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw Exception('[toast] No valid context found for Toast.');
    }
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onSecondary),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: colorScheme.secondary,
    ));
  }
}
