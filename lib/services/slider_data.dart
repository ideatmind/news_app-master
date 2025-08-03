import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_app/config/app_config.dart';
import 'package:news_app/models/slider_model.dart';

class SliderData {
  List<SliderModel> sliders = [];

  Future<void> getSliders() async {
    try {
      sliders.clear();

      var response = await http.get(
        Uri.parse(AppConfig.topHeadlinesUrl),
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
              SliderModel sliderModel = SliderModel(
                  title: element['title'],
                  description: element['description'],
                  url: element['url'] ?? '',
                  urlToImage: element['urlToImage'],
                  content: element['content'] ?? '',
                  publishedAt: element['publishedAt'] ?? '',
                  author: element['author'] ?? 'Unknown'
              );

              // Debug: Print article URL to verify it's valid
              print('Article URL: ${sliderModel.url}');

              sliders.add(sliderModel);
            }
          }
          print('Successfully parsed ${sliders.length} articles');
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