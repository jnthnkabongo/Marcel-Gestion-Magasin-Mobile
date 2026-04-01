import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static const String baseUrl = 'https://baramingap.alwaysdata.net'; //Windows
  //static const String baseUrl = 'http://192.168.1.71:8000';
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://baramingap.alwaysdata.net';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8001';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:8001';
    } else {
      return 'http://localhost:8001';
    }
  }

  // static String get baseUrl {
  //   if (kIsWeb) {
  //     //Web
  //     return 'http://localhost:8001';
  //   } else if (Platform.isAndroid) {
  //     //Mobile Android - Essayer d'abord connexion USB (hotspot)
  //     // IP typique pour connexion USB Android: 192.168.42.129 ou 192.168.43.1
  //     return 'http://192.168.42.129:8001'; // Connexion via câble USB
  //   } else if (Platform.isIOS) {
  //     //Mobile iPhone - Connexion USB hotspot
  //     // IP typique pour connexion USB iPhone: 172.20.10.1
  //     //return 'http://172.20.10.1:8001'; // Connexion via câble USB
  //     return 'http://192.168.221.76:8001';
  //   }
  //   // Default fallback pour autres plateformes
  //   return 'http://localhost:8001';
  // }

  // Alternative: Méthode pour tester différentes connexions USB
  // static List<String> getUsbConnectionUrls() {
  //   if (Platform.isAndroid) {
  //     return [
  //       'http://192.168.42.129:8001', // Android USB hotspot principal
  //       'http://192.168.43.1:8001', // Android USB hotspot alternatif
  //       'http://10.0.2.2:8001', // Emulator fallback
  //       'http://192.168.1.71:8001', // WiFi local fallback
  //     ];
  //   } else if (Platform.isIOS) {
  //     return [
  //       'http://172.20.10.1:8001', // iPhone USB hotspot
  //       'http://127.0.0.1:8001', // Local fallback
  //       'http://192.168.1.71:8001', // WiFi local fallback
  //     ];
  //   }
  //   return ['http://localhost:8001'];
  // }

  // Fonction pour tester la connexion et trouver l'URL fonctionnelle
  // static Future<String> findWorkingBaseUrl() async {
  //   final urls = getUsbConnectionUrls();

  //   for (String url in urls) {
  //     try {
  //       print('Test de connexion à: $url');
  //       final response = await http
  //           .get(
  //             Uri.parse('$url/api/test'),
  //             headers: {'Content-Type': 'application/json'},
  //           )
  //           .timeout(const Duration(seconds: 3));

  //       if (response.statusCode == 200) {
  //         print('Connexion réussie avec: $url');
  //         return url;
  //       }
  //     } catch (e) {
  //       print('Échec de connexion à $url: ${e.toString()}');
  //       continue;
  //     }
  //   }

  //   // Si aucune connexion ne fonctionne, retourner la première URL par défaut
  //   print(
  //     'Aucune connexion fonctionnelle trouvée, utilisation de: ${urls.first}',
  //   );
  //   return urls.first;
  // }

  // // Fonction simplifiée pour tester rapidement une URL
  // static Future<bool> testConnection(String url) async {
  //   try {
  //     final response = await http
  //         .get(
  //           Uri.parse('$url/api/test'),
  //           headers: {'Content-Type': 'application/json'},
  //         )
  //         .timeout(const Duration(seconds: 2));
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     return false;
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Login response: $data");

        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'role': data['role'],
          'roleId': data['role_id'] ?? data['user']['role_id'],
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Register response: $data");

        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'role': data['role'],
          'roleId': data['role_id'] ?? data['user']['role_id'],
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
    print("getUserData: Récupération depuis SharedPreferences...");
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    print("getUserData: userString = $userString");

    if (userString != null) {
      final userData = jsonDecode(userString);
      print("getUserData: userData décodé = $userData");
      return userData;
    }
    print("getUserData: Aucune donnée utilisateur trouvée");
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
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de réseau : ${e.toString()}',
      };
    }
  }

  //Récupérer le rapport de ventes avec bénéfices
  static Future<Map<String, dynamic>> getRapportVentes() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token non trouvé'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/rapport-ventes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'produitRapports': data['produitRapports'] ?? [],
          'beneficeTotal': data['beneficeTotal'] ?? 0,
          'totalVentes': data['totalVentes'] ?? 0,
          'beneficeMoyen': data['beneficeMoyen'] ?? 0,
          'meilleurProduit': data['meilleurProduit'],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération du rapport',
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
