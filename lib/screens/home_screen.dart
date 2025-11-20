import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/aggregate_heatmap.dart';

/// Drawer extracted so Dashboard and Home can both use the same categories drawer
class AppCategoryDrawer extends StatelessWidget {
  const AppCategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return SafeArea(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Categories', style: TextStyle(fontSize: 20, color: Colors.tealAccent)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: app.categories.length,
              itemBuilder: (context, i) {
                final c = app.categories[i];
                return ListTile(
                  title: Text(c.title),
                  subtitle: Text('${c.goals.length} goal(s)'),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.pushNamed(context, '/category', arguments: {'id': c.id});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Body used by both Home and Dashboard to keep them identical
class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final recent = app.recentCompletions(limit: 8);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Recent activity / habits
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent activity', style: TextStyle(color: Colors.tealAccent, fontSize: 18)),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  const Text('No recent completions. Start doing habits to see activity here.', style: TextStyle(color: Colors.white70))
                else
                  Column(
                    children: recent.map((r) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(r['habitName']),
                        subtitle: Text('${r['goalTitle']} · ${r['categoryTitle']}'),
                        trailing: Text(r['lastCompletedDate'], style: const TextStyle(color: Colors.white60)),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Aggregated heatmap
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity Heatmap (all habits)', style: TextStyle(fontSize: 18, color: Colors.tealAccent)),
                  const SizedBox(height: 8),
                  const Expanded(child: AggregateHeatmap(days: 90)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}