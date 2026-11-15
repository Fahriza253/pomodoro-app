import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/tag/system_tags.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/fluid_bottom_sheet.dart';
import 'package:pomodoro_app/presentation/shared/fluid_overscroll.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/tag/tag_error_messages.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';
import 'package:pomodoro_app/presentation/timer/widgets/mode_selector.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_swipe_actions.dart';

const _kActionSize = 48.0;
const _kActionGap = 8.0;
const _kActionPad = 8.0;

@visibleForTesting
double tagSelectPanelLinearProgressFromDrag({
  required double current,
  required double deltaDy,
  required double sheetHeight,
}) {
  return fluidSheetLinearProgressFromDrag(
    current: current,
    deltaDy: deltaDy,
    sheetHeight: sheetHeight,
  );
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
  final outcome = await showFluidBottomSheet<_TagSelectOutcome>(
    context,
    builder: (context, close) => _TagSelectSheet(onClose: close),
  );
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
      actions: (context, revealT) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _kActionPad),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionIconButton(
                revealT: revealT,
                tooltip: l10n.editTag,
                icon: PresentationPhosphorIcons.pencilSimple,
                foreground: scheme.onPrimaryContainer,
                background: scheme.primaryContainer,
                onPressed: onEdit,
              ),
              if (onDelete != null) ...[
                const SizedBox(width: _kActionGap),
                _ActionIconButton(
                  revealT: revealT,
                  tooltip: l10n.deleteTag,
                  icon: PresentationPhosphorIcons.trashSimple,
                  foreground: scheme.onError,
                  background: scheme.error,
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        );
      },
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
    required this.revealT,
    required this.tooltip,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onPressed,
  });

  final double revealT;
  final String tooltip;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = revealT.clamp(0.0, 1.0);
    final size = _kActionSize * t;
    final radius = size * 0.25;
    final iconOpacity = tagSwipeActionIconOpacity(t);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          width: _kActionSize,
          height: _kActionSize,
          child: Center(
            child: Material(
              color: background,
              shape: shape,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: shape,
                onTap: t >= 0.8 ? onPressed : null,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Opacity(
                    opacity: iconOpacity,
                    child: Icon(icon, color: foreground, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
