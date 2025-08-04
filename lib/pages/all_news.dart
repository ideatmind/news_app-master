import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article_model.dart';
import '../providers/article_provider.dart';
import 'article_view.dart';

class AllNews extends StatefulWidget {
  final String? category;
  AllNews({super.key, this.category});

  @override
  State<AllNews> createState() => _AllNewsState();
}

class _AllNewsState extends State<AllNews> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      if (provider.articles.isEmpty) {
        provider.fetchArticles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.category != null ? '${widget.category} News' : 'All News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Consumer<ArticleProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  provider.fetchArticles();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          if (provider.articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No articles available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.fetchArticles(),
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchArticles();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: provider.articles.length,
              itemBuilder: (context, index) {
                final article = provider.articles[index];
                return _buildArticleCard(article, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(ArticleModel article, ArticleProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleView(
                blogUrl: article.url,
                title: article.title,
                article: article,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),

            // Article Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Bookmark
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          article.title ?? 'No Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Consumer<ArticleProvider>(
                        builder: (context, provider, child) {
                          final isBookmarked = provider.isBookmarked(article);
                          return IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? Colors.blue : Colors.grey[600],
                            ),
                            onPressed: () async {
                              await provider.toggleBookmark(article);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isBookmarked
                                          ? 'Removed from bookmarks'
                                          : 'Added to bookmarks',
                                    ),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: isBookmarked ? Colors.red : Colors.green,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Description
                  if (article.description != null && article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 12),

                  // Author and Date
                  Row(
                    children: [
                      if (article.author != null && article.author!.isNotEmpty) ...[
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.author!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      if (article.publishedAt != null) ...[
                        if (article.author != null && article.author!.isNotEmpty)
                          SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(article.publishedAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}