import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/models/category_model.dart';
import 'package:journeys/models/plan_model.dart';
import 'package:journeys/services/api_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<PlanModel> allPlans = [];
  List<PlanModel> filteredPlans = [];
  List<CategoryModel> categories = [];
  String? selectedCategory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedPlans = await ApiService().getAllPlans();
      final fetchedCategories = await ApiService().getCategories();

      setState(() {
        allPlans = fetchedPlans;
        filteredPlans = fetchedPlans;
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterByCategory(String? categoryName) {
    setState(() {
      selectedCategory = categoryName;
      if (categoryName == null) {
        filteredPlans = allPlans;
      } else {
        filteredPlans = allPlans.where((plan) {
          return plan.categories.any((cat) =>
              cat['name'].toString().toLowerCase() ==
              categoryName.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BAR AREA
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 235, 235, 235),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Find a place...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ),

            // Category Chips Container (Background kotak putih tetap ada)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.2), // <- lebih pekat
    blurRadius: 14,                        // <- lebih besar
    spreadRadius: 3,                       // <- lebih luas
    offset: const Offset(0, 6),            // <- lebih ke bawah
  ),
],

              ),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    final isSelected = index == 0
                        ? selectedCategory == null
                        : selectedCategory == categories[index - 1].name;
                    final label =
                        index == 0 ? 'All' : categories[index - 1].name;

                    return GestureDetector(
                      onTap: () => _filterByCategory(index == 0 ? null : label),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        // Bagian dekorasi kotak per item dihapus/dibuat transparan
                        decoration: const BoxDecoration(
                          color: Colors.transparent, 
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              // Teks berubah warna saat terpilih
                              color: isSelected 
                                  ? const Color.fromARGB(255, 27, 38, 59) 
                                  : Colors.grey[400],
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Grid of Places
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: filteredPlans.length,
                      itemBuilder: (context, index) {
                        final plan = filteredPlans[index];
                        return GestureDetector(
                          onTap: () =>
                              context.push('/plan-opened/${plan.planId}'),
                          child: _buildPlaceCard(plan),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(PlanModel plan) {
    Uint8List? imageBytes;
    if (plan.bannerBase64.isNotEmpty) {
      imageBytes = base64Decode(plan.bannerBase64);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageBytes != null
                ? Image.memory(
                    imageBytes,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[300],
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  plan.authorName.isNotEmpty ? plan.authorName : 'Anonymous',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      Icons.star,
                      size: 10,
                      color: starIndex < plan.rating.round()
                          ? Colors.amber
                          : Colors.grey[400],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}