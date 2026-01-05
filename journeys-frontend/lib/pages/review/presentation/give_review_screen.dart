import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:journeys/theme/app_theme.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';


class GiveReviewScreen extends StatefulWidget {
  const GiveReviewScreen({super.key});

  @override
  State<GiveReviewScreen> createState() => _GiveReviewScreenState();
}
List<Uint8List> _selectedImages = [];

class _GiveReviewScreenState extends State<GiveReviewScreen> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Review'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Image',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
           GestureDetector(
  onTap: () async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 70);

    if (pickedFiles.isNotEmpty) {
      final images =
          await Future.wait(pickedFiles.map((e) => e.readAsBytes()));
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  },
  child: DottedBorder(
    color: AppColors.primary,
    strokeWidth: 1,
    dashPattern: const [6, 3],
    borderType: BorderType.RRect,
    radius: const Radius.circular(16),
    child: Container(
      height: _selectedImages.isEmpty ? 150 : 120,
      padding: const EdgeInsets.all(12),
      child: _selectedImages.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo,
                    size: 40, color: AppColors.primary),
                const SizedBox(height: 8),
                Text('Tap to add image',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add),
                  );
                }

                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: MemoryImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    ),
  ),
),

            const SizedBox(height: 24),
            Text(
              'Write your review',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.lightGrey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rate your experience',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40.0,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement submit review logic
                },
                child: const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}