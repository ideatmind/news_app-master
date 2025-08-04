import 'package:flutter/material.dart';
import 'package:news_app/pages/home.dart';
import 'package:news_app/pages/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                    "image/building.jpg",
                    height: MediaQuery.of(context).size.height/1.6,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Stay Informed. Stay Ahead.', style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold
            ),),
            const SizedBox(height: 10),
            const Text('From global headlines to local scoops \n          curated and delivered fast.', style: TextStyle(
                color: Colors.black54,
                fontSize: 20,
                fontWeight: FontWeight.w600
            ),),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width/1.3,
                child: Material(
                  borderRadius: BorderRadius.circular(30),
                  elevation: 4,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width/1.3,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                      child: Text('Get Started   >>', style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900
                      ),),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
