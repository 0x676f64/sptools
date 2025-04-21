// wishlist_page.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WishlistView extends StatefulWidget {
  final Set<String> wishlistItems;
  final Function(String) onRemoveFromWishlist; // Callback to remove items

  const WishlistView({super.key, required this.wishlistItems, required this.onRemoveFromWishlist});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  Future<Map<String, dynamic>> _fetchProductDetails(String itemId) async {
    final url = Uri.parse(
        'https://www.sptoolsusa.com/api/items/$itemId?c=7071087&country=US&currency=USD&fieldset=details&language=en&n=2&pricelevel=5&use_pcv=T');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return decodedData['item'];
      } else {
        print('Failed to load product details for $itemId: ${response
            .statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching product details for $itemId: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wishlistItems.isEmpty) {
      return const Center(
        child: Text(
          'Your Wishlist is Empty',
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: widget.wishlistItems.length,
        itemBuilder: (context, index) {
          final itemId = widget.wishlistItems.elementAt(index);
          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchProductDetails(itemId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                );
              } else if (snapshot.hasError || !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Card(
                  color: Colors.grey[800],
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Product ID: $itemId - Could not load details',
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Roboto Condensed'),
                    ),
                  ),
                );
              } else {
                final product = snapshot.data!;
                return Card(
                  color: Colors.white,
                  // Match category item box color
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  // Match category item box shape
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    // Match category item box padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: product['itemimages_detail'] != null &&
                                product['itemimages_detail']['urls'] != null &&
                                product['itemimages_detail']['urls']
                                    .isNotEmpty &&
                                product['itemimages_detail']['urls'][0]['url'] !=
                                    null
                                ? Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Image.network(
                                product['itemimages_detail']['urls'][0]['url'],
                                fit: BoxFit.contain,
                              ),
                            )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          product['displayname'] ?? 'No Name',
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
                              product['pricelevel1_formatted'] ?? 'No Price',
                              style: const TextStyle(
                                color: Color(0xFFF26722),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto Condensed',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.onRemoveFromWishlist(itemId);
                              },
                              child: const Icon(
                                  Icons.favorite, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // You might not need the "Add to Cart" button here,
                        // but if you do, you can add it similarly to the
                        // CategoryItemsPage.
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      );
    }
  }
}