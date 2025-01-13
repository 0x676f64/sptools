import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  GuestPageState createState() => GuestPageState();
}

class GuestPageState extends State<GuestPage> {
  int _selectedIndex = 0;
  int _cartItemCount = 0;
  int _currentPromoIndex = 0;

  final List<String> promoImages = [
    'assets/images/promo1.png',
    'assets/images/promo2.png',
    'assets/images/promo3.png',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _selectedIndex == 0 ? _buildHomePage() : Center(
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
          for (var item in [
            {'icon': 'tools.png', 'label': 'Products', 'index': 1},
            {'icon': 'heart.png', 'label': 'Wishlist', 'index': 2},
            {'icon': 'box-open.png', 'label': 'Orders', 'index': 3},
            {'icon': 'dot-pending.png', 'label': 'More', 'index': 4},
          ])
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/${item['icon']}',
                    height: 30,
                    width: 30,
                    color: _selectedIndex == item['index'] ? const Color(0xFFF26722) : Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      color: _selectedIndex == item['index'] ? const Color(0xFFF26722) : Colors.grey,
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

  Widget _buildHomePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SP Tools Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 30,
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 50),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPromoIndex = index;
                    });
                  },
                ),
                items: promoImages.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: promoImages.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _currentPromoIndex = entry.key;
                    }),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPromoIndex == entry.key
                            ? const Color(0xFFF26722)
                            : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
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
