import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import '../models/category_model.dart';

class ApiService {
  final _auth = FirebaseAuth.instance;
  final _client = ApiClient();
  final String _loginUrl = 'http://172.20.10.2:8080/auth/login';

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

  final response = await _client.post('http://172.20.10.2:8080/auth/register', {
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
    'http://172.20.10.2:8080/category/',
    headers: {
      'Authorization': 'Bearer $idToken',
    },
  );

  final data = response['data'] as List<dynamic>;
  return data.map((json) => CategoryModel.fromJson(json)).toList();
}

}

