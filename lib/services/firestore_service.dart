import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookCollection =>
      _firestore.collection('books');

  Future<void> addBook(Book book) async {
    await _bookCollection.doc(book.id).set(book.toMap());
  }

  Future<void> updateBook(Book book) async {
    await _bookCollection.doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String id) async {
    await _bookCollection.doc(id).delete();
  }

  Future<List<Book>> getBooks() async {
    final snapshot = await _bookCollection.get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }
}
