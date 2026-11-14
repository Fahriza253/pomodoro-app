import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/tag/system_tags.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/app_layout.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/tag/tag_error_messages.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';
import 'package:pomodoro_app/presentation/timer/widgets/mode_selector.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_swipe_actions.dart';

const _kSheetMotion = Duration(milliseconds: 240);
const _kSheetHeightFraction = 0.52;
const _kActionSize = 48.0;
const _kActionGap = 8.0;
const _kActionPad = 8.0;
const _kBarrierMaxOpacity = 0.45;
const _kDismissFraction = 0.5;

@visibleForTesting
double tagSelectPanelProgressFromDrag({
  required double current,
  required double deltaDy,
  required double sheetHeight,
}) {
  if (sheetHeight <= 0) {
    return current.clamp(0.0, 1.0);
  }
  return (current - deltaDy / sheetHeight).clamp(0.0, 1.0);
}

@visibleForTesting
Duration tagSelectPanelSnapDuration(double from, double to) {
  final travel = (from - to).abs().clamp(0.0, 1.0);
  return Duration(milliseconds: (240 * travel).round().clamp(120, 240));
}

sealed class _TagSelectOutcome {
  const _TagSelectOutcome();
}

class _TagSelectPicked extends _TagSelectOutcome {
  const _TagSelectPicked(this.tagId);
  final String tagId;
}

class _TagSelectManage extends _TagSelectOutcome {
  const _TagSelectManage();
}

class _TagSelectEdit extends _TagSelectOutcome {
  const _TagSelectEdit(this.tagId);
  final String tagId;
}

/// Opens the panel and applies the outcome after the reverse slide finishes.
Future<void> showTagSelectSheet(BuildContext context, WidgetRef ref) async {
  final outcome = await Navigator.of(
    context,
  ).push<_TagSelectOutcome>(_TagSelectPopupRoute());
  if (!context.mounted || outcome == null) {
    return;
  }
  switch (outcome) {
    case _TagSelectPicked(:final tagId):
      ref.read(timerUiProvider.notifier).setTag(tagId);
    case _TagSelectManage():
      context.push('/tags');
    case _TagSelectEdit(:final tagId):
      context.push('/tags/$tagId');
  }
}

class _TagSelectPopupRoute extends PopupRoute<_TagSelectOutcome> {
  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const _TagSelectPanelHost();
  }
}

/// One progress value drives open, close, and handle-drag. Pointer owns the
/// value; snap uses cubic easing. Panel height is fixed so travel distance
/// does not change with tag count.
class _TagSelectPanelHost extends StatefulWidget {
  const _TagSelectPanelHost();

  @override
  State<_TagSelectPanelHost> createState() => _TagSelectPanelHostState();
}

