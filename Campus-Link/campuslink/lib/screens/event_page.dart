import 'package:campuslink/models/comment.dart';
import 'package:campuslink/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/eventenrollment_service.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:intl/intl.dart';

import '../models/eventenrollment.dart';
import '../models/user.dart';
import '../services/comment_service.dart';
import '../services/event_invitation_service.dart';

class EventPage extends StatefulWidget {
  final int eventId;

  const EventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool _isEnrolled = false;
  bool _isLoading = true;
  EventModel? event;
  int? _currentUserAccountId;
  final ScrollController _locationController = ScrollController();
  final ScrollController _creatorController = ScrollController();
  UserObject? _creator;
  final TextEditingController _commentController = TextEditingController();
  late Future<List<CommentModel>> _commentsFuture;

  // Add this helper method in _EventPageState
  bool get _isCreator {
    final currentUserId = AuthGate.getCurrentUserId();
    return currentUserId != null &&
        event != null &&
        event!.eventCreatorUUID == currentUserId;
  }

  @override
  void initState() {
    super.initState();
    _fetchEvent();
    _getCurrentUserAccountId();
    _commentsFuture = CommentService.getCommentsForEvent(widget.eventId);

    // Start auto-scrolling for location and creator name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(_locationController);
      _startAutoScroll(_creatorController);
    });
  }

  void _startAutoScroll(ScrollController controller) {
    if (controller.hasClients) {
      // Only scroll if content overflows
      if (controller.position.maxScrollExtent > 0) {
        Future.delayed(const Duration(seconds: 2), () {
          controller
              .animateTo(
                controller.position.maxScrollExtent,
                duration: Duration(
                  seconds: controller.position.maxScrollExtent ~/ 20,
                ),
                curve: Curves.linear,
              )
              .then((_) {
                Future.delayed(const Duration(seconds: 1), () {
                  controller
                      .animateTo(
                        0,
                        duration: Duration(
                          seconds: controller.position.maxScrollExtent ~/ 20,
                        ),
                        curve: Curves.linear,
                      )
                      .then((_) => _startAutoScroll(controller));
                });
              });
        });
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _creatorController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvent() async {
    try {
      final eventData = await EventService.getEventById(widget.eventId);
      if (eventData != null) {
        UserObject? creator;
        // Fetch creator information
        if (eventData.eventCreatorUUID != null) {
          creator = await UserService().getUserByAuthUserId(
            eventData.eventCreatorUUID!,
          );
        }

        setState(() {
          event = eventData;
          _creator = creator; // Set creator here
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching event: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentUserAccountId() async {
    final userId = AuthGate.getCurrentUserId();
    if (userId != null) {
      final accountId = await UserService().getAccountIdByAuthUserId(userId);
      if (accountId != null) {
        setState(() => _currentUserAccountId = accountId);
        _checkEnrollmentStatus(accountId);
      }
    }
  }

  Future<void> _checkEnrollmentStatus(int accountId) async {
    final isEnrolled = await EventEnrollmentService.isUserEnrolled(
      widget.eventId,
      accountId,
    );
    setState(() => _isEnrolled = isEnrolled);
  }

  Future<void> _enrollInEvent() async {
    if (_currentUserAccountId == null) return;

    try {
      await EventEnrollmentService.enrollToEvent(
        widget.eventId,
        _currentUserAccountId!,
      );

      // Add this block to update invitation status
      try {
        await EventInvitationService.acceptInvitationByEventAndReceiver(
          widget.eventId,
          _currentUserAccountId!,
        );
      } catch (e) {
        print("No invitation found to update: $e");
      }

      setState(() => _isEnrolled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the event!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join: ${e.toString()}')),
      );
    }
  }

  Future<void> _unEnrollInEvent() async {
    if (_currentUserAccountId == null) return;

    try {
      await EventEnrollmentService.unEnrollToEvent(
        widget.eventId,
        _currentUserAccountId!,
      );
      setState(() => _isEnrolled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully left the event')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave: ${e.toString()}')),
      );
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty || _currentUserAccountId == null)
      return;

    try {
      await CommentService.postComment(
        widget.eventId,
        _currentUserAccountId!,
        _commentController.text,
      );
      _commentController.clear();
      // Refresh comments
      setState(() {
        _commentsFuture = CommentService.getCommentsForEvent(widget.eventId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await CommentService.deleteComment(commentId);
      // Refresh comments
      setState(() {
        _commentsFuture = CommentService.getCommentsForEvent(widget.eventId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: ${e.toString()}')),
      );
    }
  }

  Future<void> _editEvent() async {
    // Navigate to edit screen with event data
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventPage(),
      ),
    );*/
  }

  Future<void> _deleteEvent() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Event?'),
            content: const Text('This action cannot be undone'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await EventService.deleteEvent(event!.eventId);
                    Navigator.pop(context); // Close event page after deletion
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deletion failed: ${e.toString()}'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Event not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Post'),
        actions: [
          if (_isCreator)
            IconButton(icon: const Icon(Icons.edit), onPressed: _editEvent),
          if (_isCreator)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteEvent),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator info
            _buildCreatorInfo(),
            const SizedBox(height: 8),
            const Text(
              'New event',
              style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 12),
            ),
            const SizedBox(height: 8),

            // Event Card
            _buildEventCard(),
            const SizedBox(height: 16),

            // Metadata
            _buildMetadataGrid(),
            const SizedBox(height: 24),

            // Attendance
            _buildAttendanceSection(),
            const SizedBox(height: 24),

            // Comment Input
            if (_currentUserAccountId != null) _buildCommentInput(),
            const SizedBox(height: 20),

            // Comments List
            _buildCommentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorInfo() {
    return InkWell(
      onTap: () {
        if (_creator != null && _creator!.accountId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => UserProfilePage(
                    userId: _creator!.accountId!,
                    currentUserAccountId: _currentUserAccountId ?? 0,
                  ),
            ),
          );
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage:
                _creator?.profilePictureUrl != null
                    ? NetworkImage(_creator!.profilePictureUrl!)
                        as ImageProvider
                    : const AssetImage(
                      'resources/icons/profile_placeholder.png',
                    ),
          ),
          const SizedBox(width: 8),
          Text(
            _creator?.username ?? 'Unknown Creator',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const Spacer(),
          Text(
            'See profile',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x190074CE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Overlay
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child:
                    event?.eventImageUrl != null &&
                            event!.eventImageUrl!.isNotEmpty
                        ? Image.network(
                          event!.eventImageUrl!,
                          height: 230,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildImagePlaceholder(height: 230),
                        )
                        : _buildImagePlaceholder(height: 230),
              ),
              Container(
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${DateFormat('dd MMMM').format(event!.eventDate!)} | ${DateFormat('HH:mm').format(event!.eventDate!)}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event!.eventName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event!.locationName ?? 'Online Event',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              event!.description,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 4,
      children: [
        _buildMetadataItem(Icons.category, event?.category ?? 'No Category'),
        _buildMetadataItem(
          Icons.person_outline,
          _creator?.username ?? 'Unknown',
        ),
        _buildMetadataItem(
          Icons.calendar_today,
          DateFormat('dd/MM/yyyy').format(event!.eventDate!),
        ),
        _buildMetadataItem(
          Icons.pin_drop_outlined,
          event?.locationName ?? 'Online',
        ),
      ],
    );
  }

  Widget _buildAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendance :',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<EventEnrollmentModel>>(
          future: EventEnrollmentService.getEnrollmentsForEvent(widget.eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final enrollments = snapshot.data ?? [];
            if (enrollments.isEmpty) {
              return const Text('No attendees yet.');
            }
            return SizedBox(
              height: 90, // Increased height to accommodate text
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: enrollments.length,
                itemBuilder: (context, index) {
                  final accountId = enrollments[index].accountId;
                  if (accountId == null) return const SizedBox.shrink();
                  return FutureBuilder<UserObject?>(
                    future: UserService().getUserByAccountId(accountId),
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data;
                      return Padding(
                        padding: const EdgeInsets.only(right: 14.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage:
                                  user?.profilePictureUrl != null
                                      ? NetworkImage(user!.profilePictureUrl!)
                                          as ImageProvider
                                      : const AssetImage(
                                        'resources/icons/profile_placeholder.png',
                                      ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 64,
                              child: Text(
                                user?.username ?? 'Loading...',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0091FF)),
      ),
      child: TextField(
        controller: _commentController,
        decoration: InputDecoration(
          hintText: 'New comment...',
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF0091FF)),
            onPressed: _postComment,
          ),
        ),
        onSubmitted: (value) => _postComment(),
      ),
    );
  }

  Widget _buildCommentsList() {
    return FutureBuilder<List<CommentModel>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final comments = snapshot.data ?? [];
        if (comments.isEmpty) {
          return const Center(child: Text('No comments yet.'));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentItem(comment);
          },
        );
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    final bool canDelete =
        _currentUserAccountId == comment.accountId || _isCreator;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage:
              comment.user?.profilePictureUrl != null
                  ? NetworkImage(comment.user!.profilePictureUrl!)
                      as ImageProvider
                  : const AssetImage('resources/icons/profile_placeholder.png'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.user?.username ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (comment.user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UserProfilePage(
                                  userId: comment.user!.accountId!,
                                  currentUserAccountId:
                                      _currentUserAccountId ?? 0,
                                ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'See profile',
                      style: TextStyle(color: Color(0xFF0074CE), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.commentText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
            onPressed: () => _deleteComment(comment.commentId),
          ),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 21, color: Colors.black),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder({double? height}) {
    return Container(
      height: height ?? 200,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.event, size: 60, color: Colors.grey),
      ),
    );
  }
}
