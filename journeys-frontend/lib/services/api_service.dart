import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journeys/models/plan_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import '../models/category_model.dart';
import '../models/plan_model.dart';
import '../models/route_model.dart';
import '../models/traveller_model.dart';
import '../models/traveller_recomen_model.dart';
import '../models/most_active_traveller_model.dart';
import '../models/traveller_profile_model.dart';
import '../models/place_review.dart';
import '../models/place_detail.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  final _auth = FirebaseAuth.instance;
  final _client = ApiClient();
  final String _loginUrl = 'http://192.168.1.11:8080/auth/login';

  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final idToken = await credential.user!.getIdToken();

    final response = await _client.post(_loginUrl, {
      'idToken': idToken,
    });

    final user = UserModel.fromJson(response['user']);

    // Simpan data jika perlu
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.userId);
    await prefs.setString('username', user.username);

    return user;
  }

  Future<UserModel> register(String email, String password, String username) async {
  final credential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final idToken = await credential.user!.getIdToken();

  final response = await _client.post('http://192.168.1.11:8080/auth/register', {
    'idToken': idToken,
    'username': username,
  });

  final user = UserModel.fromJson(response['user']);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_id', user.userId);
  await prefs.setString('username', user.username);

  return user;
}

Future<List<CategoryModel>> getCategories() async {
  final user = _auth.currentUser;

  if (user == null) throw Exception("User not logged in");

  final idToken = await user.getIdToken();

  final response = await _client.get(
    'http://192.168.1.11:8080/category/',
    headers: {
      'Authorization': 'Bearer $idToken',
    },
  );

  final data = response['data'] as List<dynamic>;
  return data.map((json) => CategoryModel.fromJson(json)).toList();
}

Future<List<PlanModel>> getAllPlans() async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/plans/all',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  final data = response['data'] as List<dynamic>;
  return data.map((json) => PlanModel.fromJson(json)).toList();
}

 Future<PlanModelRating?> getPlanDetail(int planId) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/plans/$planId/detail',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  final data = response['data'];
  if (data == null) return null;

  final planJson = data['plan'] ?? {};
  final routesJson = data['routes'] as List<dynamic>? ?? [];

  return PlanModelRating.fromJson({
    ...planJson,
    'routes': routesJson,
    'rating': data['rating'] ?? 0,
  });
}


Future<List<TravellerModel>> getAllTravellers() async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/user/all',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  final data = response['data'] as List<dynamic>;
  return data.map((json) => TravellerModel.fromJson(json)).toList();
}

Future<List<TravellerRecommendationModel>> getCategoryTravellers() async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/user/recomendations/category',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  final data = response['data'] as List<dynamic>;
  return data
      .map((json) => TravellerRecommendationModel.fromJson(json))
      .toList();
}

Future<List<MostActiveTravellerModel>> getMostActiveTravellers() async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/user/mostactive',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  final data = response['data'] as List<dynamic>;
  return data
      .map((json) => MostActiveTravellerModel.fromJson(json))
      .toList();
}

// GET /user/profile/:id
Future<TravellerProfileModel> getUserProfile(int id) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/user/profile/$id',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  final data = response['data'];
  return TravellerProfileModel.fromJson(data);
}

// GET /follow/:id/is-following
Future<bool> isFollowing(int id) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/follow/$id/is-following',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response['is_following'] ?? false;
}

// GET /follow/:id/socials
Future<Map<String, dynamic>> getSocialCounts(int id) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/follow/$id/socials',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return {
    'followers': response['followers_count'] ?? 0,
    'following': response['following_count'] ?? 0,
  };
}

// POST /follow/:id
Future<bool> followUser(int id) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.post(
    'http://192.168.1.11:8080/follow/$id',
    {},
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response != null;
}

// DELETE /follow/:id
Future<bool> unfollowUser(int id) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.delete(
    'http://192.168.1.11:8080/follow/$id',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response != null;
}

// GET /plans/route/:id
Future<PlaceDetail?> getPlaceDetail(int routeId) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/plans/route/$routeId',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  final data = response['data'];
  if (data == null) return null;

  return PlaceDetail.fromJson(data);
}


Future<List<PlaceReview>> getPlaceReviews(int routeId) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/reviews/place/$routeId',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  final List<dynamic> data = response['data'] ?? []; // ✅ fix null case
  return data.map((e) => PlaceReview.fromJson(e)).toList();
}

// Tambah ke Favorite
Future<bool> addFavorite(int planId) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.post(
    'http://192.168.1.11:8080/favorites/$planId',
    {},
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response['message'] != null;
}

// Hapus dari Favorite
Future<bool> removeFavorite(int favoriteId) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.delete(
    'http://192.168.1.11:8080/favorites/$favoriteId',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response['message'] != null;
}

// Cek apakah plan sudah difavoritkan
Future<int?> getFavoriteIdForPlan(int planId) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.11:8080/favorites/',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  final favorites = response['data'] as List<dynamic>;
  for (final fav in favorites) {
    final favPlan = fav['plan'];
    if (favPlan != null && favPlan['plan_id'] == planId) {
      return fav['favorite_id'];
    }
  }

  return null;
}

Future<bool> submitTripReview(int planId, int rating, String comment) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.post(
    'http://192.168.1.11:8080/reviews/trip',
    {
      'plan_id': planId,
      'rating': rating,
      'comment': comment,
    },
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response['message'] == 'Review berhasil ditambahkan';
}


Future<int?> getBookmarkIdForRoute(int routeId) async {
  final user = _auth.currentUser;
  final idToken = await user?.getIdToken();

  final response = await _client.get(
    'http://192.168.1.11:8080/bookmarks/',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  if (response['data'] == null) return null;

  final bookmarks = List<Map<String, dynamic>>.from(response['data']);
  final found = bookmarks.firstWhere(
    (b) => b['route']['route_id'] == routeId,
    orElse: () => {},
  );

  return found.isNotEmpty ? found['bookmark_id'] : null;
}

Future<bool> addBookmark(int routeId) async {
  final user = _auth.currentUser;
  final idToken = await user?.getIdToken();

  final response = await _client.post(
    'http://192.168.1.11:8080/bookmarks/$routeId',
    {},
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response != null && response['message'] != null;
}

Future<bool> removeBookmark(int bookmarkId) async {
  final user = _auth.currentUser;
  final idToken = await user?.getIdToken();

  final response = await _client.delete(
    'http://192.168.1.11:8080/bookmarks/$bookmarkId',
    headers: idToken != null ? {'Authorization': 'Bearer $idToken'} : null,
  );

  return response != null && response['message'] != null;
}

Future<bool> submitPlaceReview({
  required int routeId,
  required int rating,
  required String comment,
  List<Uint8List> imageBytesList = const [],
}) async {
  final user = _auth.currentUser;
  final idToken = await user?.getIdToken();

  final uri = Uri.parse('http://192.168.1.11:8080/reviews/place');

  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $idToken'
    ..fields['route_id'] = routeId.toString()
    ..fields['rating'] = rating.toString()
    ..fields['comment'] = comment;

  for (int i = 0; i < imageBytesList.length; i++) {
    request.files.add(http.MultipartFile.fromBytes(
      'image', // harus disesuaikan dengan field array di backend
      imageBytesList[i],
      filename: 'review_$i.jpg',
    ));
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Review error: ${response.body}");
    return false;
  }
}



}

