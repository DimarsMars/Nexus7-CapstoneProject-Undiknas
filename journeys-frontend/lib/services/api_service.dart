import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';

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
}
