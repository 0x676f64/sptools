import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/pages/category_items_page.dart'; // Ensure this import is correct

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse(
        'https://www.sptoolsusa.com/api/navigation/v1/categorynavitems?bread_crumb_fields=internalid,name,displayinsite&c=7071087&category_fields=internalid,name,description,pagetitle,pageheading,pagebannerurl,addtohead,metakeywords,metadescription,displayinsite,urlfragment,idpath,fullurl,isprimaryurl&country=US&currency=USD&exclude_empty=true&full_url=/products&fullurl=%2Fproducts&language=en&n=2&pcv_all_items=F&side_menu_fields=name,internalid,sequencenumber,urlfragment,displayinsite&site_id=2&subcategory_fields=name,description,internalid,sequencenumber,urlfragment,thumbnailurl,displayinsite&use_pcv=T&_=1744998375220');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['data'] != null &&
            decodedData['data'].isNotEmpty &&
            decodedData['data'][0]['categories'] != null &&
            decodedData['data'][0]['categories'] is List) {
          setState(() {
            categories = decodedData['data'][0]['categories'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'No categories found or invalid data structure.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load categories: ${response.statusCode}';
          isLoading = false;
        });
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Categories',
              style: TextStyle(
                fontFamily: 'Roboto Condensed',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  if (category != null && category['name'] != null && category['urlfragment'] != null) {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryItemsPage(
                              categoryName: category['name'],
                              categoryUrlFragment: category['urlfragment'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category['name'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}