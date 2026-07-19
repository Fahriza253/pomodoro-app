import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';

class TagPickerField extends ConsumerWidget {
  const TagPickerField({required this.enabled, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tagsAsync = ref.watch(tagListProvider);
    final ui = ref.watch(timerUiProvider);
    final selectedId = ui.selectedTagId;

    return tagsAsync.when(
      loading: () => ListTile(
        leading: const Icon(Icons.label_outline),
        title: Text(l10n.loadingTags),
      ),
      error: (_, _) => ListTile(
        leading: const Icon(Icons.error_outline),
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
            onTap: enabled ? () => _showTagSheet(context, ref, tags) : null,
            onLongPress: enabled ? () => context.push('/tags') : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.label_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected?.name ?? l10n.selectTag,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        InkWell(
                          onTap: enabled ? () => context.push('/tags') : null,
                          child: Text(
                            l10n.manageTags,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTagSheet(
    BuildContext context,
    WidgetRef ref,
    List<Tag> tags,
  ) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
        return SafeArea(
          child: SizedBox(
            height: maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    l10n.selectTagTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return ListTile(
                        leading: const Icon(Icons.label),
                        title: Text(tag.name),
                        onTap: () => Navigator.of(context).pop(tag.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      ref.read(timerUiProvider.notifier).setTag(selected);
    }
  }
}
