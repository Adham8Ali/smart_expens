import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/firebase_options.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/screen/login_screen.dart';
import 'package:smart_expens/screen/major_screen.dart';
import 'package:smart_expens/screen/navBar_screen.dart';
import 'package:smart_expens/screen/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Spend',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF115E38),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF115E38),
            elevation: 0,
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // ── Waiting for auth state ──────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = snapshot.data;

            if (user != null) {
              // ── User is signed in → start the expense stream ──────────────
              // addPostFrameCallback ensures we never call notifyListeners()
              // during a build phase (which would throw an assertion error).
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<ExpenseProvider>().startListening(user.uid);
              });
              return const NavbarScreen(monthlyBudget: 1);
            }

            // ── User signed out → stop stream and clear local state ─────────
            // Also wrapped in addPostFrameCallback for the same reason.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ExpenseProvider>().stopListening();
            });
            return const MajorScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const NavbarScreen(monthlyBudget: 1),
        },
      ),
    );
  }
}
