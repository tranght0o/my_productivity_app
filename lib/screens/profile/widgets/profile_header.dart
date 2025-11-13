import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// ProfileHeader shows user's name and avatar, allows editing both
class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final UserService _userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  AppUser? _appUser;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      // Listen realtime changes
      _userService.streamUser(user!.uid).listen((appUser) {
        setState(() => _appUser = appUser);
      });
    }
  }

  // Function to pick image from gallery
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) return pickedFile.path;
    return null;
  }

  // Function to edit name and avatar
  void _editProfile() async {
    if (_appUser == null) return;

    final TextEditingController nameController =
        TextEditingController(text: _appUser!.name);

    String? newPhotoPath;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final path = await _pickImage();
                if (path != null) {
                  newPhotoPath = path;
                }
              },
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _appUser!.photoUrl != null &&
                        _appUser!.photoUrl!.isNotEmpty
                    ? NetworkImage(_appUser!.photoUrl!)
                    : null,
                child: _appUser!.photoUrl == null || _appUser!.photoUrl!.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _loading = true);

              String? photoUrl;
              if (newPhotoPath != null) {
                // TODO: upload newPhotoPath to Firebase Storage and get URL
                photoUrl = newPhotoPath; // placeholder, implement actual upload
              }

              await _userService.updateUser(
                user!.uid,
                name: nameController.text.trim(),
                photoUrl: photoUrl,
              );

              setState(() => _loading = false);
              Navigator.pop(context);
            },
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_appUser == null) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: _appUser!.photoUrl != null &&
                    _appUser!.photoUrl!.isNotEmpty
                ? NetworkImage(_appUser!.photoUrl!)
                : null,
            child: _appUser!.photoUrl == null || _appUser!.photoUrl!.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _appUser!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfile,
          ),
        ],
      ),
    );
  }
}
