import 'package:flutter/material.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  
  const SharedAppBar({
    super.key, 
    required this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
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
      leading: showBackButton ? IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Color(0xFFEEEEEE),
        ),
        onPressed: () => Navigator.pop(context),
      ) : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 