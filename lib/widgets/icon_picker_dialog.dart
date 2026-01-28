import 'package:flutter/material.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  // Curated list of common category icons
  static final List<Map<String, dynamic>> categoryIcons = [
    {'icon': Icons.fitness_center, 'label': 'Fitness'},
    {'icon': Icons.self_improvement, 'label': 'Meditation'},
    {'icon': Icons.book, 'label': 'Reading'},
    {'icon': Icons.school, 'label': 'Education'},
    {'icon': Icons.work, 'label': 'Work'},
    {'icon': Icons.code, 'label': 'Coding'},
    {'icon': Icons.palette, 'label': 'Art'},
    {'icon': Icons.music_note, 'label': 'Music'},
    {'icon': Icons.restaurant, 'label': 'Food'},
    {'icon': Icons.local_drink, 'label': 'Hydration'},
    {'icon': Icons.bedtime, 'label': 'Sleep'},
    {'icon': Icons.directions_run, 'label': 'Running'},
    {'icon': Icons.favorite, 'label': 'Health'},
    {'icon': Icons.psychology, 'label': 'Mental'},
    {'icon': Icons.groups, 'label': 'Social'},
    {'icon': Icons.family_restroom, 'label': 'Family'},
    {'icon': Icons.pets, 'label': 'Pets'},
    {'icon': Icons.house, 'label': 'Home'},
    {'icon': Icons.shopping_cart, 'label': 'Shopping'},
    {'icon': Icons.account_balance, 'label': 'Finance'},
    {'icon': Icons.savings, 'label': 'Savings'},
    {'icon': Icons.flight, 'label': 'Travel'},
    {'icon': Icons.camera_alt, 'label': 'Photography'},
    {'icon': Icons.sports_soccer, 'label': 'Sports'},
    {'icon': Icons.videogame_asset, 'label': 'Gaming'},
    {'icon': Icons.computer, 'label': 'Technology'},
    {'icon': Icons.science, 'label': 'Science'},
    {'icon': Icons.nature, 'label': 'Nature'},
    {'icon': Icons.eco, 'label': 'Environment'},
    {'icon': Icons.restaurant_menu, 'label': 'Cooking'},
    {'icon': Icons.local_cafe, 'label': 'Coffee'},
    {'icon': Icons.spa, 'label': 'Wellness'},
    {'icon': Icons.watch, 'label': 'Time'},
    {'icon': Icons.build, 'label': 'DIY'},
    {'icon': Icons.star, 'label': 'Goals'},
    {'icon': Icons.wb_sunny, 'label': 'Morning'},
    {'icon': Icons.nights_stay, 'label': 'Evening'},
    {'icon': Icons.water_drop, 'label': 'Water'},
    {'icon': Icons.lightbulb, 'label': 'Ideas'},
    {'icon': Icons.calendar_today, 'label': 'Planning'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose an Icon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: categoryIcons.length,
                itemBuilder: (context, index) {
                  final iconData = categoryIcons[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, iconData['icon'] as IconData);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconData['icon'] as IconData,
                            size: 32,
                            color: Colors.tealAccent,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            iconData['label'] as String,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
