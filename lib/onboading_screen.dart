import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:uchat365/colors.dart';
import 'my_home_screen.dart';
import 'security_section/registeration_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String id = 'OnBoardingScreen';
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _pageController = PageController();
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 60),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2;
            });
          },
          children: [
            Center(
              child: Container(
                // color: Colors.red,
                child: const Text('Start Chat with Yor Friends'),
              ),
            ),
            Center(
              child: Container(
                // color: Colors.yellow,
                child: const Text('No need for a phone number'),
              ),
            ),
            Center(
              child: Container(
                // color: Colors.green,
                child: const Text('Share your happiness'),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? MaterialButton(
              color: blueColor,
              height: 60,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
                  ),
                );
              },
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 20, color: whiteColor),
              ))
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _pageController.jumpToPage(2);
                    },
                    child: const Text('SKIP'),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 3,
                      onDotClicked: (index) {
                        _pageController.animateToPage(index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      effect: WormEffect(
                        activeDotColor: blueColor,
                        dotColor: greyColor,
                        dotHeight: 12.0,
                        dotWidth: 12.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    },
                    child: Text('NEXT', style: TextStyle(color: blueColor)),
                  ),
                ],
              ),
            ),
    );
  }
}
