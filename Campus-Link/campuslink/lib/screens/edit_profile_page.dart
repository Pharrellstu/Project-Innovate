import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:campuslink/services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _bioController = TextEditingController();

  File? _newImageFile;
  String? _currentImageUrl;
  int? _accountId;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final account = await ProfileService.getProfileByUserId(user.id);
    if (account == null) return;

    setState(() {
      _accountId = account['accountid'];
      _nameController.text = account['username'] ?? '';
      _nationalityController.text = account['nationality'] ?? '';
      _bioController.text = account['bio'] ?? '';
      _currentImageUrl = account['profilepictureurl'];
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_accountId == null) return;

    String? uploadedUrl = _currentImageUrl;

    if (_newImageFile != null) {
      uploadedUrl = await ProfileService.uploadProfileImage(_newImageFile!);
    }

    final updates = {
      'username': _nameController.text,
      'nationality': _nationalityController.text,
      'bio': _bioController.text,
      'profilepictureurl': uploadedUrl,
    };

    final success = await ProfileService.updateProfile(_accountId!, updates);

    if (success && mounted) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'nationality': _nationalityController.text,
        'bio': _bioController.text,
        'profilePictureUrl': uploadedUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: TopBar(title: 'Edit Profile'),
      ),
      bottomNavigationBar: const NavBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          backgroundImage: _newImageFile != null
                              ? FileImage(_newImageFile!)
                              : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                  ? NetworkImage(_currentImageUrl!)
                                  : const AssetImage('resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp'))
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
                  _buildField(label: 'Name', controller: _nameController),
                  const SizedBox(height: 16),
                  _buildField(label: 'Nationality', controller: _nationalityController),
                  const SizedBox(height: 16),
                  _buildField(label: 'Bio', controller: _bioController, maxLines: 4),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Save Changes'),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildField({
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
              fontWeight: FontWeight.bold,
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
