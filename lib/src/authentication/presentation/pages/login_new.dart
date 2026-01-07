import 'package:flutter/material.dart';
import 'package:visitor_management/src/authentication/presentation/pages/widgets/login_form_new.dart';

class LoginNew extends StatelessWidget {
  const LoginNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/samata_doot_logo.png',
                    height: 80,
                  ),
                  Image.asset(
                    'assets/cm-dcm-social justice.png',
                    height: 80,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Samta Doot",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Justice for All,\nEquality for Everyone",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 4,
                            spreadRadius: 0,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.25))
                      ],
                      color: Colors.white),
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
                  child: LoginFormNew())
            ],
          ),
        ));
  }
}
