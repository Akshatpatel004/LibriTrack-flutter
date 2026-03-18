import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/book_provider.dart';
import '../routes/app_routes.dart';
import 'add_edit_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Lumina Design Palette
  static const Color primaryOrange = Color(0xffF05A22);
  static const Color primaryGreen = Color(0xff18C37E);
  static const Color bgColor = Color(0xffF8F9FA);
  static const Color titleColor = Color(0xff1D2939);
  static const Color subtitleColor = Color(0xff667085);
  static const Color borderColor = Color(0xffEAECF0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  void _showAddEditDialog({dynamic book}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: AddEditBookScreen(book: book),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic book, BookProvider provider) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xffFEF3F2), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xffD92D20), size: 32),
              ),
              const SizedBox(height: 16),
              const Text("Are you sure?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor)),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: subtitleColor, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: "This action will permanently delete "),
                    TextSpan(text: '"${book.title}"', style: const TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
                    const TextSpan(text: " from your personal library."),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xffD0D5DD)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xff344054), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.deleteBook(book.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Delete Book"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffD92D20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: FadeTransition(opacity: anim1, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    final allFilteredBooks = provider.books.where((book) {
      final query = _searchController.text.toLowerCase();
      return book.title.toLowerCase().contains(query) || book.author.toLowerCase().contains(query);
    }).toList();

    int totalItems = allFilteredBooks.length;
    int totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    final pagedBooks = allFilteredBooks.sublist(
      startIndex,
      endIndex > totalItems ? totalItems : endIndex,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Library Books", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: titleColor)),
            const Text("Manage and track your comprehensive library collection.", style: TextStyle(color: subtitleColor, fontSize: 14)),
            const SizedBox(height: 32),
            _buildStatsRow(provider),
            const SizedBox(height: 32),
            _buildBookTableContainer(provider, pagedBooks, totalItems, totalPages),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(User? user) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Text("LibriTrack", style: TextStyle(color: titleColor, fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(width: 40),
          Container(
            width: 350,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xffF2F4F7), borderRadius: BorderRadius.circular(8)),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() => _currentPage = 1),
              decoration: const InputDecoration(
                hintText: "Search books, authors...",
                hintStyle: TextStyle(fontSize: 13, color: subtitleColor),
                prefixIcon: Icon(Icons.search, size: 18, color: subtitleColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none, color: subtitleColor), onPressed: () {}),
        IconButton(icon: const Icon(Icons.settings_outlined, color: subtitleColor), onPressed: () {}),
        const VerticalDivider(width: 30, indent: 20, endIndent: 20),
        _buildProfileMenu(user),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildProfileMenu(User? user) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        if (value == 'logout') {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            children: [
              const CircleAvatar(radius: 25, backgroundColor: Color(0xffF5E7D8), child: Icon(Icons.person, color: Color(0xff8D6D4B), size: 28)),
              const SizedBox(height: 10),
              Text(user?.displayName ?? "Admin User", style: const TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
              Text(user?.email ?? "admin@libritrack.com", style: const TextStyle(fontSize: 11, color: subtitleColor)),
              const Divider(),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [Icon(Icons.logout, color: Colors.red, size: 18), SizedBox(width: 10), Text("Logout", style: TextStyle(color: Colors.red))]),
        ),
      ],
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Color(0xffF5E7D8), child: Icon(Icons.person, size: 18, color: Color(0xff8D6D4B))),
          const SizedBox(width: 8),
          Text(user?.displayName?.split(' ')[0] ?? "Admin", style: const TextStyle(color: titleColor, fontWeight: FontWeight.w600, fontSize: 14)),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: subtitleColor),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BookProvider provider) {
    return Row(
      children: [
        _statCard("TOTAL BOOKS", "${provider.books.length}", const Color(0xffEEF4FF), const Color(0xff3B82F6), Icons.collections_bookmark),
        const SizedBox(width: 24),
        _statCard("AVAILABLE", "${provider.books.where((b) => !b.isIssued).length}", const Color(0xffECFDF3), primaryGreen, Icons.check_circle),
        const SizedBox(width: 24),
        _statCard("ISSUED", "${provider.books.where((b) => b.isIssued).length}", const Color(0xffFEF3F2), const Color(0xffD92D20), Icons.outbound),
      ],
    );
  }

  Widget _statCard(String label, String val, Color bg, Color iconC, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: iconC, size: 24)),
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 0.5)),
              Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: titleColor)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTableContainer(BookProvider provider, List pagedBooks, int totalItems, int totalPages) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Book"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          _buildTableHeader(),
          provider.isLoading 
              ? const Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()) 
              : Column(children: pagedBooks.map((book) => _buildBookRow(book, provider)).toList()),
          _buildTableFooter(totalItems, totalPages),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: const BoxDecoration(color: Color(0xffF9FAFB), border: Border(bottom: BorderSide(color: borderColor))),
      child: const Row(
        children: [
          Expanded(flex: 5, child: Text("Book Title", style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor, fontSize: 13))),
          Expanded(flex: 4, child: Text("Author", style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor, fontSize: 13))),
          Expanded(flex: 2, child: Text("ISBN", style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor, fontSize: 13))),
          Expanded(flex: 2, child: Center(child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor, fontSize: 13)))),
          Expanded(flex: 2, child: Center(child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor, fontSize: 13)))),
          SizedBox(width: 40), // Spacer before actions
          SizedBox(width: 120, child: Center(child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: subtitleColor, fontSize: 13)))),
        ],
      ),
    );
  }

  Widget _buildBookRow(dynamic book, BookProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffF2F4F7)))),
      child: Row(
        children: [
          Expanded(flex: 5, child: Row(children: [
            Container(
              height: 48, width: 38, 
              decoration: BoxDecoration(color: const Color(0xffF2F4F7), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xffEAECF0))), 
              child: const Icon(Icons.menu_book_rounded, size: 22, color: primaryOrange)
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, color: titleColor, fontSize: 14))),
          ])),
          Expanded(flex: 4, child: Text(book.author, style: const TextStyle(color: subtitleColor, fontSize: 14))),
          Expanded(flex: 2, child: Text(book.isbn, style: const TextStyle(color: subtitleColor, fontSize: 14))),
          
          // Tightened Quantity Column
          Expanded(flex: 2, child: Center(child: _quantityBadge(book.quantity))),
          
          // Tightened Status Column
          Expanded(flex: 2, child: Center(child: _statusBadge(book.isIssued))),
          
          const SizedBox(width: 40), // Space before actions

          SizedBox(width: 120, child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.refresh, size: 18, color: subtitleColor), onPressed: () => provider.toggleIssuedStatus(book.id)),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: subtitleColor), onPressed: () => _showAddEditDialog(book: book)),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: subtitleColor), onPressed: () => _showDeleteDialog(context, book, provider)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _quantityBadge(int qty) {
    Color bg;
    Color text;
    String label;

    if (qty == 0) {
      bg = const Color(0xffFEF3F2);
      text = const Color(0xffB42318);
      label = "OUT OF STOCK";
    } else if (qty <= 10) {
      bg = const Color(0xffFFFAEB);
      text = const Color(0xffB54708);
      label = "LOW STOCK";
    } else {
      bg = const Color(0xffECFDF3);
      text = const Color(0xff027A48);
      label = "IN STOCK";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$qty", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: text)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: text, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isIssued) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isIssued ? const Color(0xffF2F4F7) : const Color(0xffECFDF3), borderRadius: BorderRadius.circular(6)),
      child: Text(isIssued ? "ISSUED" : "AVAILABLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isIssued ? const Color.fromARGB(255, 227, 123, 58) : const Color(0xff027A48))),
    );
  }

  Widget _buildTableFooter(int totalItems, int totalPages) {
    int start = totalItems == 0 ? 0 : ((_currentPage - 1) * _itemsPerPage) + 1;
    int end = _currentPage * _itemsPerPage > totalItems ? totalItems : _currentPage * _itemsPerPage;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Showing $start to $end of $totalItems entries", style: const TextStyle(color: subtitleColor, fontSize: 13)),
          Row(
            children: [
              _pageNavBtn("Previous", _currentPage > 1, () => setState(() => _currentPage--)),
              const SizedBox(width: 8),
              ...List.generate(totalPages, (i) => _pageNumberBtn(i + 1)),
              const SizedBox(width: 8),
              _pageNavBtn("Next", _currentPage < totalPages, () => setState(() => _currentPage++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageNavBtn(String text, bool active, VoidCallback tap) {
    return TextButton(onPressed: active ? tap : null, child: Text(text, style: TextStyle(color: active ? subtitleColor : Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 13)));
  }

  Widget _pageNumberBtn(int page) {
    bool isSelected = _currentPage == page;
    return GestureDetector(
      onTap: () => setState(() => _currentPage = page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? primaryOrange : Colors.transparent, borderRadius: BorderRadius.circular(6)),
        child: Text("$page", style: TextStyle(color: isSelected ? Colors.white : subtitleColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// 0xffFEF3F2