import '../repository/green_note_repository.dart';
import '../models/green_note_model.dart';

class GreenNoteService {
  final GreenNoteRepository _repository = GreenNoteRepository();

  // Create green note
  Future<GreenNote> createGreenNote(GreenNote note) async {
    try {
      return await _repository.createGreenNote(note);
    } catch (e) {
      throw Exception('Failed to create green note: ${e.toString()}');
    }
  }

  // Get green note by ID
  Future<GreenNote> getGreenNote(String noteId) async {
    try {
      return await _repository.getGreenNote(noteId);
    } catch (e) {
      throw Exception('Failed to get green note: ${e.toString()}');
    }
  }

  // Update green note
  Future<GreenNote> updateGreenNote(String noteId, GreenNote note) async {
    try {
      return await _repository.updateGreenNote(noteId, note);
    } catch (e) {
      throw Exception('Failed to update green note: ${e.toString()}');
    }
  }

  // Cancel green note
  Future<void> cancelGreenNote(String noteId, {String? cancelReason}) async {
    try {
      await _repository.cancelGreenNote(noteId, cancelReason: cancelReason);
    } catch (e) {
      throw Exception('Failed to cancel green note: ${e.toString()}');
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
      return await _repository.listGreenNotes(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        statusFilter: statusFilter,
      );
    } catch (e) {
      throw Exception('Failed to list green notes: ${e.toString()}');
    }
  }
}
