import 'package:firebase_auth/firebase_auth.dart';
import 'package:journeys/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import '../models/category_model.dart';
import '../models/plan_model.dart';
import '../models/route_model.dart';
import '../models/traveller_model.dart';
import '../models/traveller_recomen_model.dart';
import 'package:journeys/models/most_active_traveller_model.dart';
import 'package:journeys/models/my_trip_review_model.dart';
import 'package:journeys/models/review_on_my_plan_model.dart';
import 'package:journeys/models/user_xp_model.dart';
import 'package:journeys/models/past_trip_model.dart';
import 'package:journeys/models/favorite_trip_model.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final _auth = FirebaseAuth.instance;
  final _client = ApiClient();
  final String _loginUrl = 'http://192.168.1.8:8080/auth/login';

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

  final response = await _client.post('http://192.168.1.8:8080/auth/register', {
    'idToken': idToken,
    'username': username,
  });

  final user = UserModel.fromJson(response['user']);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_id', user.userId);
  await prefs.setString('username', user.username);

  return user;
}

Future<UserModel> getUserMe() async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("User not logged in");

  final idToken = await user.getIdToken();

  final response = await _client.get(
    'http://192.168.1.8:8080/user/me',
    headers: {
      'Authorization': 'Bearer $idToken',
    },
  );

  final data = response['data'];
  return UserModel.fromJson(data);
}

Future<ProfileModel> getProfile() async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("User not logged in");

  final idToken = await user.getIdToken();

  final response = await _client.get(
    'http://192.168.1.8:8080/profile/me',
    headers: {
      'Authorization': 'Bearer $idToken',
    },
  );

  final data = response['data'];
  return ProfileModel.fromJson(data);
}

Future<UserXpModel> getUserXP() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    final response = await _client.get(
      'http://192.168.1.8:8080/user/xp',
      headers: {'Authorization': 'Bearer $idToken'},
    );
    
    return UserXpModel.fromJson(response);
  }

Future<List<CategoryModel>> getCategories() async {
  final user = _auth.currentUser;

  if (user == null) throw Exception("User not logged in");

  final idToken = await user.getIdToken();

  final response = await _client.get(
    'http://192.168.1.8:8080/category/',
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
    'http://192.168.1.8:8080/plans/all',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  final data = response['data'] as List<dynamic>;
  return data.map((json) => PlanModel.fromJson(json)).toList();
}

 Future<PlanModel?> getPlanDetail(int planId) async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.8:8080/plans/$planId/detail',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  if (response['data'] == null) return null;

  final planJson = response['data']['plan'];
  final routesJson = response['data']['routes'] as List<dynamic>;

  final plan = PlanModel.fromJson({
    ...planJson,
    'routes': routesJson,
  });

  return plan;
}

Future<List<TravellerModel>> getAllTravellers() async {
  final user = _auth.currentUser;
  final idToken = user != null ? await user.getIdToken() : null;

  final response = await _client.get(
    'http://192.168.1.8:8080/user/all',
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
    'http://192.168.1.8:8080/user/recomendations/category',
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
    'http://192.168.1.8:8080/user/mostactive',
    headers: idToken != null
        ? {'Authorization': 'Bearer $idToken'}
        : null,
  );

  final data = response['data'] as List<dynamic>;
  return data
      .map((json) => MostActiveTravellerModel.fromJson(json))
      .toList();
}

Future<List<PlanModel>> getMyPlans() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    final idToken = await user.getIdToken();

    final response = await _client.get(
      'http://192.168.1.8:8080/plans/',
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    final data = response['data'] as List<dynamic>;
    return data.map((json) => PlanModel.fromJson(json)).toList();
  }

  Future<void> updateUserProfile({
    required String birthDate,
    required String description,
    required String status,
    File? photo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    final idToken = await user.getIdToken();

    http.MultipartFile? photoFile;
    if (photo != null) {
      photoFile = await http.MultipartFile.fromPath('photo', photo.path);
    }

    await _client.putMultipart(
      'http://192.168.1.8:8080/profile/update',
      headers: {
        'Authorization': 'Bearer $idToken',
      },
      fields: {
        'birth_date': birthDate,
        'description': description,
        'status': status,
        'location': 'Solo',
        'languages': 'ID',
      },
      file: photoFile,
    );
  }

  Future<void> deleteReviewTrips(int reviewId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    await _client.delete(
      'http://192.168.1.8:8080/reviews/my/$reviewId',
      headers: {'Authorization': 'Bearer $idToken'},
    );
  }


  Future<List<MyTripReviewModel>> getMyTripReviews() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    final response = await _client.get(
      'http://192.168.1.8:8080/reviews/trip/me',
      headers: {'Authorization': 'Bearer $idToken'},
    );
    final data = response['data'] as List<dynamic>;
    return data.map((json) => MyTripReviewModel.fromJson(json)).toList();
  }

  Future<List<ReviewOnMyPlanModel>> getReviewsOnMyPlans() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    final response = await _client.get(
      'http://192.168.1.8:8080/reviews/trip/my-plans',
      headers: {'Authorization': 'Bearer $idToken'},
    );
    final data = response['data'] as List<dynamic>;
    return data.map((json) => ReviewOnMyPlanModel.fromJson(json)).toList();
  }

  Future<List<PastTripModel>> getPastTrips() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    final response = await _client.get(
      'http://192.168.1.8:8080/plans/history',
      headers: {'Authorization': 'Bearer $idToken'},
    );
    final data = response['data'] as List<dynamic>;
    return data.map((json) => PastTripModel.fromJson(json)).toList();
  }

  Future<void> deletePastTrip(int progressId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    await _client.delete(
      'http://192.168.1.8:8080/plans/history/$progressId',
      headers: {'Authorization': 'Bearer $idToken'},
    );
  }

  Future<List<FavoriteTripModel>> getFavoriteTrips() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    final response = await _client.get(
      'http://192.168.1.8:8080/favorites/',
      headers: {'Authorization': 'Bearer $idToken'},
    );
    final data = response['data'] as List<dynamic>;
    return data.map((json) => FavoriteTripModel.fromJson(json)).toList();
  }

  Future<void> removeFavoriteTrip(int favoriteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final idToken = await user.getIdToken();

    await _client.delete(
      'http://192.168.1.8:8080/favorites/$favoriteId',
      headers: {'Authorization': 'Bearer $idToken'},
    );
  }
}
