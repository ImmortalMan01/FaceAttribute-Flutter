import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        appBar: NeumorphicAppBar(
          title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
          buttonStyle: const NeumorphicStyle(depth: 4),
          actions: [
            PopupMenuButton<AdaptiveThemeMode>(
              onSelected: (mode) {
                switch (mode) {
                  case AdaptiveThemeMode.dark:
                    AdaptiveTheme.of(context).setDark();
                    break;
                  case AdaptiveThemeMode.light:
                    AdaptiveTheme.of(context).setLight();
                    break;
                  case AdaptiveThemeMode.system:
                  default:
                    AdaptiveTheme.of(context).setSystem();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: AdaptiveThemeMode.system,
                  child: Text('System'),
                ),
                PopupMenuItem(
                  value: AdaptiveThemeMode.light,
                  child: Text('Light'),
                ),
                PopupMenuItem(
                  value: AdaptiveThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            )
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final content = _buildContent(textScale);
              if (!isWide) return content;
              return Row(
                children: [
                  Expanded(child: content),
                  SizedBox(
                    width: 300,
                    child: _buildList(textScale),
                  )
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Neumorphic(
          style: const NeumorphicStyle(depth: 4),
          child: NeumorphicBottomNavigation(
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Tasks'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double textScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: NeumorphicText(
            'Hello There!',
            style: NeumorphicStyle(
              depth: 4,
              color: NeumorphicTheme.defaultTextColor(context),
            ),
            textStyle: NeumorphicTextStyle(
              fontSize: 24 * textScale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _buildActionButton(Icons.add, 'Add')),
              const SizedBox(width: 16),
              Expanded(child: _buildActionButton(Icons.list, 'View')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildList(textScale)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return NeumorphicButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      style: NeumorphicStyle(
        depth: 4,
        boxShape: NeumorphicBoxShape.roundRect(
          const BorderRadius.all(Radius.circular(16)),
        ),
      ),
      duration: const Duration(milliseconds: 150),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicIcon(icon, size: 24),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildList(double textScale) {
    return Neumorphic(
      margin: const EdgeInsets.all(16),
      style: const NeumorphicStyle(depth: 2),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: NeumorphicButton(
              minDistance: -4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              style: NeumorphicStyle(
                depth: -4,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              ),
              duration: const Duration(milliseconds: 150),
              onPressed: () {},
              child: Row(
                children: [
                  NeumorphicIcon(Icons.task, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Task ${index + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 16 * textScale),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NeumorphicBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const NeumorphicBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final accent = NeumorphicTheme.accentColor(context);
    return Row(
      children: List.generate(items.length, (index) {
        final selected = index == selectedIndex;
        final item = items[index];
        final icon = item.icon as Icon;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Semantics(
              selected: selected,
              button: true,
              child: NeumorphicButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                duration: const Duration(milliseconds: 150),
                style: NeumorphicStyle(
                  depth: selected ? 4 : -4,
                  color: selected ? accent : null,
                  boxShape: const NeumorphicBoxShape.stadium(),
                ),
                onPressed: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeumorphicIcon(icon.icon!, size: 24),
                    const SizedBox(height: 4),
                    Text(item.label ?? ''),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
