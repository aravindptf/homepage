// import 'package:shared_preferences/shared_preferences.dart';

// class TokenManager {
//   static const String _tokenKey = 'token';
//   static const String _parlourIdKey = 'parlourId'; // Key for user ID

//   /// Function to store the token
//   static Future<void> storeToken(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }

//   /// Function to retrieve the token
//   static Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   /// Function to delete the token
//   static Future<void> deleteToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }

//   // / Function to store the user ID
//   static Future<void> storeparlourId(String parlourId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_parlourIdKey, parlourId);
//   }

//   /// Function to retrieve the user ID
//   static Future<String?> getparlourId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_parlourIdKey);
//   }

//   /// Function to delete the user ID
//   static Future<void> deleteparlourId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_parlourIdKey);
//   }

//   /// Optional: Function to clear all stored data
//   static Future<void> clear() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }