import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/color_helpers.dart';
import 'package:pomodoro_app/presentation/tag/tag_error_messages.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';

class TagListScreen extends ConsumerWidget {
  const TagListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.manageTagsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.newTagTooltip,
            onPressed: () => context.push('/tags/new'),
          ),
        ],
      ),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.loadTagListFailed),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(tagListProvider),
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
        data: (tags) {
          if (tags.isEmpty) {
            return Center(child: Text(l10n.noTagsYet));
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tags.length,
            onReorderItem: (oldIndex, newIndex) =>
                _onReorder(context, ref, tags, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final tag = tags[index];
              return _TagListTile(
                key: ValueKey(tag.id),
                index: index,
                tag: tag,
                onTap: () => context.push('/tags/${tag.id}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onReorder(
    BuildContext context,
    WidgetRef ref,
    List<Tag> tags,
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = List<Tag>.from(tags);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    final result = await ref
        .read(tagUseCasesProvider)
        .reorderTags(reordered.map((t) => t.id).toList());
    if (!context.mounted) {
      return;
    }
    if (result.isErr) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(tagErrorMessage(result.error!, context.l10n))),
      );
    }
  }
}

class _TagListTile extends StatelessWidget {
  const _TagListTile({
    required this.index,
    required this.tag,
    required this.onTap,
    super.key,
  });

  final int index;
  final Tag tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColorOr(tag.color, Colors.indigo);
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: Icon(Icons.drag_handle, color: color),
      ),
      title: Text(tag.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
