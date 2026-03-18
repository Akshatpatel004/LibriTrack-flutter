import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = await _storageService.getBooks();
      notifyListeners();

      final firebaseBooks = await _firestoreService.getBooks();

      if (firebaseBooks.isNotEmpty) {
        _books = firebaseBooks;
        await _storageService.saveBooks(_books);
      }
    } catch (e) {
      debugPrint("Load Books Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    _books.add(book);
    notifyListeners();

    await _storageService.saveBooks(_books);

    try {
      await _firestoreService.addBook(book);
    } catch (e) {
      debugPrint("Add Book Error: $e");
    }
  }

  Future<void> updateBook(String id, Book updatedBook) async {
    final index = _books.indexWhere((book) => book.id == id);
    if (index == -1) return;

    _books[index] = updatedBook;
    notifyListeners();

    await _storageService.saveBooks(_books);

    try {
      await _firestoreService.updateBook(updatedBook);
    } catch (e) {
      debugPrint("Update Book Error: $e");
    }
  }

  Future<void> toggleIssuedStatus(String id) async {
    final index = _books.indexWhere((book) => book.id == id);
    if (index == -1) return;

    final currentBook = _books[index];
    final updatedBook = currentBook.copyWith(
      isIssued: !currentBook.isIssued,
    );

    _books[index] = updatedBook;
    notifyListeners();

    await _storageService.saveBooks(_books);

    try {
      await _firestoreService.updateBook(updatedBook);
    } catch (e) {
      debugPrint("Toggle Issued Status Error: $e");
    }
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((book) => book.id == id);
    notifyListeners();

    await _storageService.saveBooks(_books);

    try {
      await _firestoreService.deleteBook(id);
    } catch (e) {
      debugPrint("Delete Book Error: $e");
    }
  }
}
