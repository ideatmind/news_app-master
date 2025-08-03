import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../models/slider_model.dart';
import '../services/news.dart';
import '../services/slider_data.dart';
import 'article_view.dart';

class AllNews extends StatefulWidget {
  String? news;
  AllNews({super.key, this.news});

  @override
  State<AllNews> createState() => _AllNewsState();
}

class _AllNewsState extends State<AllNews> {
  List<SliderModel> sliders = [];
  List<ArticleModel> articles = [];
  bool _loading = true;

  @override
  void initState() {
    getSliders();
    getNews();
    super.initState();
  }

  getSliders() async {
    try {
      SliderData slider = SliderData();
      await slider.getSliders();
      sliders = slider.sliders;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Error in getNews: $e');
      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to load news. Please check your internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  getNews() async {
    try {
      News newsClass = News();
      await newsClass.getNews();
      articles = newsClass.news;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Error in getNews: $e');
      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to load news. Please check your internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('All News'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: articles[index].urlToImage != null
                ? Image.network(
              articles[index].urlToImage!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            )
                : Icon(Icons.article),
            title: Text(
              articles[index].title ?? 'No title',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            subtitle: Text(
              articles[index].description ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ArticleView(
                        blogUrl: articles[index].url,
                        title: articles[index].title,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}