import 'package:flutter/material.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  GuestPageState createState() => GuestPageState();
}

class GuestPageState extends State<GuestPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Text(
          'Page: ${_getPageName(_selectedIndex)}',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0A0A0A),
        selectedItemColor: const Color(0xFFF26722),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/icon-sp-2.png',
                  height: 50,
                  width: 50,
                  color: _selectedIndex == 0 ? const Color(0xFFF26722) : Colors.grey,
                ),
                const SizedBox(height: 2),
                Text(
                  'Home',
                  style: TextStyle(
                    color: _selectedIndex == 0 ? const Color(0xFFF26722) : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/tools.png',
                  height: 30,
                  width: 30,
                  color: _selectedIndex == 1 ? const Color(0xFFF26722) : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'Products',
                  style: TextStyle(
                    color: _selectedIndex == 1 ? const Color(0xFFF26722) : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/heart.png',
                  height: 30,
                  width: 30,
                  color: _selectedIndex == 2 ? const Color(0xFFF26722) : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'Wishlist',
                  style: TextStyle(
                    color: _selectedIndex == 2 ? const Color(0xFFF26722) : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/box-open.png',
                  height: 30,
                  width: 30,
                  color: _selectedIndex == 3 ? const Color(0xFFF26722) : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'Orders',
                  style: TextStyle(
                    color: _selectedIndex == 3 ? const Color(0xFFF26722) : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/dot-pending.png',
                  height: 30,
                  width: 30,
                  color: _selectedIndex == 4 ? const Color(0xFFF26722) : Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'More',
                  style: TextStyle(
                    color: _selectedIndex == 4 ? const Color(0xFFF26722) : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  String _getPageName(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Products';
      case 2:
        return 'Wishlist';
      case 3:
        return 'Orders';
      case 4:
        return 'More';
      default:
        return 'Home';
    }
  }
}
