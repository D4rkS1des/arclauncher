import 'dart:ui' as ui;

import 'package:flauncher/actions.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings/settings_theme.dart';

/// The sliding settings surface.
///
/// Classic look: a soft dark gradient with a faint accent glow in the top corner and a single
/// specular hairline on the inner edge, without [BackdropFilter] or shadows.
///
/// tvOS look ([SettingsService.tvosStyleEnabled]): a floating sheet inset from the screen edges,
/// rounded on every corner, made of dark frosted glass over a blurred view of the home screen.
/// The blur is a live [BackdropFilter], but the panel is static apart from focus moves, so it
/// only re-blurs during those short animations.
class SidePanelDialog extends StatelessWidget {
  final Widget child;
  final double width;
  final bool isRightSide;

  const SidePanelDialog({
    required this.child,
    this.width = 250,
    this.isRightSide = false,
  });

  static const double _tvosInset = 28;
  static const double _tvosRadius = 30;

  @override
  Widget build(BuildContext context) {
    final tvos = context.select<SettingsService, bool>((s) => s.tvosStyleEnabled);
    return tvos ? _tvosPanel(context) : _classicPanel(context);
  }

  Widget _content(BuildContext context) => Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Actions(
            actions: {BackIntent: BackAction(context)},
            child: child,
          ),
        ),
      );

  Widget _tvosPanel(BuildContext context) {
    final radius = BorderRadius.circular(_tvosRadius);
    return Align(
      alignment: isRightSide ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(_tvosInset),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 16))],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: SizedBox(
                width: width,
                child: Stack(
                  children: [
                    // Frosted dark material, slightly lighter at the top like tvOS sheets
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xB83A3A3C), Color(0xC71C1C1E)],
                          ),
                        ),
                      ),
                    ),
                    // Thin light rim along the edge of the glass
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                          ),
                        ),
                      ),
                    ),
                    _content(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _classicPanel(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.horizontal(
      right: isRightSide ? Radius.zero : const Radius.circular(SettingsStyle.panelRadius),
      left: isRightSide ? const Radius.circular(SettingsStyle.panelRadius) : Radius.zero,
    );

    return Align(
      alignment: isRightSide ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [SettingsStyle.panelTop, SettingsStyle.panelBottom],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: isRightSide ? const Alignment(1, -1.2) : const Alignment(-1, -1.2),
                        radius: 1.4,
                        colors: [
                          accentColor.withValues(alpha: 0.20),
                          accentColor.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: isRightSide ? 0 : null,
                right: isRightSide ? null : 0,
                child: Container(width: 1, color: Colors.white.withValues(alpha: 0.08)),
              ),
              _content(context),
            ],
          ),
        ),
      ),
    );
  }
}
