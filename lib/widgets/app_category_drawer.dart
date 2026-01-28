import 'package:flutter/material.dart';
import 'package:goals_app/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'icon_picker_dialog.dart';

class AppCategoryDrawer extends StatelessWidget {
  const AppCategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Categories',
                    style: TextStyle(fontSize: 20, color: Colors.tealAccent)),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.tealAccent, indent: 16, endIndent: 16),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Opacity(
                      opacity: 0.05,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 900,
                          height: 900,
                        ),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: app.activeCategories.length,
                  itemBuilder: (context, i) {
                    final c = app.activeCategories[i];
                    return ListTile(
                      leading: Icon(
                        c.icon ?? Icons.category,
                        color: Colors.tealAccent,
                      ),
                      title: Text(c.title),
                      subtitle: Text('${c.goals.length} goal(s)'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              _showEditCategoryDialog(context, app, c);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Category?'),
                                  content: Text('Move "${c.title}" to bin?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<AppProvider>()
                                            .deleteCategory(c.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Move to bin'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        Navigator.pushNamed(context, '/category',
                            arguments: {'id': c.id});
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red,),
            title: const Text('Bin', style: TextStyle(color: Colors.red),),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bin');
            },
          ),
        ],
        
      ),
      
    );
  }

  void _showEditCategoryDialog(BuildContext context, AppProvider app, dynamic category) {
    final controller = TextEditingController(text: category.title);
    IconData? selectedIcon = category.icon;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Icon: '),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final icon = await showDialog<IconData>(
                        context: context,
                        builder: (_) => const IconPickerDialog(),
                      );
                      if (icon != null) {
                        setState(() {
                          selectedIcon = icon;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.tealAccent),
                      ),
                      child: Icon(
                        selectedIcon ?? Icons.category,
                        color: Colors.tealAccent,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tap to change', style: TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = controller.text.trim();
                if (v.isNotEmpty) {
                  app.editCategory(
                    category.id,
                    v,
                    iconCodePoint: selectedIcon?.codePoint,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}