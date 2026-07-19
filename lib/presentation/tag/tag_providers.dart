import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/application/tag/tag_use_cases.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/domain/tag/tag_form_data.dart';

final tagUseCasesProvider = Provider<TagUseCases>((ref) {
  return TagUseCases(
    tagRepository: ref.watch(tagRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
  );
});

final tagListProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchActiveOrdered();
});

final tagFormProvider = FutureProvider.family<TagFormData, String>((
  ref,
  tagId,
) async {
  return ref.watch(tagUseCasesProvider).getTagForm(tagId);
});

/// Preset tag colors for the form UI.
const tagColorPresets = [
  '#6366F1',
  '#3B82F6',
  '#10B981',
  '#F59E0B',
  '#EF4444',
  '#8B5CF6',
];
