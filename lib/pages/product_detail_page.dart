// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(String) toggleWishlistItem;
  final bool Function(String) isItemInWishlist;
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.toggleWishlistItem,
    required this.isItemInWishlist,
    required this.onAddToCart,
  });

  @override
  ProductDetailPageState createState() => ProductDetailPageState();
}

class ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final itemId = product['itemid']?.toString() ?? '';
    final displayName = product['displayname'] ?? 'Unknown Product';
    final price = product['pricelevel1_formatted'] ?? 'Price not available';
    final isInStock = product['isinstock'] == true;
    final stockDescription = product['stockdescription'] ?? '';
    
    // Extract product images
    List<String> imageUrls = [];
    if (product['itemimages_detail'] != null &&
        product['itemimages_detail']['urls'] != null) {
      for (var imageData in product['itemimages_detail']['urls']) {
        if (imageData['url'] != null) {
          imageUrls.add(imageData['url']);
        }
      }
    }
    
    // Product description and other details
    final description = product['storedescription'] ?? product['storedetaileddescription'] ?? '';
    final itemType = product['itemtype'] ?? '';
    final weight = product['weight'] ?? '';
    final dimensions = product['dimensions'] ?? '';
    
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Roboto Condensed'),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Product Details',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto Condensed',
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                widget.isItemInWishlist(itemId)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: const Color(0xFFF26722),
              ),
              onPressed: () {
                widget.toggleWishlistItem(itemId);
                setState(() {});
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images Section
              _buildImageSection(imageUrls),
              
              // Product Info Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto Condensed',
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Price
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFFF26722),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto Condensed',
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Stock Status
                    Row(
                      children: [
                        Icon(
                          isInStock ? Icons.check_circle : Icons.cancel,
                          color: isInStock ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isInStock 
                              ? (stockDescription.isNotEmpty ? stockDescription : 'In Stock')
                              : 'Out of Stock',
                          style: TextStyle(
                            color: isInStock ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto Condensed',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Divider
                    const Divider(color: Colors.grey),
                    
                    const SizedBox(height: 16),
                    
                    // Product Description
                    if (description.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stripHtmlTags(description),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Product Specifications
                    _buildSpecifications(product),
                    
                    const SizedBox(height: 32),
                    
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: isInStock
                          ? ElevatedButton(
                              onPressed: () {
                                widget.onAddToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added $displayName to cart',
                                      style: const TextStyle(fontFamily: 'Roboto Condensed'),
                                    ),
                                    backgroundColor: const Color(0xFFF26722),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF26722),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto Condensed',
                                ),
                              ),
                              child: const Text('Add to Cart'),
                            )
                          : ElevatedButton(
                              onPressed: null,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(Colors.grey[600]!),
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                              ),
                              child: const Text(
                                'Out of Stock',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto Condensed',
                                ),
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImageSection(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
    
    return Column(
      children: [
        // Main Image
        Container(
          height: 300,
          width: double.infinity,
          color: Colors.white,
          child: PageView.builder(
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        
        // Image Indicators
        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageUrls.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? const Color(0xFFF26722)
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSpecifications(Map<String, dynamic> product) {
    List<Widget> specs = [];
    
    // Item ID
    if (product['itemid'] != null) {
      specs.add(_buildSpecRow('Item ID', product['itemid'].toString()));
    }
    
    // Item Type
    if (product['itemtype'] != null && product['itemtype'].toString().isNotEmpty) {
      specs.add(_buildSpecRow('Type', product['itemtype'].toString()));
    }
    
    // Weight
    if (product['weight'] != null && product['weight'].toString().isNotEmpty) {
      specs.add(_buildSpecRow('Weight', product['weight'].toString()));
    }
    
    // Dimensions
    if (product['dimensions'] != null && product['dimensions'].toString().isNotEmpty) {
      specs.add(_buildSpecRow('Dimensions', product['dimensions'].toString()));
    }
    
    // Brand/Manufacturer
    if (product['manufacturer'] != null && product['manufacturer'].toString().isNotEmpty) {
      specs.add(_buildSpecRow('Manufacturer', product['manufacturer'].toString()));
    }
    
    if (specs.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto Condensed',
          ),
        ),
        const SizedBox(height: 8),
        ...specs,
      ],
    );
  }
  
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto Condensed',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Roboto Condensed',
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
}