import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class eventFormPage extends StatefulWidget {
  const eventFormPage({super.key});
  
  @override
  State<eventFormPage> createState() => _eventFormPageState();
}

class _eventFormPageState extends State<eventFormPage> {
  // Track whether the event is Public (true) or Private (false)
  bool _isPublic = true;

  // Controller for the max‐attendees TextField
  late TextEditingController _maxAttendeesController;

  // The chosen sign‐up deadline (nullable if none)
  DateTime? _signUpDeadline;

  // Whether “Offer Badge/Collectible” is ON
  bool _offerBadge = true;

  // A list of “invited” user placeholders; each entry is just a Color/ID for demo
  List<Color> _invitedAvatars = [
    Colors.teal,
    Colors.purple,
    Colors.redAccent,
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the max‐attendees field to “5”
    _maxAttendeesController = TextEditingController(text: null);
  }

  @override
  void dispose() {
    _maxAttendeesController.dispose();
    super.dispose();
  }

  /// Opens a date picker and updates `_signUpDeadline`.
  Future<void> _pickDeadline() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _signUpDeadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && picked != _signUpDeadline) {
      setState(() {
        _signUpDeadline = picked;
      });
    }
  }

  /// Adds a new “invited” placeholder avatar to the list.
  void _addGuest() {
    // For demo we just pick a random color each time.
    final randomColor = Colors.primaries[_invitedAvatars.length % Colors.primaries.length];
    setState(() {
      _invitedAvatars.add(randomColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format the chosen deadline for display
    String deadlineText = _signUpDeadline == null
        ? 'Select date'
        : DateFormat.yMMMMd().format(_signUpDeadline!);

    return Center(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // “Is it a Public or a Private Event?” header
                Text(
                  'Is it a Public or a Private Event?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Segmented control for Public / Private
                Center(
                  child: ToggleButtons(
                    isSelected: [_isPublic, !_isPublic],
                    onPressed: (index) {
                      setState(() {
                        _isPublic = (index == 0);
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    selectedColor: Colors.white,
                    fillColor: Theme.of(context).primaryColor,
                    color: Theme.of(context).primaryColor,
                    borderColor: Theme.of(context).primaryColor,
                    selectedBorderColor: Theme.of(context).primaryColor,
                    constraints: BoxConstraints(
                      minHeight: 22, // Reduce height
                      minWidth: 60,  // Reduce width
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

                // “Max attendees (optional)” label + input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Max attendees (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxAttendeesController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 13), // Smaller text inside input
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          prefixIcon: Icon(Icons.person, size: 18), // Smaller icon
                          hintText: 'e.g. 10',
                          hintStyle: TextStyle(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
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
                            deadlineText,
                            style: TextStyle(
                              fontSize: 13,
                              color: _signUpDeadline == null
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

                // “Offer Badge/Collectible?” switch
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
                      value: _offerBadge,
                      onChanged: (v) {
                        setState(() {
                          _offerBadge = v;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // “Invite people” avatars + add button
                Text(
                  'Invite people',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _invitedAvatars.length + 1,
                    itemBuilder: (context, index) {
                      // Last item is the “+” button
                      if (index == _invitedAvatars.length) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: _addGuest,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey.shade300,
                              child: Icon(
                                Icons.add,
                                size: 32,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        );
                      }
                      // Otherwise, show a placeholder avatar
                      Color bgColor = _invitedAvatars[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: bgColor,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // “Overview →” button
                ElevatedButton(
                  onPressed: () {
                    // For demo, just show a simple dialog of current values:
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Current Form Values'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Event Type: ${_isPublic ? "Public" : "Private"}'),
                            Text(
                                'Max Attendees: ${_maxAttendeesController.text}'),
                            Text(
                                'Deadline: ${_signUpDeadline == null ? "None" : null}'),
                            Text('Offer Badge: ${_offerBadge ? "Yes" : "No"}'),
                            Text(
                                'Invited Count: ${_invitedAvatars.length}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          )
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Overview  →',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
