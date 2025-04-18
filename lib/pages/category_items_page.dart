import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryItemsPage extends StatefulWidget {
  final String categoryName;
  final String categoryUrlFragment;


  const CategoryItemsPage({
    super.key,
    required this.categoryName,
    required this.categoryUrlFragment,
  });

  @override
  _CategoryItemsPageState createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  List<dynamic> categoryItems = [];
  bool _isLoadingCategoryItems = true;
  String _categoryItemsError = '';
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategoryItems();
  }

  Future<void> _fetchCategoryItems() async {
    final url = Uri.parse(
        'https://www.sptoolsusa.com/api/cacheable/items?c=7071087&commercecategoryurl=/products/${widget.categoryUrlFragment}&country=US&currency=USD&facet.exclude=custitem_ns_sc_ext_only_pdp%2Ccustitem_ns_sc_ext_gift_cert_group_id%2Citemtype&fieldset=search&include=facets&language=en&limit=24&matrixchilditems_fieldset=matrixchilditems_search&n=2&offset=0&pricelevel=5&sort=custitem_ns_sc_ext_ts_365_amount%3Adesc&use_pcv=T');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData != null && decodedData['items'] != null && decodedData['items'] is List) {
          setState(() {
            categoryItems = decodedData['items'];
            _isLoadingCategoryItems = false;
          });
        } else {
          setState(() {
            _categoryItemsError = 'No items found in ${widget.categoryName} or invalid data structure.';
            _isLoadingCategoryItems = false;
          });
        }
      } else {
        setState(() {
          _categoryItemsError = 'Failed to load items for ${widget.categoryName}: ${response.statusCode}';
          _isLoadingCategoryItems = false;
        });
        print('Failed to load items for ${widget.categoryName}: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _categoryItemsError = 'An error occurred loading items for ${widget.categoryName}: $e';
        _isLoadingCategoryItems = false;
      });
      print('Error fetching items for ${widget.categoryName}: $e');
    }
  }

  Widget _buildCategoryItemsGrid() {
    if (_isLoadingCategoryItems) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (_categoryItemsError.isNotEmpty) {
      return Center(child: Text(_categoryItemsError, style: const TextStyle(color: Colors.red, fontFamily: 'Roboto Condensed')));
    } else if (categoryItems.isEmpty) {
      return Center(child: Text('No products found in ${widget.categoryName}.', style: const TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed')));
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65, // Increased childAspectRatio to make boxes longer
        ),
        itemCount: categoryItems.length,
        itemBuilder: (context, index) {
          final item = categoryItems[index];
          if (item != null && item['displayname'] != null && item['pricelevel1_formatted'] != null) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: item['itemimages_detail'] != null &&
                          item['itemimages_detail']['urls'] != null &&
                          item['itemimages_detail']['urls'].isNotEmpty &&
                          item['itemimages_detail']['urls'][0]['url'] != null
                          ? Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Image.network(
                          item['itemimages_detail']['urls'][0]['url'],
                          fit: BoxFit.contain,
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 1),
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
                  const SizedBox(height: 2),
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
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontFamily: 'Roboto Condensed'),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontFamily: 'Roboto Condensed')),
                    )
                        : ElevatedButton(
                      onPressed: null,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.grey[600]!),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Out of Stock', style: TextStyle(fontFamily: 'Roboto Condensed')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white, // Change this color if needed
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(''),
        actions: [
          Stack(
            children: [
              const Icon(
                Icons.shopping_cart,
                color: Colors.white, // You can change the cart icon color here
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
                    '$_cartItemCount', // Use the cart item count
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
          const SizedBox(width: 16), // Add some spacing to the right
        ],
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView( // Wrap the entire body in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.categoryName, // Display category name above the grid
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto Condensed',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Promotions filter logic
                      print('Promotions button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF26722),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Promotions', style: TextStyle(fontFamily: 'Roboto Condensed')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Sort By logic
                      print('Sort By button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF26722),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sort By', style: TextStyle(fontFamily: 'Roboto Condensed')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryItemsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}