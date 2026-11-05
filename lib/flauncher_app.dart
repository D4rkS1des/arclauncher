/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/actions.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'flauncher.dart';

class FLauncherApp extends StatelessWidget
{
  static const PrioritizedIntents _backIntents = PrioritizedIntents(orderedIntents: [
    DismissIntent(),
    BackIntent()
  ]);

  static const MaterialColor _swatch = MaterialColor(0xFF011526, <int, Color>{
    50: Color(0xFF36A0FA),
    100: Color(0xFF067BDE),
    200: Color(0xFF045CA7),
    300: Color(0xFF033662),
    400: Color(0xFF022544),
    500: Color(0xFF011526),
    600: Color(0xFF000508),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  });

  const FLauncherApp();

  static const String _fontFamily = 'Inter';

  /// Sets both the nominal weight and the variable font's 'wght' axis, so Inter renders the real
  /// weight instead of a synthesised bold on engines that do not map one to the other.
  static TextStyle? _w(TextStyle? style, FontWeight weight, {double? letterSpacing, Color? color, double? size}) =>
      style?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: weight,
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
        letterSpacing: letterSpacing,
        color: color,
        fontSize: size,
      );

  /// tvOS-like typography: heavy, tightly tracked titles; plain body text; quiet grey captions.
  static TextTheme _tvosTextTheme() {
    final base = Typography.material2018().white;
    return base.copyWith(
      displayLarge: _w(base.displayLarge, FontWeight.w700, letterSpacing: -1.0),
      displayMedium: _w(base.displayMedium, FontWeight.w700, letterSpacing: -0.8),
      displaySmall: _w(base.displaySmall, FontWeight.w700, letterSpacing: -0.6),
      headlineLarge: _w(base.headlineLarge, FontWeight.w700, letterSpacing: -0.6),
      headlineMedium: _w(base.headlineMedium, FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: _w(base.headlineSmall, FontWeight.w700, letterSpacing: -0.4),
      titleLarge: _w(base.titleLarge, FontWeight.w700, letterSpacing: -0.4, size: 22),
      titleMedium: _w(base.titleMedium, FontWeight.w600, letterSpacing: -0.2),
      titleSmall: _w(base.titleSmall, FontWeight.w600, letterSpacing: -0.1),
      bodyLarge: _w(base.bodyLarge, FontWeight.w400, letterSpacing: -0.1),
      bodyMedium: _w(base.bodyMedium, FontWeight.w400, letterSpacing: -0.1, size: 15),
      bodySmall: _w(base.bodySmall, FontWeight.w400, color: Colors.white.withValues(alpha: 0.6), size: 13),
      labelLarge: _w(base.labelLarge, FontWeight.w600, letterSpacing: 0),
      labelMedium: _w(base.labelMedium, FontWeight.w500, letterSpacing: 0),
      labelSmall: _w(base.labelSmall, FontWeight.w500, letterSpacing: 0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppsService appsService = context.read<AppsService>();
    LauncherState launcherState = context.read<LauncherState>();
    launcherState.refresh(appsService);

    return Selector<SettingsService, Color>(
      selector: (_, settings) => settings.accentColor,
      builder: (context, accentColor, _) {

        return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.escape): _backIntents,
        const SingleActivator(LogicalKeyboardKey.gameButtonB): _backIntents,
        const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent()
      },
      actions: {
        ...WidgetsApp.defaultActions,
        BackIntent: BackAction(context),
        DirectionalFocusIntent: SoundFeedbackDirectionalFocusAction(context)
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'FLauncher',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          fontFamily: _fontFamily,
          textTheme: _tvosTextTheme(),
          // Use ColorScheme based on accent color
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Brightness.dark,
            primary: accentColor,
            secondary: accentColor,
            surface: const Color(0xFF1E1E1E),
            background: const Color(0xFF121212),
          ),
          cardColor: const Color(0xFF1E1E1E), // Dark surface color
          canvasColor: const Color(0xFF121212),
          scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Revert to white for settings list
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              )
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xFF1E1E1E),
            titleTextStyle: _tvosTextTheme().titleLarge,
            contentTextStyle: _tvosTextTheme().bodyMedium,
          ),
          appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent),
          typography: Typography.material2018(),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            labelStyle: _tvosTextTheme().bodyMedium,
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: accentColor,
            selectionColor: accentColor.withOpacity(0.4),
            selectionHandleColor: accentColor,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(color: accentColor),
          sliderTheme: SliderThemeData(
            activeTrackColor: accentColor,
            thumbColor: accentColor,
            inactiveTrackColor: accentColor.withOpacity(0.3),
          ),
          toggleButtonsTheme: ToggleButtonsThemeData(
            selectedColor: accentColor,
            fillColor: accentColor.withOpacity(0.1),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return accentColor;
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return accentColor.withOpacity(0.5);
              return null;
            }),
          ), tabBarTheme: TabBarThemeData(indicatorColor: accentColor),
        ),
      home: Builder(
        builder: (context) => PopScope(
          canPop: false,
          child: ExcludeSemantics(
            child: FLauncher(),
          ),
          onPopInvoked: (didPop) {
            LauncherState launcherState = context.read<LauncherState>();
            launcherState.handleBackNavigation(context);
          }
        )
      ),
      );
    });
  }
}
