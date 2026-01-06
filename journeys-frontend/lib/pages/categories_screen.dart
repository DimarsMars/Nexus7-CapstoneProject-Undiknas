import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/services/api_service.dart';

import '../models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  List<CategoryModel> categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final result = await ApiService().getCategories();
      setState(() {
        categories = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories
        .where((cat) =>
            cat.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchText = value),
                  decoration: InputDecoration(
                    hintText: 'Find Categories...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // --- BACK BUTTON & TITLE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chevron_left, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- CONTENT ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75, // ← lebih kotak
                          ),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            return buildCategoryCard(
                                filteredCategories[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryCard(CategoryModel category) {
    Uint8List? imageBytes;

    if (category.imageBase64.isNotEmpty) {
      imageBytes =
          const Base64Decoder().convert(category.imageBase64.split(',').last);
    }

    return Column(
      children: [
        Container(
          height: 190, // ← gambar lebih tinggi
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey[300]),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
