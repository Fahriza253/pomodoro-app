import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/tag/system_tags.dart';
import 'package:pomodoro_app/domain/tag/tag_form_data.dart';
import 'package:pomodoro_app/domain/tag/tag_config_limits.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/tag/tag_error_messages.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';

class TagFormScreen extends ConsumerStatefulWidget {
  const TagFormScreen({this.tagId, super.key});

  final String? tagId;

  bool get isNew => tagId == null;

  @override
  ConsumerState<TagFormScreen> createState() => _TagFormScreenState();
}

class _TagFormScreenState extends ConsumerState<TagFormScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late TabController _tabController;

  String _color = tagColorPresets.first;
  bool _autoStartBreak = false;
  bool _autoStartFocus = false;
  bool _reminderEnabled = true;

  int _focusMin = 25;
  int _shortBreakMin = 5;
  int _longBreakMin = 15;
  int _sessionsBeforeLongBreak = 4;
  int _totalCycles = 4;
  int? _defaultDurationMin;
  int _reminderIntervalMin = 25;

  bool _saving = false;
  bool _hydrated = false;
  bool _canDelete = false;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() => _activeTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _applyFormData(TagFormData data) {
    _nameController.text = data.tag.name;
    _color = data.tag.color;
    _canDelete = data.tag.name != SystemTags.generalName;
    _autoStartBreak = data.pomodoro.autoStartBreak ?? false;
    _autoStartFocus = data.pomodoro.autoStartFocus ?? false;
    _focusMin = TagConfigLimits.snapToGrid(
      TagConfigLimits.secToMinRounded(data.pomodoro.focusDurationSec ?? 1500),
      min: TagConfigLimits.focusMinMin,
      max: TagConfigLimits.focusMaxMin,
      step: TagConfigLimits.focusStepMin,
    );
    _shortBreakMin = TagConfigLimits.snapToGrid(
      TagConfigLimits.secToMinRounded(
        data.pomodoro.shortBreakDurationSec ?? 300,
      ),
      min: TagConfigLimits.shortBreakMinMin,
      max: TagConfigLimits.shortBreakMaxMin,
      step: TagConfigLimits.shortBreakStepMin,
    );
    _longBreakMin = TagConfigLimits.snapToGrid(
      TagConfigLimits.secToMinRounded(
        data.pomodoro.longBreakDurationSec ?? 900,
      ),
      min: TagConfigLimits.longBreakMinMin,
      max: TagConfigLimits.longBreakMaxMin,
      step: TagConfigLimits.longBreakStepMin,
    );
    _sessionsBeforeLongBreak = (data.pomodoro.sessionsBeforeLongBreak ?? 4)
        .clamp(
          TagConfigLimits.sessionsBeforeLongBreakMin,
          TagConfigLimits.sessionsBeforeLongBreakMax,
        );
    _totalCycles = TagConfigLimits.snapToGrid(
      data.pomodoro.totalCycles ?? 4,
      min: TagConfigLimits.totalCyclesMin,
      max: TagConfigLimits.totalCyclesMax,
      step: TagConfigLimits.totalCyclesStep,
    );
    _defaultDurationMin = data.flexible.defaultDurationSec == null
        ? null
        : TagConfigLimits.snapToGrid(
            TagConfigLimits.secToMinRounded(data.flexible.defaultDurationSec!),
            min: TagConfigLimits.focusMinMin,
            max: TagConfigLimits.focusMaxMin,
            step: TagConfigLimits.focusStepMin,
          );
    _reminderEnabled = data.flexible.reminderEnabled ?? true;
    _reminderIntervalMin = TagConfigLimits.snapToGrid(
      data.flexible.reminderIntervalMin ?? 25,
      min: TagConfigLimits.reminderMinMinutes,
      max: TagConfigLimits.reminderMaxMinutes,
      step: TagConfigLimits.reminderStepMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!widget.isNew) {
      final formAsync = ref.watch(tagFormProvider(widget.tagId!));
      return formAsync.when(
        loading: () =>
            _scaffold(body: const Center(child: CircularProgressIndicator())),
        error: (_, _) => _scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.loadTagFailed),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    setState(() => _hydrated = false);
                    ref.invalidate(tagFormProvider(widget.tagId!));
                  },
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          if (!_hydrated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              setState(() {
                _applyFormData(data);
                _hydrated = true;
              });
            });
            return _scaffold(
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return _buildForm(context, canDelete: _canDelete);
        },
      );
    }

    if (_nameController.text.isEmpty) {
      _nameController.text = '';
    }
    return _buildForm(context, canDelete: false);
  }

  Widget _buildForm(BuildContext context, {required bool canDelete}) {
    final l10n = context.l10n;
    return _scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.tagNameLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.color, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tagColorPresets
                .map(
                  (hex) => GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: _colorSwatch(hex, _color == hex),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.modePomodoro),
              Tab(text: l10n.modeFlexible),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _activeTabIndex == 0
                ? _pomodoroTab(l10n, key: const ValueKey('pomodoroTab'))
                : _flexibleTab(l10n, key: const ValueKey('flexibleTab')),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.saveUpper),
          ),
          if (canDelete) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _saving ? null : _confirmDelete,
              child: Text(l10n.deleteTag),
            ),
          ],
        ],
      ),
    );
  }

  Widget _colorSwatch(String hex, bool selected) {
    final color = _parseTagColor(hex);
    final ringColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? ringColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
      ),
    );
  }

  Color _parseTagColor(String hex) {
    return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
  }

  Widget _scaffold({required Widget body}) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isNew ? context.l10n.newTag : context.l10n.editTag),
      ),
      body: body,
    );
  }

  Widget _pomodoroTab(AppLocalizations l10n, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _sliderField(
          label: l10n.focusDuration,
          value: _focusMin,
          min: TagConfigLimits.focusMinMin,
          max: TagConfigLimits.focusMaxMin,
          step: TagConfigLimits.focusStepMin,
          suffix: l10n.minutesUnit,
          onChanged: (v) => setState(() => _focusMin = v),
        ),
        _sliderField(
          label: l10n.shortBreakDuration,
          value: _shortBreakMin,
          min: TagConfigLimits.shortBreakMinMin,
          max: TagConfigLimits.shortBreakMaxMin,
          step: TagConfigLimits.shortBreakStepMin,
          suffix: l10n.minutesUnit,
          onChanged: (v) => setState(() => _shortBreakMin = v),
        ),
        _sliderField(
          label: l10n.longBreakDuration,
          value: _longBreakMin,
          min: TagConfigLimits.longBreakMinMin,
          max: TagConfigLimits.longBreakMaxMin,
          step: TagConfigLimits.longBreakStepMin,
          suffix: l10n.minutesUnit,
          onChanged: (v) => setState(() => _longBreakMin = v),
        ),
        _sliderField(
          label: l10n.focusBeforeLongBreak,
          value: _sessionsBeforeLongBreak,
          min: TagConfigLimits.sessionsBeforeLongBreakMin,
          max: TagConfigLimits.sessionsBeforeLongBreakMax,
          step: 1,
          suffix: l10n.timesUnit,
          onChanged: (v) => setState(() => _sessionsBeforeLongBreak = v),
        ),
        _sliderField(
          label: l10n.totalCycles,
          value: _totalCycles,
          min: TagConfigLimits.totalCyclesMin,
          max: TagConfigLimits.totalCyclesMax,
          step: TagConfigLimits.totalCyclesStep,
          suffix: l10n.timesUnit,
          onChanged: (v) => setState(() => _totalCycles = v),
        ),
        SwitchListTile(
          title: Text(l10n.autoStartBreak),
          value: _autoStartBreak,
          onChanged: (v) => setState(() => _autoStartBreak = v),
        ),
        SwitchListTile(
          title: Text(l10n.autoStartFocus),
          value: _autoStartFocus,
          onChanged: (v) => setState(() => _autoStartFocus = v),
        ),
      ],
    );
  }

  Widget _flexibleTab(AppLocalizations l10n, {Key? key}) {
    final isUnlimited = _defaultDurationMin == null;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        SwitchListTile(
          title: Text(l10n.unlimitedDefaultDuration),
          value: isUnlimited,
          onChanged: (v) {
            setState(() {
              _defaultDurationMin = v ? null : 25;
            });
          },
        ),
        if (!isUnlimited)
          _sliderField(
            label: l10n.defaultDuration,
            value: _defaultDurationMin!,
            min: TagConfigLimits.focusMinMin,
            max: TagConfigLimits.focusMaxMin,
            step: TagConfigLimits.focusStepMin,
            suffix: l10n.minutesUnit,
            onChanged: (v) => setState(() => _defaultDurationMin = v),
          ),
        SwitchListTile(
          title: Text(l10n.reminderEnabled),
          value: _reminderEnabled,
          onChanged: (v) => setState(() => _reminderEnabled = v),
        ),
        _sliderField(
          label: l10n.reminderInterval,
          value: _reminderIntervalMin,
          min: TagConfigLimits.reminderMinMinutes,
          max: TagConfigLimits.reminderMaxMinutes,
          step: TagConfigLimits.reminderStepMinutes,
          suffix: l10n.minutesUnit,
          onChanged: _reminderEnabled
              ? (v) => setState(() => _reminderIntervalMin = v)
              : null,
        ),
      ],
    );
  }

  Widget _sliderField({
    required String label,
    required int value,
    required int min,
    required int max,
    required int step,
    required String suffix,
    required ValueChanged<int>? onChanged,
  }) {
    final divisions = ((max - min) / step).round();
    final enabled = onChanged != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        label: label,
        value: '$value $suffix',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label)),
                Text(
                  '$value $suffix',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              label: '$value $suffix',
              onChanged: enabled
                  ? (d) {
                      final v = TagConfigLimits.snapToGrid(
                        d.round(),
                        min: min,
                        max: max,
                        step: step,
                      );
                      onChanged(v);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  TagModeConfigPomodoro _pomodoroInput() => TagModeConfigPomodoro(
    focusDurationSec: TagConfigLimits.minToSec(_focusMin),
    shortBreakDurationSec: TagConfigLimits.minToSec(_shortBreakMin),
    longBreakDurationSec: TagConfigLimits.minToSec(_longBreakMin),
    sessionsBeforeLongBreak: _sessionsBeforeLongBreak,
    totalCycles: _totalCycles,
    autoStartBreak: _autoStartBreak,
    autoStartFocus: _autoStartFocus,
  );

  TagModeConfigFlexible _flexibleInput() => TagModeConfigFlexible(
    defaultDurationSec: _defaultDurationMin == null
        ? null
        : TagConfigLimits.minToSec(_defaultDurationMin!),
    reminderEnabled: _reminderEnabled,
    reminderIntervalMin: _reminderIntervalMin,
  );

  Future<void> _save() async {
    setState(() => _saving = true);
    final useCases = ref.read(tagUseCasesProvider);
    final AppResult result;

    if (widget.isNew) {
      result = await useCases.createTag(
        CreateTagInput(
          name: _nameController.text,
          color: _color,
          pomodoro: _pomodoroInput(),
          flexible: _flexibleInput(),
        ),
      );
    } else {
      result = await useCases.updateTag(
        UpdateTagInput(
          id: widget.tagId!,
          name: _nameController.text,
          color: _color,
          pomodoro: _pomodoroInput(),
          flexible: _flexibleInput(),
        ),
      );
    }

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);

    if (result.isErr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tagErrorMessage(result.error!, context.l10n))),
      );
      return;
    }
    if (!widget.isNew) {
      ref.invalidate(tagFormProvider(widget.tagId!));
    }
    context.pop();
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTagConfirmTitle(_nameController.text)),
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
    setState(() => _saving = true);
    final result = await ref.read(tagUseCasesProvider).deleteTag(widget.tagId!);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (result.isErr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tagErrorMessage(result.error!, context.l10n))),
      );
      return;
    }
    ref.invalidate(tagFormProvider(widget.tagId!));
    context.pop();
  }

  // ponytail: keep local ints as minutes; convert at submit time only.
}
