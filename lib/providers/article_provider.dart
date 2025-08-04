import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/models/bookmark_model.dart';
import 'package:news_app/services/news.dart';
import 'package:news_app/services/slider_data.dart';
import 'package:news_app/models/slider_model.dart';

class ArticleProvider extends ChangeNotifier {
  List<ArticleModel> _articles = [];
  List<ArticleModel> _filteredArticles = [];
  List<SliderModel> _sliders = [];
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Box<BookmarkModel>? _bookmarkBox;

  // Getters
  List<ArticleModel> get articles => _filteredArticles.isEmpty && _searchQuery.isEmpty ? _articles : _filteredArticles;
  List<SliderModel> get sliders => _sliders;
  List<BookmarkModel> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Initialize Hive and load bookmarks
  Future<void> initializeHive() async {
    await Hive.initFlutter();
    
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BookmarkModelAdapter());
    }
    
    _bookmarkBox = await Hive.openBox<BookmarkModel>('bookmarks');
    await loadBookmarks();
  }

  // Load bookmarks from Hive
  Future<void> loadBookmarks() async {
    if (_bookmarkBox != null) {
      _bookmarks = _bookmarkBox!.values.toList();
      notifyListeners();
    }
  }

  // Fetch articles from API
  Future<void> fetchArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      News newsService = News();
      await newsService.getNews();
      _articles = newsService.news;
      
      // Apply current search filter if any
      if (_searchQuery.isNotEmpty) {
        _filterArticles(_searchQuery);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching articles: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch slider articles
  Future<void> fetchSliders() async {
    try {
      SliderData sliderService = SliderData();
      await sliderService.getSliders();
      _sliders = sliderService.sliders;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sliders: $e');
      }
    }
  }

  // Search and filter articles
  void searchArticles(String query) {
    _searchQuery = query;
    _filterArticles(query);
    notifyListeners();
  }

  void _filterArticles(String query) {
    if (query.isEmpty) {
      _filteredArticles = [];
    } else {
      _filteredArticles = _articles.where((article) {
        final titleMatch = article.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final descriptionMatch = article.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final authorMatch = article.author?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return titleMatch || descriptionMatch || authorMatch;
      }).toList();
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredArticles = [];
    notifyListeners();
  }

  // Check if article is bookmarked
  bool isBookmarked(ArticleModel article) {
    return _bookmarks.any((bookmark) => bookmark.url == article.url);
  }

  // Add bookmark
  Future<void> bookmarkArticle(ArticleModel article) async {
    if (_bookmarkBox != null && !isBookmarked(article)) {
      final bookmark = BookmarkModel.fromArticle(article);
      await _bookmarkBox!.add(bookmark);
      _bookmarks.add(bookmark);
      notifyListeners();
    }
  }

  // Remove bookmark
  Future<void> unbookmarkArticle(ArticleModel article) async {
    if (_bookmarkBox != null) {
      final index = _bookmarks.indexWhere((bookmark) => bookmark.url == article.url);
      if (index != -1) {
        await _bookmarks[index].delete();
        _bookmarks.removeAt(index);
        notifyListeners();
      }
    }
  }

  // Toggle bookmark status
  Future<void> toggleBookmark(ArticleModel article) async {
    if (isBookmarked(article)) {
      await unbookmarkArticle(article);
    } else {
      await bookmarkArticle(article);
    }
  }

  // Get bookmarked articles as ArticleModel list for display
  List<ArticleModel> getBookmarkedArticles() {
    return _bookmarks.map((bookmark) {
      return ArticleModel(
        author: bookmark.author,
        title: bookmark.title,
        description: bookmark.description,
        url: bookmark.url,
        urlToImage: bookmark.urlToImage,
        content: bookmark.content,
        publishedAt: bookmark.publishedAt,
      );
    }).toList();
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    if (_bookmarkBox != null) {
      await _bookmarkBox!.clear();
      _bookmarks.clear();
      notifyListeners();
    }
  }
}
