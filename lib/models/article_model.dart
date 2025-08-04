class ArticleModel {
  String? author;
  String? title;
  String? description;
  String? url;
  String? urlToImage;
  String? content;
  String? publishedAt;

  ArticleModel({this.author, this.title, this.description, this.url, this.urlToImage, this.content, this.publishedAt});

  // Convert to JSON
  Map<String, dynamic> toJson() {
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

  // Create from JSON
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      content: json['content'],
      publishedAt: json['publishedAt'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleModel && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}