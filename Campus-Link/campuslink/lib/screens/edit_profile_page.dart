import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campuslink/services/profile_service.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController(); // Includes nationality
  
  File? _newImageFile;
  String? _currentImageUrl;
  bool _isLoading = true;
  int? _accountId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final profileData = await ProfileService.fetchCurrentLoggedInUserProfile();
    if (profileData != null && mounted) {
      setState(() {
        _accountId = profileData.id;
        _nameController.text = profileData.name;
        _bioController.text = profileData.bio; // Bio now includes nationality
        _currentImageUrl = profileData.profilePictureUrl;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      // Handle error or if profile is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load profile data.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Account ID not found.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? uploadedImageUrl = _currentImageUrl;

    if (_newImageFile != null) {
      // Upload new image if one was picked
      uploadedImageUrl = await ProfileService.uploadProfileImage(_newImageFile!, _accountId!);
      if (uploadedImageUrl == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error uploading new profile picture.')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    final success = await ProfileService.updateProfileData(
      _accountId!,
      name: _nameController.text,
      bio: _bioController.text, // Bio includes nationality
      profilePictureUrl: (_newImageFile != null) ? uploadedImageUrl : null, // Only pass URL if new image was processed
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Pass back the updated data if needed, or just pop
        Navigator.pop(context, true); // Indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(title: 'Edit Profile'),
      ),
      bottomNavigationBar: const NavBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _newImageFile != null
                              ? FileImage(_newImageFile!)
                              : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                  ? NetworkImage(_currentImageUrl!)
                                  : const AssetImage('resources/img/default_profile.png')) // Ensure you have a default asset
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Change Profile Picture',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    label: 'Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Bio (including Nationality)',
                    controller: _bioController,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}