import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ api_service.dart';
import '../utils/ constants.dart';
import '../widgets/gamecard.dart';
import 'game_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  List<String> searchHistory = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', searchHistory);
  }

  void _addToSearchHistory(String query) {
    if (!searchHistory.contains(query)) {
      setState(() {
        searchHistory.insert(0, query);
        if (searchHistory.length > 10) {
          searchHistory.removeLast();
        }
      });
      _saveSearchHistory();
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final results = await _apiService.searchGames(query);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
      _addToSearchHistory(query);
    } catch (e) {
      print('Error searching games: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search games. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        title: Text('Search Games', style: TextStyle(color: TEXT_COLOR)),
        backgroundColor: PRIMARY_COLOR,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: PRIMARY_COLOR,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: TEXT_COLOR),
              decoration: InputDecoration(
                hintText: 'Search for games...',
                hintStyle: TextStyle(color: TEXT_COLOR.withOpacity(0.6)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: ACCENT_COLOR),
                  onPressed: () => _search(_searchController.text),
                ),
                filled: true,
                fillColor: SURFACE_COLOR,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: ACCENT_COLOR))
                : searchResults.isEmpty
                    ? _buildSearchHistory()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return ListView.builder(
      itemCount: searchHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.history, color: ACCENT_COLOR),
          title:
              Text(searchHistory[index], style: TextStyle(color: TEXT_COLOR)),
          onTap: () {
            _searchController.text = searchHistory[index];
            _search(searchHistory[index]);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return GameCard(
          game: searchResults[index],
          onTap: () => _navigateToGameDetail(context, searchResults[index]),
        );
      },
    );
  }

  void _navigateToGameDetail(BuildContext context, dynamic game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(game: game),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
