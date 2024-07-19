import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_expo/src/bloc/stall_list_bloc/stall_list_bloc.dart';
import 'package:product_expo/src/router/router_generator.dart';
import 'package:product_expo/src/router/screen_routes.dart';
import 'package:product_expo/src/screen_util/app_widget_size.dart';
import 'package:product_expo/src/screen_util/screen_util.dart';
import 'package:product_expo/src/theme/light_theme.dart';

void main() {
  runApp(const ProductExpoApp());
}

class ProductExpoApp extends StatefulWidget {
  const ProductExpoApp({super.key});

  @override
  State<ProductExpoApp> createState() => _ProductExpoAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final scaffoldkey = GlobalKey<ScaffoldMessengerState>();

class _ProductExpoAppState extends State<ProductExpoApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<StallListBloc>(create: (context) => StallListBloc())
      ],
      child: ScreenUtilInit(
          scale: 1,
          designSize: const Size(414, 896),
          minTextAdapt: true,
          builder: (BuildContext context, Widget? child) {
            return FutureBuilder(
                future: AppWidgetSize().initSize(),
                builder: (context, snapshot) {
                  return bodyWidget();
                });
          }),
    );
  }

  Widget bodyWidget() {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: 1.0, boldText: false),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldkey,
      supportedLocales: const [Locale('en')],
      initialRoute: ScreenRoutes.splashScreen,
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.light,
      theme: lightTheme(),
      onGenerateRoute: generateRoute,
    );
  }
}
