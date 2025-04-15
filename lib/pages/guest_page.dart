import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '/pages/products_page.dart';
import '/pages/wishlist_page.dart';
import '/pages/orders_page.dart';
import '/pages/more_page.dart';


class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  GuestPageState createState() => GuestPageState();
}

class GuestPageState extends State<GuestPage> {
  int _selectedIndex = 0;
  int _cartItemCount = 0;
  int _currentPromoIndex = 0;
  List<String> promoImages = [];

  @override
  void initState() {
    super.initState();
    _fetchPromoImages();
  }

  Future<void> _fetchPromoImages() async {
    setState(() {
      promoImages = [
        'https://www.sptoolsusa.com/SC_Assets/homepage-banner-Q22025.jpg'
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          _buildHeader(_getPageName(_selectedIndex)), // Header
          Expanded(child: _buildContent()), // Content
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(String pageName) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pageName,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          Stack(
            children: [
              const Icon(
                Icons.shopping_cart,
                color: Colors.grey,
                size: 30,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1.0),
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
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const ProductsView();
      case 2:
        return const WishlistView();
      case 3:
        return const OrdersView();
      case 4:
        return const MoreView();
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        const SizedBox(height: 40.0),
        _buildPromoCarousel(),
        const Spacer(),
      ],
    );
  }

  Widget _buildPromoCarousel() {
    return promoImages.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPromoIndex = index;
              });
            },
          ),
          items: promoImages.map((image) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
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
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0A0A0A),
      selectedItemColor: const Color(0xFFF26722),
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        _buildNavBarItem('icon-sp-2.png', 'Home', 0, 50),
        _buildNavBarItem('tools.png', 'Products', 1, 30),
        _buildNavBarItem('heart.png', 'Wishlist', 2, 30),
        _buildNavBarItem('box-open.png', 'Orders', 3, 30),
        _buildNavBarItem('dot-pending.png', 'More', 4, 30),
      ],
    );
  }

  BottomNavigationBarItem _buildNavBarItem(String icon, String label, int index, double size) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$icon',
            height: size,
            width: size,
            color: _selectedIndex == index ? const Color(0xFFF26722) : Colors.grey,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? const Color(0xFFF26722) : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
      label: '',
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getPageName(int index) {
    return ['SP Tools Home', 'Products', 'Wishlist', 'Orders', 'More'][index];
  }
}
