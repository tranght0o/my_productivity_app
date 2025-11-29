import 'package:flutter/material.dart';
import 'library_todo_section.dart';
import 'library_habit_section.dart';
import 'library_mood_section.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedOption = 'todo';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode(); // controls keyboard focus on search bar

  @override
  void initState() {
    super.initState();

    // Rebuild UI when search text changes
    _searchController.addListener(() {
      setState(() {});
    });

    // Rebuild UI when focus changes (to show/hide the clear button)
    _searchFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Search bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 20),

                  // Show clear (X) button if field is focused OR has text
                  suffixIcon: (_searchFocus.hasFocus ||
                          _searchController.text.isNotEmpty)
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchController.clear(); // clear text
                            _searchFocus.unfocus(); // remove keyboard focus
                            setState(() {}); // refresh UI
                          },
                        )
                      : null,

                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

          // --- Menu for section switching ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildSegment('To Do', 'todo'),
                  _buildSegment('Habit', 'habit'),
                  _buildSegment('Mood', 'mood'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Dynamic section display ---
          Expanded(
            child: _selectedOption == 'todo'
                ? LibraryTodoSection(searchQuery: _searchController.text)
                : _selectedOption == 'habit'
                    ? LibraryHabitSection(searchQuery: _searchController.text)
                    : const LibraryMoodSection(),
          ),
        ],
      ),
    );
  }

  // Build one segment button
  Widget _buildSegment(String label, String value) {
    final bool isSelected = _selectedOption == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedOption = value),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
