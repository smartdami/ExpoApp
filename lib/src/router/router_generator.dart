import 'dart:io';

import 'package:flutter/material.dart';
import 'package:product_expo/src/data/app_constants.dart';
import 'package:product_expo/src/router/screen_routes.dart';
import 'package:product_expo/src/ui/screens/stall_detailed_screen.dart';

import '../ui/screens/splash_screen.dart';
import '../ui/screens/stall_list_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case ScreenRoutes.splashScreen:
     return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.splashScreen,
        ),
        builder: (BuildContext context) {
          return const SplashScreen();
        },
      );
    case ScreenRoutes.stallListScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.stallListScreen,
        ),
        builder: (BuildContext context) {
          return const StallListScreen();
        },
      );
    case ScreenRoutes.stallDetailedScreen:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.stallDetailedScreen,
        ),
        builder: (BuildContext context) {
          return StallDetailedScreen(
            stallIndex: (args as Map)[AppConstants.stallIndex],
            stallList: (args)[AppConstants.stallDetails],
          );
        },
      );
    default:
      return SlideRoute(
        settings: const RouteSettings(
          name: ScreenRoutes.stallListScreen,
        ),
        builder: (BuildContext context) {
          return const StallListScreen();
        },
      );
  }
}

class SlideRoute extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;
  @override
  final RouteSettings settings;
  SlideRoute({required this.settings, required this.builder})
      : super(
            settings: settings,
            barrierDismissible: true,
            transitionDuration: const Duration(milliseconds: 0),
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                builder(context),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              const begin = Offset(1, 0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: GestureDetector(
                    onHorizontalDragEnd: (dragEndDetails) {
                      if (Navigator.canPop(context) &&
                          (dragEndDetails.primaryVelocity ?? 0) > 1000 &&
                          Platform.isIOS) {
                        Navigator.pop(context);
                      }
                    },
                    child: child),
              );
            });
}
