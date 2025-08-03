import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/models/category_model.dart';
import 'package:news_app/models/show_category.dart';
import 'package:news_app/models/slider_model.dart';
import 'package:news_app/pages/all_news.dart';
import 'package:news_app/pages/article_view.dart';
import 'package:news_app/pages/category_news.dart';
// import 'package:news_app/pages/article_view_simple.dart'; // Simple WebView
// import 'package:news_app/pages/article_view_text.dart';   // Text-based
import 'package:news_app/services/category_data.dart';
import 'package:news_app/services/news.dart';
import 'package:news_app/services/slider_data.dart';
import 'package:news_app/config/app_config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categories = [];
  List<SliderModel> sliders = [];
  List<ArticleModel> articles = [];
  bool _loading = true;

  int activeIndex = 0;

  @override
  void initState() {
    categories = getCategories();
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
            content: Text('Failed to load news. Please check your internet connection.'),
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
            content: Text('Failed to load news. Please check your internet connection.'),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TheCodeWork', style: TextStyle(fontFamily: 'Poppins')),
            Text(
              'News',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body:
          _loading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading trending news...'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await getNews();
                  },
                  child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return CategoryTile(
                              categoryName: categories[index].categoryName,
                              image: categories[index].image,
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Breaking News!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> AllNews()));
                              },
                              child: Text(
                                'View all ->',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 6),

                      CarouselSlider.builder(
                        itemCount: 5,
                        itemBuilder: (context, index, realIndex) {
                          String? image = sliders[index].urlToImage;
                          String? name = sliders[index].title;
                          return buildImage(image!, index, name!);
                        },
                        options: CarouselOptions(
                          height: 250,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                          onPageChanged: (index, reason) {
                            setState(() {
                              activeIndex = index;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      Center(child: buildIndicator()),

                      SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trending News!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> AllNews()));
                              },
                              child: Text(
                                'View all ->',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                                            SizedBox(height: 10),

                      Container(
                        child: articles.isEmpty
                            ? Container(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    'No trending news available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: articles.length,
                                itemBuilder: (context, index) {
                                  return BlogTile(
                                    description: articles[index].description,
                                    title: articles[index].title,
                                    imageUrl: articles[index].urlToImage,
                                    publishedAt: articles[index].publishedAt,
                                    articleUrl: articles[index].url,
                                    author: articles[index].author,
                                    content: articles[index].content,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
    );
  }

  Widget buildImage(String image, int index, String name) => Container(
    margin: EdgeInsets.symmetric(horizontal: 10),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            height: 250,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width, imageUrl: image,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 170),
          width: MediaQuery.of(context).size.width,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget buildIndicator() => AnimatedSmoothIndicator(
    activeIndex: activeIndex,
    count: 5,
    effect: WormEffect(
      dotWidth: 13,
      dotHeight: 13,
      activeDotColor: Colors.blue,
    ),
  );
}

class CategoryTile extends StatelessWidget {
  final String? image;
  final String? categoryName;

  const CategoryTile({required this.categoryName, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryNews(categoryName)));
      },
      child: Container(
        margin: EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                image!,
                width: 120,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: 120,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.black38,
              ),
              child: Center(
                child: Text(
                  categoryName!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlogTile extends StatelessWidget {
  String? imageUrl, title, description, publishedAt, articleUrl, author, content;
  BlogTile({
    super.key,
    required this.description,
    required this.title,
    required this.imageUrl,
    required this.publishedAt,
    required this.articleUrl,
    this.author,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          Navigator.push(
            context, 
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ArticleView(
                blogUrl: articleUrl,
                title: title,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 300),
            )
          );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Material(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        imageUrl: imageUrl!,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.8,
                        child: Text(
                          title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.8,
                        child: Text(
                          description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
