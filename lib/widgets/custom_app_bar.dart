import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final int? currentQuestionIndex;
  final int? totalQuestions;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    this.currentQuestionIndex,
    this.totalQuestions,
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
          bottom: Radius.circular(16),
        ),
      ),
      backgroundColor: const Color(0xFF00ADB5),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFFEEEEEE),
          size: 22,
        ),
        onPressed: onBackPressed,
      ),
      actions: currentQuestionIndex != null && totalQuestions != null
          ? [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'Q${currentQuestionIndex! + 1}/$totalQuestions',
                    style: const TextStyle(
                      color: Color(0xFFEEEEEE),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
