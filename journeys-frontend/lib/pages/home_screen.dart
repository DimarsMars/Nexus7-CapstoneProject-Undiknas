import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/models/category_model.dart';
import 'package:journeys/models/plan_model.dart';
import 'package:journeys/models/traveller_model.dart';
import 'package:journeys/services/api_service.dart';
import 'package:journeys/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;

  List<PlanModel> plans = [];
  bool isLoading = true;

  List<TravellerModel> travellers = [];
  bool isTravellerLoading = true;

  List<CategoryModel> categories = [];
  bool isCategoryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _loadTravellers();
    _loadCategories();
  }

  Future<void> _loadPlans() async {
    try {
      final result = await ApiService().getAllPlans();
      setState(() {
        plans = result;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadTravellers() async {
    try {
      final result = await ApiService().getAllTravellers();
      result.shuffle(Random());
      setState(() {
        travellers = result.take(5).toList();
        isTravellerLoading = false;
      });
    } catch (_) {
      setState(() => isTravellerLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ApiService().getCategories();
      result.shuffle(Random());
      setState(() {
        categories = result;
        isCategoryLoading = false;
      });
    } catch (_) {
      setState(() => isCategoryLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH BAR AREA (Disamakan dengan ExploreScreen)
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

            const SizedBox(height: 20),

            // KATEGORI ATAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 55,
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
                child: isCategoryLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Center(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // FEATURED PLANS
            SizedBox(
              height: 240,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        Uint8List? imageBytes;
                        if (plan.bannerBase64.isNotEmpty) {
                          imageBytes = base64Decode(plan.bannerBase64);
                        }

                        return GestureDetector(
                          onTap: () async {
                            final result = await context
                                .push('/plan-opened/${plan.planId}');
                            if (result == true) {
                              _loadPlans();
                            }
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 16),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageBytes != null
                                      ? Image.memory(
                                          imageBytes,
                                          width: 180,
                                          height: 240,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 180,
                                          height: 240,
                                          color: Colors.grey[300],
                                        ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        plan.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        plan.authorName.isNotEmpty
                                            ? plan.authorName
                                            : "Anonymous",
 style: GoogleFonts.inter(
  color: Colors.white.withOpacity(0.85),
  fontSize: 11,
  fontStyle: FontStyle.normal,
),

                                      ),
                                      const SizedBox(height: 6),
Row(
  children: List.generate(5, (index) {
    double starFill = plan.rating - index;
    IconData icon;
    Color color;

    if (starFill >= 1) {
      icon = Icons.star;
      color = Colors.amber;
    } else if (starFill >= 0.5) {
      icon = Icons.star_half;
      color = Colors.amber;
    } else {
      icon = Icons.star;
      color = Colors.white;
    }

    return Icon(icon, size: 14, color: color);
  }),

                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/explore'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Explore More',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Forge Your Route',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  context.go('/explore');
                },
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/icons/forge_your_route.jpg',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.25),
                        ),
                        const Center(
                          child: Text(
                            'Create your own plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Plan's Category",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/categories'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'See More',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isCategoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        categories.length.clamp(0, 4),
                        (index) {
                          final category = categories[index];

                          return Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: index < 3 ? 12 : 0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 75,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: category.imageBase64.isNotEmpty
                                          ? Image.memory(
                                              base64Decode(
                                                  category.imageBase64),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Image.asset(
                                              'assets/icons/forge_your_route.jpg',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Follow These Traveller",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/traveller'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'See More',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 120,
              child: isTravellerLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: travellers.length,
                      itemBuilder: (context, index) {
                        final traveller = travellers[index];
                        Uint8List? imageBytes;
                        if (traveller.photoBase64.isNotEmpty) {
                          try {
                            final base64String =
                                traveller.photoBase64.split(',').last;
                            imageBytes = base64Decode(base64String);
                          } catch (_) {}
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: imageBytes != null
                                    ? MemoryImage(imageBytes)
                                    : null,
                                child: imageBytes == null
                                    ? const Icon(Icons.person,
                                        size: 35, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                traveller.username,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}