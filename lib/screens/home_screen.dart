import 'package:flutter/material.dart';
import '../widgets/naver_map_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'ZARI'),
      drawer: CustomDrawer(),
      body: NaverMapWidget(),
    );
  }
}
