import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/models/category_model.dart';
import 'package:news_app/models/show_category.dart';
import 'package:news_app/models/slider_model.dart';
import 'package:news_app/pages/all_news.dart';
import 'package:news_app/pages/article_view.dart';
import 'package:news_app/pages/category_news.dart';
import 'package:news_app/pages/bookmarks_page.dart';
import 'package:news_app/providers/article_provider.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    categories = getCategories();

    // Load data using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      provider.fetchArticles();
      provider.fetchSliders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        Provider.of<ArticleProvider>(context, listen: false).clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black87),
          onChanged: (value) {
            Provider.of<ArticleProvider>(context, listen: false)
                .searchArticles(value);
          },
        )
            : const Row(
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
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading trending news...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchArticles();
              await provider.fetchSliders();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show search results or regular content
                  if (provider.searchQuery.isNotEmpty)
                    _buildSearchResults(provider)
                  else
                    _buildRegularContent(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(ArticleProvider provider) {
    if (provider.articles.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Search Results (${provider.articles.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.articles.length,
          itemBuilder: (context, index) {
            return BlogTile(
              imageUrl: provider.articles[index].urlToImage ?? '',
              title: provider.articles[index].title ?? '',
              desc: provider.articles[index].description ?? '',
              url: provider.articles[index].url ?? '',
              article: provider.articles[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRegularContent(ArticleProvider provider) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0),
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
          const SizedBox(height: 8),
          // Fix: Move GestureDetector outside of const widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Breaking News!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllNews()),
                    );
                  },
                  child: const Text(
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
          const SizedBox(height: 6),
          if (provider.sliders.isNotEmpty)
            CarouselSlider.builder(
              itemCount: provider.sliders.length,
              itemBuilder: (context, index, realIndex) {
                String? image = provider.sliders[index].urlToImage;
                String? name = provider.sliders[index].title;
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
          const SizedBox(height: 15),
          if (provider.sliders.isNotEmpty)
            Center(child: buildIndicator(provider)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending News!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllNews()),
                    );
                  },
                  child: const Text(
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
          const SizedBox(height: 10),
          provider.articles.isEmpty
              ? const SizedBox(
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
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: provider.articles.length,
            itemBuilder: (context, index) {
              return BlogTile(
                imageUrl: provider.articles[index].urlToImage ?? '',
                title: provider.articles[index].title ?? '',
                desc: provider.articles[index].description ?? '',
                url: provider.articles[index].url ?? '',
                article: provider.articles[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildImage(String image, int index, String name) => GestureDetector(
    onTap: () {
      // Get the slider URL from provider
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      if (provider.sliders.isNotEmpty && index < provider.sliders.length) {
        final sliderUrl = provider.sliders[index].url;
        if (sliderUrl != null && sliderUrl.isNotEmpty) {
          final slider = provider.sliders[index];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleView(
                blogUrl: sliderUrl,
                title: slider.title,
              ),
            ),
          );
        }
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              height: 250,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              imageUrl: image,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 150),
            width: MediaQuery.of(context).size.width,
            height: 250,
            decoration: const BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget buildIndicator(ArticleProvider provider) => AnimatedSmoothIndicator(
    activeIndex: activeIndex,
    count: provider.sliders.length,
    effect: const WormEffect(
      dotWidth: 13,
      dotHeight: 13,
      activeDotColor: Colors.blue,
    ),
  );
}

class CategoryTile extends StatelessWidget {
  final String? image;
  final String? categoryName;

  const CategoryTile({super.key, required this.categoryName, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryNews(categoryName)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
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
                  style: const TextStyle(
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
  final String imageUrl, title, desc, url;
  final ArticleModel article;

  const BlogTile({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.desc,
    required this.url,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        final isBookmarked = provider.isBookmarked(article);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleView(
                  blogUrl: url,
                  title: title,
                  article: article,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              desc,
                              maxLines: 3,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.author ?? 'Unknown Author',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatPublishedDate(article.publishedAt),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    provider.toggleBookmark(article);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isBookmarked
                                              ? 'Removed from bookmarks'
                                              : 'Added to bookmarks',
                                        ),
                                        backgroundColor: isBookmarked
                                            ? Colors.orange
                                            : Colors.green,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isBookmarked ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPublishedDate(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) {
      return 'Unknown date';
    }

    try {
      final DateTime dateTime = DateTime.parse(publishedAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      // If parsing fails, try to extract a readable date
      return publishedAt.split('T')[0]; // Return just the date part
    }
  }
}