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

import 'dart:async';
import 'dart:math';

import 'package:flauncher/actions.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/app_image_type.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/app_card_contour_painter.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app.dart';
import '../models/category.dart';

const _validationKeys = [LogicalKeyboardKey.select, LogicalKeyboardKey.enter, LogicalKeyboardKey.gameButtonA];

const kAppCardAspectRatio = 16 / 9;
// Roomier gutters than stock FLauncher: the tvOS-style focus lift scales a card by
// _focusedScale, and it needs that much air to grow into without covering its neighbours.
const kAppCardHorizontalPadding = 16.0;
const kAppCardVerticalPadding = 12.0;
const kLauncherSectionHorizontalPadding = 32.0;
const kAppNameLabelHeight = 30.0;
const double kAppCardRadius = 14.0;

/// Row extent for a grid/dock line given the content width between section paddings.
double appCardRowExtentFromContentWidth(double contentWidth, {int columnCount = Category.ColumnsCount}) {
  final slotWidth = contentWidth / columnCount;
  return slotWidth / kAppCardAspectRatio;
}

/// Adjusted aspect ratio for grid cells that includes space for the app name label.
double appCardGridAspectRatio(double crossAxisExtent, int columnsCount) {
  final cellWidth = crossAxisExtent / columnsCount;
  return cellWidth / (cellWidth / kAppCardAspectRatio + kAppNameLabelHeight);
}

class AppCard extends StatefulWidget {
  final App application;
  final Category category;
  final bool autofocus;
  final void Function(AxisDirection) onMove;
  final VoidCallback onMoveEnd;
  final bool handleUpNavigationToSettings;
  final double scrollAlignment;
  final bool enforceAspectRatio;
  final VoidCallback? onFocused;
  final bool ensureVisibleOnFocus;
  final bool onlyScrollWhenNearBottom;