class _TagSelectPanelHostState extends State<_TagSelectPanelHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snap;
  late final _TagSelectSheet _body;
  Animation<double>? _snapAnimation;
  double _progress = 0;
  bool _closing = false;
  _TagSelectOutcome? _result;

  @override
  void initState() {
    super.initState();
    _body = _TagSelectSheet(onClose: _onBodyClose);
    _snap = AnimationController(vsync: this, duration: _kSheetMotion)
      ..addListener(() {
        final anim = _snapAnimation;
        if (anim == null) {
          return;
        }
        setState(() => _progress = anim.value);
      })
      ..addStatusListener(_onSnapStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_animateTo(1));
    });
  }

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }

  void _onBodyClose(_TagSelectOutcome? result) {
    _dismiss(result);
  }

  void _onSnapStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    if (_closing && _progress <= 0.001 && mounted) {
      Navigator.of(context).pop(_result);
    }
  }

  Future<void> _animateTo(double target) async {
    if (!mounted) {
      return;
    }
    final reduced = MediaQuery.disableAnimationsOf(context);
    _snap.stop();
    if (reduced) {
      setState(() => _progress = target);
      if (_closing && target == 0 && mounted) {
        Navigator.of(context).pop(_result);
      }
      return;
    }
    _snap.duration = tagSelectPanelSnapDuration(_progress, target);
    _snapAnimation = Tween<double>(
      begin: _progress,
      end: target,
    ).animate(CurvedAnimation(parent: _snap, curve: Curves.easeOutCubic));
    _snap.reset();
    await _snap.forward();
  }

  void _dismiss(_TagSelectOutcome? result) {
    if (_closing) {
      return;
    }
    _closing = true;
    _result = result;
    unawaited(_animateTo(0));
  }

  void _onHandleDragStart(DragStartDetails details) {
    _snap.stop();
    _closing = false;
  }

  void _onHandleDragUpdate(DragUpdateDetails details, double sheetHeight) {
    _snap.stop();
    setState(() {
      _progress = tagSelectPanelProgressFromDrag(
        current: _progress,
        deltaDy: details.primaryDelta ?? details.delta.dy,
        sheetHeight: sheetHeight,
      );
    });
  }

  void _onHandleDragEnd(DragEndDetails details) {
    if (_progress < _kDismissFraction) {
      _dismiss(null);
      return;
    }
    _closing = false;
    unawaited(_animateTo(1));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * _kSheetHeightFraction;
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _dismiss(null);
      },
      child: IgnorePointer(
        ignoring: _progress <= 0,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _dismiss(null),
                child: ColoredBox(
                  color: Colors.black.withValues(
                    alpha: _kBarrierMaxOpacity * _progress,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionalTranslation(
                translation: Offset(0, 1 - _progress),
                child: RepaintBoundary(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: kAppContentMaxWidth,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: sheetHeight,
                      child: Material(
                        color: scheme.surfaceContainerLow,
                        clipBehavior: Clip.antiAlias,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: Column(
                          children: [
                            _PanelHandle(
                              onDragStart: _onHandleDragStart,
                              onDragUpdate: (details) =>
                                  _onHandleDragUpdate(details, sheetHeight),
                              onDragEnd: _onHandleDragEnd,
                              onDragCancel: () =>
                                  _onHandleDragEnd(DragEndDetails()),
                            ),
                            Expanded(child: _body),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelHandle extends StatelessWidget {
  const _PanelHandle({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final GestureDragCancelCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: onDragStart,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      onVerticalDragCancel: onDragCancel,
      child: SizedBox(
        height: 28,
        width: double.infinity,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const SizedBox(width: 32, height: 4),
          ),
        ),
      ),
    );
  }
}

class _TagSelectSheet extends ConsumerStatefulWidget {
  const _TagSelectSheet({required this.onClose});

  final void Function(_TagSelectOutcome? result) onClose;

  @override
  ConsumerState<_TagSelectSheet> createState() => _TagSelectSheetState();
}

class _TagSelectSheetState extends ConsumerState<_TagSelectSheet> {
  String? _openTagId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tagsAsync = ref.watch(timerTagListProvider);
    final ui = ref.watch(timerUiProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: 8 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l10n.selectTagTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ModeSelector(
              selected: ui.selectedMode,
              onChanged: ref.read(timerUiProvider.notifier).setMode,
            ),
          ),
          Expanded(
            child: tagsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.loadTagsFailed)),
              data: (tags) {
                if (tags.isEmpty) {
                  return Center(child: Text(l10n.noTagsYet));
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    return RepaintBoundary(
                      child: _TagSelectRow(
                        key: ValueKey(tag.id),
                        tag: tag,
                        selected: tag.id == ui.selectedTagId,
                        isOpen: _openTagId == tag.id,
                        onExclusiveDragStart: () {
                          if (_openTagId != null && _openTagId != tag.id) {
                            setState(() => _openTagId = null);
                          }
                        },
                        onOpenChanged: (open) {
                          setState(() {
                            _openTagId = open ? tag.id : null;
                          });
                        },
                        onSelect: () {
                          widget.onClose(_TagSelectPicked(tag.id));
                        },
                        onEdit: () {
                          widget.onClose(_TagSelectEdit(tag.id));
                        },
                        onDelete: tag.name == SystemTags.generalName
                            ? null
                            : () => _confirmDelete(tag),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(PresentationPhosphorIcons.listBullets),
            title: Text(l10n.manageTags),
            trailing: const Icon(PresentationPhosphorIcons.caretRight),
            onTap: () {
              widget.onClose(const _TagSelectManage());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Tag tag) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTagConfirmTitle(tag.name)),
        content: Text(l10n.deleteTagConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final result = await ref.read(tagUseCasesProvider).deleteTag(tag.id);
    if (!mounted) {
      return;
    }
    if (result.isErr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tagErrorMessage(result.error!, l10n))),
      );
      return;
    }
    setState(() {
      if (_openTagId == tag.id) {
        _openTagId = null;
      }
    });
  }
}

class _TagSelectRow extends StatelessWidget {
  const _TagSelectRow({
    required this.tag,
    required this.selected,
    required this.isOpen,
    required this.onOpenChanged,
    this.onExclusiveDragStart,
    required this.onSelect,
    required this.onEdit,
    this.onDelete,
    super.key,
  });

  final Tag tag;
  final bool selected;
  final bool isOpen;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback? onExclusiveDragStart;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  double get _actionsWidth {
    final count = onDelete == null ? 1 : 2;
    return _kActionPad +
        (count * _kActionSize) +
        ((count - 1) * _kActionGap) +
        _kActionPad;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return TagSwipeActions(
      actionsWidth: _actionsWidth,
      isOpen: isOpen,
      onOpenChanged: onOpenChanged,
      onExclusiveDragStart: onExclusiveDragStart,
      actions: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kActionPad),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ActionIconButton(
              tooltip: l10n.editTag,
              icon: PresentationPhosphorIcons.pencilSimple,
              foreground: scheme.onPrimaryContainer,
              background: scheme.primaryContainer,
              onPressed: onEdit,
            ),
            if (onDelete != null) ...[
              const SizedBox(width: _kActionGap),
              _ActionIconButton(
                tooltip: l10n.deleteTag,
                icon: PresentationPhosphorIcons.trashSimple,
                foreground: scheme.onError,
                background: scheme.error,
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
      child: Material(
        color: scheme.surfaceContainerLow,
        child: ListTile(
          leading: Icon(
            PresentationPhosphorIcons.tag,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
          title: Text(tag.name),
          trailing: selected
              ? Icon(
                  PresentationPhosphorIcons.checkCircle(filled: true),
                  color: scheme.primary,
                )
              : null,
          onTap: isOpen ? () => onOpenChanged(false) : onSelect,
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: _kActionSize,
              height: _kActionSize,
              child: Icon(icon, color: foreground, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
