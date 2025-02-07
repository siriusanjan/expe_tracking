import 'package:expe_traking/data_domain/firebase/firebase_utils.dart';
import 'package:expe_traking/data_domain/notification/notification_manager.dart';
import 'package:expe_traking/data_domain/utils/AppValues.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Check if user is logged in (returns `true` if logged in)
  static Future<bool> isUserLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('uid');
  }

  /// 🔹 Get the currently logged-in user (returns `null` if not logged in)
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// 🔹 Save user credentials after login
  static Future<void> saveUserCredentials(User user, UserRole userRole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('email', user.email ?? "");
    await prefs.setString('userRole', userRole.name ?? "");
  }

  /// 🔹 Save  notification token after login
  static Future<void> saveNotificationToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationToken', token);
  }

  /// 🔹 Retrieve saved user ID (UID)
  static Future<String> getSavedNotificationToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('notificationToken') ?? accessToken;
  }

  /// 🔹 Retrieve saved user ID (UID)
  static Future<String?> getSavedUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  /// 🔹 Retrieve saved user Role (userRole)
  static Future<String> getSavedUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole') ?? "employee";
  }

  /// 🔹 Sign in with email and password
  static Future<User?> signInWithEmail(
      String email, String password, UserRole userRole) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await saveUserCredentials(
          userCredential.user!, userRole); // Save credentials
      return userCredential.user;
    } catch (e) {
      print("Login failed: $e");
      return null;
    }
  }

  /// 🔹 Register a new user with email and password
  static Future<User?> signUpWithEmail(
      String email, String password, UserRole userRole) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveUserCredentials(
          userCredential.user!, userRole); // Save credentials
      return userCredential.user;
    } catch (e) {
      print("Signup failed: $e");
      return null;
    }
  }

  /// 🔹 Log out user and clear saved credentials
  static Future<void> logout() async {
    await _auth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored user data
  }

  /// 🔹 Auto-login check (Navigate to home or login screen)
  static Future<bool> checkUserLoginStatus() async {
    return await isUserLoggedIn();
  }
}
