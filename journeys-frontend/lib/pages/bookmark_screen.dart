import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journeys/pages/route_screen.dart';
import 'package:journeys/services/api_service.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _bookmarks;
  final TextEditingController searchController = TextEditingController();

List<Map<String, dynamic>> savedPlaces = [];
/*************  ✨ Windsurf Command ⭐  *************/
/// Called when this object is inserted into the tree.
///
/// The framework will call this method exactly once for each State object,
/// after the widget that owns this State object is inserted into the tree.
///
/// The framework might call this method again if it rebuilds the widget tree.
/// For example, if the parent of the widget that owns this State object is
/// rebuilt with a new set of arguments, the framework will call
/// initState again.
///
/// Subclasses of State must override this method. Most subclasses
/// only need to perform initialization that is specific to the subclass.
/// Subclasses that wish to perform initialization that is not specific
/// to the subclass should invoke the superclass's implementation of
/// initState.
///
/// If a subclass has an override for initState, the subclass should
/*******  97f93247-e309-49c8-9ea8-41cad35e5835  *******/
  @override
  void initState() {
/// The framework does not test whether the implementation of this method
/// validly initialized the object. Instead, the framework assumes that
/// the implementation of this method will not return until the object is

/// fully initialized.
///
/// If the object is a StatefulWidget, the framework will call the
/// StatefulWidget's createState method to obtain the State object that is
/// associated with the widget that owns this State object.
///
/// If the object is a State object, the framework will call the
/// State object's reassemble method to reassemble the object.
///
/// The framework will not call build until after it has called initState for
/// this object and all of the object's ancestors.
///
/// The framework will call initState exactly once for each State object.
/// After a State object has been initialized, the framework does not call
/// initState again when the widget's parent rebuilds the widget tree.
/// Instead, the framework will call the State object's reassemble method
/// to reassemble the object.
///
/// The framework might call initState again if it rebuilds the widget tree
/// of a widget that owns a State object. If the framework rebuilds the
/// widget tree of a widget that owns a State object, the framework will call
/// initState again for that State object.
///
/// The framework will not call build until after it has called initState for
/// this object and all of the object's ancestors.
///
/// The framework will call initState exactly once for each State object.
/// After a State object has been initialized, the framework does not call
/// initState again when the widget's parent rebuilds the widget tree.
/// Instead, the framework will call the State object's reassemble method
/// to reassemble the object.
///
/// The framework might call initState again if it rebuilds the widget tree
/// of a widget that owns a State object. If the framework rebuilds the
/// widget tree of a widget that owns a State object, the framework will call
/// initState again for that State object.
///
/// The framework will not call build until after it has called initState for

    _bookmarks = apiService.getAllBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F4),
      appBar: AppBar(
        title: const Text(
          "Bookmarked",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0.3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBox(),
            const SizedBox(height: 16),
            _buildSavedHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _bookmarks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No bookmarks found."));
                  }

                  final savedPlaces = snapshot.data!;
                  return ListView(
                    children: [
                      ...savedPlaces.map((item) => _buildCard(item)),
                      const SizedBox(height: 20),
                      _buildAddToRouteButton(),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Column(
      children: [
        const Text(
          "Search",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Restaurant...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Saved",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _bookmarks = Future.value([]);
            });
          },
          child: const Text(
            "Remove all",
            style: TextStyle(color: Color(0xFF274664)),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> place) {
  final base64Image = place['image'] ?? '';
  final imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : null;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 52,
                  height: 52,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                place['description'] ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.place, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      place['address'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
       Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(
        Icons.bookmark,
        color: Colors.black87, // Bookmark aktif
        size: 20,
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bookmark aktif")),
        );
      },
    ),
    GestureDetector(
      onTap: () async {
        await apiService.removeBookmark(place['bookmark_id']);
        setState(() {
          _bookmarks = apiService.getAllBookmarks();
        });
      },
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.delete, size: 16),
      ),
    ),
  ],
)

      ],
    ),
  );
}


  Widget _buildAddToRouteButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF274664),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RouteScreen()),
          );
        },
        child: const Text(
          "Add to route",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
