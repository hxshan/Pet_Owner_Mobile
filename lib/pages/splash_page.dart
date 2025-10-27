import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigate to next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      // );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            colors: [Color(0xFFF26B8C), const Color(0x40F26B8C)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative paw prints
            Positioned(
              top: sh * 0.15,
              left: sw * 0.1,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.pets,
                    size: sw * 0.08,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Positioned(
              top: sh * 0.25,
              right: sw * 0.15,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Icon(
                    Icons.pets,
                    size: sw * 0.06,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: sh * 0.2,
              left: sw * 0.15,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.pets,
                    size: sw * 0.07,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: sh * 0.3,
              right: sw * 0.1,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.pets,
                    size: sw * 0.09,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon container
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: sw * 0.4,
                        height: sw * 0.4,

                        child: Image.asset('asserts/logo.png'),
                        // child: Stack(
                        //   alignment: Alignment.center,
                        //   children: [
                        //     Icon(
                        //       Icons.pets,
                        //       size: sw * 0.2,
                        //       color: Colors.white,
                        //     ),
                        //     Positioned(
                        //       top: sw * 0.08,
                        //       right: sw * 0.08,
                        //       child: Container(
                        //         width: sw * 0.06,
                        //         height: sw * 0.06,
                        //         decoration: const BoxDecoration(
                        //           color: Color(0xFFFF69B4),
                        //           shape: BoxShape.circle,
                        //         ),
                        //         child: Center(
                        //           child: Icon(
                        //             Icons.favorite,
                        //             size: sw * 0.04,
                        //             color: Colors.white,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.04),

                  // App name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'PetCareHub',
                      style: TextStyle(
                        fontSize: sw * 0.09,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.015),

                  // Tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Join a community of pet lovers',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.08),

                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: sw * 0.15,
                      height: sw * 0.15,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom paw icon
            Positioned(
              bottom: sh * 0.05,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Icon(
                  Icons.pets,
                  size: sw * 0.08,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
