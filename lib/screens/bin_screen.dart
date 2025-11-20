import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class BinScreen extends StatelessWidget {
  static const routeName = '/bin';
  const BinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final deletedCategories = app.deletedCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: deletedCategories.isEmpty
            ? const Center(
                child: Text('Bin is empty.', style: TextStyle(color: Colors.white70)),
              )
            : ListView.builder(
                itemCount: deletedCategories.length,
                itemBuilder: (context, i) {
                  final c = deletedCategories[i];
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(c.title),
                      subtitle: Text('${c.goals.length} goal(s)'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Restore',
                            icon: const Icon(Icons.restore, color: Colors.greenAccent),
                            onPressed: () {
                              context.read<AppProvider>().restoreCategory(c.id);
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete forever',
                            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete forever?'),
                                  content: Text('Permanently delete "${c.title}" and all its goals and habits?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () {
                                        context.read<AppProvider>().permanentlyDeleteCategory(c.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      children: [
                        if (c.goals.isEmpty)
                          const ListTile(
                            title: Text('No goals in this category.'),
                          )
                        else
                          ...c.goals.map((g) => ExpansionTile(
                                title: Text(g.title),
                                subtitle: Text('${g.habits.length} habit(s)'),
                                children: [
                                  if (g.habits.isEmpty)
                                    const ListTile(
                                      title: Text('No habits.'),
                                    )
                                  else
                                    ...g.habits.map((h) => ListTile(
                                          title: Text(h.name),
                                        )),
                                ],
                              )),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
