import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A), // Set background to #0a0a0a
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3), // Spacer to adjust the position
          Center(
            child: SvgPicture.asset(
              'assets/images/SP-Tools-USA.svg', // Updated path to the SVG
              height: 140, // Adjusted height for a smaller size
              width: 140, // Maintain aspect ratio with a smaller width
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF26722), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Border radius
                    ),
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                  child: Text(
                    "Sign In",
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFF26722), width: 3), // Border color and width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Border radius
                    ),
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                  child: Text(
                    "Sign Up",
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {}, // Add navigation logic here
                  child: Text(
                    "Continue As Guest",
                    style: GoogleFonts.rubik(
                      color: Colors.grey,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
