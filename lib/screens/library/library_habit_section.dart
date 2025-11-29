import 'package:flutter/material.dart';
import '../../models/habit_model.dart';
import '../../services/habit_service.dart';
import '../../widgets/add_habit_bottom_sheet.dart';
import '../../utils/message_helper.dart';
import 'habit_detail_screen.dart';

class LibraryHabitSection extends StatefulWidget {
  final String searchQuery;
  const LibraryHabitSection({super.key, this.searchQuery = ''});

  @override
  State<LibraryHabitSection> createState() => _LibraryHabitSectionState();
}

class _LibraryHabitSectionState extends State<LibraryHabitSection> {
  final _habitService = HabitService();
  
  String _filterStatus = 'all'; // all, active, completed
  String _sortBy = 'newest'; // newest, oldest, name

  String _getFrequencyText(Habit habit) {
    switch (habit.frequency) {
      case 'daily':
        return 'Everyday';
      case 'weekly':
        return 'Every ${habit.daysOfWeek.join(", ")}';
      case 'monthly':
        return 'Every ${habit.daysOfMonth.join(", ")}';
      default:
        return '';
    }
  }

  void _showEditSheet(Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddHabitBottomSheet(habitToEdit: habit),
    );
  }

  Future<void> _confirmDelete(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _habitService.deleteHabit(habit.id);
        if (mounted) {
          MessageHelper.showSuccess(context, 'Habit deleted successfully!');
        }
      } catch (e) {
        if (mounted) {
          MessageHelper.showError(context, 'Failed to delete: $e');
        }
      }
    }
  }

  void _showOptionsMenu(Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.deepPurple),
            title: const Text('Edit Habit'),
            onTap: () {
              Navigator.pop(ctx);
              _showEditSheet(habit);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Habit'),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDelete(habit);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Habit> _filterAndSortHabits(List<Habit> habits) {
    final now = DateTime.now();
    
    // Filter by status
    List<Habit> filtered = habits.where((habit) {
      if (_filterStatus == 'active') {
        return habit.endDate == null || habit.endDate!.isAfter(now);
      } else if (_filterStatus == 'completed') {
        return habit.endDate != null && habit.endDate!.isBefore(now);
      }
      return true; // 'all'
    }).toList();

    // Sort
    if (_sortBy == 'newest') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'oldest') {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sortBy == 'name') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final purple = Colors.deepPurple.shade400;

    return Column(
      children: [

        // filter & sort bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Filter Segmented Chips
              Expanded(
                child: Row(
                  children: [
                    _buildChip("All", "all", purple),
                    const SizedBox(width: 6),
                    _buildChip("Active", "active", purple),
                    const SizedBox(width: 6),
                    _buildChip("Completed", "completed", purple),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // SORT ICON 
              InkWell(
                onTap: () {
                  setState(() {
                    _sortBy = _sortBy == 'newest' ? 'oldest' : 'newest';
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _sortBy == 'newest'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 18,
                    color: purple,
                  ),
                ),
              ),
            ],
          ),
        ),



        Expanded(
          child: StreamBuilder<List<Habit>>(
            stream: _habitService.getHabits(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final habits = snapshot.data ?? [];
              
              final searchFiltered = widget.searchQuery.isEmpty
                  ? habits
                  : habits.where((h) => h.name
                      .toLowerCase()
                      .contains(widget.searchQuery.toLowerCase()))
                      .toList();

              final filteredHabits = _filterAndSortHabits(searchFiltered);

              if (filteredHabits.isEmpty) {
                return const Center(
                  child: Text(
                    'No habits found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: filteredHabits.length,
                itemBuilder: (context, index) {
                  final habit = filteredHabits[index];
                  return _buildHabitCard(habit);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Modern Chip Builder
  Widget _buildChip(String label, String value, Color purple) {
    final bool selected = _filterStatus == value;

    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? purple.withOpacity(0.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? purple : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  // Habit Card 
  Widget _buildHabitCard(Habit habit) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => HabitDetailScreen(habit: habit),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Habit icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Habit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFrequencyText(habit),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showOptionsMenu(habit),
            ),
          ],
        ),
      ),
    );
  }
}
