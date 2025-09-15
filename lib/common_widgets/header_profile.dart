import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String? userImageUrl;
  final void Function(String) onMenuSelected;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const Header({
    super.key,
    this.userImageUrl,
    required this.onMenuSelected,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight + 18);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colors.surfaceContainer;
    final txtColor = textColor ?? colors.onSurface;
    final iconClr = iconColor ?? colors.onPrimary;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Finance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                height: 1.2,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage your financial transactions and reports',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: txtColor.withValues(alpha:0.73),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      toolbarHeight: kToolbarHeight + 18, // a little taller for the double-row header
      actions: [
        TextButton(
          onPressed: () => onMenuSelected('option1'),
          child: Text('Home', style: TextStyle(color: txtColor)),
        ),
        TextButton(
          onPressed: () => onMenuSelected('option2'),
          child: Text('About', style: TextStyle(color: txtColor)),
        ),
        TextButton(
          onPressed: () => onMenuSelected('option3'),
          child: Text('Contact', style: TextStyle(color: txtColor)),
        ),
        TextButton(
          onPressed: () => onMenuSelected('option4'),
          child: Text('Settings', style: TextStyle(color: txtColor)),
        ),
        PopupMenuButton<String>(
          tooltip: 'Profile',
          icon: ClipOval(
            child: Image.network(
              userImageUrl ??
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3i_qZtrjSgoPCyIOywhlX8MKOzRIaQbKU0A&s',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.surface,
                  child: Icon(Icons.person, color: iconClr),
                );
              },
            ),
          ),
          color: bgColor,
          onSelected: onMenuSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Text('Profile', style: TextStyle(color: txtColor)),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Text('Settings', style: TextStyle(color: txtColor)),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text('Logout', style: TextStyle(color: txtColor)),
            ),
          ],
        ),
      ],
    );
  }
}
