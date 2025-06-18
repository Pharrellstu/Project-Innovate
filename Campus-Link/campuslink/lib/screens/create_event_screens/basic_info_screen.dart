import 'package:flutter/material.dart';
import '../create_event_page.dart';

class basicInputInfo extends StatefulWidget {
  final Function(bool) onValidityChanged;
  final EventData eventData;

  const basicInputInfo(
      {Key? key, required this.onValidityChanged, required this.eventData})
      : super(key: key);

  @override
  State<basicInputInfo> createState() => _basicInputInfoState();
}

class _basicInputInfoState extends State<basicInputInfo> {
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;

  final List<_Category> _categories = [
    _Category(label: 'Drinks', icon: Icons.local_bar_rounded),
    _Category(label: 'Party', icon: Icons.celebration_rounded),
    _Category(label: 'Sports', icon: Icons.sports_soccer_rounded),
    _Category(label: 'Gaming', icon: Icons.videogame_asset_rounded),
    _Category(label: 'Food', icon: Icons.fastfood_rounded),
    _Category(label: 'Other', icon: Icons.more_horiz_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _eventNameController =
        TextEditingController(text: widget.eventData.eventName);
    _descriptionController =
        TextEditingController(text: widget.eventData.description);

    _eventNameController.addListener(() {
      widget.eventData.eventName = _eventNameController.text;
      _checkValidity();
    });
    _descriptionController.addListener(() {
      widget.eventData.description = _descriptionController.text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkValidity());
  }

  void _checkValidity() {
    final isValid =
        widget.eventData.eventName.trim().isNotEmpty && widget.eventData.category != null;
    widget.onValidityChanged(isValid);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('What is the name of your event?'),
          TextField(
            controller: _eventNameController,
            decoration: const InputDecoration(
              hintText: 'e.g. End of Summer Party',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Choose a category'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: _categories.map((cat) {
              final bool isSelected = widget.eventData.category == cat.label;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.eventData.category = cat.label;
                  });
                  _checkValidity();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat.icon,
                        size: 32,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Event description (Optional)'),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tell guests what to expect, any special notes, etc.',
            ),
          ),
          const SizedBox(height: 24),
          _buildOnlineEventToggle(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOnlineEventToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Online Event',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Guests will join via a link',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Switch(
            value: widget.eventData.isOnline,
            onChanged: (val) {
              setState(() {
                widget.eventData.isOnline = val;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;

  _Category({required this.label, required this.icon});
}