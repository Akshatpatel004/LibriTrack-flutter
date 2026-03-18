import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;
  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _author;
  late TextEditingController _isbn;
  late TextEditingController _quantity;

  static const Color primaryOrange = Color(0xffF05A22);
  static const Color textDark = Color(0xff1D2939);
  static const Color borderColor = Color(0xffEAECF0);

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.book?.title ?? '');
    _author = TextEditingController(text: widget.book?.author ?? '');
    _isbn = TextEditingController(text: widget.book?.isbn ?? '');
    _quantity = TextEditingController(text: widget.book?.quantity.toString() ?? '1');
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _isbn.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.book == null ? "Add New Book" : "Edit Book Detail",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const Divider(height: 32, color: borderColor),
              
              _buildLabel("Book Title"),
              _buildField(
                _title, 
                "e.g. The Great Gatsby",
                validator: (v) => (v == null || v.trim().isEmpty) ? "Title is required" : null,
              ),
              
              const SizedBox(height: 20),
              
              _buildLabel("Author"),
              _buildField(
                _author, 
                "e.g. F. Scott Fitzgerald",
                validator: (v) => (v == null || v.trim().isEmpty) ? "Author is required" : null,
              ),
              
              const SizedBox(height: 20),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align for error messages
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("ISBN"),
                        _buildField(
                          _isbn, 
                          "123456789",
                          isNumOnly: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            if (!RegExp(r'^[0-9]+$').hasMatch(v)) return "Numbers only";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Quantity"),
                        _buildField(
                          _quantity, 
                          "1", 
                          isNumOnly: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            final n = int.tryParse(v);
                            if (n == null || n <= 0) return "Min 1";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: const BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: textDark, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _handleSave,
                      child: Text(
                        widget.book == null ? "Add Book" : "Update Book",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
    );
  }

  Widget _buildField(
    TextEditingController ctrl, 
    String hint, {
    bool isNumOnly = false, 
    String? Function(String?)? validator
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumOnly 
          ? [FilteringTextInputFormatter.digitsOnly] // Blocks non-number typing physically
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xffF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      ),
      validator: validator,
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: widget.book?.id ?? DateTime.now().toString(),
        title: _title.text.trim(),
        author: _author.text.trim(),
        isbn: _isbn.text.trim(),
        quantity: int.tryParse(_quantity.text) ?? 1,
        isIssued: widget.book?.isIssued ?? false,
      );

      if (widget.book == null) {
        context.read<BookProvider>().addBook(book);
      } else {
        context.read<BookProvider>().updateBook(widget.book!.id, book);
      }
      Navigator.pop(context);
    }
  }
}