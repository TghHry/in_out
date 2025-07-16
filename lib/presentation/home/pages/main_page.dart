
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:in_out_2/presentation/attandance/pages/attandance_page.dart';
import 'package:in_out_2/presentation/history/pages/history_page.dart';
import 'package:in_out_2/presentation/home/pages/home_page.dart';
import 'package:in_out_2/presentation/profile/pages/profile_page.dart';


import 'package:in_out_2/utils/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    AttandancePage(),
    const HistoryPage(userId: 'dummy_user_id'),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('MainPage: initState terpanggil.');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    debugPrint('MainPage: Item tab dipilih: $index');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MainPage: build terpanggil. Index terpilih: $_selectedIndex');

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: Container(
        color: AppColors.historyCardBackground,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppColors.historyCardBackground,
          selectedItemColor: AppColors.bottomNavIconColor,
          unselectedItemColor: AppColors.bottomNavIconColor.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Kehadiran'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
