// orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrdersView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int) onRemoveFromCart;
  final Function(int, int) onUpdateQuantity;

  const OrdersView({
    super.key, 
    required this.cartItems, 
    required this.onRemoveFromCart,
    required this.onUpdateQuantity,
  });

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String couponCode = '';
  double couponDiscount = 0.0;
  bool couponApplied = false;

  double get subtotal {
    return widget.cartItems.fold(0.0, (sum, item) {
      final price = double.tryParse(item['pricelevel1']?.toString() ?? '0') ?? 0.0;
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  double get tax => subtotal * 0.08; // 8% tax rate
  double get shipping => subtotal > 50 ? 0.0 : 9.99; // Free shipping over $50
  double get total => subtotal - couponDiscount + tax + shipping;

  void _applyCoupon() {
    // Simulate coupon validation
    if (couponCode.toUpperCase() == 'SAVE10') {
      setState(() {
        couponDiscount = subtotal * 0.10;
        couponApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon applied successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code')),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      couponCode = '';
      couponDiscount = 0.0;
      couponApplied = false;
    });
  }

  void _proceedToCheckout() {
    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: widget.cartItems,
          subtotal: subtotal,
          couponDiscount: couponDiscount,
          tax: tax,
          shipping: shipping,
          total: total,
          couponCode: couponApplied ? couponCode : '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cartItems.isEmpty) {
      return const Center(
        child: Text(
          'Your Cart is Empty',
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.cartItems.length,
            itemBuilder: (context, index) {
              final item = widget.cartItems[index];
              final quantity = item['quantity'] ?? 1;
              
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
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Qty: ',
                                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                                  onPressed: quantity > 1 
                                    ? () => widget.onUpdateQuantity(index, quantity - 1)
                                    : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                                  onPressed: () => widget.onUpdateQuantity(index, quantity + 1),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () {
                          widget.onRemoveFromCart(index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.grey[850],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Coupon Section
              if (!couponApplied) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter coupon code',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF26722)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) => couponCode = value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: couponCode.isNotEmpty ? _applyCoupon : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF26722),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Coupon "$couponCode" applied',
                      style: const TextStyle(color: Colors.green, fontFamily: 'Roboto Condensed'),
                    ),
                    TextButton(
                      onPressed: _removeCoupon,
                      child: const Text('Remove', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Order Summary
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
                      ),
                      Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
                      ),
                    ],
                  ),
                  if (couponApplied) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Coupon Discount:',
                          style: TextStyle(color: Colors.green, fontFamily: 'Roboto Condensed'),
                        ),
                        Text(
                          '-\$${couponDiscount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green, fontFamily: 'Roboto Condensed'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tax:',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
                      ),
                      Text(
                        '\$${tax.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shipping == 0 ? 'Shipping (Free):' : 'Shipping:',
                        style: const TextStyle(color: Colors.white, fontFamily: 'Roboto Condensed'),
                      ),
                      Text(
                        shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: shipping == 0 ? Colors.green : Colors.white,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFF26722),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _proceedToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF26722),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// checkout_page.dart
class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double couponDiscount;
  final double tax;
  final double shipping;
  final double total;
  final String couponCode;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.couponDiscount,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.couponCode,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Shipping Information
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  
  // Payment Information
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  String selectedShippingMethod = 'standard';
  String selectedPaymentMethod = 'credit_card';
  bool sameAsShipping = true;
  bool savePaymentMethod = false;
  
  List<Map<String, dynamic>> savedCards = [
    {'id': '1', 'last4': '4242', 'brand': 'Visa', 'expiry': '12/26'},
    {'id': '2', 'last4': '5555', 'brand': 'Mastercard', 'expiry': '08/27'},
  ];
  
  String? selectedSavedCard;

  Map<String, Map<String, dynamic>> shippingMethods = {
    'standard': {'name': 'Standard (5-7 days)', 'cost': 9.99},
    'express': {'name': 'Express (2-3 days)', 'cost': 19.99},
    'overnight': {'name': 'Overnight', 'cost': 39.99},
  };

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      Navigator.pop(context); // Close loading dialog
      
      // Navigate to confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
            total: widget.total,
            email: _emailController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Information
                    _buildSectionHeader('Contact Information'),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        if (!value!.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Shipping Address
                    _buildSectionHeader('Shipping Address'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'State',
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _zipController,
                            label: 'ZIP Code',
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Shipping Method
                    _buildSectionHeader('Shipping Method'),
                    ...shippingMethods.entries.map((entry) {
                      return RadioListTile<String>(
                        title: Text(
                          entry.value['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '\$${entry.value['cost'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        value: entry.key,
                        groupValue: selectedShippingMethod,
                        onChanged: (value) => setState(() => selectedShippingMethod = value!),
                        activeColor: const Color(0xFFF26722),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    
                    // Payment Method
                    _buildSectionHeader('Payment Method'),
                    
                    // Payment Method Selection
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Credit Card', style: TextStyle(color: Colors.white)),
                            value: 'credit_card',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) => setState(() => selectedPaymentMethod = value!),
                            activeColor: const Color(0xFFF26722),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('PayPal', style: TextStyle(color: Colors.white)),
                            value: 'paypal',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) => setState(() => selectedPaymentMethod = value!),
                            activeColor: const Color(0xFFF26722),
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Apple Pay', style: TextStyle(color: Colors.white)),
                            value: 'apple_pay',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) => setState(() => selectedPaymentMethod = value!),
                            activeColor: const Color(0xFFF26722),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Google Pay', style: TextStyle(color: Colors.white)),
                            value: 'google_pay',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) => setState(() => selectedPaymentMethod = value!),
                            activeColor: const Color(0xFFF26722),
                          ),
                        ),
                      ],
                    ),
                    
                    if (selectedPaymentMethod == 'credit_card') ...[
                      const SizedBox(height: 16),
                      
                      // Saved Cards
                      if (savedCards.isNotEmpty) ...[
                        const Text(
                          'Saved Cards',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...savedCards.map((card) {
                          return RadioListTile<String>(
                            title: Text(
                              '${card['brand']} •••• ${card['last4']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Expires ${card['expiry']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            value: card['id'],
                            groupValue: selectedSavedCard,
                            onChanged: (value) => setState(() => selectedSavedCard = value),
                            activeColor: const Color(0xFFF26722),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        
                        RadioListTile<String>(
                          title: const Text('Use new card', style: TextStyle(color: Colors.white)),
                          value: 'new',
                          groupValue: selectedSavedCard,
                          onChanged: (value) => setState(() => selectedSavedCard = value),
                          activeColor: const Color(0xFFF26722),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      if (selectedSavedCard == 'new' || savedCards.isEmpty) ...[
                        _buildTextField(
                          controller: _cardHolderController,
                          label: 'Cardholder Name',
                          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _cardNumberController,
                          label: 'Card Number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Card number is required';
                            if (value!.length < 13) return 'Invalid card number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _expiryController,
                                label: 'MM/YY',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  _ExpiryDateFormatter(),
                                ],
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Required';
                                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) return 'Invalid format';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _cvvController,
                                label: 'CVV',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Required';
                                  if (value!.length < 3) return 'Invalid CVV';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text('Save this payment method', style: TextStyle(color: Colors.white)),
                          value: savePaymentMethod,
                          onChanged: (value) => setState(() => savePaymentMethod = value ?? false),
                          activeColor: const Color(0xFFF26722),
                        ),
                      ],
                    ],
                    
                    if (selectedPaymentMethod == 'paypal') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'You will be redirected to PayPal to complete your payment.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    
                    if (selectedPaymentMethod == 'apple_pay' || selectedPaymentMethod == 'google_pay') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'You will use ${selectedPaymentMethod == 'apple_pay' ? 'Apple Pay' : 'Google Pay'} to complete your payment.',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Order Summary Footer
            Container(
              color: Colors.grey[850],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:', style: TextStyle(color: Colors.white)),
                      Text('\$${widget.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  if (widget.couponDiscount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount (${widget.couponCode}):', style: const TextStyle(color: Colors.green)),
                        Text('-\$${widget.couponDiscount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax:', style: TextStyle(color: Colors.white)),
                      Text('\$${widget.tax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping:', style: TextStyle(color: Colors.white)),
                      Text('\$${shippingMethods[selectedShippingMethod]!['cost'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('\$${(widget.subtotal - widget.couponDiscount + widget.tax + shippingMethods[selectedShippingMethod]!['cost']).toStringAsFixed(2)}', 
                           style: const TextStyle(color: Color(0xFFF26722), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF26722),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Place Order',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto Condensed',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFF26722)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}

// Custom formatter for expiry date
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.length <= 2) {
      return newValue;
    }
    
    if (newText.length <= 4) {
      return TextEditingValue(
        text: '${newText.substring(0, 2)}/${newText.substring(2)}',
        selection: TextSelection.collapsed(offset: newText.length + 1),
      );
    }
    
    return oldValue;
  }
}

// order_confirmation_page.dart
class OrderConfirmationPage extends StatelessWidget {
  final String orderNumber;
  final double total;
  final String email;

  const OrderConfirmationPage({
    super.key,
    required this.orderNumber,
    required this.total,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Order Confirmed', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 120,
            ),
            const SizedBox(height: 32),
            const Text(
              'Order Confirmed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto Condensed',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you for your purchase. Your order has been successfully placed.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Roboto Condensed',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF26722), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Number:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      Text(
                        orderNumber,
                        style: const TextStyle(
                          color: Color(0xFFF26722),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Total:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      Text(
                        '\${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFF26722),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Email Confirmation:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.email,
                    color: Color(0xFFF26722),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Order Confirmation Email Sent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto Condensed',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'We\'ve sent a confirmation email with order details and tracking information.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Roboto Condensed',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to order tracking or order history
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order tracking feature coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26722),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Track Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Need help? Contact our customer support.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Roboto Condensed',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Handle customer support contact
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening customer support...')),
                );
              },
              child: const Text(
                'support@yourstore.com | 1-800-123-4567',
                style: TextStyle(
                  color: Color(0xFFF26722),
                  fontSize: 14,
                  fontFamily: 'Roboto Condensed',
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// error_page.dart - For handling checkout failures
class CheckoutErrorPage extends StatelessWidget {
  final String errorMessage;
  final String orderAttemptId;

  const CheckoutErrorPage({
    super.key,
    required this.errorMessage,
    required this.orderAttemptId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Order Failed', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 120,
            ),
            const SizedBox(height: 32),
            const Text(
              'Order Failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto Condensed',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'We encountered an issue processing your order. Please try again.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Roboto Condensed',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Error Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Roboto Condensed',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reference ID:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                      Text(
                        orderAttemptId,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'Roboto Condensed',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to checkout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26722),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Back to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Need help? Our support team is ready to assist you.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Roboto Condensed',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Handle customer support contact
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening customer support...')),
                );
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(
                  color: Color(0xFFF26722),
                  fontSize: 14,
                  fontFamily: 'Roboto Condensed',
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}