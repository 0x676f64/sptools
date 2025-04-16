import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '/pages/products_page.dart';
import '/pages/wishlist_page.dart';
import '/pages/orders_page.dart';
import '/pages/more_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  List<dynamic> promoItems = [];
  bool _isLoadingPromoItems = true;
  String _promoItemsError = '';

  @override
  void initState() {
    super.initState();
    _fetchPromoImages();
    _fetchPromoItems();
  }

  Future<void> _fetchPromoImages() async {
    setState(() {
      promoImages = [
        'https://www.sptoolsusa.com/SC_Assets/homepage-banner-Q22025.jpg'
      ];
    });
  }

  Future<void> _fetchPromoItems() async {
    final url = Uri.parse(
        'https://www.sptoolsusa.com/api/cacheable/items?c=7071087&commercecategoryurl=%2Fproducts%2Fpromos&country=US&currency=USD&facet.exclude=custitem_ns_sc_ext_only_pdp%2Ccustitem_ns_sc_ext_gift_cert_group_id%2Citemtype&fieldset=search&include=facets&language=en&limit=48&matrixchilditems_fieldset=matrixchilditems_search&n=2&offset=0&pricelevel=5&sort=custitem_ns_sc_ext_ts_365_amount%3Adesc&use_pcv=T');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData != null && decodedData['items'] != null && decodedData['items'] is List) {
          setState(() {
            promoItems = decodedData['items'];
            _isLoadingPromoItems = false;
          });
        } else {
          setState(() {
            _promoItemsError = 'API response missing or invalid data. Check API response: ${response.body}';
            _isLoadingPromoItems = false;
          });
        }
      } else {
        setState(() {
          _promoItemsError = 'Failed to load promo items: ${response.statusCode}. Check API response: ${response.body}';
          _isLoadingPromoItems = false;
        });
        print('Failed to load promo items: ${response.statusCode}. Check API response: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _promoItemsError = 'An error occurred loading promo items: $e. Check error: $e';
        _isLoadingPromoItems = false;
      });
      print('Error fetching promo items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          _buildHeader(_getPageName(_selectedIndex)),
          Expanded(child: _buildContent()),
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
    return SingleChildScrollView(
      child: Padding( // Added padding to the entire homepage
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40.0),
            _buildPromoCarousel(),
            const SizedBox(height: 20.0),
            _buildPromoItemsGrid(),
          ],
        ),
      ),
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
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 2.0),
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

  Widget _buildPromoItemsGrid() {
    if (_isLoadingPromoItems) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (_promoItemsError.isNotEmpty) {
      return Center(child: Text(_promoItemsError, style: const TextStyle(color: Colors.red)));
    } else if (promoItems.isEmpty) {
      return const Center(child: Text('No promo items found.', style: TextStyle(color: Colors.white)));
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16, // Increased spacing
          mainAxisSpacing: 16, // Increased spacing
          childAspectRatio: 0.7,
        ),
        itemCount: promoItems.length,
        itemBuilder: (context, index) {
          final item = promoItems[index];
          if (item != null && item['displayname'] != null && item['pricelevel1_formatted'] != null) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(12.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['displayname'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Increased spacing
                  Text(
                    item['pricelevel1_formatted'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10), // Increased spacing
                  Expanded(
                    child: Center(
                      child: item['image'] != null
                          ? Image.network(
                        item['image']['url'],
                        fit: BoxFit.contain,
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    }
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