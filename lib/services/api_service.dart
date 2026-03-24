import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.207:8000'; //Windows
  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://localhost:8000';
  //   } else if (Platform.isAndroid) {
  //     return 'http://10.0.2.2:8000';
  //   } else {
  //     return 'http://192.168.1.207:8000';
  //   }
  // }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user';

  // // Headers pour les requêtes authentifiées
  // static Map<String, String> _getHeaders({bool requireAuth = true}) {
  //   Map<String, String> headers = {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //   };

  //   if (requireAuth && _tokenKey != null) {
  //     headers['Authorization'] = 'Bearer $_tokenKey';
  //   }

  //   return headers;
  // }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'roleId': data['user']['role_id'],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de connexiion',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'roleId': data['user']['role_id'],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de registration',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  //Recuperer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  //Sauvegarder les infos de l'utilisateur
  static Future<void> saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  //Recuperer les infos de l'utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  //Recuperer les informations du dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération des données',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  // Récupérer la liste des produits
  static Future<Map<String, dynamic>> getProduits() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/liste-produits'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'produits': data['produits']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération des produits',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getVentes() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/liste-vente'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'ventes': data['ventes']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération des ventes',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getHistoriques() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/liste-historiques'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'historiques': data['historiques']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              data['message'] ??
              'Erreur lors de la récupération des historiques',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getUtilisateurs() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/liste-utilisateurs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'utilisateurs': data['utilisateurs']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              data['message'] ??
              'Erreur lors de la récupération des utilisateurs',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getRoles() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/liste-roles'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'roles': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération des rôles',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> effectuerVente(
    Map<String, dynamic> venteData,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/vente-produit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(venteData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'vente': data['vente'],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la vente',
          'errors': data['errors'] ?? null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();
    print('Token: $token');

    if (token == null) return false;
    final response = await http.post(
      Uri.parse('$baseUrl/api/logout'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    return response.statusCode == 200;
  }
}
