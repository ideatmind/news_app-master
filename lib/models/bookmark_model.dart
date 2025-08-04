import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 0)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  String? author;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? url;

  @HiveField(4)
  String? urlToImage;

  @HiveField(5)
  String? content;

  @HiveField(6)
  String? publishedAt;

  @HiveField(7)
  DateTime? bookmarkedAt;

  BookmarkModel({
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.content,
    this.publishedAt,
    this.bookmarkedAt,
  });

  // Factory constructor to create BookmarkModel from ArticleModel
  factory BookmarkModel.fromArticle(dynamic article) {
    return BookmarkModel(
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.urlToImage,
      content: article.content,
      publishedAt: article.publishedAt,
      bookmarkedAt: DateTime.now(),
    );
  }

  // Convert to ArticleModel for display purposes
  dynamic toArticle() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'content': content,
      'publishedAt': publishedAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkModel && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
