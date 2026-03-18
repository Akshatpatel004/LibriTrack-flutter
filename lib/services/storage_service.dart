import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class StorageService {
  static const String _booksKey = 'books_list';

  Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookList = books.map((book) => book.toJson()).toList();
    await prefs.setStringList(_booksKey, bookList);
  }

  Future<List<Book>> getBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookList = prefs.getStringList(_booksKey) ?? [];
    return bookList.map((item) => Book.fromJson(item)).toList();
  }

  Future<void> clearBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_booksKey);
  }
}
