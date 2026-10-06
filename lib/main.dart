import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'send_money_screen.dart';
import 'qr_scanner_screen.dart';
import 'language_screen.dart';
import 'locale_controller.dart';




// ============================================================
// ECPAY COLORS
// ============================================================

const Color kBackground = Color.fromRGBO(13, 233, 112, 0.815);
const Color kDark = Color(0xFF000000);
const Color kSurface = Color.fromRGBO(17, 90, 53, 1);
const Color kLightSurface = Color.fromARGB(255, 255, 238, 238);
const Color kWhite = Color.fromARGB(255, 236, 255, 250);
const Color kTextGrey = Color.fromARGB(255, 206, 197, 197);

// ============================================================
// DARK MODE NOTIFIER
// ============================================================

final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);

// ============================================================
// NEUMORPHIC DECORATION
// ============================================================

BoxDecoration neumorphicDecoration({double radius = 20}) {
  return BoxDecoration(
    color: kSurface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(
        color: Colors.black87,
        blurRadius: 15,
        offset: Offset(7, 7),
      ),
      BoxShadow(
        color: Colors.white10,
        blurRadius: 12,
        offset: Offset(-5, -5),
      ),
    ],
  );
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration appInput({
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: kTextGrey, fontSize: 13),
    floatingLabelStyle: const TextStyle(
      color: kWhite,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    prefixIcon: Icon(icon, color: kTextGrey, size: 18),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: kDark,
    contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.white, width: 1.3),
    ),
  );
}

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await loadSavedLocale();

  runApp(const PaymentApp());
}

// ============================================================
// PAYMENT APP
// ============================================================

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('ta', 'IN'),
                Locale('hi', 'IN'),
                Locale('ml', 'IN'),
              ],
              debugShowCheckedModeBanner: false,
              title: 'ECpay',
              theme: ThemeData(
                useMaterial3: true,
                scaffoldBackgroundColor: kBackground,
                colorScheme: isDarkMode
                    ? const ColorScheme.dark(
                        surface: kBackground,
                        primary: kWhite,
                        secondary: kWhite,
                      )
                    : const ColorScheme.light(
                        surface: kBackground,
                        primary: kDark,
                        secondary: kDark,
                      ),
                appBarTheme: AppBarTheme(
                  backgroundColor: isDarkMode ? kDark : kWhite,
                  foregroundColor: isDarkMode ? kWhite : kDark,
                  elevation: 0,
                ),
              ),
              home: const AuthGate(),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kBackground,
            body: Center(
              child: CircularProgressIndicator(color: kWhite),
            ),
          );
        }

        if (snapshot.hasData) {
          return const RootScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: kSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        default:
          message = e.message ?? 'Login failed.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: kDark,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email first.'),
          backgroundColor: kDark,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent.'),
          backgroundColor: kSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to send reset email.'),
          backgroundColor: kDark,
        ),
      );
    }
  }

  // ==========================================================
  // LOGIN UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Language',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );
            },
            icon: const Icon(Icons.language, color: kDark),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              children: [
                // ECpay logo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  decoration: neumorphicDecoration(radius: 20),
                  child: const Text(
                    'ECpay',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Login container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 25, 22, 20),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 20,
                        offset: Offset(8, 8),
                      ),
                      BoxShadow(
                        color: Colors.white10,
                        blurRadius: 15,
                        offset: Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome to ECpay!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Login to continue making payments',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kTextGrey, fontSize: 12),
                        ),

                        const SizedBox(height: 25),

                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: kWhite, fontSize: 14),
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Please enter your email';
                            }

                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                          decoration: appInput(
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            loginUser();
                          },
                          style: const TextStyle(color: kWhite, fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }

                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }

                            return null;
                          },
                          decoration: appInput(
                            label: 'Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: kTextGrey,
                                size: 19,
                              ),
                            ),
                          ),
                        ),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: resetPassword,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: kWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Login button
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kWhite,
                                foregroundColor: kDark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: kDark,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // OR
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: kTextGrey,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: kTextGrey, fontSize: 12),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: kWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Secure payments with ECpay',
                  style: TextStyle(color: kTextGrey, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER SCREEN
// ============================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // REGISTER USER
  // ==========================================================

  Future<void> registerUser() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text;

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(name);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: kSurface,
        ),
      );

      // AuthGate automatically shows RootScreen.
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'operation-not-allowed':
          message = 'Email/Password login is disabled in Firebase.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: kDark),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: kDark),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // REGISTER UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kDark,
        foregroundColor: kWhite,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create your ECpay account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 28),

                // Name
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  decoration: appInput(
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!email.contains('@') || !email.contains('.')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                  decoration: appInput(
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 15),

                // Phone
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Please enter phone number';
                    }

                    if (phone.length < 10) {
                      return 'Enter a valid phone number';
                    }

                    return null;
                  },
                  decoration: appInput(
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                ),

                const SizedBox(height: 15),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                  decoration: appInput(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kTextGrey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Confirm password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    registerUser();
                  },
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }

                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                  decoration: appInput(
                    label: 'Confirm Password',
                    icon: Icons.lock_reset_outlined,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kTextGrey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Create account
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kWhite,
                      foregroundColor: kDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: kDark,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: kTextGrey, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROOT SCREEN
// ============================================================

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kDark,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: kWhite,
        unselectedItemColor: kTextGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void openScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kDark,
        foregroundColor: kWhite,
        title: const Text(
          'ECpay',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Language',
            onPressed: () => openScreen(context, const LanguageScreen()),
            icon: const Icon(Icons.language),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome
            Text(
              'Welcome ${user?.displayName ?? 'User'}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              user?.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextGrey, fontSize: 13),
            ),

            const SizedBox(height: 25),

            // Balance
            Container(
              padding: const EdgeInsets.all(24),
              decoration: neumorphicDecoration(radius: 25),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Balance',
                    style: TextStyle(color: kTextGrey, fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '₹1,250.00',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Quick Actions',
              style: TextStyle(
                color: kWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                actionButton(
                  context,
                  Icons.send_rounded,
                  'Send',
                  const SendMoneyScreen(),
                ),
                actionButton(
                  context,
                  Icons.qr_code_scanner_rounded,
                  'Scan',
                  const QrScannerScreen(),
                ),
                actionButton(
                  context,
                  Icons.history_rounded,
                  'History',
                  const HistoryScreen(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Send Money
            GestureDetector(
              onTap: () {
                openScreen(context, const SendMoneyScreen());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: neumorphicDecoration(radius: 18),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, color: kWhite),
                    SizedBox(width: 10),
                    Text(
                      'Send Money',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Recent transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: kWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            transactionTile(
              Icons.person_rounded,
              'Ajay Santhosh',
              'Sent',
              '-₹400',
            ),
            transactionTile(
              Icons.person_rounded,
              'Santhosh',
              'Received',
              '+₹500',
            ),
            transactionTile(
              Icons.person_rounded,
              'Ajay Santhosh',
              'Sent',
              '-₹400',
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ACTION BUTTON
  // ==========================================================

  static Widget actionButton(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: neumorphicDecoration(radius: 18),
            child: Icon(icon, color: kWhite, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: kWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TRANSACTION TILE
  // ==========================================================

  static Widget transactionTile(
    IconData icon,
    String name,
    String type,
    String amount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: neumorphicDecoration(radius: 16),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: neumorphicDecoration(radius: 14),
            child: Icon(icon, color: kWhite),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  type,
                  style: const TextStyle(color: kTextGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: kWhite,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
