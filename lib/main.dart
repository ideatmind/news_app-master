import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/pages/home.dart';
import 'package:news_app/pages/landing_page.dart';
import 'package:news_app/providers/article_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the ArticleProvider and Hive
  final articleProvider = ArticleProvider();
  await articleProvider.initializeHive();
  
  runApp(MyApp(articleProvider: articleProvider));
}

class MyApp extends StatelessWidget {
  final ArticleProvider articleProvider;
  
  const MyApp({super.key, required this.articleProvider});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: articleProvider,
      child: MaterialApp(
        title: 'TheCodeWorkNews',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LandingPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

