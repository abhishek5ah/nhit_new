import '../models/bank_models/bank_letter_model.dart';

/// In-memory storage service for bank letters
/// This will be replaced with actual API calls later
class LetterStorageService {
  static final LetterStorageService _instance = LetterStorageService._internal();
  factory LetterStorageService() => _instance;
  LetterStorageService._internal();

  final Map<String, BankLetter> _letters = {};

  /// Store a letter temporarily
  void storeLetter(String id, BankLetter letter) {
    _letters[id] = letter;
  }

  /// Retrieve a letter by ID
  BankLetter? getLetter(String id) {
    return _letters[id];
  }

  /// Clear all stored letters
  void clearAll() {
    _letters.clear();
  }

  /// Remove a specific letter
  void removeLetter(String id) {
    _letters.remove(id);
  }

  /// Get all letters
  List<BankLetter> getAllLetters() {
    return _letters.values.toList();
  }
}
