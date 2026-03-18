class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final int quantity;
  final bool isIssued;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.quantity,
    this.isIssued = false,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    int? quantity,
    bool? isIssued,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      quantity: quantity ?? this.quantity,
      isIssued: isIssued ?? this.isIssued,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'quantity': quantity,
      'isIssued': isIssued,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      author: map['author']?.toString() ?? '',
      isbn: map['isbn']?.toString() ?? '',
      quantity: (map['quantity'] is int)
          ? map['quantity'] as int
          : int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      isIssued: map['isIssued'] == true,
    );
  }

  String toJson() {
    return '$id||$title||$author||$isbn||$quantity||$isIssued';
  }

  factory Book.fromJson(String json) {
    final parts = json.split('||');

    return Book(
      id: parts.isNotEmpty ? parts[0] : '',
      title: parts.length > 1 ? parts[1] : '',
      author: parts.length > 2 ? parts[2] : '',
      isbn: parts.length > 3 ? parts[3] : '',
      quantity: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
      isIssued: parts.length > 5 ? parts[5].toLowerCase() == 'true' : false,
    );
  }
}
