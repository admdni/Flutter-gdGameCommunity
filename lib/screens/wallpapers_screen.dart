import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class WallpapersScreen extends StatefulWidget {
  @override
  _WallpapersScreenState createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends State<WallpapersScreen> {
  final String apiKey =
      '0LlqmaPhM2j4BeFuTjAE5KabZhTpc1TlgNdAzBJEKEk'; // Unsplash API anahtarınızı buraya ekleyin
  final String baseUrl = 'https://api.unsplash.com';

  List<dynamic> wallpapers = [];
  bool isLoading = true;
  String currentCategory = 'gaming';

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }

  Future<void> _loadWallpapers({String category = 'gaming'}) async {
    setState(() {
      isLoading = true;
      currentCategory = category;
    });

    try {
      final fetchedWallpapers = await fetchWallpapers(category: category);
      setState(() {
        wallpapers = fetchedWallpapers;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading wallpapers: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load wallpapers. Please try again.')),
      );
    }
  }

  Future<List<dynamic>> fetchWallpapers({String category = 'gaming'}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/search/photos?query=$category&per_page=30&client_id=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> fetchedWallpapers = data['results'];
      return fetchedWallpapers;
    } else {
      throw Exception('Failed to load wallpapers: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gaming Wallpapers',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            _buildCategoryButtons(),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.amber))
                  : _buildWallpaperGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: GAMING_CATEGORIES.length,
        itemBuilder: (context, index) {
          final category = GAMING_CATEGORIES[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: Text(
                category.replaceAll(' gaming', '').toUpperCase(),
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: category == currentCategory
                    ? Colors.redAccent
                    : Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => _loadWallpapers(category: category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWallpaperGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = wallpapers[index];
        return GestureDetector(
          onTap: () => _showWallpaperDetails(wallpaper),
          child: Hero(
            tag: wallpaper['id'],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: wallpaper['urls']['small'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.amber)),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWallpaperDetails(Map<String, dynamic> wallpaper) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: wallpaper['id'],
                        child: CachedNetworkImage(
                          imageUrl: wallpaper['urls']['regular'],
                          fit: BoxFit.cover,
                          height: 300,
                          width: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photographer: ${wallpaper['user']['name']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Description: ${wallpaper['description'] ?? 'No description'}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadWallpaper(String url) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading wallpaper...')),
      );

      // Download image using flutter_file_downloader
      FileDownloader.downloadFile(
        url: url,
        name: 'wallpaper.jpg',
        onProgress: (name, progress) {
          print('Download progress: $progress%');
        },
        onDownloadCompleted: (path) {
          print('File downloaded to: $path');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wallpaper downloaded successfully!')),
          );
        },
        onDownloadError: (error) {
          print('Download error: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to download wallpaper. Please try again.')),
          );
        },
      );
    } catch (e) {
      print('Error downloading wallpaper: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to download wallpaper. Please try again.')),
      );
    }
  }
}

const List<String> GAMING_CATEGORIES = [
  'gaming',
  'gaming pc',
  'gaming setup',
  'gaming room',
  'gaming laptop',
  'gaming console',
  'gaming chair',
  'gaming desk',
  'gaming monitor',
  'gaming mouse',
  'gaming keyboard',
  'gaming headset',
  'gaming controller',
  'gaming wallpaper',
  'gaming background',
  'gaming art',
  'gaming illustration',
  'gaming concept',
  'gaming character',
  'gaming logo',
  'gaming icon',
  'gaming poster',
  'gaming banner',
  'gaming cover',
  'gaming splash',
  'gaming intro',
  'gaming outro',
  'gaming montage',
  'gaming highlight',
  'gaming clip',
  'gaming stream',
  'gaming broadcast',
  'gaming tournament',
  'gaming event',
  'gaming convention',
  'gaming expo',
  'gaming festival'
];
