import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/active_trip_session_model.dart';
import '../models/category_model.dart';
import '../models/favorite_trip_model.dart'; // Model Punya Anda
import '../models/most_active_traveller_model.dart';
import '../models/my_trip_review_model.dart'; // Model Punya Anda
import '../models/past_trip_model.dart'; // Model Punya Anda
import '../models/place_detail.dart';
import '../models/place_review.dart';
import '../models/plan_model.dart';
import '../models/plan_rating.dart'; // Model Teman
import '../models/profile_model.dart';
import '../models/review_on_my_plan_model.dart'; // Model Punya Anda
import '../models/traveller_model.dart';
import '../models/traveller_profile_model.dart'; // Model Teman
import '../models/traveller_recomen_model.dart';
import '../models/user_model.dart';
import '../models/user_xp_model.dart'; // Model Punya Anda
// --- IMPORTS MODELS (Gabungan Punya Anda & Teman) ---
import 'api_client.dart';

class ApiService {
  final _auth = FirebaseAuth.instance;
  final _client = ApiClient();

  // --- CONFIGURATION ---
  // Satu variabel untuk semua endpoint agar konsisten
  static const String _baseUrl = 'http://172.20.10.2:8080';

  // --- HELPER ---
  // Helper untuk mengambil token agar tidak duplicate code
  Future<Map<String, String>?> _getHeaders() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final idToken = await user.getIdToken();
    return {'Authorization': 'Bearer $idToken'};
  }

  // ===========================================================================
  // AUTHENTICATION (Login & Register)
  // ===========================================================================

  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final idToken = await credential.user!.getIdToken();

    final response = await _client.post('$_baseUrl/auth/login', {
      'idToken': idToken,
    });

    final user = UserModel.fromJson(response['user']);

    // Simpan data di SharedPreferences
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

    final response = await _client.post('$_baseUrl/auth/register', {
      'idToken': idToken,
      'username': username,
    });

    final user = UserModel.fromJson(response['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.userId);
    await prefs.setString('username', user.username);

    return user;
  }

  // ===========================================================================
  // MY PROFILE FEATURES (Dari Code Anda)
  // ===========================================================================

  Future<UserModel> getUserMe() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/user/me',
      headers: headers,
    );

    return UserModel.fromJson(response['data']);
  }

  Future<ProfileModel> getProfile() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/profile/me',
      headers: headers,
    );

    return ProfileModel.fromJson(response['data']);
  }

  Future<UserXpModel> getUserXP() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/user/xp',
      headers: headers,
    );

    return UserXpModel.fromJson(response);
  }

  // Fitur Update Profile dengan Gambar (Dari Code Anda)
  Future<void> updateUserProfile({
    required String birthDate,
    required String description,
    required String status,
    XFile? photo,
  }) async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    http.MultipartFile? photoFile;
    if (photo != null) {
      if (kIsWeb) {
        final bytes = await photo.readAsBytes();
        photoFile =
            http.MultipartFile.fromBytes('photo', bytes, filename: photo.name);
      } else {
        photoFile = await http.MultipartFile.fromPath('photo', photo.path);
      }
    }

    await _client.putMultipart(
      '$_baseUrl/profile/update',
      headers: headers,
      fields: {
        'birth_date': birthDate,
        'description': description,
        'status': status,
        'location': 'Solo', // Default value
        'languages': 'ID', // Default value
      },
      file: photoFile,
    );
  }

  // ===========================================================================
  // OTHER USER PROFILE & SOCIALS (Dari Code Teman + Tambahan Anda)
  // ===========================================================================

  // Dari Teman: Menggunakan TravellerProfileModel
  Future<TravellerProfileModel> getUserProfile(int id) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/user/profile/$id',
      headers: headers,
    );

    return TravellerProfileModel.fromJson(response['data']);
  }

  // Dari Teman (Socials)
  Future<Map<String, dynamic>> getUserSocials(int userId) async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/profile/socials/$userId',
      headers: headers,
    );

    // Safety check untuk response structure
    if (response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  Future<bool> checkIsFollowing(int userId) async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/follow/status/$userId',
      headers: headers,
    );

    if (response.containsKey('data')) {
      return response['data']['is_following'] ?? false;
    }
    return response['is_following'] ?? false;
  }

  // Metode isFollowing versi teman (endpoint sedikit berbeda pathnya)
  Future<bool> isFollowing(int id) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/follow/$id/is-following',
      headers: headers,
    );
    return response['is_following'] ?? false;
  }

  Future<Map<String, dynamic>> getSocialCounts(int id) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/follow/$id/socials',
      headers: headers,
    );

    return {
      'followers': response['followers_count'] ?? 0,
      'following': response['following_count'] ?? 0,
    };
  }

  Future<bool> followUser(int id) async {
    final headers = await _getHeaders();
    final response = await _client.post(
      '$_baseUrl/follow/$id',
      {},
      headers: headers,
    );
    return response != null;
  }

  Future<bool> unfollowUser(int id) async {
    final headers = await _getHeaders();
    final response = await _client.delete(
      '$_baseUrl/follow/$id',
      headers: headers,
    );
    return response != null;
  }

  // ===========================================================================
  // CATEGORIES, PLANS & TRAVELLERS (Gabungan)
  // ===========================================================================

  Future<List<CategoryModel>> getCategories() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/category/',
      headers: headers,
    );

    final data = response['data'] as List<dynamic>;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<List<PlanModel>> getAllPlans() async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/plans/all',
      headers: headers,
    );

    final data = response['data'] as List<dynamic>;
    return data.map((json) => PlanModel.fromJson(json)).toList();
  }

  Future<List<PlanModel>> getMyPlans() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/plans/',
      headers: headers,
    );

    final rawData = response['data'];
    if (rawData == null || rawData is! List) {
      return []; // Jika tidak ada data, kembalikan list kosong
    }

    return rawData.map((json) => PlanModel.fromJson(json)).toList();
  }

  // Dari Teman: Return PlanModelRating (Lebih lengkap)
  Future<PlanModelRating?> getPlanDetail(int planId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/plans/$planId/detail',
      headers: headers,
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
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/user/all',
      headers: headers,
    );

    final data = response['data'] as List<dynamic>;
    return data.map((json) => TravellerModel.fromJson(json)).toList();
  }

  Future<List<TravellerRecommendationModel>> getCategoryTravellers() async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/user/recomendations/category',
      headers: headers,
    );

    final data = response['data'] as List<dynamic>;
    return data
        .map((json) => TravellerRecommendationModel.fromJson(json))
        .toList();
  }

  Future<List<MostActiveTravellerModel>> getMostActiveTravellers() async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/user/mostactive',
      headers: headers,
    );

    final data = response['data'] as List<dynamic>;
    return data.map((json) => MostActiveTravellerModel.fromJson(json)).toList();
  }

  // ===========================================================================
  // HISTORY & FAVORITES (Gabungan)
  // ===========================================================================

  // Dari Code Anda (Past Trips)
  Future<List<PastTripModel>> getPastTrips() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/plans/history',
      headers: headers,
    );

    final rawData = response['data'];
    if (rawData == null || rawData is! List) {
      return [];
    }

    return rawData.map((json) => PastTripModel.fromJson(json)).toList();
  }


  Future<void> deletePastTrip(int progressId) async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    await _client.delete(
      '$_baseUrl/plans/completed-plans/$progressId',
      headers: headers,
    );
  }

  // Dari Code Anda (List Favorites)
  Future<List<FavoriteTripModel>> getFavoriteTrips() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/favorites/',
      headers: headers,
    );
    final data = response['data'] as List<dynamic>;
    return data.map((json) => FavoriteTripModel.fromJson(json)).toList();
  }

  // Dari Code Teman (Add/Remove/Check Favorites)
  Future<bool> addFavorite(int planId) async {
    final headers = await _getHeaders();
    final response = await _client.post(
      '$_baseUrl/favorites/$planId',
      {},
      headers: headers,
    );
    return response['message'] != null;
  }

  Future<bool> removeFavorite(int favoriteId) async {
    final headers = await _getHeaders();
    final response = await _client.delete(
      '$_baseUrl/favorites/$favoriteId',
      headers: headers,
    );
    return response['message'] != null;
  }

  // Wrapper agar kompatibel dengan code Anda yang mungkin memanggil removeFavoriteTrip
  Future<void> removeFavoriteTrip(int favoriteId) async {
    await removeFavorite(favoriteId);
  }

  Future<int?> getFavoriteIdForPlan(int planId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/favorites/',
      headers: headers,
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

  // ===========================================================================
  // REVIEWS & PLACE DETAILS (Gabungan)
  // ===========================================================================

  // Dari Code Teman (Place Detail)
  Future<PlaceDetail?> getPlaceDetail(int routeId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/plans/route/$routeId',
      headers: headers,
    );

    final data = response['data'];
    if (data == null) return null;

    return PlaceDetail.fromJson(data);
  }

  // Dari Code Teman (Place Reviews)
  Future<List<PlaceReview>> getPlaceReviews(int routeId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/reviews/place/$routeId',
      headers: headers,
    );

    final List<dynamic> data = response['data'] ?? [];
    return data.map((e) => PlaceReview.fromJson(e)).toList();
  }

  // Dari Code Anda (My Reviews)
  Future<List<MyTripReviewModel>> getMyTripReviews() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/reviews/trip/me',
      headers: headers,
    );
    final rawData = response['data'];
    if (rawData == null || rawData is! List) {
      return []; // Jika kosong/null, kembalikan list kosong
    }

    return rawData.map((json) => MyTripReviewModel.fromJson(json)).toList();
  }

  Future<List<ReviewOnMyPlanModel>> getReviewsOnMyPlans() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/reviews/trip/my-plans',
      headers: headers,
    );
    final rawData = response['data'];
    if (rawData == null || rawData is! List) {
      return []; // Jika kosong/null, kembalikan list kosong
    }
    return rawData.map((json) => ReviewOnMyPlanModel.fromJson(json)).toList();
  }

  Future<void> deleteReviewTrips(int reviewId) async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    await _client.delete(
      '$_baseUrl/reviews/my/$reviewId',
      headers: headers,
    );
  }

  // Dari Code Teman (Submit Review dengan return boolean)
  Future<bool> submitTripReview(int planId, int rating, String comment) async {
    final headers = await _getHeaders();
    final response = await _client.post(
      '$_baseUrl/reviews/trip',
      {
        'plan_id': planId,
        'rating': rating,
        'comment': comment,
      },
      headers: headers,
    );

    return response['message'] == 'Review berhasil ditambahkan';
  }

  // Dari Code Teman (Submit Place Review + Image Multipart)
  Future<bool> submitPlaceReview({
    required int routeId,
    required int rating,
    required String comment,
    List<Uint8List> imageBytesList = const [],
  }) async {
    final user = _auth.currentUser;
    final idToken = await user?.getIdToken();

    final uri = Uri.parse('$_baseUrl/reviews/place');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $idToken'
      ..fields['route_id'] = routeId.toString()
      ..fields['rating'] = rating.toString()
      ..fields['comment'] = comment;

    for (int i = 0; i < imageBytesList.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
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

  // ===========================================================================
  // BOOKMARKS (Dari Code Teman)
  // ===========================================================================

  Future<int?> getBookmarkIdForRoute(int routeId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/bookmarks/',
      headers: headers,
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
    final headers = await _getHeaders();
    final response = await _client.post(
      '$_baseUrl/bookmarks/$routeId',
      {},
      headers: headers,
    );

    return response != null && response['message'] != null;
  }

  Future<bool> removeBookmark(int bookmarkId) async {
    final headers = await _getHeaders();
    final response = await _client.delete(
      '$_baseUrl/bookmarks/$bookmarkId',
      headers: headers,
    );

    return response != null && response['message'] != null;
  }

  Future<PlanModel?> postPlanMultipart({
    required String title,
    required String description,
    required String status,
    required List<String> categories,
    required List<Map<String, dynamic>> routes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final token = await user.getIdToken();
    final uri = Uri.parse('$_baseUrl/plans/');

    final request = http.MultipartRequest('POST', uri);

    // 🔐 Auth
    request.headers['Authorization'] = 'Bearer $token';

    // 📝 FORM FIELDS (HARUS STRING)
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['status'] = status;

    // backend pakai category_ids (comma separated)
    request.fields['category_ids'] = categories.join(',');

    // backend expect JSON string
    request.fields['routes'] = jsonEncode(routes);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      if (data == null) return null;
      return PlanModel.fromJson(data);
    } else {
      throw Exception("Post plan failed: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    final headers = await _getHeaders();
    final response = await _client.get('$_baseUrl/bookmarks/', headers: headers);

    final data = response['data'] as List<dynamic>;

    return data.map((bookmark) {
      final route = bookmark['route'] ?? {};
      return {
        'bookmark_id': bookmark['bookmark_id'],
        'title': route['title'] ?? '',
        'description': route['description'] ?? '',
        'address': route['address'] ?? '',
        'image': route['image'] ?? '',
      };
    }).toList();
  }

 Future<List<Map<String, dynamic>>> getActiveTripSessions() async {
  final headers = await _getHeaders();
  final response = await _client.get(
    '$_baseUrl/trip-sessions/active',
    headers: headers,
  );

  final data = response['data'];
  if (data is List) {
    return List<Map<String, dynamic>>.from(data);
  }

  return [];
}


  Future<bool> postTripSessionAction({
    required int planId,
    required String action,
    required int routeId,
  }) async {
    final headers = await _getHeaders();

    final response = await _client.post(
      '$_baseUrl/trip-sessions/$planId', // ✅ BENAR
      {
        'action': action,
        'route_id': routeId,
      },
      headers: headers,
    );

    return response['message'] != null;
  }

  Future<Map<String, dynamic>?> verifyLocation(
    int planId,
    int stepOrder, // ✅ Ubah nama param juga biar gak bingung
    LatLng currentLocation,
  ) async {
    final headers = await _getHeaders();

    final response = await _client.post(
      '$_baseUrl/plans/$planId/verify-location',
      {
        "step_order": stepOrder,
        "latitude": currentLocation.latitude,
        "longitude": currentLocation.longitude,
      },
      headers: headers,
    );

    return response;
  }
Future<int> getCurrentSessionId() async {
  final sessions = await getActiveTrips(); // ← versi model
  if (sessions.isEmpty) throw Exception("No active trip");

  return sessions.first.sessionId;
}


  Future<Map<String, dynamic>> postTripSessionStart(
      int planId, int routeId) async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.post(
      '$_baseUrl/trip-sessions/$planId',
      {
        'action': 'start',
        'route_id': routeId,
      },
      headers: headers,
    );

    if (response.containsKey('data')) {
      return response['data'];
    }

    throw Exception("Failed to start trip session");
  }

  Future<PlanModel?> getPlanDetailForTrip(int planId) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      '$_baseUrl/plans/$planId/detail',
      headers: headers,
    );

    final data = response['data'];
    if (data == null) return null;

    // Ambil plan info dari data['plan']
    final planJson = data['plan'] as Map<String, dynamic>? ?? {};

    // Ambil routes list dari data['routes']
    final routesJson = data['routes'] as List<dynamic>? ?? [];

    // Gabungkan ke satu JSON yang cocok dengan PlanModel
    final merged = {
      "plan_id": planJson['plan_id'],
      "title": planJson['title'],
      "description": planJson['description'],
      "banner": data['banner'], // dari root
      "categories": planJson['categories'] ?? [],
      "status": planJson['status'] ?? "",
      "author_name": planJson['author_name'] ?? "",
      "rating": (data['rating'] ?? 0),
      "routes": routesJson, // pakai yang ini!
    };

    return PlanModel.fromJson(merged);
  }

    Future<List<ActiveTripSessionModel>> getActiveTrips() async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    final response = await _client.get(
      '$_baseUrl/trip-sessions/active',
      headers: headers,
    );

    final rawData = response['data'];

    if (rawData == null) {
      return [];
    }

    // Pastikan rawData is a List
    if (rawData is List) {
      return rawData
          .map((json) => ActiveTripSessionModel.fromJson(json))
          .toList();
    }

    // Jika hanya 1 object
    return [ActiveTripSessionModel.fromJson(rawData)];
  }

  Future<void> cancelTripSessions(int planId) async {
    final headers = await _getHeaders();
    if (headers == null) throw Exception("User not logged in");

    await _client.delete(
      '$_baseUrl/trip-sessions/cancel?plan_id=$planId',
      headers: headers,
    );
  }
}