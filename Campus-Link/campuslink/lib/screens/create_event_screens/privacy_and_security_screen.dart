import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../create_event_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  List<UserObject> _selectedUsers = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _maxAttendeesController = TextEditingController(
        text: widget.eventData.maxAttendees?.toString()
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged(true);
    });

    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _allUsers = users;
        // Initialize selected users from eventData
        _selectedUsers = _allUsers.where((user) =>
            widget.eventData.invitedUserIds.contains(user.accountId.toString())
        ).toList();
      });
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() => _loadingUsers = false);
    }
  }

  Future<void> _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.eventData.signUpDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() {
        widget.eventData.signUpDeadline = picked;
      });
    }
  }

  void _showUserSelectionDialog() async {
    final result = await showDialog<List<UserObject>>(
      context: context,
      builder: (_) => UserSelectionDialog(
        allUsers: _allUsers,
        selectedUsers: _selectedUsers,       // ← pass the “live” list
      ),
    );

    if (result != null) {
      setState(() {
        _selectedUsers = result;            // ← update what your UI shows
        // ALSO sync into your eventData so when you persist the form it's correct:
        widget.eventData.invitedUsers = result;
        widget.eventData.invitedUserIds = result
            .map((u) => u.accountId.toString())
            .toList();
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedFile != null) {
      setState(() {
        widget.eventData.eventImageFile = File(pickedFile.path);
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
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Public/Private toggle
                  Text(
                    'Is it a Public or a Private Event?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Segmented control for Public / Private
                  Center(
                    child: ToggleButtons(
                      isSelected: [widget.eventData.isPublic, !widget.eventData.isPublic],
                      onPressed: (index) {
                        setState(() {
                          widget.eventData.isPublic = (index == 0);
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).primaryColor,
                      color: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).primaryColor,
                      selectedBorderColor: Theme.of(context).primaryColor,
                      constraints: BoxConstraints(
                        minHeight: 22,
                        minWidth: 60,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            'Public',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            'Private',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Max attendees input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: Text(
                          'Max attendees (optional)',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxAttendeesController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            prefixIcon: Icon(Icons.person, size: 18),
                            hintText: 'e.g. 10',
                            hintStyle: TextStyle(fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              widget.eventData.maxAttendees = parsed;
                            } else {
                              widget.eventData.maxAttendees = null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign-up deadline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: Text(
                          'Sign-up Deadline (optional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _pickDeadline,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              prefixIcon: Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              widget.eventData.signUpDeadline != null
                                  ? DateFormat.yMMMMd().format(widget.eventData.signUpDeadline!)
                                  : 'Select date',
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.eventData.signUpDeadline == null
                                    ? Colors.grey.shade500
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Badge offer switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offer Badge/Collectible?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: widget.eventData.offerBadge,
                        onChanged: (v) {
                          setState(() {
                            widget.eventData.offerBadge = v;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Invite section header
                  Row(
                    children: [
                      Text(
                        'Invite people',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_selectedUsers.isNotEmpty)
                        Text(
                          '(${_selectedUsers.length} selected)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Invited users list
                  SizedBox(
                    height: 70,
                    child: _loadingUsers
                        ? Center(child: CircularProgressIndicator())
                        : _buildInvitedUsersList(),
                  ),
                  _buildImageSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Event Image (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16/9, // Maintain aspect ratio (16:9 is common for event images)
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias, // Ensure image doesn't overflow
              child: widget.eventData.eventImageFile != null
                  ? Stack(
                children: [
                  // Image with center crop
                  Center(
                    child: Image.file(
                      widget.eventData.eventImageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Semi-transparent overlay for better text visibility
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey.shade500),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to add an image',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.eventData.eventImageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  widget.eventData.eventImageFile = null;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete,
                      size: 20,
                      color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                      'Remove image',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInvitedUsersList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _selectedUsers.length + 1,
      itemBuilder: (context, index) {
        // index 0: add button
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _showUserSelectionDialog,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.grey),
              ),
            ),
          );
        }

        // avatar slots start at index 1 → map to _selectedUsers[index-1]
        final user = _selectedUsers[index - 1];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: _showUserSelectionDialog,
            child: Tooltip(
              message: user.username,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        user.username!.isNotEmpty
                            ? user.username![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    Positioned(
                          top: 30,
                          right: 0,
                          child: Container(
                            width: 25,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close, size: 12, color: Colors.white),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _selectedUsers.removeAt(index);
                                  widget.eventData.invitedUserIds
                                      .remove(user.accountId.toString());
                                });
                              },
                            ),
                          ),
                        ),
                  ]
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UserSelectionDialog extends StatefulWidget {
  final List<UserObject> allUsers;
  final List<UserObject> selectedUsers;

  const UserSelectionDialog({
    Key? key,
    required this.allUsers,
    required this.selectedUsers,
  }) : super(key: key);

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  late List<UserObject> _tempSelected;
  late List<UserObject> _displayedUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedUsers);
    _displayedUsers = List.from(widget.allUsers);

    // Add listener to search controller
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedUsers = List.from(widget.allUsers);
      } else {
        _displayedUsers = widget.allUsers.where((user) {
          return (user.username?.toLowerCase().contains(query) ?? false) ||
              (user.email?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('Select Users'),
          const Spacer(),
          Text(
            '${_tempSelected.length} selected',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterUsers();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),

            // User list
            Flexible(
              child: _displayedUsers.isEmpty
                  ? const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _displayedUsers.length,
                itemBuilder: (context, index) {
                  final user = _displayedUsers[index];
                  final isSelected = _tempSelected.any(
                          (u) => u.accountId == user.accountId);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _tempSelected.add(user);
                        } else {
                          _tempSelected.removeWhere(
                                  (u) => u.accountId == user.accountId);
                        }
                      });
                    },
                    title: Text(user.username ?? 'Unknown'),
                    subtitle: Text(user.email ?? 'No email'),
                    secondary: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        user.username?.isNotEmpty == true
                            ? user.username![0].toUpperCase()
                            : '?',
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}