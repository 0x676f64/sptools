// more_page.dart
import 'package:flutter/material.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  static const Color _iconColor = Color(0xFFF26722);

  // Helper to build individual buttons (now simpler)
  Widget _buildSettingsButton({
    required String title,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Button's own background
        foregroundColor: Colors.black, // Text color
        minimumSize: const Size(double.infinity, 20), // From your code
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // From your code
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Rectangular
        elevation: 0, // No shadow for individual buttons within a group
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Minimize extra default padding
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: _iconColor, size: 24), // Slightly smaller icon to fit better
            const SizedBox(width: 20), // Adjusted space
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                // fontFamily: 'Roboto Condensed',
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
        ],
      ),
    );
  }

  // Helper to build a group of settings buttons
  Widget _buildSettingsGroup({required List<Widget> buttons}) {
    List<Widget> itemsWithDividers = [];
    for (int i = 0; i < buttons.length; i++) {
      itemsWithDividers.add(buttons[i]);
      if (i < buttons.length - 1) {
        // Add a divider if it's not the last button in the group
        itemsWithDividers.add(Divider(
          height: 1,        // Thickness of the line itself
          thickness: 0.5,   // Can make it thinner
          color: Colors.grey[400], // Light grey color for the divider
          indent: buttons[i] is ElevatedButton && (buttons[i] as ElevatedButton).child is Row && ((buttons[i] as ElevatedButton).child as Row).children.any((w) => w is Icon && w.icon != null)
              ? 56  // Indent past icon (20padding + 20icon + 16space)
              : 20, // Indent for text-only items (matches button's horizontal padding)
          endIndent: 0, // No indent from the right
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0), // Rounded corners for the group
        // Optional: Add a subtle shadow to the group container
         boxShadow: [
           BoxShadow(
             color: Colors.white.withOpacity(0.05),
             blurRadius: 1,
             spreadRadius: 1,
             offset: const Offset(0, 1),
           ),
         ],
      ),
      child: ClipRRect( // Ensures children (buttons) also clip to rounded corners
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          children: itemsWithDividers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define topBodyPadding as a const double directly here
    // Or, more simply, just use the literal value in EdgeInsets.fromLTRB
    // const double topBodyPadding = 16.0; // This line can be removed if using literal below

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        // Use a literal const double for the top padding value
        padding: const EdgeInsets.fromLTRB(25.0, 16.0, 25.0, 25.0), // Use 16.0 directly (or your desired const value)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28, // Make it look like a page title
                fontWeight: FontWeight.bold,
                // fontFamily: 'Roboto Condensed', // Optional
              ),
            ),
            const SizedBox(height: 16), // Space between "Settings" and "Guest"

            const Text(
              'Guest User',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),

            // --- My Profile (Standalone Group) ---
            _buildSettingsGroup(
              buttons: [
                _buildSettingsButton(
                  title: 'My Profile',
                  icon: Icons.person,
                  onPressed: () => print('My Profile tapped'),
                ),
              ],
            ),
            const SizedBox(height: 16), // Space between groups

            // --- Payment & SP Cash Group ---
            _buildSettingsGroup(
              buttons: [
                _buildSettingsButton(
                  title: 'Payment',
                  icon: Icons.credit_card,
                  onPressed: () => print('Payment tapped'),
                ),
                _buildSettingsButton(
                  title: 'SP Cash',
                  icon: Icons.monetization_on_outlined,
                  onPressed: () => print('SP Cash tapped'),
                ),
              ],
            ),
            const SizedBox(height: 16), // Space between groups

            // --- Main Settings Group ---
            _buildSettingsGroup(
              buttons: [
                _buildSettingsButton(
                  title: 'Delivery Options',
                  icon: Icons.local_shipping_outlined,
                  onPressed: () => print('Delivery Options tapped'),
                ),
                _buildSettingsButton(
                  title: 'Notification',
                  icon: Icons.notifications_outlined,
                  onPressed: () => print('Notification tapped'),
                ),
                _buildSettingsButton(
                  title: 'Terms & Privacy Policy',
                  icon: Icons.policy_outlined,
                  onPressed: () => print('Terms & Privacy Policy tapped'),
                ),
                _buildSettingsButton(
                  title: 'Get Support',
                  icon: Icons.support_agent_outlined,
                  onPressed: () => print('Get Support tapped'),
                ),
                _buildSettingsButton(
                  title: 'Tickets',
                  icon: Icons.confirmation_number_outlined,
                  onPressed: () => print('Tickets tapped'),
                ),
                _buildSettingsButton(
                  title: 'Referral Code',
                  icon: Icons.card_giftcard_outlined,
                  onPressed: () => print('Referral Code tapped'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}