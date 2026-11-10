import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'settings_screens.dart';

// ============================================================
// ECPAY COLORS
// ============================================================

const Color kBackground = Color.fromARGB(255, 45, 194, 0);
const Color kDark = Color.fromARGB(255, 0, 0, 0);
const Color kSurface = Color.fromARGB(255, 104, 179, 85);
const Color kAvatarBackground = Color.fromARGB(255, 30, 30, 30);
const Color kWhite = Color(0xFFF7F7F7);
const Color kTextGrey = Color.fromARGB(255, 237, 243, 252);

// ============================================================
// NEUMORPHIC DECORATION
// ============================================================

BoxDecoration neumorphicDecoration({double radius = 18, bool pressed = false}) {
  return BoxDecoration(
    color: pressed ? kDark : kSurface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: pressed
        ? const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white10,
              offset: Offset(-2, -2),
              blurRadius: 6,
            ),
          ]
        : const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(6, 6),
              blurRadius: 12,
            ),
            BoxShadow(
              color: Colors.white10,
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
  );
}

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? imageUrl;
  String? phoneNumber;

  bool isUploading = false;

  final ImagePicker picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();

  Uint8List? selectedImageBytes;

  // ==========================================================
  // INIT STATE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    loadUserData();
    recoverLostImage();
  }

  Future<void> recoverLostImage() async {
    try {
      final LostDataResponse response = await picker.retrieveLostData();
      final List<XFile>? files = response.files;

      if (files == null || files.isEmpty) {
        if (response.exception != null) {
          showMessage(
            "Failed to recover selected image:\n${response.exception}",
            Colors.red,
          );
        }
        return;
      }

      await useSelectedImage(files.first);
    } catch (e) {
      showMessage("Failed to recover selected image:\n$e", Colors.red);
    }
  }

  // ==========================================================
  // LOAD USER DATA
  // ==========================================================

  Future<void> loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    nameController.text = user.displayName ?? "";

    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      if (mounted) {
        setState(() {
          imageUrl = user.photoURL;
        });
      }
    }

    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) return;

      final dynamic firestoreImage = data["profileImage"];
      if (firestoreImage != null && firestoreImage.toString().isNotEmpty) {
        if (mounted) {
          setState(() {
            imageUrl = firestoreImage.toString();
          });
        }
      }

      final dynamic firestorePhone = data["phone"];
      if (firestorePhone != null && firestorePhone.toString().isNotEmpty) {
        if (mounted) {
          setState(() {
            phoneNumber = firestorePhone.toString();
          });
        }
      }

      final dynamic firestoreName = data["name"];
      if (firestoreName != null && firestoreName.toString().trim().isNotEmpty) {
        if (user.displayName == null || user.displayName!.trim().isEmpty) {
          nameController.text = firestoreName.toString();
        }
      }
    } catch (e) {
      debugPrint("Failed to load user data: $e");
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // SHARED INPUT DECORATION
  // ==========================================================

  InputDecoration dialogInputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: kTextGrey),
      hintStyle: const TextStyle(color: kTextGrey),
      prefixIcon: Icon(icon, color: kWhite),
      suffixIcon: suffix,
      filled: true,
      fillColor: kDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kWhite, width: 2),
      ),
    );
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  Future<void> changePassword() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage("Please login first", Colors.red);
      return;
    }

    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Local dialog state (declared outside the builder so it survives
    // StatefulBuilder rebuilds)
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    bool isChangingPassword = false;
    String? errorMessage;

    final bool? changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Change Password",
                style: GoogleFonts.nunitoSans(
                  color: kWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // NEW PASSWORD
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: const TextStyle(color: kWhite),
                        decoration: dialogInputDecoration(
                          label: "New Password",
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: kWhite,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter a new password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // CONFIRM PASSWORD
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        style: const TextStyle(color: kWhite),
                        decoration: dialogInputDecoration(
                          label: "Confirm Password",
                          icon: Icons.lock_reset_outlined,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: kWhite,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm your password";
                          }
                          if (value != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      // INLINE ERROR (visible above the dialog barrier)
                      if (errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isChangingPassword
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: kTextGrey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isChangingPassword
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            isChangingPassword = true;
                            errorMessage = null;
                          });

                          try {
                            await user.updatePassword(
                              passwordController.text.trim(),
                            );

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext, true);
                          } on FirebaseAuthException catch (e) {
                            if (!dialogContext.mounted) return;

                            String message;
                            switch (e.code) {
                              case "requires-recent-login":
                                message =
                                    "For security, please logout and login again before changing your password.";
                                break;
                              case "weak-password":
                                message = "The password is too weak.";
                                break;
                              case "network-request-failed":
                                message =
                                    "Please check your internet connection.";
                                break;
                              default:
                                message =
                                    e.message ?? "Failed to change password.";
                            }

                            setDialogState(() {
                              isChangingPassword = false;
                              errorMessage = message;
                            });
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isChangingPassword = false;
                              errorMessage = "Failed to change password:\n$e";
                            });
                          }
                        },
                  icon: isChangingPassword
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kBackground,
                          ),
                        )
                      : const Icon(Icons.lock_reset),
                  label: Text(isChangingPassword ? "Changing..." : "Change"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    foregroundColor: kBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
    confirmPasswordController.dispose();

    if (changed == true && mounted) {
      showMessage("Password changed successfully", kSurface);
    }
  }

  // ==========================================================
  // SAVE NAME
  // ==========================================================

  Future<void> saveName() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final String name = nameController.text.trim();

    if (name.isEmpty) {
      showMessage("Please enter your name", Colors.red);
      return;
    }

    try {
      await user.updateDisplayName(name);

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": user.email,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.reload();

      if (!mounted) return;

      setState(() {});

      showMessage("Profile name saved successfully", kSurface);
    } catch (e) {
      showMessage("Failed to save name:\n$e", Colors.red);
    }
  }

  // ==========================================================
  // PICK IMAGE
  // ==========================================================

  Future<void> pickImage() async {
    if (isUploading) return;

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      await useSelectedImage(image);
    } catch (e) {
      showMessage("Failed to select image:\n$e", Colors.red);
    }
  }

  Future<void> useSelectedImage(XFile image) async {
    final Uint8List imageBytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      selectedImageBytes = imageBytes;
    });

    await uploadImage(imageBytes);
  }

  // ==========================================================
  // UPLOAD IMAGE
  // ==========================================================

  Future<void> uploadImage(Uint8List imageBytes) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage("Please login first", Colors.red);
      return;
    }

    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }

    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user.uid}.jpg");

      await storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: "image/jpeg"),
      );

      final String downloadUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "profileImage": downloadUrl,
        "email": user.email,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.reload();

      final User? updatedUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      setState(() {
        imageUrl = updatedUser?.photoURL ?? downloadUrl;
        selectedImageBytes = null;
        isUploading = false;
      });

      showMessage("Profile image updated successfully!", kSurface);
    } catch (e) {
      if (!mounted) return;

      // Keep the selected image as a preview so the user can tap to retry
      setState(() {
        isUploading = false;
      });

      showMessage("Failed to upload image:\n$e", Colors.red);
    }
  }

  // ==========================================================
  // PROFILE IMAGE
  // ==========================================================

  Widget profileImage() {
    return GestureDetector(
      onTap: isUploading ? null : pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            padding: const EdgeInsets.all(6),
            decoration: neumorphicDecoration(radius: 65, pressed: true),
            child: CircleAvatar(
              radius: 59,
              backgroundColor: kAvatarBackground,
              child: ClipOval(
                child: selectedImageBytes != null
                    ? Image.memory(
                        selectedImageBytes!,
                        width: 118,
                        height: 118,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 62,
                          color: kTextGrey,
                        ),
                      )
                    : imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        width: 118,
                        height: 118,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 62,
                          color: kTextGrey,
                        ),
                      )
                    : const Icon(Icons.person, size: 62, color: kTextGrey),
              ),
            ),
          ),

          if (isUploading)
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: kWhite, strokeWidth: 3),
              ),
            ),

          if (!isUploading)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: kWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(3, 3),
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: kBackground,
                  size: 21,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // INFORMATION CARD
  // ==========================================================

  Widget informationCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: neumorphicDecoration(radius: 18),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: neumorphicDecoration(radius: 24, pressed: true),
              child: Icon(icon, color: kWhite, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      color: kTextGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunitoSans(
                      color: kWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: neumorphicDecoration(radius: 18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: neumorphicDecoration(radius: 26, pressed: true),
              child: Icon(icon, color: kWhite, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      color: kTextGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: GoogleFonts.nunitoSans(
                      color: kWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PAYMENT STATISTICS (own StreamBuilder so only this part rebuilds)
  // ==========================================================

  Widget paymentStatistics(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("transactions")
          .where("userId", isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(color: kWhite, strokeWidth: 2.5),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: neumorphicDecoration(radius: 20, pressed: true),
            child: Text(
              "Error loading transactions:\n\n${snapshot.error}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: kWhite, fontSize: 14),
            ),
          );
        }

        final List<QueryDocumentSnapshot> transactions =
            snapshot.data?.docs ?? [];

        double totalAmount = 0;

        for (final transaction in transactions) {
          final dynamic rawData = transaction.data();

          if (rawData is! Map<String, dynamic>) continue;

          final dynamic amount = rawData["amount"];

          if (amount is num) {
            totalAmount += amount.toDouble();
          } else if (amount is String) {
            totalAmount += double.tryParse(amount.trim()) ?? 0;
          }
        }

        return Column(
          children: [
            statCard(
              icon: Icons.receipt_long_outlined,
              title: "Total Transactions",
              value: "${transactions.length} transactions",
            ),
            statCard(
              icon: Icons.currency_rupee,
              title: "Total Amount",
              value: "₹${totalAmount.toStringAsFixed(2)}",
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // EDIT NAME
  // ==========================================================

  Future<void> showEditNameDialog() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    nameController.text = user.displayName ?? "";

    String? errorText;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Edit Profile Name",
                style: GoogleFonts.nunitoSans(
                  color: kWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: kWhite, fontSize: 16),
                decoration: dialogInputDecoration(
                  label: "Name",
                  hint: "Enter your name",
                  icon: Icons.person_outline,
                ).copyWith(errorText: errorText),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: kTextGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      setDialogState(() {
                        errorText = "Please enter your name";
                      });
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    foregroundColor: kBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await saveName();
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            "Please login first",
            style: TextStyle(color: kWhite, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 10, 9),
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Text(
            "Profile",
            style: GoogleFonts.nunitoSans(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          children: [
            // PROFILE IMAGE
            profileImage(),

            const SizedBox(height: 14),

            Text(
              "Tap image to change",
              style: GoogleFonts.nunitoSans(fontSize: 13, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // USER NAME
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : "ECpay User",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      color: kWhite,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: showEditNameDialog,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: neumorphicDecoration(radius: 20, pressed: true),
                    child: const Icon(Icons.edit, color: kWhite, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            // EMAIL
            Text(
              user.email ?? "No email available",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(color: kTextGrey, fontSize: 14),
            ),

            const SizedBox(height: 28),

            // ACCOUNT INFORMATION
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Account Information",
                style: GoogleFonts.nunitoSans(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            informationCard(
              icon: Icons.phone_android_outlined,
              title: "Mobile Number",
              value: phoneNumber ?? "Not added",
            ),

            informationCard(
              icon: Icons.email_outlined,
              title: "Email",
              value: user.email ?? "No email available",
            ),

            // CHANGE PASSWORD
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: neumorphicDecoration(radius: 18),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: neumorphicDecoration(
                        radius: 24,
                        pressed: true,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: kWhite,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Change Password",
                            style: GoogleFonts.nunitoSans(
                              color: kWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Update your account password",
                            style: GoogleFonts.nunitoSans(
                              color: kTextGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: changePassword,
                      icon: const Icon(Icons.password_outlined, size: 18),
                      label: const Text("Change"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kWhite,
                        foregroundColor: kBackground,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SETTINGS BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: neumorphicDecoration(radius: 18),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: neumorphicDecoration(
                          radius: 24,
                          pressed: true,
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: kWhite,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Settings",
                              style: GoogleFonts.nunitoSans(
                                color: kWhite,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Manage your account settings",
                              style: GoogleFonts.nunitoSans(
                                color: kTextGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: kTextGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // PAYMENT STATISTICS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment Statistics",
                style: GoogleFonts.nunitoSans(
                  color: kWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            paymentStatistics(user),

            const SizedBox(height: 18),

            // LOGOUT
            SizedBox(
              width: 230,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout_rounded, size: 21),
                label: Text(
                  "Logout",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kWhite,
                  foregroundColor: kBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "ECpay • Secure Payments",
              style: GoogleFonts.nunitoSans(color: kTextGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
