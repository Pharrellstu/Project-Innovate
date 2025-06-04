import 'package:flutter/material.dart';

import '../create_event_page.dart';

class basicInputInfo extends StatefulWidget {
  final Function(bool) onValidityChanged;
  final EventData eventData;

  const basicInputInfo({Key? key, required this.onValidityChanged, required this.eventData}) : super(key: key);

  @override
  State<basicInputInfo> createState() => _basicInputInfoState();
}

class _basicInputInfoState extends State<basicInputInfo> {

  late TextEditingController _eventNameController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  bool _isOnline = false;
  String? _selectedCategory;
  int _descriptionCharCount = 0;

  // Define a list of categories with labels and icons
  final List<_Category> _categories = [
    _Category(label: 'Drinks', icon: Icons.local_bar),
    _Category(label: 'Party', icon: Icons.celebration),
    _Category(label: 'Sports', icon: Icons.sports_soccer),
    _Category(label: 'Gaming', icon: Icons.videogame_asset),
    _Category(label: 'Food', icon: Icons.fastfood),
    _Category(label: 'Other', icon: Icons.more_horiz),
  ];

  @override
  void initState() {
    super.initState();

    _eventNameController = TextEditingController(text: widget.eventData.eventName);
    _descriptionController = TextEditingController(text: widget.eventData.description);
    // Listen to description changes to update character count
    _descriptionController.addListener(() {
      setState(() {
        _descriptionCharCount = _descriptionController.text.length;
      });
    });

    _eventNameController.addListener(() {
      setState(() {
        widget.eventData.eventName = _eventNameController.text; // Update eventData
        _checkValidity();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkValidity();
    });

    //_eventNameController.addListener(_checkValidity);
  }

  void _checkValidity() {
    final isValid = widget.eventData.eventName.isNotEmpty && widget.eventData.category != null;
    widget.onValidityChanged(isValid);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isNextEnabled {
    return _eventNameController.text.trim().isNotEmpty && _selectedCategory != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Event name",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18)
              ),
          SizedBox(height: 8),
          TextField(
            controller: _eventNameController,
            decoration: InputDecoration(
              hintText: 'e.g. Jane’s Birthday Bash', // Grey hint text
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Color(0xFBBBBBB), // Light background color
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade700, // When focused
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade500, // Default border
                  width: 1,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            onChanged: (_) {
              setState(() {
                // Trigger rebuild to update Next button state
                _checkValidity();
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            'What is the category of your event? (Choose one)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: _categories.map((cat) {
              final bool isSelected = widget.eventData.category == cat.label;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.eventData.category = cat.label;
                  });
                  _checkValidity();
                },
                child: Semantics(
                  button: true,
                  label: 'Category: ${cat.label}',
                  selected: isSelected,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF0066CC) : Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Color(0xFF0066CC), width: 2)
                          : Border.all(color: Colors.transparent),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Color(0xFF0066CC).withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat.icon,
                          size: 36,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 15),
          Text(
            'Event description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          TextField(
            controller: _descriptionController,
            onChanged: (value) => widget.eventData.description = value,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Tell guests what to expect, any special notes, etc.',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Color(0xFBBBBBB),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade500,
                  width: 1,
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_descriptionCharCount}/300',
              style: TextStyle(
                fontSize: 12,
                // color: _descriptionCharCount > 300 ? Colors.red : Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Is this an online event?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Semantics(
                container: true,
                label: 'Is this an online event? Switch',
                child: Switch(
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade400,
                  value: widget.eventData.isOnline,
                  onChanged: (val) {
                    setState(() {
                      widget.eventData.isOnline = val;
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            widget.eventData.isOnline
                ? 'Guests will join via a link.'
                : 'You will add a location in the next step.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryTile(String label, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 95,
            height: 95,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Category {
  final String label;
  final IconData icon;

  _Category({
    required this.label,
    required this.icon,
  });
}