import 'package:flutter/material.dart';
import 'drawer_item.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 124.0,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 189, 88, 0),
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          DrawerItem(
            icon: Icons.home,
            title: '홈',
            onTap: () => Navigator.pop(context),
          ),
          DrawerItem(
            icon: Icons.settings,
            title: '설정',
            onTap: () => Navigator.pop(context),
          ),
          DrawerItem(
            icon: Icons.info,
            title: '정보',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
