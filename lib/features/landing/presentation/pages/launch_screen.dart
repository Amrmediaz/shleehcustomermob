import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/pages/login_page.dart';
import 'package:shleehcustomer/features/home_page/presentation/pages/home_page.dart';

import '../../../../core/util/cashed_data/cashed_file.dart';
import '../../../../core/util/common_functions.dart';
import 'landing_screen.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

late GifController _controller;
late bool isLaunched;
late bool isLogin;

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    _controller = GifController(vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Gif(
          image: AssetImage("assets/images/landing/animated_logo.gif"),
          controller:
              _controller, // if duration and fps is null, original gif fps will be used.
          //fps: 30,
          duration: const Duration(seconds: 3),
          autostart: Autostart.no,
          placeholder: (context) => const Text(''),
          onFetchCompleted: () {
            _controller.reset();
            _controller.forward();
            Future.delayed(const Duration(seconds: 5), () {
              configureNextScreen();

            });
          },
        ),
      ),
    );
  }

  void configureNextScreen() async {
    await CommonFunctions().checkDeviceType(context);

    isLaunched = await CasheFile().isAppLaunched();
    isLogin = await CasheFile().isLogin();
    if (!isLaunched) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const LandingPage()),
      );
    } else if (!isLogin) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const LoginPage()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const HomePage()),
      );
    }
    setState(() {});
  }
}
