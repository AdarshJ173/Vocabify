import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ui'; // Add this import for ImageFilter
import 'package:vocabify/main.dart'; // Add this import for HomePage

class SettingsPage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '1.0.0';
  int _currentIndex = 1; // Set to 1 for settings page

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      // Fallback if package info fails
      if (mounted) {
        setState(() {
          _appVersion = '1.0.0';
        });
      }
    }
  }

  void _onTap(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            onThemeChanged: widget.onThemeChanged,
            isDarkMode: widget.isDarkMode,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
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
        backgroundColor: Color(0xFF00ADB5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isDarkMode
                ? const [Color(0xFF222831), Color(0xFF393E46)]
                : const [Color(0xFFF4EEFF), Color(0xFFDCD6F7)],
          ),
        ),
        child: ListView(
          children: [
            const _SettingsHeader(),
            const SizedBox(height: 16),
            _buildSettingsSection(
              title: 'Appearance',
              children: [_buildThemeToggle()],
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(
              title: 'Language',
              children: [_buildLanguageSelector()],
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(
              title: 'About',
              children: [_buildVersionTile()],
            ),
          ],
        ),
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
              decoration: BoxDecoration(
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
                currentIndex: _currentIndex,
                onTap: _onTap,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        size: 24,
                        color: widget.isDarkMode
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                      ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? const Color(0xFF00ADB5).withOpacity(0.2)
                            : const Color(0xFF424874).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        size: 28,
                      ),
                    ),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode
                  ? const Color(0xFF00ADB5)
                  : const Color(0xFF424874),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? const Color(0xFF393E46).withOpacity(0.9)
                : const Color(0xFFDCD6F7).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF00ADB5).withOpacity(0.2)
              : const Color(0xFF424874).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: widget.isDarkMode
              ? const Color(0xFF00ADB5)
              : const Color(0xFF424874),
        ),
      ),
      title: Text(
        'Dark Mode',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: widget.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        widget.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
        style: TextStyle(
          fontSize: 13,
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.6),
        ),
      ),
      trailing: Switch.adaptive(
        value: widget.isDarkMode,
        onChanged: widget.onThemeChanged,
        activeColor: const Color(0xFF00ADB5),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF00ADB5).withOpacity(0.2)
              : const Color(0xFF424874).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.language,
          color: widget.isDarkMode
              ? const Color(0xFF00ADB5)
              : const Color(0xFF424874),
        ),
      ),
      title: Text(
        'Language',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: widget.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        'English',
        style: TextStyle(
          fontSize: 13,
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.7)
            : Colors.black.withOpacity(0.6),
      ),
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF00ADB5).withOpacity(0.2)
              : const Color(0xFF424874).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.info_outline,
          color: widget.isDarkMode
              ? const Color(0xFF00ADB5)
              : const Color(0xFF424874),
        ),
      ),
      title: Text(
        'Version',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: widget.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        _appVersion,
        style: TextStyle(
          fontSize: 13,
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF00ADB5).withOpacity(0.2)
                  : const Color(0xFF424874).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings,
              size: 32,
              color: isDarkMode
                  ? const Color(0xFF00ADB5)
                  : const Color(0xFF424874),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your app experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
