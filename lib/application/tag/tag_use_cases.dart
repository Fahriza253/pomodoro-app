import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/tag/debug_short_tag.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/domain/tag/tag_config_validator.dart';
import 'package:pomodoro_app/domain/tag/tag_form_data.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';

/// UC-03 — tag CRUD with validation and guards (BR-TAG-003–005).
class TagUseCases {
  TagUseCases({
    required this._tagRepository,
    required this._sessionRepository,
    TagConfigValidator? validator,
  }) : _validator = validator ?? const TagConfigValidator();

  final TagRepository _tagRepository;
  final SessionRepository _sessionRepository;
  final TagConfigValidator _validator;

  /// Tag management UI — never includes the debug QA Tag.
  Future<List<Tag>> listTagsForManagement() async {
    final tags = await _tagRepository.listActiveOrdered();
    return DebugShortTag.forManagement(tags);
  }

  /// Timer picker — includes debug Tag only when [DebugShortTag.enabled].
  Future<List<Tag>> listTagsForTimerPicker() async {
    final tags = await _tagRepository.listActiveOrdered();
    return DebugShortTag.forTimerPicker(tags);
  }

  Future<List<Tag>> listTags() => listTagsForManagement();

  Future<TagFormData> getTagForm(String id) async {
    final withConfigs = await _tagRepository.getWithConfigs(id);
    return TagFormData(
      tag: withConfigs.tag,
      pomodoro: withConfigs.pomodoro,
      flexible: withConfigs.flexible,
    );
  }

  Future<AppResult<Tag>> createTag(CreateTagInput input) async {
    final validation = _validator.validateCreate(input);
    if (!validation.isValid) {
      return err(_validationError(validation));
    }
    try {
      final tag = await _tagRepository.create(input);
      return ok(tag);
    } on AppError catch (e) {
      return err(e);
    }
  }

  Future<AppResult<Tag>> updateTag(UpdateTagInput input) async {
    if (await _hasActiveSession()) {
      return err(
        const ConflictError(
          code: 'TAG_EDIT_BLOCKED_ACTIVE',
          message: 'Tidak dapat mengubah tag saat sesi aktif.',
        ),
      );
    }

    final validation = _validator.validateUpdate(input);
    if (!validation.isValid) {
      return err(_validationError(validation));
    }

    try {
      final tag = await _tagRepository.update(input);
      return ok(tag);
    } on AppError catch (e) {
      return err(e);
    }
  }

  Future<AppResult<void>> deleteTag(String id) async {
    if (await _hasActiveSession()) {
      return err(
        const ConflictError(
          code: 'TAG_EDIT_BLOCKED_ACTIVE',
          message: 'Tidak dapat mengubah tag saat sesi aktif.',
        ),
      );
    }

    try {
      await _tagRepository.softDelete(id);
      return ok();
    } on AppError catch (e) {
      return err(e);
    }
  }

  Future<AppResult<void>> reorderTags(List<String> tagIdsInOrder) async {
    try {
      await _tagRepository.reorder(tagIdsInOrder);
      return ok();
    } on AppError catch (e) {
      return err(e);
    }
  }

  Future<bool> _hasActiveSession() async {
    final active = await _sessionRepository.getActiveSession();
    return active != null;
  }

  ValidationError _validationError(ValidationResult result) {
    return ValidationError(
      code: 'TAG_CONFIG_INVALID',
      message: result.issues.isNotEmpty
          ? result.issues.first.message
          : 'Konfigurasi tag tidak valid.',
      details: {
        'issues': result.issues.map((i) => '${i.field}: ${i.message}').toList(),
      },
    );
  }
}
