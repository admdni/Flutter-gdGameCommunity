// utils/constants.dart
import 'package:flutter/material.dart';

const String API_KEY = 'api';
const String BASE_URL = 'https://www.giantbomb.com/api';
const String PEXELS_API_KEY =
    'api';

const String UNSPLASH_API_KEY =
    'api'; // Unsplash API anahtarınızı buraya ekleyin

const List<String> GAMING_CATEGORIES = [
  'gaming',
  'action gaming',
  'rpg gaming',
  'fps gaming',
  'simulation gaming'
];

// Kategori listesi
const List<String> GAME_CATEGORIES = [
  'Action',
  'RPG',
  'Strategy',
  'Sports',
  'Adventure',
  'Puzzle',
  'Shooter',
  'Racing',
  'Simulation',
  'Fighting',
  'Platformer',
  'Survival',
  'Horror',
  'Stealth',
  'Music',
  'Party',
  'Educational',
  'Casual',
  'MMO',
  'Sandbox',
  'Open World',
  'Rhythm',
  'Tactical',
  'Hack and Slash',
  'Visual Novel',
  'Interactive Movie',
  'Pinball',
  'Board Game',
  'Card Game',
  'Arcade',
  'FPS',
  'TPS',
  'MOBA',
  'Battle Royale',
  'Roguelike',
  'Roguelite',
  'Metroidvania',
  'Survival Horror',
  'Action-Adventure',
  'JRPG',
  'MMORPG',
  'RTS',
  'RTT',
  '4X',
  'Grand Strategy',
  'Turn-Based Strategy',
  'Turn-Based Tactics',
  'Real-Time Tactics',
  'TBS',
  'Rhythm',
  'Puzzle-Platformer',
  'Action RPG',
  'MMOFPS',
  'MMORTS',
  'MMOTPS',
  'MMOSG',
  'MMOARPG',
  'MMORPG'
];

// Tema renkleri

const Color PRIMARY_COLOR = Colors.deepPurple;
const Color ACCENT_COLOR = Colors.deepPurpleAccent;
const Color BACKGROUND_COLOR = Color(0xFF121212);
const Color SURFACE_COLOR = Color(0xFF1E1E1E);
const Color ON_SURFACE_COLOR = Color.fromARGB(255, 11, 212, 215);
const Color ON_ACCENT_COLOR = Color.fromARGB(255, 204, 37, 37);
const Color TEXT_COLOR = Color(0xFFFFFFFF);

// Metin stilleri
const TextStyle HEADER_TEXT_STYLE = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle SUBHEADER_TEXT_STYLE = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.blue,
);

const TextStyle BODY_TEXT_STYLE = TextStyle(
  fontSize: 14,
  color: Colors.white60,
);

// Animasyon süreleri
const Duration TRANSITION_DURATION = Duration(milliseconds: 300);
const Duration SPLASH_DURATION = Duration(seconds: 3);

// Görüntü boyutları
const double CAROUSEL_HEIGHT = 200.0;
const double GRID_ITEM_HEIGHT = 180.0;
const double GRID_ITEM_WIDTH = 120.0;

// Arama gecikmesi
const Duration SEARCH_DEBOUNCE = Duration(milliseconds: 500);
