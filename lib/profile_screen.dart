
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'settings_screens.dart';

// ============================================================
// ECpay COLORS
// ============================================================

const Color kBackground = Color.fromARGB(255, 0, 194, 97);
const Color kDark = Color.fromARGB(255, 0, 0, 0);
const Color kSurface = Color.fromARGB(255, 85, 179, 127);
const Color kLightSurface = Color.fromARGB(255, 221, 238, 255);
const Color kWhite = Color(0xFFF7F7F7);
const Color kTextGrey = Color.fromARGB(255, 237, 243, 252);

// ============================================================
// NEUMORPHIC DECORATION
// ============================================================

BoxDecoration neumorphicDecoration({
  double radius = 18,
  bool pressed = false,
}) {
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

  bool isUploading = false;
  bool isChangingPassword = false;

  final ImagePicker picker = ImagePicker();

  final TextEditingController nameController =
      TextEditingController();

  XFile? selectedImage;

  // ==========================================================
  // INIT STATE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ==========================================================
  // LOAD USER DATA
  // ==========================================================

  Future<void> loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    nameController.text = user.displayName ?? "";

    // Load image from Firebase Authentication
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      if (mounted) {
        setState(() {
          imageUrl = user.photoURL;
        });
      }
    }

    // Load additional information from Firestore
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) return;

      // Firestore profile image
      final dynamic firestoreImage = data["profileImage"];

      if (firestoreImage != null &&
          firestoreImage.toString().isNotEmpty) {
        if (mounted) {
          setState(() {
            imageUrl = firestoreImage.toString();
          });
        }
      }

      // Firestore name
      final dynamic firestoreName = data["name"];

      if (firestoreName != null &&
          firestoreName.toString().trim().isNotEmpty) {
        if (user.displayName == null ||
            user.displayName!.trim().isEmpty) {
          nameController.text = firestoreName.toString();
        }
      }
    } catch (e) {
      debugPrint("Failed to load user data: $e");
    }
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  Future<void> changePassword() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        "Please login first",
        Colors.red,
      );
      return;
    }

    final TextEditingController passwordController =
        TextEditingController();

    final TextEditingController confirmPasswordController =
        TextEditingController();

    final GlobalKey<FormState> formKey =
        GlobalKey<FormState>();

    final bool? changePasswordConfirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool obscurePassword = true;
        bool obscureConfirmPassword = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Change Password",
                style: TextStyle(
                  color: kWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NEW PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: const TextStyle(
                        color: kWhite,
                      ),
                      decoration: InputDecoration(
                        labelText: "New Password",
                        labelStyle: const TextStyle(
                          color: kTextGrey,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: kWhite,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: kWhite,
                          ),
                        ),
                        filled: true,
                        fillColor: kDark,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
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
                      style: const TextStyle(
                        color: kWhite,
                      ),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: const TextStyle(
                          color: kTextGrey,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_reset_outlined,
                          color: kWhite,
                        ),
                        suffixIcon: IconButton(
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
                        filled: true,
                        fillColor: kDark,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: kTextGrey,
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: isChangingPassword
                      ? null
                      : () async {
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          setDialogState(() {
                            isChangingPassword = true;
                          });

                          try {
                            await user.updatePassword(
                              passwordController.text.trim(),
                            );

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          } on FirebaseAuthException catch (e) {
                            setDialogState(() {
                              isChangingPassword = false;
                            });

                            String message;

                            switch (e.code) {
                              case "requires-recent-login":
                                message =
                                    "For security, please logout and login again before changing your password.";
                                break;

                              case "weak-password":
                                message =
                                    "The password is too weak.";
                                break;

                              case "network-request-failed":
                                message =
                                    "Please check your internet connection.";
                                break;

                              default:
                                message = e.message ??
                                    "Failed to change password.";
                            }

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isChangingPassword = false;
                            });

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Failed to change password:\n$e",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
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
                      : const Icon(
                          Icons.lock_reset,
                        ),
                  label: Text(
                    isChangingPassword
                        ? "Changing..."
                        : "Change",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    foregroundColor: kBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
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

    if (changePasswordConfirmed == true && mounted) {
      showMessage(
        "Password changed successfully",
        kSurface,
      );
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
    String message,
    Color color,
  ) {
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
  // SAVE NAME
  // ==========================================================

  Future<void> saveName() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final String name =
        nameController.text.trim();

    if (name.isEmpty) {
      showMessage(
        "Please enter your name",
        Colors.red,
      );
      return;
    }

    try {
      await user.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(
        {
          "uid": user.uid,
          "name": name,
          "email": user.email,
          "updatedAt":
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await user.reload();

      if (!mounted) return;

      setState(() {});

      showMessage(
        "Profile name saved successfully",
        kSurface,
      );
    } catch (e) {
      showMessage(
        "Failed to save name:\n$e",
        Colors.red,
      );
    }
  }

  // ==========================================================
  // PICK IMAGE
  // ==========================================================

  Future<void> pickImage() async {
    if (isUploading) return;

    try {
      final XFile? image =
          await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        selectedImage = image;
      });

      await uploadImage(image);
    } catch (e) {
      showMessage(
        "Failed to select image:\n$e",
        Colors.red,
      );
    }
  }

  // ==========================================================
  // UPLOAD IMAGE
  // ==========================================================

  Future<void> uploadImage(
    XFile imageFile,
  ) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        "Please login first",
        Colors.red,
      );
      return;
    }

    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }

    try {
      final Reference storageRef =
          FirebaseStorage.instance
              .ref()
              .child("profile_images")
              .child("${user.uid}.jpg");

      await storageRef.putFile(
        File(imageFile.path),
        SettableMetadata(
          contentType: "image/jpeg",
        ),
      );

      final String downloadUrl =
          await storageRef.getDownloadURL();

      // Save to Firebase Authentication
      await user.updatePhotoURL(downloadUrl);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(
        {
          "uid": user.uid,
          "profileImage": downloadUrl,
          "email": user.email,
          "updatedAt":
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await user.reload();

      final User? updatedUser =
          FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      setState(() {
        imageUrl =
            updatedUser?.photoURL ?? downloadUrl;

        selectedImage = null;
        isUploading = false;
      });

      showMessage(
        "Profile image updated successfully!",
        kSurface,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      showMessage(
        "Failed to upload image:\n$e",
        Colors.red,
      );
    }
  }

  // ==========================================================
  // PROFILE IMAGE
  // ==========================================================

  Widget profileImage(User user) {
    return GestureDetector(
      onTap: isUploading ? null : pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            padding: const EdgeInsets.all(6),
            decoration: neumorphicDecoration(
              radius: 65,
              pressed: true,
            ),
            child: CircleAvatar(
              radius: 59,
              backgroundColor: kLightSurface,
              backgroundImage:
                  selectedImage != null
                      ? FileImage(
                          File(selectedImage!.path),
                        )
                      : imageUrl != null &&
                              imageUrl!.isNotEmpty
                          ? NetworkImage(imageUrl!)
                          : null,
              child: selectedImage == null &&
                      (imageUrl == null ||
                          imageUrl!.isEmpty)
                  ? const Icon(
                      Icons.person,
                      size: 62,
                      color: kTextGrey,
                    )
                  : null,
            ),
          ),

          if (isUploading)
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.65,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: kWhite,
                  strokeWidth: 3,
                ),
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
      decoration: neumorphicDecoration(
        radius: 18,
      ),
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
              child: Icon(
                icon,
                color: kWhite,
                size: 22,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kTextGrey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    value,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
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
      decoration: neumorphicDecoration(
        radius: 18,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: neumorphicDecoration(
                radius: 26,
                pressed: true,
              ),
              child: Icon(
                icon,
                color: kWhite,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kTextGrey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    value,
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
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
  // EDIT NAME
  // ==========================================================

  void showEditNameDialog() {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    nameController.text =
        user.displayName ?? "";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            "Edit Profile Name",
            style: TextStyle(
              color: kWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            style: const TextStyle(
              color: kWhite,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: "Enter your name",
              hintStyle: const TextStyle(
                color: kTextGrey,
              ),
              labelText: "Name",
              labelStyle: const TextStyle(
                color: kTextGrey,
              ),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: kWhite,
              ),
              filled: true,
              fillColor: kDark,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide:
                    const BorderSide(
                  color: kWhite,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: kTextGrey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final String name =
                    nameController.text.trim();

                if (name.isEmpty) {
                  showMessage(
                    "Please enter your name",
                    Colors.red,
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                await saveName();
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: kWhite,
                foregroundColor: kBackground,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            "Please login first",
            style: TextStyle(
              color: kWhite,
              fontSize: 16,
            ),
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
        backgroundColor: kBackground,
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 9,
          ),
          decoration:
              neumorphicDecoration(
            radius: 25,
          ),
          child: const Text(
            "Profile",
            style: TextStyle(
              color: kWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // ======================================================
      // TRANSACTIONS
      // ======================================================

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("transactions")
            .where(
              "userId",
              isEqualTo: user.uid,
            )
            .snapshots(),

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: kWhite,
                strokeWidth: 2.5,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration:
                      neumorphicDecoration(
                    radius: 20,
                    pressed: true,
                  ),
                  child: Text(
                    "Error loading transactions:\n\n"
                    "${snapshot.error}",
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: kWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }

          final List<QueryDocumentSnapshot>
              transactions =
              snapshot.data?.docs ?? [];

          double totalAmount = 0;

          for (final transaction
              in transactions) {
            final data =
                transaction.data()
                    as Map<String, dynamic>;

            final dynamic amount =
                data["amount"];

            if (amount is num) {
              totalAmount +=
                  amount.toDouble();
            } else if (amount is String) {
              totalAmount +=
                  double.tryParse(amount) ?? 0;
            }
          }

          // ==================================================
          // MAIN CONTENT
          // ==================================================

          return SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              children: [
                // PROFILE IMAGE
                profileImage(user),

                const SizedBox(height: 14),

                const Text(
                  "Tap image to change",
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),

                // USER NAME
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName
                                    ?.isNotEmpty ==
                                true
                            ? user.displayName!
                            : "ECpay User",
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color: kWhite,
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap:
                          showEditNameDialog,
                      child: Container(
                        padding:
                            const EdgeInsets
                                .all(7),
                        decoration:
                            neumorphicDecoration(
                          radius: 20,
                          pressed: true,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: kWhite,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                // EMAIL
                Text(
                  user.email ??
                      "No email available",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // ACCOUNT INFORMATION
                // ==================================================

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    "Account Information",
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                informationCard(
                  icon: Icons.phone_outlined,
                  title: "Mobile Number",
                  value: "+91 1234567890",
                ),

                informationCard(
                  icon: Icons.email_outlined,
                  title: "Email",
                  value: user.email ??
                      "No email available",
                ),

                // ==================================================
                // CHANGE PASSWORD
                // ==================================================

                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),
                  decoration:
                      neumorphicDecoration(
                    radius: 18,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration:
                              neumorphicDecoration(
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

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Change Password",
                                style: TextStyle(
                                  color: kWhite,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Update your account password",
                                style: TextStyle(
                                  color: kTextGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ElevatedButton.icon(
                          onPressed:
                              changePassword,
                          icon: const Icon(
                            Icons.password_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            "Change",
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                kWhite,
                            foregroundColor:
                                kBackground,
                            elevation: 0,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // SETTINGS BUTTON
                // ==================================================

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),
                    decoration:
                        neumorphicDecoration(
                      radius: 18,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration:
                                neumorphicDecoration(
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

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: kWhite,
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Manage your account settings",
                                  style: TextStyle(
                                    color: kTextGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            color: kTextGrey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // ==================================================
                // PAYMENT STATISTICS
                // ==================================================

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    "Payment Statistics",
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                statCard(
                  icon:
                      Icons.receipt_long_outlined,
                  title: "Total Transactions",
                  value:
                      "${transactions.length} transactions",
                ),

                statCard(
                  icon:
                      Icons.currency_rupee,
                  title: "Total Amount",
                  value:
                      "₹${totalAmount.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 18),

                // ==================================================
                // LOGOUT
                // ==================================================

                SizedBox(
                  width: 230,
                  height: 56,
                  child:
                      ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth
                          .instance
                          .signOut();
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 21,
                    ),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: kWhite,
                      foregroundColor:
                          kBackground,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "ECpay • Secure Payments",
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

