import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulso/core/providers/theme_provider.dart';
import 'package:pulso/core/router/app_router.dart';
import 'package:pulso/features/auth/providers/auth_providers.dart';

class PulsoApp extends ConsumerWidget {
  const PulsoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authSessionProvider);
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    const primary = Color(0xFFE91E63);
    const darkPink = Color(0xFFC2185B);
    const darkText = Color(0xFF1F2937);
    const secondaryText = Color(0xFF4B5563);
    const placeholderText = Color(0xFF6B7280);

    return MaterialApp.router(
      title: 'StudyGram',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: darkPink,
          onSurface: darkText,
          onSurfaceVariant: secondaryText,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF1F5),
        textTheme: ThemeData.light()
            .textTheme
            .apply(
              bodyColor: darkText,
              displayColor: darkText,
            )
            .copyWith(
              headlineSmall:
                  ThemeData.light().textTheme.headlineSmall?.copyWith(
                        color: darkText,
                        fontWeight: FontWeight.w800,
                      ),
              titleLarge: ThemeData.light().textTheme.titleLarge?.copyWith(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                  ),
              titleMedium: ThemeData.light().textTheme.titleMedium?.copyWith(
                    color: darkText,
                    fontWeight: FontWeight.w700,
                  ),
              bodyMedium: ThemeData.light().textTheme.bodyMedium?.copyWith(
                    color: darkText,
                    fontWeight: FontWeight.w500,
                  ),
              bodySmall: ThemeData.light().textTheme.bodySmall?.copyWith(
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
              labelLarge: ThemeData.light().textTheme.labelLarge?.copyWith(
                    color: darkText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
        iconTheme: const IconThemeData(color: darkText),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shadowColor: primary.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
          ),
          floatingLabelStyle: const TextStyle(
            color: darkPink,
            fontWeight: FontWeight.w800,
          ),
          hintStyle: const TextStyle(
            color: placeholderText,
            fontWeight: FontWeight.w500,
          ),
          helperStyle: const TextStyle(
            color: secondaryText,
            fontWeight: FontWeight.w500,
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFB91C1C),
            fontWeight: FontWeight.w700,
          ),
          prefixIconColor: secondaryText,
          suffixIconColor: secondaryText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: primary, width: 1.6),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primary,
          selectionColor: Color(0xFFFFC4D8),
          selectionHandleColor: darkPink,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: darkPink,
            side: const BorderSide(color: darkPink, width: 1.2),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkPink,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFD7E4),
          selectedColor: primary,
          labelStyle: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
          ),
          secondaryLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return darkText;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return primary;
              return Colors.white;
            }),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w800),
            ),
            iconColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return darkPink;
            }),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFD7E4),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: darkPink);
            }
            return const IconThemeData(color: secondaryText);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? darkPink
                : secondaryText;
            return TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            );
          }),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: darkText,
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
          contentTextStyle: TextStyle(
            color: darkText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          modalBackgroundColor: Colors.white,
          dragHandleColor: secondaryText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF1F5),
          foregroundColor: darkText,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