  const AppCard({
    super.key,
    required this.application,
    required this.category,
    required this.autofocus,
    required this.onMove,
    required this.onMoveEnd,
    this.handleUpNavigationToSettings = false,
    this.scrollAlignment = 0.5,
    this.enforceAspectRatio = true,
    this.onFocused,
    this.ensureVisibleOnFocus = true,
    this.onlyScrollWhenNearBottom = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with TickerProviderStateMixin {
  /// Direction of the last D-pad move made from a card, so the card that receives focus can
  /// swing in from that side (the tvOS "parallax" nudge). Shared by all cards on purpose.
  static AxisDirection? _lastNavDirection;

  bool _moving = false;
  bool _clicked = false;
  bool _isFocused = false;
  bool _isTraditionalHighlightMode = false;
  bool _isHighlightAnimating = false;
  bool _animationEnabled = false;
  String? _accentColorHex;
  Color _accentColor = const Color(0xFF000000);
  DateTime? _lastMoveAt;
  DateTime? _lastEnsureVisibleAt;
  late FocusNode _focusNode;

  (AppImageType, ImageProvider)? _loadedImage;
  bool _imageLoadError = false;

  late final AnimationController _animation;

  late final CurvedAnimation _curvedAnimation;
  static const double _focusedScale = 1.13;
  static const Duration _focusAnimationDuration = Duration(milliseconds: 220);

  /// Swing-in tilt played when focus arrives (0 → 1), and the side it swings from.
  late final AnimationController _tilt;
  Offset _tiltFrom = Offset.zero;

  /// One-shot specular sweep across the card when it gains focus.
  late final AnimationController _sheen;

  /// Slow, endless 'breathing' of the focused tile's light and shadow, so it feels alive.
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _tilt = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);
    _sheen = AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: 1);
    _breath = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _curvedAnimation = CurvedAnimation(parent: _animation, curve: Curves.easeInOut);
    _focusNode = FocusNode();
    _isTraditionalHighlightMode = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

    FocusManager.instance.addHighlightModeListener(_focusHighlightModeChanged);
    _loadAppImage(Provider.of<AppsService>(context, listen: false));

    // Check if we need to restore focus/reorder mode after a move
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appsService = Provider.of<AppsService>(context, listen: false);
      if (appsService.pendingReorderFocusPackage == widget.application.packageName &&
          appsService.pendingReorderFocusCategoryId == widget.category.id) {
        appsService.clearPendingReorderFocusPackage();
        _focusNode.requestFocus();

        setState(() {
          _moving = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AppCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final appsService = Provider.of<AppsService>(context, listen: false);

    if (oldWidget.application.packageName != widget.application.packageName) {
      _loadedImage = null;
      _imageLoadError = false;
      _loadAppImage(appsService);
    } else if (appsService.consumeDirtyImage(widget.application.packageName)) {
      _loadAppImage(appsService);
    }

    // Check for pending focus on update as well
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appsService = Provider.of<AppsService>(context, listen: false);
      if (appsService.pendingReorderFocusPackage == widget.application.packageName &&
          appsService.pendingReorderFocusCategoryId == widget.category.id) {
        appsService.clearPendingReorderFocusPackage();
        _focusNode.requestFocus();

        if (!_moving) {
          setState(() {
            _moving = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_focusHighlightModeChanged);
    _curvedAnimation.dispose();
    _animation.dispose();
    _tilt.dispose();
    _sheen.dispose();
    _breath.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppNames = context.select<SettingsService, bool>((s) => s.showAppNamesBelowIcons);
    final bool tvos = context.select<SettingsService, bool>((s) => s.tvosStyleEnabled);
    final (bool animationEnabled, String accentColorHex, bool showFocusBorders, double borderThickness) = context.select<SettingsService, (bool, String, bool, double)>(
      (s) => (s.appHighlightAnimationEnabled, s.accentColorHex, s.showFocusBorders, s.focusBorderThickness),
    );
    if (accentColorHex != _accentColorHex) {
      _accentColorHex = accentColorHex;
      _accentColor = Color(int.parse('FF$accentColorHex', radix: 16));
    }
    if (animationEnabled != _animationEnabled) {
      _animationEnabled = animationEnabled;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateHighlightAnimation();
      });
    }
    final appImageWidget = _appImage();
    final bool shouldHighlight = _shouldHighlight();

    return FocusKeyboardListener(
      onPressed: _onPressed,
      onLongPress: _onLongPress,
      child: AnimatedScale(
        // tvOS press: a short, firm push-in, then the tile springs back
        scale: _clicked ? 0.94 : 1.0,
        duration: Duration(milliseconds: _clicked ? 110 : 320),
        curve: _clicked ? Curves.easeOutCubic : Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: _wrapAspectRatio(
                  RepaintBoundary(
                    child: _TvosTilt(
                      animation: _tilt,
                      from: tvos ? _tiltFrom : Offset.zero,
                      child: AnimatedScale(
                      scale: !_moving && shouldHighlight ? _focusedScale : 1.0,
                      duration: _focusAnimationDuration,
                      alignment: Alignment.center,
                      curve: Curves.easeOutCubic,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Lift: a soft, wide shadow that drops further when focused
                          AnimatedContainer(
                            duration: _focusAnimationDuration,
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kAppCardRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: shouldHighlight ? 0.55 : 0.30),
                                  blurRadius: shouldHighlight ? 30 : 10,
                                  offset: Offset(0, shouldHighlight ? 18 : 4),
                                ),
                              ],
                            ),
                          ),
                          // A second, wider shadow that slowly breathes while the tile is focused
                          if (tvos)
                            IgnorePointer(
                              child: AnimatedOpacity(
                                duration: _focusAnimationDuration,
                                opacity: shouldHighlight && !_moving ? 1.0 : 0.0,
                                child: AnimatedBuilder(
                                  animation: _breath,
                                  builder: (context, _) {
                                    final b = Curves.easeInOut.transform(_breath.value);
                                    return DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(kAppCardRadius),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.16 + 0.10 * b),
                                            blurRadius: 34 + 14 * b,
                                            offset: Offset(0, 22 + 6 * b),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          Material(
                            borderRadius: BorderRadius.circular(kAppCardRadius),
                            clipBehavior: Clip.antiAlias,
                            elevation: 0,
                            color: const Color(0xFF2C2C2E),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                InkWell(
                                  focusNode: _focusNode,
                                  autofocus: widget.autofocus,
                                  focusColor: Colors.transparent,
                                  child: appImageWidget,
                                  onTap: () => _onPressed(LogicalKeyboardKey.enter),
                                  onLongPress: () => _onLongPress(LogicalKeyboardKey.enter),
                                  onFocusChange: (focused) {
                                    _handleFocusChange(context, focused);
                                  },
                                ),
                                if (_moving) ..._arrows(),
                                // Unfocused cards sit slightly back, so the focused one reads as lit
                                IgnorePointer(
                                  child: AnimatedOpacity(
                                    duration: _focusAnimationDuration,
                                    curve: Curves.easeInOut,
                                    opacity: shouldHighlight ? 0.0 : 1.0,
                                    child: const ColoredBox(color: Color(0x26000000)),
                                  ),
                                ),
                                // Glass: a soft top-light plus a one-off sweep when focus lands
                                if (tvos && shouldHighlight && !_moving)
                                  IgnorePointer(
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                        animation: Listenable.merge([_sheen, _breath]),
                                        builder: (context, _) => CustomPaint(
                                          painter: _TvosGlarePainter(
                                            progress: _sheen.value,
                                            breath: Curves.easeInOut.transform(_breath.value),
                                          ),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if ((shouldHighlight && showFocusBorders) || _moving)
                            if (animationEnabled && !_moving)
                              IgnorePointer(
                                child: RepaintBoundary(
                                  child: AnimatedBuilder(
                                    animation: _curvedAnimation,
                                    builder: (context, _) {
                                      final alpha = 0.65 + (_animation.value * 0.35);
                                      return _HighlightOutline(
                                        accentColor: _accentColor,
                                        alpha: alpha,
                                        strokeWidth: borderThickness,
                                      );
                                    },
                                  ),
                                ),
                              )
                            else
                              IgnorePointer(
                                child: RepaintBoundary(
                                  child: _HighlightOutline(
                                    accentColor: _accentColor,
                                    isMoving: _moving,
                                    strokeWidth: borderThickness,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                    ),
                ),
                ),
              ),
              // tvOS shows the name only under the focused tile, below its lifted shadow
              if (showAppNames)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: AnimatedOpacity(
                    duration: _focusAnimationDuration,
                    opacity: !tvos || (shouldHighlight && !_moving) ? 1.0 : 0.0,
                    child: _AppNameLabel(name: widget.application.name),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadAppImage(AppsService service) async {
    try {
      Uint8List bytes = Uint8List(0);

      bytes = await service.getAppBanner(widget.application.packageName);
      AppImageType type = AppImageType.Banner;
      if (bytes.isEmpty) {
        type = AppImageType.Icon;
        bytes = await service.getAppIcon(widget.application.packageName);
      }
      if (mounted) {
        setState(() {
          _loadedImage = (type, ResizeImage(MemoryImage(bytes), width: 480));
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _imageLoadError = true);
      }
    }
  }

  Widget _wrapAspectRatio(Widget child) {
    if (widget.enforceAspectRatio) {
      return AspectRatio(aspectRatio: kAppCardAspectRatio, child: child);
    }
    return child;
  }

  Widget _appImage() {
    App app = widget.application;

    if (_loadedImage != null) {
      final (type, image) = _loadedImage!;
      if (type == AppImageType.Banner) {
        return Ink.image(image: image, fit: BoxFit.cover);
      } else {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(flex: 2, child: Ink.image(image: image, height: double.maxFinite)),
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    app.name,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (_imageLoadError) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            app.name,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.loading),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _focusHighlightModeChanged(FocusHighlightMode mode) {
    final nextMode = mode == FocusHighlightMode.traditional;
    if (nextMode == _isTraditionalHighlightMode) {
      return;
    }
    setState(() {
      _isTraditionalHighlightMode = nextMode;
    });
    _updateHighlightAnimation();
  }

  bool _shouldHighlight() {
    return _isTraditionalHighlightMode && _isFocused;
  }

  void _handleFocusChange(BuildContext context, bool focused) {
    if (_isFocused != focused) {
      setState(() {
        _isFocused = focused;
        if (focused) {
          // Swing in from the side the user came from, settling with a small overshoot
          switch (_lastNavDirection) {
            case AxisDirection.right:
              _tiltFrom = const Offset(-1, 0);
            case AxisDirection.left:
              _tiltFrom = const Offset(1, 0);
            case AxisDirection.down:
              _tiltFrom = const Offset(0, -1);
            case AxisDirection.up:
              _tiltFrom = const Offset(0, 1);
            case null:
              _tiltFrom = Offset.zero;
          }
        }
      });
      if (focused) {
        _tilt.forward(from: 0);
        _sheen.forward(from: 0);
        if (context.read<SettingsService>().tvosStyleEnabled) {
          _breath.repeat(reverse: true);
        }
      } else {
        _breath.stop();
        _breath.value = 0;
      }
    }
    _updateHighlightAnimation();

    if (!focused) {
      return;
    }

    final now = DateTime.now();
    if (_lastEnsureVisibleAt != null && now.difference(_lastEnsureVisibleAt!).inMilliseconds < 120) {
      return;
    }
    _lastEnsureVisibleAt = now;
    if (widget.ensureVisibleOnFocus) {
      _ensureVisibleIfNeeded(
        context,
        // This specific alignment value is not only
        // to center the focused card in the row while
        // scrolling, but to prevent the topmost category
        // title to be hidden by the content above it when
        // scrolling from the app bar. How it relates to this,
        // I don't know
        alignment: widget.scrollAlignment,
        onlyWhenNearBottom: widget.onlyScrollWhenNearBottom,
      );
    }
    widget.onFocused?.call();
  }

  void _updateHighlightAnimation() {
    _setHighlightAnimation(_shouldHighlight() && _animationEnabled);
  }

  void _setHighlightAnimation(bool shouldAnimate) {
    if (_isHighlightAnimating == shouldAnimate) {
      return;
    }
    _isHighlightAnimating = shouldAnimate;
    if (shouldAnimate) {
      _animation.repeat(reverse: true);
    } else {
      _animation.stop();
    }
  }

  void _ensureVisibleIfNeeded(BuildContext context, {required double alignment, bool onlyWhenNearBottom = false}) {
    final renderObject = context.findRenderObject();
    final scrollable = Scrollable.maybeOf(context);
    if (renderObject == null || scrollable == null) {
      return;
    }

    final viewport = RenderAbstractViewport.of(renderObject);

    final position = scrollable.position;
    const minDeltaToScroll = 24.0;
    if (onlyWhenNearBottom &&
        (position.axisDirection == AxisDirection.down || position.axisDirection == AxisDirection.up)) {
      const topEdgePadding = kToolbarHeight + 24.0;
      const bottomEdgePadding = 96.0;
      final topTargetOffset = (viewport.getOffsetToReveal(renderObject, 0).offset - topEdgePadding).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (position.pixels - topTargetOffset >= minDeltaToScroll) {
        position.animateTo(
          topTargetOffset,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 220),
        );
        return;
      }

      final bottomTargetOffset = (viewport.getOffsetToReveal(renderObject, 1).offset + bottomEdgePadding).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (bottomTargetOffset - position.pixels < minDeltaToScroll) {
        return;
      }

      position.animateTo(
        bottomTargetOffset,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 220),
      );
      return;
    }

    final targetOffset = viewport.getOffsetToReveal(renderObject, alignment).offset;
    if ((targetOffset - position.pixels).abs() < minDeltaToScroll) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      alignment: alignment,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 220),
    );
  }

  List<Widget> _arrows() {
    final arrows = <Widget>[
      _arrow(Alignment.centerLeft, Icons.keyboard_arrow_left, () {
        widget.onMove(AxisDirection.left);
      }),
      _arrow(Alignment.centerRight, Icons.keyboard_arrow_right, () {
        widget.onMove(AxisDirection.right);
      }),
    ];

    // Only show Up/Down arrows for grid layouts
    if (widget.category.type == CategoryType.grid) {
      arrows.add(
        _arrow(Alignment.topCenter, Icons.keyboard_arrow_up, () {
          widget.onMove(AxisDirection.up);
        }),
      );
      arrows.add(
        _arrow(Alignment.bottomCenter, Icons.keyboard_arrow_down, () {
          widget.onMove(AxisDirection.down);
        }),
      );
    }

    return arrows;
  }

  Widget _arrow(Alignment alignment, IconData icon, VoidCallback onTap) => Align(
    alignment: alignment,
    child: Ink(
      decoration: ShapeDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), shape: CircleBorder()),
      child: SizedBox(
        height: 36,
        width: 36,
        child: IconButton(icon: Icon(icon, size: 24), onPressed: onTap, padding: EdgeInsets.all(0)),
      ),
    ),
  );

  KeyEventResult _onPressed(LogicalKeyboardKey? key) {
    if (_moving) {
      if (_validationKeys.contains(key) || key == LogicalKeyboardKey.escape) {
        _lastMoveAt = null;
        setState(() => _moving = false);
        widget.onMoveEnd();
      } else {
        final now = DateTime.now();
        if (_lastMoveAt != null && now.difference(_lastMoveAt!).inMilliseconds < 60) {
          return KeyEventResult.handled;
        }

        if (key == LogicalKeyboardKey.arrowLeft) {
          widget.onMove(AxisDirection.left);
        } else if (key == LogicalKeyboardKey.arrowUp) {
          widget.onMove(AxisDirection.up);
        } else if (key == LogicalKeyboardKey.arrowRight) {
          widget.onMove(AxisDirection.right);
        } else if (key == LogicalKeyboardKey.arrowDown) {
          widget.onMove(AxisDirection.down);
        } else {
          return KeyEventResult.ignored;
        }

        _lastMoveAt = now;
        final nowForScroll = DateTime.now();
        if (_lastEnsureVisibleAt == null || nowForScroll.difference(_lastEnsureVisibleAt!).inMilliseconds >= 120) {
          _lastEnsureVisibleAt = nowForScroll;
          WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisibleIfNeeded(context, alignment: 0.1));
        }
      }

      return KeyEventResult.handled;
    }

    switch (key) {
      case LogicalKeyboardKey.arrowLeft:
        _lastNavDirection = AxisDirection.left;
      case LogicalKeyboardKey.arrowRight:
        _lastNavDirection = AxisDirection.right;
      case LogicalKeyboardKey.arrowUp:
        _lastNavDirection = AxisDirection.up;
      case LogicalKeyboardKey.arrowDown:
        _lastNavDirection = AxisDirection.down;
    }

    if (_validationKeys.contains(key)) {
      if (!_clicked) {
        setState(() => _clicked = true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          context.read<AppsService>().launchApp(widget.application);
          // Reset after a short delay so it looks normal when user returns
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _clicked = false);
            }
          });
        });
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp && widget.handleUpNavigationToSettings) {
      Actions.invoke(context, const MoveFocusToSettingsIntent());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onLongPress(LogicalKeyboardKey? key) {
    if (!_moving && (key == null || longPressableKeys.contains(key))) {
      _showPanel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _showPanel() async {
    final result = await showDialog<ApplicationInfoPanelResult>(
      context: context,
      builder: (context) => ApplicationInfoPanel(category: widget.category, application: widget.application),
    );
    if (result == ApplicationInfoPanelResult.reorderApp) {
      setState(() => _moving = true);
    }
  }
}

class _AppNameLabel extends StatelessWidget {
  final String name;

  const _AppNameLabel({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.92),
        shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }
}

/// Small 3D swing applied when a card gains focus: it starts tilted towards the side focus came
/// from and settles flat with a slight overshoot, which is what makes tvOS tiles feel physical.
class _TvosTilt extends StatelessWidget {
  final Animation<double> animation;
  final Offset from;
  final Widget child;

  const _TvosTilt({required this.animation, required this.from, required this.child});

  static const double _maxAngle = 0.14; // radians, ~8 degrees

  @override
  Widget build(BuildContext context) {
    if (from == Offset.zero) return child;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        if (t >= 1.0) return child!;
        // 1 → 0 with a little overshoot past flat on the way
        final remaining = 1.0 - Curves.easeOutBack.transform(t);
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // perspective
          ..rotateY(from.dx * _maxAngle * remaining)
          ..rotateX(-from.dy * _maxAngle * remaining);
        return Transform(transform: transform, alignment: Alignment.center, child: child);
      },
    );
  }
}

/// The glassy finish on a focused tile: a constant soft light from the top edge plus a diagonal
/// highlight that sweeps across once when focus arrives ([progress] 0 → 1).
class _TvosGlarePainter extends CustomPainter {
  final double progress;
  final double breath;

  const _TvosGlarePainter({required this.progress, this.breath = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final topLight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [Colors.white.withValues(alpha: 0.12 + 0.08 * breath), Colors.white.withValues(alpha: 0.0)],
      ).createShader(rect);
    canvas.drawRect(rect, topLight);

    if (progress < 1.0) {
      // Band travels from beyond the top-left corner to beyond the bottom-right one
      final eased = Curves.easeInOutCubic.transform(progress);
      final center = -0.6 + eased * 2.2;
      final fade = progress < 0.85 ? 1.0 : (1.0 - progress) / 0.15;
      final sweep = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [
            (center - 0.18).clamp(0.0, 1.0),
            center.clamp(0.0, 1.0),
            (center + 0.18).clamp(0.0, 1.0),
          ],
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.28 * fade),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect);
      canvas.drawRect(rect, sweep);
    }
  }

  @override
  bool shouldRepaint(_TvosGlarePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.breath != breath;
}

class _HighlightOutline extends StatelessWidget {
  final Color accentColor;
  final double alpha;
  final bool isMoving;
  final double strokeWidth;

  const _HighlightOutline({
    required this.accentColor,
    this.alpha = 1.0,
    this.isMoving = false,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: AppCardContourPainter(
        radius: kAppCardRadius,
        strokeWidth: isMoving ? max(2.0, strokeWidth + 0.5) : strokeWidth,
        accentColor: accentColor,
        alpha: alpha,
        isMoving: isMoving,
      ),
      child: const SizedBox.expand(),
    );
  }
}
