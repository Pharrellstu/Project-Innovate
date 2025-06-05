import 'dart:io';
import 'package:campuslink/services/user.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campuslink/services/db_handler.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late UserObject currentUser;
  late TextEditingController nameController;
  late TextEditingController bioController;
  File? selectedImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeUser();
  }

  Future<void> initializeUser() async {
    final user = await DbHandler.getCurrentUser();
    setState(() {
      currentUser = user;
      nameController = TextEditingController(text: currentUser.username);
      bioController = TextEditingController(text: currentUser.bio);
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const TopBar(title: "Edit Profile"),
      bottomNavigationBar: const NavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        selectedImage != null
                            ? FileImage(selectedImage!)
                            : const AssetImage('resources/img/pfp.jpg') // TODO: use DB image
                                as ImageProvider,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Change profile picture',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            _buildTextField(label: 'Name', controller: nameController!),
            
            const SizedBox(height: 16),

            const SizedBox(height: 16),

            _buildTextField(
              label: 'Bio',
              controller: bioController!,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FB),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.lightBlue,
            ),
          ),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
