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
  final _bioController = TextEditingController();
  String? _selectedNationality;
  final _ageController = TextEditingController();

  final List<String> _nationalities = [
    'Afghan', 'Albanian', 'Algerian', 'American', 'Andorran', 'Angolan', 'Argentine', 'Armenian', 'Australian', 'Austrian',
    'Azerbaijani', 'Bahamian', 'Bahraini', 'Bangladeshi', 'Barbadian', 'Belarusian', 'Belgian', 'Belizean', 'Beninese', 'Bhutanese',
    'Bolivian', 'Bosnian', 'Botswanan', 'Brazilian', 'British', 'Bruneian', 'Bulgarian', 'Burkinabe', 'Burmese', 'Burundian',
    'Cambodian', 'Cameroonian', 'Canadian', 'Cape Verdean', 'Central African', 'Chadian', 'Chilean', 'Chinese', 'Colombian',
    'Comoran', 'Congolese (Congo-Brazzaville)', 'Congolese (Congo-Kinshasa)', 'Costa Rican', 'Croatian', 'Cuban', 'Cypriot', 'Czech',
    'Danish', 'Djiboutian', 'Dominican', 'Dutch', 'East Timorese', 'Ecuadorean', 'Egyptian', 'Emirati', 'Equatorial Guinean',
    'Eritrean', 'Estonian', 'Ethiopian', 'Fijian', 'Filipino', 'Finnish', 'French', 'Gabonese', 'Gambian', 'Georgian',
    'German', 'Ghanaian', 'Greek', 'Grenadian', 'Guatemalan', 'Guinean', 'Guinean-Bissauan', 'Guyanese', 'Haitian', 'Honduran',
    'Hungarian', 'Icelander', 'Indian', 'Indonesian', 'Iranian', 'Iraqi', 'Irish', 'Israeli', 'Italian', 'Ivorian',
    'Jamaican', 'Japanese', 'Jordanian', 'Kazakhstani', 'Kenyan', 'Kiribatian', 'Kuwaiti', 'Kyrgyz', 'Laotian', 'Latvian',
    'Lebanese', 'Liberian', 'Libyan', 'Liechtensteiner', 'Lithuanian', 'Luxembourger', 'Macedonian', 'Malagasy', 'Malawian',
    'Malaysian', 'Maldivan', 'Malian', 'Maltese', 'Marshallese', 'Mauritanian', 'Mauritian', 'Mexican', 'Micronesian', 'Moldovan',
    'Monacan', 'Mongolian', 'Montenegrin', 'Moroccan', 'Mosotho', 'Mozambican', 'Namibian', 'Nauruan', 'Nepalese', 'New Zealander',
    'Nicaraguan', 'Nigerian', 'Nigerien', 'North Korean', 'Norwegian', 'Omani', 'Pakistani', 'Palauan', 'Panamanian',
    'Papua New Guinean', 'Paraguayan', 'Peruvian', 'Polish', 'Portuguese', 'Qatari', 'Romanian', 'Russian', 'Rwandan',
    'Saint Lucian', 'Salvadoran', 'Samoan', 'San Marinese', 'Sao Tomean', 'Saudi', 'Senegalese', 'Serbian', 'Seychellois',
    'Sierra Leonean', 'Singaporean', 'Slovakian', 'Slovenian', 'Solomon Islander', 'Somali', 'South African', 'South Korean',
    'South Sudanese', 'Spanish', 'Sri Lankan', 'Sudanese', 'Surinamer', 'Swazi', 'Swedish', 'Swiss', 'Syrian',
    'Taiwanese', 'Tajik', 'Tanzanian', 'Thai', 'Togolese', 'Tongan', 'Trinidadian or Tobagonian', 'Tunisian', 'Turkish',
    'Turkmen', 'Tuvaluan', 'Ugandan', 'Ukrainian', 'Uruguayan', 'Uzbekistani', 'Venezuelan', 'Vietnamese', 'Yemenite',
    'Zambian', 'Zimbabwean'
  ];
  
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
        _bioController.text = profileData.bio; 
        _currentImageUrl = profileData.profilePictureUrl;
        _selectedNationality = profileData.nationality;
        if (_selectedNationality != null && !_nationalities.contains(_selectedNationality)) {
          _nationalities.add(_selectedNationality!);
          _nationalities.sort();
        }
        _ageController.text = profileData.age?.toString() ?? '';
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
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
      bio: _bioController.text, 
      profilePictureUrl: (_newImageFile != null) ? uploadedImageUrl : null, 
      nationality: _selectedNationality,
      age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
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
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 3, // maxLine for bio
                  ),
                  const SizedBox(height: 24),
                  _buildNationalityDropdown(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
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
    TextInputType? keyboardType, // Added keyboardType
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
          keyboardType: keyboardType,
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

  Widget _buildNationalityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nationality',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
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
          value: _selectedNationality,
          hint: const Text('Select Nationality'),
          isExpanded: true,
          items: _nationalities.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedNationality = newValue;
            });
          },
        ),
      ],
    );
  }
}