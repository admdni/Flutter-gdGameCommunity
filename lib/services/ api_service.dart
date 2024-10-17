import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String BASE_URL = 'https://api.rawg.io/api';
  static const String API_KEY =
      '29baf58b6b9d4b7fb3a23ecb55dbc0bb'; // RAWG API anahtarınızı buraya ekleyin
  static const Duration CACHE_DURATION = Duration(minutes: 5);

  final Map<String, CacheItem> _cache = {};

  Future<dynamic> _getWithCache(String url) async {
    if (_cache.containsKey(url)) {
      final cacheItem = _cache[url]!;
      if (DateTime.now().difference(cacheItem.timestamp) < CACHE_DURATION) {
        return cacheItem.data;
      }
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _cache[url] = CacheItem(data, DateTime.now());
      return data;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchTrendingGames() async {
    final url = '$BASE_URL/games?key=$API_KEY&ordering=-rating&page_size=10';
    try {
      final data = await _getWithCache(url);
      return data['results'];
    } catch (e) {
      throw Exception('Failed to load trending games: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGameCategories() async {
    final url = '$BASE_URL/genres?key=$API_KEY';
    try {
      final data = await _getWithCache(url);
      List<Map<String, dynamic>> categories = (data['results'] as List)
          .map((category) => {
                'id': category['id'],
                'name': category['name'],
                'slug': category['slug'], // slug'ı kullanın
              })
          .toList();
      print('Fetched categories: $categories'); // Kategorileri konsola yazdırın
      return categories;
    } catch (e) {
      throw Exception('Failed to load game categories: $e');
    }
  }

  Future<List<dynamic>> fetchGamesByCategory(String slug) async {
    final url = '$BASE_URL/games?key=$API_KEY&genres=$slug&page_size=20';
    try {
      final data = await _getWithCache(url);
      print('Fetched data: $data'); // Veriyi konsola yazdırıyoruz
      return data['results'];
    } catch (e) {
      print('Error fetching games for category $slug: $e'); // Hata mesajı
      throw Exception('Failed to load games for category $slug: $e');
    }
  }

  Future<Map<String, dynamic>> fetchGameDetails(String gameId) async {
    final url = '$BASE_URL/games/$gameId?key=$API_KEY';
    try {
      final data = await _getWithCache(url);
      return data;
    } catch (e) {
      throw Exception('Failed to load game details for game $gameId: $e');
    }
  }

  Future<List<dynamic>> searchGames(String query) async {
    final url = '$BASE_URL/games?key=$API_KEY&search=$query&page_size=20';
    try {
      final data = await _getWithCache(url);
      return data['results'];
    } catch (e) {
      throw Exception('Failed to search games with query $query: $e');
    }
  }

  Future<List<dynamic>> fetchVideos({int perPage = 15}) async {
    // RAWG API'si video dönmüyor, bu yüzden bu metod şu an için sahte veri döndürüyor
    // Gerçek bir video API'si ile değiştirilmeli
    await Future.delayed(Duration(seconds: 1)); // Simüle edilmiş ağ gecikmesi
    return List.generate(
        perPage,
        (index) => {
              'id': 'video_$index',
              'name': 'Video $index',
              'image':
                  'https://via.placeholder.com/300x200.png?text=Video+$index',
              'duration': 120 + index * 10,
            });
  }

  Future<List<dynamic>> fetchWallpapers(
      {String category = 'gaming', int perPage = 30}) async {
    // RAWG API'si duvar kağıdı dönmüyor, bu yüzden bu metod şu an için sahte veri döndürüyor
    // Gerçek bir duvar kağıdı API'si ile değiştirilmeli
    await Future.delayed(Duration(seconds: 1)); // Simüle edilmiş ağ gecikmesi
    return List.generate(
        perPage,
        (index) => {
              'id': 'wallpaper_$index',
              'urls': {
                'small':
                    'https://via.placeholder.com/300x200.png?text=Wallpaper+$index',
                'regular':
                    'https://via.placeholder.com/1080x720.png?text=Wallpaper+$index',
              },
              'user': {
                'name': 'Photographer $index',
              },
              'description': 'A beautiful $category wallpaper',
            });
  }

  Future<List<dynamic>> fetchMoreGames(int page) async {
    final url = '$BASE_URL/games?key=$API_KEY&page=$page&page_size=10';
    try {
      final data = await _getWithCache(url);
      return data['results'];
    } catch (e) {
      throw Exception('Failed to load more games: $e');
    }
  }

  Future<List<dynamic>> fetchTopRatedGames() async {
    final url = '$BASE_URL/games?key=$API_KEY&ordering=-rating&page_size=10';
    try {
      final data = await _getWithCache(url);
      return data['results'];
    } catch (e) {
      throw Exception('Failed to load top rated games: $e');
    }
  }

  Future<List<dynamic>> fetchNewestGames() async {
    final url = '$BASE_URL/games?key=$API_KEY&ordering=-released&page_size=10';
    try {
      final data = await _getWithCache(url);
      return data['results'];
    } catch (e) {
      throw Exception('Failed to load newest games: $e');
    }
  }
}

class CacheItem {
  final dynamic data;
  final DateTime timestamp;

  CacheItem(this.data, this.timestamp);
}
