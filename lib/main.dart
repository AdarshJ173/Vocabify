import 'package:flutter/material.dart';
import 'package:vocabify/pages/idioms.dart';
import 'package:vocabify/pages/phrasalVerbs.dart';
import 'package:vocabify/pages/synonyms.dart';
import 'package:vocabify/pages/antonyms.dart';
import 'package:vocabify/pages/settings.dart';
import 'package:vocabify/pages/synonymsType.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VocabularyApp());
}

class VocabularyApp extends StatefulWidget {
  const VocabularyApp({super.key});

  @override
  _VocabularyAppState createState() => _VocabularyAppState();
}

class _VocabularyAppState extends State<VocabularyApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vocabify',
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF00ADB5),
              scaffoldBackgroundColor: const Color(0xFF222831),
              cardColor: const Color(0xFF393E46),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF00ADB5),
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: const Color(0xFF00ADB5),
              scaffoldBackgroundColor: const Color(0xFFF4EEFF),
              cardColor: const Color(0xFFDCD6F7),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF424874),
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
            ),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            HomePage(onThemeChanged: _toggleTheme, isDarkMode: _isDarkMode),
        '/idioms': (context) => const IdiomsPage(),
        '/phrasalVerbs': (context) => const PhrasalVerbsPage(),
        '/synonyms': (context) => const SynonymsPage(),
        '/antonyms': (context) => const AntonymsPage(),
        '/settings': (context) =>
            SettingsPage(onThemeChanged: _toggleTheme, isDarkMode: _isDarkMode),
        '/synonymsType': (context) => const SynonymsType(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const HomePage(
      {super.key, required this.onThemeChanged, required this.isDarkMode});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showVersion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVersionInfo() {
    setState(() {
      _showVersion = true;
    });
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _controller.reverse().then((_) {
            setState(() {
              _showVersion = false;
            });
          });
        }
      });
    });
  }

  void _onTap(int index) {
    if (_currentIndex == index && index == 0) {
      return; // Prevent layering of home page
    }
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                onThemeChanged: widget.onThemeChanged,
                isDarkMode: widget.isDarkMode)),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushNamed(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vocabify',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Color(0xFFEEEEEE),
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(17),
          ),
        ),
        backgroundColor: const Color(0xFF00ADB5),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFEEEEEE),
            ),
            onPressed: _toggleVersionInfo,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.isDarkMode
                    ? const [
                        Color(0xFF222831),
                        Color(0xFF393E46),
                      ]
                    : const [
                        Color(0xFFF4EEFF),
                        Color(0xFFDCD6F7),
                      ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildGrid(context),
                ),
              ),
            ),
          ),
          if (_showVersion)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? const Color(0xFF393E46)
                        : const Color(0xFFDCD6F7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: widget.isDarkMode
                            ? const Color(0xFF00ADB5)
                            : const Color(0xFF424874),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? const Color(0xFFEEEEEE)
                              : const Color(0xFF424874),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxdropFilter(
                color: widget.isDarkMode
                    ? const Color(0xFF393E46).withOpacity(0.9)
                    : const Color(0xFFDCD6F7).withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: widget.isDarkMode
                    ? const Color(0xFF00ADB5)
                    : const Color(0xFF424874),
                unselectedItemColor: widget.isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                selectedFontSize: 14,
                unselectedFontSize: 12,
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (_currentIndex == 0 &&
                                Navigator.canPop(context) == false)
                            ? (widget.isDarkMode
                                ? const Color(0xFF00ADB5).withOpacity(0.2)
                                : const Color(0xFF424874).withOpacity(0.2))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        size: (_currentIndex == 0 &&
                                Navigator.canPop(context) == false)
                            ? 28
                            : 24,
                        color: (_currentIndex == 0 &&
                                Navigator.canPop(context) == false)
                            ? (widget.isDarkMode
                                ? const Color(0xFF00ADB5)
                                : const Color(0xFF424874))
                            : (widget.isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5)),
                      ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _currentIndex == 1
                            ? (widget.isDarkMode
                                ? const Color(0xFF00ADB5).withOpacity(0.2)
                                : const Color(0xFF424874).withOpacity(0.2))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        size: _currentIndex == 1 ? 28 : 24,
                      ),
                    ),
                    label: 'Settings',
                  ),
                ],
                currentIndex: _currentIndex,
                onTap: _onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildNavigationCard(context, 'Idioms', '/idioms', Icons.auto_stories),
        _buildNavigationCard(
            context, 'Phrasal Verbs', '/phrasalVerbs', Icons.psychology),
        _buildNavigationCard(
            context, 'Synonyms', '/synonyms', Icons.compare_arrows),
        _buildNavigationCard(context, 'Antonyms', '/antonyms', Icons.compare),
      ],
    );
  }

  Widget _buildNavigationCard(
      BuildContext context, String title, String route, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDarkMode
                  ? const [
                      Color(0xFF393E46),
                      Color(0xFF00ADB5),
                    ]
                  : const [
                      Color(0xFFDCD6F7),
                      Color(0xFF00ADB5),
                    ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: const Color(0xFFEEEEEE),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoxdropFilter extends BoxDecoration {
  const BoxdropFilter({
    super.color,
    super.borderRadius,
    Border? super.border,
    super.boxShadow,
    super.gradient,
  });
}
