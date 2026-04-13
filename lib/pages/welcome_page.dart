import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Auto-advance to Get Started after 2.5 seconds — no tap needed.
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.goNamed('GetStartedPage');
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: sw,
        height: sh,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB6D9), Color(0xFFFFE5F0), Color(0xFFFFF5F8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top right decorative dog
              Positioned(
                top: -sh * 0.02,
                right: -sw * 0.05,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      'assets/logo.png',
                      width: sw * 0.4,
                      height: sw * 0.4,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: sw * 0.35,
                          height: sw * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(sw * 0.05),
                          ),
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Bottom left decorative dog
              Positioned(
                bottom: -sh * 0.01,
                left: -sw * 0.08,
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(
                    'assets/logo.png',
                    width: sw * 0.4,
                    height: sw * 0.4,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: sw * 0.35,
                        height: sw * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(sw * 0.05),
                        ),
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  SizedBox(height: sh * 0.06),

                  // App title
                  Image.asset('assets/text_logo.png', width: sw * 0.55),

                  // Small heart below title
                  Icon(
                    Icons.favorite,
                    size: sw * 0.04,
                    color: const Color(0xFFB8A8D8),
                  ),

                  SizedBox(height: sh * 0.06),

                  // Main dog illustration
                  Container(
                    width: sw * 0.6,
                    height: sw * 0.6,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dog image
                        Image.asset(
                          'assets/logo.png',
                          width: sw * 0.55,
                          height: sw * 0.55,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: sw * 0.4,
                              height: sw * 0.4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4169E1),
                                borderRadius: BorderRadius.circular(sw * 0.05),
                              ),
                              child: Icon(
                                Icons.pets,
                                size: sw * 0.25,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),

                        // Surrounding hearts
                        Positioned(
                          top: sw * 0.05,
                          left: sw * 0.05,
                          child: Icon(
                            Icons.favorite,
                            size: sw * 0.035,
                            color: const Color(0xFF7BA4E8),
                          ),
                        ),
                        Positioned(
                          bottom: sw * 0.02,
                          left: sw * 0.08,
                          child: Icon(
                            Icons.favorite,
                            size: sw * 0.04,
                            color: const Color(0xFF7BA4E8),
                          ),
                        ),
                        Positioned(
                          bottom: sw * 0.02,
                          right: sw * 0.08,
                          child: Icon(
                            Icons.favorite,
                            size: sw * 0.04,
                            color: const Color(0xFF7BA4E8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * 0.06),

                  // Tagline text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
                    child: Column(
                      children: [
                        Text(
                          "Manage your pet's",
                          style: TextStyle(
                            fontSize: sw * 0.068,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF7BA5),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "health easily.",
                          style: TextStyle(
                            fontSize: sw * 0.068,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF7BA5),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: sh * 0.01),
                        Text(
                          "Join a community of pet lovers!",
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF7BA5),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Auto-advance indicator
                  Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.05),
                    child: SizedBox(
                      width: sw * 0.12,
                      height: sw * 0.12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFFF7BA5).withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.02),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
