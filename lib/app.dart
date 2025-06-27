import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_map/pages/dashborads/dashboard.dart';

class AppInitBuilder extends StatelessWidget {
  const AppInitBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPageView(),
    );
  }
}
