import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudygramColors {
  static const primary = Color(0xFFE91E63);
  static const darkPink = Color(0xFFC2185B);
  static const softPink = Color(0xFFFFF1F5);
  static const lightGray = Color(0xFFF5F7FA);
  static const darkText = Color(0xFF2D2D2D);
  static const secondaryText = Color(0xFF777777);
}

BoxDecoration softCardDecoration({Color color = Colors.white}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: StudygramColors.primary.withOpacity(0.10),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

LinearGradient pinkPageGradient() {
  return const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE4EE),
      Color(0xFFFFF1F5),
      Color(0xFFF5F7FA),
    ],
  );
}

class StudygramLogo extends StatelessWidget {
  const StudygramLogo({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StudygramColors.primary, StudygramColors.darkPink],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: StudygramColors.primary.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.school_rounded,
        color: Colors.white,
        size: size * 0.56,
      ),
    );
  }
}

class StudygramHeader extends StatelessWidget {
  const StudygramHeader({
    super.key,
    this.trailing,
    this.showBack = false,
    this.title = 'StudyGram',
  });

  final Widget? trailing;
  final bool showBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/feed');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
            )
          else
            const StudygramLogo(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: StudygramColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class StudygramBottomNav extends StatelessWidget {
  const StudygramBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/feed');
            break;
          case 1:
            context.go('/search');
            break;
          case 2:
            context.push('/compose');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline_rounded),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Create',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class StudyThumbnail extends StatelessWidget {
  const StudyThumbnail({
    super.key,
    required this.icon,
    this.width,
    this.height,
  });

  final IconData icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD7E4), Color(0xFFFFF1F5)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: StudygramColors.primary, size: 38),
    );
  }
}

class SubjectPill extends StatelessWidget {
  const SubjectPill({
    super.key,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: StudygramColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : StudygramColors.secondaryText,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    );
  }
}
