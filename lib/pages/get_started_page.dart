import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: sh * 0.08,
            horizontal: sw * 0.08,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: sh * 0.05),

              /// TITLE
              Text(
                "Get Started With\nPet Something",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sw * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: sh * 0.1),

              /// SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: AppButtonStyles.blackButton(context),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: sh * 0.05),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: AppButtonStyles.blackButton(context),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: sh * 0.07),

              /// FOOTER TEXT
              Text(
                "Join a community of pet lovers!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: sw * 0.04, color: Colors.black87),
              ),

              SizedBox(height: sh * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
