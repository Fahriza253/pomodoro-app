import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_select_sheet.dart';

class TagPickerField extends ConsumerWidget {
  const TagPickerField({required this.enabled, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tagsAsync = ref.watch(timerTagListProvider);
    final ui = ref.watch(timerUiProvider);
    final selectedId = ui.selectedTagId;
    final modeLabel = ui.selectedMode == TimerMode.pomodoro
        ? l10n.modePomodoro
        : l10n.modeFlexible;

    return tagsAsync.when(
      loading: () => ListTile(
        leading: const Icon(PresentationPhosphorIcons.tag),
        title: Text(l10n.loadingTags),
      ),
      error: (_, _) => ListTile(
        leading: Icon(PresentationPhosphorIcons.warningCircle()),
        title: Text(l10n.loadTagsFailed),
      ),
      data: (tags) {
        Tag? selected;
        for (final tag in tags) {
          if (tag.id == selectedId) {
            selected = tag;
            break;
          }
        }
        selected ??= tags.isNotEmpty ? tags.first : null;
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? () => showTagSelectSheet(context, ref) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(PresentationPhosphorIcons.tag),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected?.name ?? l10n.selectTag,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          modeLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(PresentationPhosphorIcons.caretDown),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
