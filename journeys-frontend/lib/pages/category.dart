import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  String selectedCategory = 'Culture';

  final List<String> smallCategories = [
    'Culture',
    'Eatery',
    'Health',
    "Craft's",
  ];

  final List<String> allCategories = [
    'Waterfall',
    'Beaches',
    "Temple's & Shrine's",
    'Mountain & Hills',
    'Mini Resto',
    "Store's",
  ];

  // mapping gambar untuk grid categories (Opsi B + related images)
  final Map<String, String> categoryImages = {
    "Waterfall": "https://images.unsplash.com/photo-1508614987370-8d3b9c2a3a61?auto=format&fit=crop&w=500&q=80",
    "Beaches": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    "Temple's & Shrine's": "https://images.unsplash.com/photo-1524492412937-b28074a5d7da",
    "Mountain & Hills": "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
    "Mini Resto": "https://images.unsplash.com/photo-1528605248644-14dd04022da1",
    "Store's": "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=500&q=80",
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // filter berdasarkan search
    final filteredCategories = allCategories
        .where((cat) =>
            cat.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "See More Categories",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🔍 Search Bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchText = value),
                  decoration: const InputDecoration(
                    hintText: 'Find Categories...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🟦 Small Category Bar (Culture, Eatery, etc.)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: smallCategories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 📦 Grid Categories
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: filteredCategories
                    .map((cat) => _categoryBox(cat, categoryImages[cat]!))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryBox(String title, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.45),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
