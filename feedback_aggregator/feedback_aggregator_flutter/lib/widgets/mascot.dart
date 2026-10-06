import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Row-major order of the cells in the directions sheet.
enum _Direction {
  upLeft,
  up,
  upRight,
  left,
  center,
  right,
  downLeft,
  down,
  downRight,
}

// The reactions sheet's cells that a boop shows. The others are surprised,
// wink, bashful and sleepy.
enum _Reaction {
  blink(0),
  heart(1),
  sparkle(2),
  dizzy(7),
  delighted(8);

  const _Reaction(this.cell);

  final int cell;
}

// Clockwise from the right, matching atan2 with y pointing down.
const _clockwise = [
  _Direction.right,
  _Direction.downRight,
  _Direction.down,
  _Direction.downLeft,
  _Direction.left,
  _Direction.upLeft,
  _Direction.up,
  _Direction.upRight,
];
final _sectorAngle = math.pi * 2 / _clockwise.length;
const _hysteresis = 0.12;
const _deadZone = 70.0;

const _payoffs = [_Reaction.heart, _Reaction.sparkle, _Reaction.delighted];
const _boopPayoff = Duration(milliseconds: 120);
const _boopEnd = Duration(milliseconds: 560);
const _squashDuration = Duration(milliseconds: 420);
const _dizzyAfter = 4;
const _dizzyWindow = Duration(milliseconds: 1600);
const _dizzyEnd = Duration(milliseconds: 1100);

// Each curve runs from its keyframe to the next, with the controller itself
// linear: a curve on the whole animation would front-load the bounce.
final _squash = TweenSequence<Offset>([
  _keyframe(const Offset(1, 1), const Offset(1.10, 0.86), Curves.easeIn, 18),
  _keyframe(
    const Offset(1.10, 0.86),
    const Offset(0.95, 1.08),
    Curves.easeOut,
    27,
  ),
  _keyframe(
    const Offset(0.95, 1.08),
    const Offset(1.03, 0.97),
    Curves.easeInOut,
    27,
  ),
  _keyframe(const Offset(1.03, 0.97), const Offset(1, 1), Curves.easeInOut, 28),
]);

TweenSequenceItem<Offset> _keyframe(
  Offset from,
  Offset to,
  Curve curve,
  double weight,
) => TweenSequenceItem(
  tween: Tween(begin: from, end: to).chain(CurveTween(curve: curve)),
  weight: weight,
);

// With the sheet drawn at three times the box, -1/0/1 picks the column and row.
Alignment _cell(int index) => Alignment(index % 3 - 1.0, index ~/ 3 - 1.0);

double _wrap(double angle) => math.atan2(math.sin(angle), math.cos(angle));

/// A character whose head turns toward the mouse and reacts when tapped.
///
/// [directions] and [reactions] are asset paths of its two 3×3 sprite sheets:
/// nine head directions and nine expressions.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    required this.directions,
    required this.reactions,
    this.size = 140,
    this.label = 'mascot',
  });

  final String directions;
  final String reactions;
  final double size;

  /// What a screen reader calls it.
  final String label;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final _squashController = AnimationController(
    vsync: this,
    duration: _squashDuration,
  );
  late final _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _boop()),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _boop(),
    ),
  };
  final _timers = <Timer>[];
  var _boops = 0;
  var _boopAt = DateTime.fromMillisecondsSinceEpoch(0);
  var _direction = _Direction.center;
  _Reaction? _reaction;
  var _sector = -1;
  Offset? _pointer;
  ScrollPosition? _scroll;
  var _focused = false;

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scroll = Scrollable.maybeOf(context)?.position;
    if (scroll != _scroll) {
      _scroll?.removeListener(_onScroll);
      _scroll = scroll?..addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    _scroll?.removeListener(_onScroll);
    _cancelTimers();
    _squashController.dispose();
    super.dispose();
  }

  void _onPointer(PointerEvent event) {
    // Touch has no hover to follow, so the head stays facing forward.
    if (event.kind != PointerDeviceKind.mouse) return;
    if (event is! PointerHoverEvent && event is! PointerMoveEvent) return;
    _pointer = event.position;
    _aim();
  }

  // The page can scroll under a still mouse. Measure once the new offset is
  // laid out.
  void _onScroll() => SchedulerBinding.instance.addPostFrameCallback((_) {
    if (mounted) _aim();
  });

  void _aim() {
    final pointer = _pointer;
    final box = context.findRenderObject() as RenderBox?;
    if (pointer == null || box == null || !box.attached || !box.hasSize) {
      return;
    }

    final delta = pointer - box.localToGlobal(box.size.center(Offset.zero));
    if (delta.distance < _deadZone) {
      _sector = -1;
      _turn(_Direction.center);
      return;
    }

    // Hold the current sector until the pointer is well past its edge.
    final angle = delta.direction;
    if (_sector != -1 &&
        _wrap(angle - _sector * _sectorAngle).abs() <
            _sectorAngle / 2 + _hysteresis) {
      return;
    }

    _sector = (angle / _sectorAngle).round() % _clockwise.length;
    _turn(_clockwise[_sector]);
  }

  void _turn(_Direction direction) {
    if (direction != _direction) setState(() => _direction = direction);
  }

  void _boop() {
    _cancelTimers();

    final now = DateTime.now();
    _boops = now.difference(_boopAt) < _dizzyWindow ? _boops + 1 : 1;
    _boopAt = now;

    if (_boops >= _dizzyAfter) {
      _boops = 0;
      _react(_Reaction.dizzy);
      _later(_dizzyEnd, null);
    } else {
      _react(_Reaction.blink);
      _later(_boopPayoff, _payoffs[(_boops - 1) % _payoffs.length]);
      _later(_boopEnd, null);
    }

    if (MediaQuery.disableAnimationsOf(context)) return;
    _squashController.forward(from: 0);
  }

  void _react(_Reaction? reaction) => setState(() => _reaction = reaction);

  void _later(Duration delay, _Reaction? next) =>
      _timers.add(Timer(delay, () => _react(next)));

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  Widget _sheet(String asset, int index, bool visible) {
    final sheet = widget.size * 3;
    return Opacity(
      opacity: visible ? 1 : 0,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: sheet,
          maxHeight: sheet,
          alignment: _cell(index),
          child: Image.asset(
            asset,
            width: sheet,
            height: sheet,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Boop the ${widget.label}',
      onTap: _boop,
      excludeSemantics: true,
      child: FocusableActionDetector(
        actions: _actions,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        child: GestureDetector(
          onTap: _boop,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: _focused
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: SizedBox.square(
              dimension: widget.size,
              child: AnimatedBuilder(
                animation: _squashController,
                builder: (context, child) {
                  final scale = _squash.evaluate(_squashController);
                  return Transform.scale(
                    scaleX: scale.dx,
                    scaleY: scale.dy,
                    alignment: const Alignment(0, 0.56),
                    child: child,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _sheet(
                      widget.directions,
                      _direction.index,
                      _reaction == null,
                    ),
                    // Always built so the sheet loads up front, never on the
                    // first tap.
                    _sheet(
                      widget.reactions,
                      (_reaction ?? _Reaction.blink).cell,
                      _reaction != null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
