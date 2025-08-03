import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_app/config/app_config.dart';
import 'package:news_app/models/show_category.dart';
import 'package:news_app/models/slider_model.dart';

class ShowCategoryNews {
  List<ShowCategory> categories = [];

  Future<void> getCategories(String category) async {
    try {
      categories.clear();

      var response = await http.get(
        Uri.parse("https://newsapi.org/v2/top-headlines?country=us&category=$category&apiKey=06773c62b9b74db2b7ffbc4be748edcb"),
        headers: {'User-Agent': 'NewsApp/1.0'},
      ).timeout(
        Duration(seconds: AppConfig.requestTimeoutSeconds),
      );

      print('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('API Response: ${jsonData['status']}, Total Articles: ${jsonData['totalResults']}');

        if(jsonData['status'] == 'ok' && jsonData['articles'] != null) {
          for (var element in jsonData['articles']) {
            if(element['urlToImage'] != null &&
                element['description'] != null &&
                element['title'] != null) {
              ShowCategory showCategory = ShowCategory(
                  title: element['title'],
                  description: element['description'],
                  url: element['url'] ?? '',
                  urlToImage: element['urlToImage'],
                  content: element['content'] ?? '',
                  publishedAt: element['publishedAt'] ?? '',
                  author: element['author'] ?? 'Unknown'
              );

              // Debug: Print article URL to verify it's valid
              print('Article URL: ${showCategory.url}');

              categories.add(showCategory);
            }
          }
          print('Successfully parsed ${categories.length} articles');
        } else {
          print('API returned error status: ${jsonData['status']}');
          if (jsonData['message'] != null) {
            print('Error message: ${jsonData['message']}');
          }
        }
      } else {
        print('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      rethrow; // Re-throw to allow UI to handle the error
    }
  }
}