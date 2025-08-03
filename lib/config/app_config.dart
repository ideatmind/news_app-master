class AppConfig {
  static const String newsApiKey = '06773c62b9b74db2b7ffbc4be748edcb';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';

  static String get topHeadlinesUrl => '$newsApiBaseUrl/top-headlines?country=us&sortBy=popularity&apiKey=$newsApiKey';
  static String get everythingUrl => '$newsApiBaseUrl/everything?apiKey=$newsApiKey';

  static const int maxTrendingArticles = 5;
  static const int requestTimeoutSeconds = 30;
}