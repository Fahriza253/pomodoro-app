import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/domain/tag/tag_mode_config.dart';

/// Tag + dual configs for edit form (UC-03).
class TagFormData {
  const TagFormData({
    required this.tag,
    required this.pomodoro,
    required this.flexible,
  });

  final Tag tag;
  final TagModeConfig pomodoro;
  final TagModeConfig flexible;
}
