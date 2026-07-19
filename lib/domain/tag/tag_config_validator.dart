import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/domain/tag/tag_config_limits.dart';

class ValidationIssue {
  const ValidationIssue({required this.field, required this.message});

  final String field;
  final String message;
}

class ValidationResult {
  const ValidationResult({required this.isValid, this.issues = const []});

  const ValidationResult.ok() : this(isValid: true);

  ValidationResult.invalid(List<ValidationIssue> issues)
    : this(isValid: false, issues: issues);

  final bool isValid;
  final List<ValidationIssue> issues;
}

/// Validates tag name and mode configs (BR-TAG-003).
class TagConfigValidator {
  const TagConfigValidator();

  ValidationResult validateTagName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.invalid([
        const ValidationIssue(field: 'name', message: 'Nama tag wajib diisi.'),
      ]);
    }
    if (trimmed.length > 64) {
      return ValidationResult.invalid([
        const ValidationIssue(
          field: 'name',
          message: 'Nama tag maksimal 64 karakter.',
        ),
      ]);
    }
    return const ValidationResult.ok();
  }

  ValidationResult validatePomodoro(TagModeConfigPomodoro config) {
    final issues = <ValidationIssue>[];

    final focusMin = TagConfigLimits.secToMinRounded(config.focusDurationSec);
    final shortBreakMin = TagConfigLimits.secToMinRounded(
      config.shortBreakDurationSec,
    );
    final longBreakMin = TagConfigLimits.secToMinRounded(
      config.longBreakDurationSec,
    );

    if (!TagConfigLimits.isOnGrid(
      focusMin,
      min: TagConfigLimits.focusMinMin,
      max: TagConfigLimits.focusMaxMin,
      step: TagConfigLimits.focusStepMin,
    )) {
      issues.add(
        const ValidationIssue(
          field: 'focusDurationSec',
          message: 'Durasi fokus harus 5–180 menit (kelipatan 5).',
        ),
      );
    }
    if (!TagConfigLimits.isOnGrid(
      shortBreakMin,
      min: TagConfigLimits.shortBreakMinMin,
      max: TagConfigLimits.shortBreakMaxMin,
      step: TagConfigLimits.shortBreakStepMin,
    )) {
      issues.add(
        const ValidationIssue(
          field: 'shortBreakDurationSec',
          message: 'Istirahat pendek harus 2–14 menit (kelipatan 2).',
        ),
      );
    }
    if (!TagConfigLimits.isOnGrid(
      longBreakMin,
      min: TagConfigLimits.longBreakMinMin,
      max: TagConfigLimits.longBreakMaxMin,
      step: TagConfigLimits.longBreakStepMin,
    )) {
      issues.add(
        const ValidationIssue(
          field: 'longBreakDurationSec',
          message: 'Istirahat panjang harus 5–30 menit (kelipatan 5).',
        ),
      );
    }
    if (!TagConfigLimits.isWithin(
      config.sessionsBeforeLongBreak,
      min: TagConfigLimits.sessionsBeforeLongBreakMin,
      max: TagConfigLimits.sessionsBeforeLongBreakMax,
    )) {
      issues.add(
        const ValidationIssue(
          field: 'sessionsBeforeLongBreak',
          message: 'Fokus sebelum istirahat panjang harus 1–10.',
        ),
      );
    }
    if (!TagConfigLimits.isOnGrid(
      config.totalCycles,
      min: TagConfigLimits.totalCyclesMin,
      max: TagConfigLimits.totalCyclesMax,
      step: TagConfigLimits.totalCyclesStep,
    )) {
      issues.add(
        const ValidationIssue(
          field: 'totalCycles',
          message: 'Total siklus harus 2–8 (kelipatan 2).',
        ),
      );
    }

    return issues.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.invalid(issues);
  }

  ValidationResult validateFlexible(TagModeConfigFlexible config) {
    final issues = <ValidationIssue>[];

    if (config.defaultDurationSec != null && config.defaultDurationSec! <= 0) {
      issues.add(
        const ValidationIssue(
          field: 'defaultDurationSec',
          message: 'Durasi default harus lebih dari 0.',
        ),
      );
    }
    if (config.reminderEnabled && (config.reminderIntervalMin <= 0)) {
      issues.add(
        const ValidationIssue(
          field: 'reminderIntervalMin',
          message: 'Interval pengingat harus lebih dari 0.',
        ),
      );
    }

    return issues.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.invalid(issues);
  }

  ValidationResult validateCreate(CreateTagInput input) {
    return _merge(
      validateTagName(input.name),
      validatePomodoro(input.pomodoro),
      validateFlexible(input.flexible),
    );
  }

  ValidationResult validateUpdate(UpdateTagInput input) {
    return validateCreate(
      CreateTagInput(
        name: input.name,
        color: input.color,
        pomodoro: input.pomodoro,
        flexible: input.flexible,
      ),
    );
  }

  ValidationResult _merge(
    ValidationResult a,
    ValidationResult b, [
    ValidationResult? c,
  ]) {
    final issues = [...a.issues, ...b.issues, if (c != null) ...c.issues];
    if (issues.isEmpty) {
      return const ValidationResult.ok();
    }
    return ValidationResult.invalid(issues);
  }
}
