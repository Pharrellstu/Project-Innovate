import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import '../create_event_page.dart';

class eventFormPage extends StatefulWidget {
  final EventData eventData;
  final Function(bool) onValidityChanged;

  const eventFormPage({
    Key? key,
    required this.eventData,
    required this.onValidityChanged,
  }) : super(key: key);

  @override
  State<eventFormPage> createState() => _eventFormPageState();
}

class _eventFormPageState extends State<eventFormPage> {
  late TextEditingController _maxAttendeesController;
  final UserService _userService = UserService();
  List<UserObject> _allUsers = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _maxAttendeesController =
        TextEditingController(text: widget.eventData.maxAttendees?.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged(true);
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final users = await _userService.getAllUsers();
      final currentUserId = AuthGate.getCurrentUserId();
      if (mounted) {
        setState(() {
          _allUsers = users
              .where((user) => user.authUserId != currentUserId)
              .toList();
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null && mounted) {
      setState(() => widget.eventData.eventImageFile = File(pickedFile.path));
    }
  }

  void _showUserSelectionDialog() async {
    final result = await showDialog<List<UserObject>>(
      context: context,
      builder: (_) => UserSelectionDialog(
        allUsers: _allUsers,
        initiallySelectedUsers: widget.eventData.invitedUsers,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.eventData.invitedUsers = result;
        widget.eventData.invitedUserIds =
            result.map((u) => u.accountId.toString()).toList();
      });
    }
  }

  @override
  void dispose() {
    _maxAttendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Event Privacy'),
          _buildPublicPrivateToggle(),
          const SizedBox(height: 24),
          _buildSectionTitle('Event Details'),
          _buildDetailsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Invite People'),
          _buildInviteSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Event Image (Optional)'),
          _buildImagePicker(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildPublicPrivateToggle() {
    return Center(
      child: ToggleButtons(
        isSelected: [widget.eventData.isPublic, !widget.eventData.isPublic],
        onPressed: (index) =>
            setState(() => widget.eventData.isPublic = (index == 0)),
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: Theme.of(context).primaryColor,
        color: Theme.of(context).primaryColor,
        constraints:
        const BoxConstraints(minHeight: 40, minWidth: 100),
        children: const [
          Text('Public', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Private', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Max Attendees'),
              subtitle: const Text('Leave blank for no limit'),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: _maxAttendeesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: 'e.g. 50'),
                  onChanged: (v) =>
                  widget.eventData.maxAttendees = int.tryParse(v),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Offer Badge'),
              subtitle: const Text('Reward attendees with a badge'),
              trailing: Switch(
                value: widget.eventData.offerBadge,
                onChanged: (v) => setState(() => widget.eventData.offerBadge = v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteSection() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: InkWell(
        onTap: _showUserSelectionDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.person_add_alt_1_rounded, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.eventData.invitedUsers.isEmpty
                      ? 'Select users to invite'
                      : '${widget.eventData.invitedUsers.length} users invited',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.eventData.eventImageFile != null
              ? Image.file(widget.eventData.eventImageFile!, fit: BoxFit.cover)
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    size: 40, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                const Text('Add an event image'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// User Selection Dialog
class UserSelectionDialog extends StatefulWidget {
  final List<UserObject> allUsers;
  final List<UserObject> initiallySelectedUsers;

  const UserSelectionDialog({
    Key? key,
    required this.allUsers,
    required this.initiallySelectedUsers,
  }) : super(key: key);

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  late List<UserObject> _tempSelected;
  late List<UserObject> _displayedUsers;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.initiallySelectedUsers);
    _displayedUsers = List.from(widget.allUsers);
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedUsers = widget.allUsers
          .where((user) =>
      user.username?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  Widget _buildProfileAvatar(UserObject user) {
    // Avatar size for the dialog
    const double avatarSize = 25;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Add gradient border for verified users
        if (user.isVerified == true)
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: avatarSize,
                backgroundImage: user.profilePictureUrl != null &&
                    user.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(user.profilePictureUrl!)
                    : null,
                child: user.profilePictureUrl == null ||
                    user.profilePictureUrl!.isEmpty
                    ? const Icon(Icons.person, size: avatarSize)
                    : null,
              ),
            ),
          )
        else
          CircleAvatar(
            radius: avatarSize,
            backgroundImage: user.profilePictureUrl != null &&
                user.profilePictureUrl!.isNotEmpty
                ? NetworkImage(user.profilePictureUrl!)
                : null,
            child: user.profilePictureUrl == null ||
                user.profilePictureUrl!.isEmpty
                ? const Icon(Icons.person, size: avatarSize)
                : null,
          ),

        // Add verification badge for verified users
        if (user.isVerified == true)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Users to Invite'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _displayedUsers.length,
                itemBuilder: (context, index) {
                  final user = _displayedUsers[index];
                  final isSelected =
                  _tempSelected.any((u) => u.accountId == user.accountId);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected!) {
                          _tempSelected.add(user);
                        } else {
                          _tempSelected.removeWhere(
                                  (u) => u.accountId == user.accountId);
                        }
                      });
                    },
                    title: Text(user.username ?? 'Unknown'),
                    secondary: _buildProfileAvatar(user),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, _tempSelected),
            child: const Text('Confirm')),
      ],
    );
  }
}