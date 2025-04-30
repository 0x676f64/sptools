// orders_page.dart
import 'package:flutter/material.dart';

class OrdersView extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int) onRemoveFromCart;

  const OrdersView({super.key, required this.cartItems, required this.onRemoveFromCart});

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return const Center(
        child: Text(
          'Your Cart is Empty',
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Card(
            color: Colors.grey[800],
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: item['itemimages_detail'] != null &&
                        item['itemimages_detail']['urls'] != null &&
                        item['itemimages_detail']['urls'].isNotEmpty &&
                        item['itemimages_detail']['urls'][0]['url'] != null
                        ? Image.network(
                      item['itemimages_detail']['urls'][0]['url'],
                      fit: BoxFit.contain,
                    )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['displayname'] ?? 'No Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto Condensed',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Product Number: ${item['itemid'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.grey, fontFamily: 'Roboto Condensed'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['pricelevel1_formatted'] ?? 'No Price',
                          style: const TextStyle(color: Color(0xFFF26722), fontFamily: 'Roboto Condensed'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () {
                      onRemoveFromCart(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}