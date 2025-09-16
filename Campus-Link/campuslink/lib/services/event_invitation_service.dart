import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/eventinvitation.dart';

class EventInvitationService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'eventinvitation';

  Future<void> createInvitations(List<EventInvitationModel> invitations) async {
    try {
      final invitationMaps = invitations.map((inv) => inv.toMap()).toList();
      await _supabase.from('eventinvitation').insert(invitationMaps);
    } catch (e) {
      print('Error creating invitations: $e');
      final postgrestError = e as PostgrestException?;
      print('''
        Error creating invitations: 
        Code: ${postgrestError?.code}
        Message: ${postgrestError?.message}
        Details: ${postgrestError?.details}
        Hint: ${postgrestError?.hint}
      ''');
      rethrow;
    }
  }

  Future<List<EventInvitationModel>> fetchInvitationsForUser(int accountId) async {
    try {
      final rows = await _supabase
          .from(_table)
          .select()
          .eq('receiveraccount_id', accountId);

      return (rows as List)
          .map((r) => EventInvitationModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching invitations: $e');
      rethrow;
    }
  }

  Future<void> updateInvitationStatus(int invitationId, String status) async {
    try {
      await _supabase
          .from(_table)
          .update({'status': status})
          .eq('eventinvitation_id', invitationId);
    } catch (e) {
      print('Error updating invitation status: $e');
      rethrow;
    }
  }

  /// Fetch all invitations
  static Future<List<EventInvitationModel>> fetchAll() async {
    final rows = await _supabase.from(_table).select();
    return (rows as List)
        .map((r) => EventInvitationModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch one by its PK
  static Future<EventInvitationModel?> fetchById(int id) async {
    final resp = await _supabase
        .from(_table)
        .select()
        .eq('eventinvitation_id', id)
        .maybeSingle();
    if (resp == null) return null;
    return EventInvitationModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Update existing invitation
  static Future<bool> update(EventInvitationModel model) async {
    final rows = await _supabase
        .from(_table)
        .update(model.toMap())
        .eq('eventinvitation_id', model.eventInvitationId)
        .select();
    return (rows as List).isNotEmpty;
  }

  /// Delete invitation
  static Future<bool> delete(int id) async {
    final rows = await _supabase
        .from(_table)
        .delete()
        .eq('eventinvitation_id', id)
        .select();
    return (rows as List).isNotEmpty;
  }

  static Future<void> acceptInvitationByEventAndReceiver(
      int eventId,
      int receiverAccountId
      ) async {
    try {
      await _supabase
          .from(_table)
          .update({'status': 'accepted'})
          .eq('event_id', eventId)
          .eq('receiveraccount_id', receiverAccountId)
          .eq('status', 'pending');
    } catch (e) {
      print('Error accepting invitation: $e');
      rethrow;
    }
  }
}
