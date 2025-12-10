import '../services/green_note_api_client.dart';
import '../models/green_note_model.dart';

class GreenNoteRepository {
  final GreenNoteApiClient _apiClient = GreenNoteApiClient();

  // Create green note
  Future<GreenNote> createGreenNote(GreenNote note) async {
    try {
      final response = await _apiClient.post(
        '/green-notes',
        data: note.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GreenNote.fromJson(response.data);
      } else {
        throw Exception('Failed to create green note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating green note: ${e.toString()}');
    }
  }

  // Get green note by ID
  Future<GreenNote> getGreenNote(String noteId) async {
    try {
      final response = await _apiClient.get('/green-notes/$noteId');

      if (response.statusCode == 200) {
        return GreenNote.fromJson(response.data);
      } else {
        throw Exception('Failed to get green note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching green note: ${e.toString()}');
    }
  }

  // Update green note
  Future<GreenNote> updateGreenNote(String noteId, GreenNote note) async {
    try {
      final response = await _apiClient.patch(
        '/green-notes/$noteId',
        data: note.toJson(),
      );

      if (response.statusCode == 200) {
        return GreenNote.fromJson(response.data);
      } else {
        throw Exception('Failed to update green note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating green note: ${e.toString()}');
    }
  }

  // Cancel green note
  Future<void> cancelGreenNote(String noteId, {String? cancelReason}) async {
    try {
      final response = await _apiClient.post(
        '/green-notes/$noteId/cancel',
        data: {
          'cancel_reason': cancelReason ?? 'Cancelled by user',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel green note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error cancelling green note: ${e.toString()}');
    }
  }

  // List green notes
  Future<List<GreenNote>> listGreenNotes({
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search_query'] = searchQuery;
      }

      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['status_filter'] = statusFilter;
      }

      final response = await _apiClient.get(
        '/green-notes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both array response and object with notes array
        List<dynamic> notesList;
        if (data is List) {
          notesList = data;
        } else if (data is Map && data.containsKey('notes')) {
          notesList = data['notes'] as List;
        } else if (data is Map && data.containsKey('data')) {
          notesList = data['data'] as List;
        } else {
          notesList = [];
        }
        
        return notesList.map((note) => GreenNote.fromJson(note)).toList();
      } else {
        throw Exception('Failed to list green notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing green notes: ${e.toString()}');
    }
  }
}
