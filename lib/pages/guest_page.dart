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
    return DefaultTextStyle( // Wrap the entire app or a significant part
      style: const TextStyle(fontFamily: 'Roboto Condensed'),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Column(
          children: [
            _buildHeader(_getPageName(_selectedIndex)),
            Expanded(child: _buildContent()),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
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
              fontFamily: 'Roboto Condensed',
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
                      fontFamily: 'Roboto Condensed',
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7, // Increased further
        ),
        itemCount: promoItems.length,
        itemBuilder: (context, index) {
          final item = promoItems[index];
          if (item != null && item['displayname'] != null && item['pricelevel1_formatted'] != null) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out children vertically
                children: [
                  SizedBox(
                    height: 120.0,
                    child: Center(
                      child: item['itemimages_detail'] != null &&
                          item['itemimages_detail']['urls'] != null &&
                          item['itemimages_detail']['urls'].isNotEmpty &&
                          item['itemimages_detail']['urls'][0]['url'] != null
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          item['itemimages_detail']['urls'][0]['url'],
                          fit: BoxFit.contain,
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['displayname'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Roboto Condensed',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['pricelevel1_formatted'],
                        style: const TextStyle(
                          color: Color(0xFFF26722),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle adding to favorites/wishlist
                          print('Added to Favorites: ${item['displayname']}');
                        },
                        child: const Icon(
                          Icons.favorite_border,
                          color: Color(0xFFF26722),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: item['isinstock'] == true
                        ? ElevatedButton(
                      onPressed: () {
                        // Handle adding to cart
                        print('Add to Cart: ${item['displayname']}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF26722),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Add to Cart'),
                    )
                        : ElevatedButton(
                      onPressed: null,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.grey[600]!),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Out of Stock'),
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