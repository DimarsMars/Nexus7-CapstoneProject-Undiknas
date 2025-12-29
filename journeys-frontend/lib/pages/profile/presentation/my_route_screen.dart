import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/models/plan_model.dart';
import 'package:journeys/services/api_service.dart';

class MyRouteOwned extends StatefulWidget {
  const MyRouteOwned({super.key});

  @override
  State<MyRouteOwned> createState() => _MyRouteOwnedState();
}

class _MyRouteOwnedState extends State<MyRouteOwned> {
  final ApiService _apiService = ApiService();
  List<PlanModel> _myPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPlans();
  }

  Future<void> _loadMyPlans() async {
    try {
      final plans = await _apiService.getMyPlans();
      if (mounted) {
        setState(() {
          _myPlans = plans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load routes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9ebee),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Routes'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myPlans.isEmpty) {
      return const Center(
        child: Text(
          'You have no routes yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _myPlans.length,
      itemBuilder: (context, index) {
        final plan = _myPlans[index];
        return _buildPlanCard(plan);
      },
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    Uint8List? imageBytes;
    if (plan.bannerBase64.isNotEmpty) {
       try {
        imageBytes = base64Decode(plan.bannerBase64);
      } catch (e) {
        imageBytes = null;
      }
    }

    return GestureDetector(
      onTap: () {
        context.push('/plan-opened/${plan.planId}');
      },
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
           boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 240,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    plan.authorName.isNotEmpty ? plan.authorName : "Anonymous",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        Icons.star,
                        size: 14,
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
      ),
    );
  }
}