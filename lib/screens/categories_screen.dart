import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const String BASE_URL = 'https://api.rawg.io/api';
  static const String API_KEY = '29baf58b6b9d4b7fb3a23ecb55dbc0bb';

  List<dynamic> categories = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = '$BASE_URL/genres?key=$API_KEY';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['results'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load categories. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  void _navigateToCategoryGames(BuildContext context, String categorySlug) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryGamesScreen(categorySlug: categorySlug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Categories'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (ctx, index) {
                    final category = categories[index];
                    return CategoryCard(
                      category: category['name'],
                      onTap: () =>
                          _navigateToCategoryGames(context, category['slug']),
                    );
                  },
                ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey[200],
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.games,
                size: 50,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 10),
              Text(
                category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryGamesScreen extends StatefulWidget {
  final String categorySlug;

  CategoryGamesScreen({required this.categorySlug});

  @override
  _CategoryGamesScreenState createState() => _CategoryGamesScreenState();
}

class _CategoryGamesScreenState extends State<CategoryGamesScreen> {
  static const String BASE_URL = 'https://api.rawg.io/api';
  static const String API_KEY = '29baf58b6b9d4b7fb3a23ecb55dbc0bb';

  List<dynamic> games = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url =
          '$BASE_URL/games?key=$API_KEY&genres=${widget.categorySlug}&page_size=20';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          games = data['results'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load games. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categorySlug.toUpperCase()} Games'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : games.isEmpty
                  ? Center(child: Text('No games found for this category.'))
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  game['background_image'] ??
                                      'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  game['name'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
