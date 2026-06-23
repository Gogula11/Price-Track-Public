import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, AuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'package:TrueTrack/services/service_registry.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final registry = context.watch<ServiceRegistry>();

    if (registry.mockMode) {
      return const HomeScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    "https://d1rdz15x9x7c4f.cloudfront.net/assets/payload-images/TrackR_logo.png",
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    },
                  ),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to TrueTrack!, please sign in!')
                    : const Text('Welcome to TrueTrack!, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    "https://d1rdz15x9x7c4f.cloudfront.net/assets/payload-images/TrackR_logo.png",
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    },
                  ),
                ),
              );
            },
          );
        }

        final user = snapshot.data!;
        context.read<ServiceRegistry>().notification.saveFcmToken(user);
        context.read<ServiceRegistry>().notification.listenTokenRefresh(user);

        return const HomeScreen();
      },
    );
  }
}
