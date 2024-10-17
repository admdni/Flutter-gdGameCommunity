/*import 'package:flutter/material.dart';

import '../services/ api_service.dart';
import '../utils/ constants.dart';
import '../widgets/gamecard.dart';
import 'game_detail_screen.dart';

class CategoryGamesScreen extends StatefulWidget {
  final String category;

  CategoryGamesScreen({required this.category});

  @override
  _CategoryGamesScreenState createState() => _CategoryGamesScreenState();
}

class _CategoryGamesScreenState extends State<CategoryGamesScreen> {
  final ApiService _apiService = ApiService();
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
      final fetchedGames =
          await _apiService.fetchGamesByCategory(widget.category);
      setState(() {
        games = fetchedGames;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load games. Please try again.';
        isLoading = false;
      });
      print('Error loading games: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Games'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: ACCENT_COLOR))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGames,
                        child: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ACCENT_COLOR),
                      ),
                    ],
                  ),
                )
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
                        
                          
                        );
                      },
                    ),
    );
  }
}
*/