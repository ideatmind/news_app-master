import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/category_model.dart';
import 'package:news_app/models/slider_model.dart';
import 'package:news_app/pages/article_view.dart';
import 'package:news_app/services/show_category-news.dart';

import '../models/show_category.dart';

class CategoryNews extends StatefulWidget {
  String? name;
  CategoryNews(this.name, {super.key});

  @override
  State<CategoryNews> createState() => _CategoryNewsState();
}

class _CategoryNewsState extends State<CategoryNews> {
  List<ShowCategory> showCategory = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    getCategoreies();
  }

  getCategoreies() async {
    setState(() {
      _loading = true;
    });
    try {
      ShowCategoryNews showCategoryNews = ShowCategoryNews();
      await showCategoryNews.getCategories(widget.name!.toLowerCase());
      showCategory = showCategoryNews.categories;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.name!,
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : Container(
              child: ListView.builder(
                itemCount: showCategory.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(15),
                    child: ShowCategoryWidget(
                      image: showCategory[index].urlToImage,
                      title: showCategory[index].title,
                      description: showCategory[index].description,
                      url: showCategory[index].url,
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class ShowCategoryWidget extends StatelessWidget {
  String? image, description, title, url;
  ShowCategoryWidget({super.key, this.image, this.description, this.title, this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ArticleView(
              blogUrl: url,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: image!,
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          ],
        ),
      ),
    );
  }
}
