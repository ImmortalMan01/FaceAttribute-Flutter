import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';

/// Entry point for standalone demo.
void main() {
  runApp(const FaceRecognitionApp());
}

/// Root widget that sets up theme and typography.
class FaceRecognitionApp extends StatelessWidget {
  const FaceRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF5B3FBB);
    final textTheme = GoogleFonts.nunitoTextTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        textTheme: textTheme,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: seed,
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const FaceRecognitionHome(),
    );
  }
}

/// Main home screen with actions and description.
const _logoBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wIAAgMBj9u0AAAAAElFTkSuQmCC';

class FaceRecognitionHome extends StatelessWidget {
  const FaceRecognitionHome({super.key});

  void _onPressed(String name) {
    debugPrint(name);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 600;
    final primaryStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(64, 64),
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
    );
    final secondaryStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(64, 64),
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
    );

    List<Widget> buttons = [
      Semantics(
        label: 'Kaydet',
        button: true,
        child: ElevatedButton.icon(
          style: primaryStyle,
          onPressed: () => _onPressed('Kaydet'),
          icon: const Icon(Icons.person_add),
          label: const Text('Kaydet'),
        ).animate().fadeIn(duration: 350.ms),
      ),
      Semantics(
        label: 'Tan\u0131',
        button: true,
        child: ElevatedButton.icon(
          style: primaryStyle,
          onPressed: () => _onPressed('Tan\u0131'),
          icon: const Icon(Icons.face),
          label: const Text('Tan\u0131'),
        ).animate().fadeIn(duration: 350.ms),
      ),
      Semantics(
        label: 'Yakala',
        button: true,
        child: ElevatedButton.icon(
          style: primaryStyle,
          onPressed: () => _onPressed('Yakala'),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Yakala'),
        ).animate().fadeIn(duration: 350.ms),
      ),
      Semantics(
        label: 'Ayarlar',
        button: true,
        child: OutlinedButton.icon(
          style: secondaryStyle,
          onPressed: () => _onPressed('Ayarlar'),
          icon: const Icon(Icons.settings),
          label: const Text('Ayarlar'),
        ).animate().fadeIn(duration: 350.ms),
      ),
      Semantics(
        label: 'Kay\u0131tlar',
        button: true,
        child: OutlinedButton.icon(
          style: secondaryStyle,
          onPressed: () => _onPressed('Kay\u0131tlar'),
          icon: const Icon(Icons.list),
          label: const Text('Kay\u0131tlar'),
        ).animate().fadeIn(duration: 350.ms),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Y\u00fcz Tan\u0131ma',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16, end: 72),
            ),
            actions: [
              Hero(
                tag: 'brand-logo',
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.memory(
                    base64Decode(_logoBase64),
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'OGULCAN-AI y\u00fcz tan\u0131ma, canl\u0131l\u0131k tespiti ve kimlik belgesi tan\u0131ma i\u00e7in SDK\'lar sunar.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ).animate().fadeIn(duration: 350.ms),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate(buttons),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 2 : 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isWide ? 3 : 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
