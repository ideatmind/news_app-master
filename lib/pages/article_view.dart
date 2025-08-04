import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:news_app/providers/article_provider.dart';
import 'package:news_app/models/article_model.dart';

class ArticleView extends StatefulWidget {
  final String? blogUrl;
  final String? title;
  final ArticleModel? article;
  
  ArticleView({super.key, required this.blogUrl, this.title, this.article});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.blogUrl ?? 'https://example.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
          child: Text(
            widget.title ?? 'Article',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
        actions: [
          if (widget.article != null)
            Consumer<ArticleProvider>(
              builder: (context, provider, child) {
                final isBookmarked = provider.isBookmarked(widget.article!);
                return IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.blue : Colors.grey[600],
                  ),
                  onPressed: () async {
                    await provider.toggleBookmark(widget.article!);
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
                  },
                );
              },
            ),
        ],
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
