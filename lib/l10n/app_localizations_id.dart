// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Pomodoro';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Simpan';

  @override
  String get saveUpper => 'SIMPAN';

  @override
  String get discard => 'Buang';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get enabled => 'Aktif';

  @override
  String get disabled => 'Nonaktif';

  @override
  String get navTimer => 'Timer';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navStatistic => 'Statistic';

  @override
  String get navSettings => 'Setelan';

  @override
  String get databaseNotReadyTitle => 'Menyiapkan data';

  @override
  String get databaseNotReadyBody =>
      'Database belum siap. Mohon tunggu sebentar.';

  @override
  String get timerTitle => 'Timer';

  @override
  String get timerLoadStateFailed => 'Gagal memuat status timer';

  @override
  String get selectTagFirst => 'Pilih tag terlebih dahulu';

  @override
  String get sessionNotActiveOrEnded =>
      'Session ini sudah tidak aktif atau telah berakhir';

  @override
  String flexibleReminderEveryMinutes(int minutes) {
    return 'Pengingat: setiap $minutes menit';
  }

  @override
  String get start => 'Mulai';

  @override
  String get skip => 'Lewati';

  @override
  String get resume => 'Lanjutkan';

  @override
  String get pause => 'Jeda';

  @override
  String get stop => 'Berhenti';

  @override
  String stopWithGraceSeconds(int seconds) {
    return 'Berhenti (${seconds}d)';
  }

  @override
  String get skipBreakUpper => 'LEWATI ISTIRAHAT';

  @override
  String get finish => 'Selesai';

  @override
  String get focusCompleteTitle => 'Focus selesai';

  @override
  String get breakCompleteTitle => 'Istirahat selesai';

  @override
  String get timeForBreak => 'Waktunya istirahat';

  @override
  String get readyForNextFocus => 'Siap untuk sesi focus berikutnya';

  @override
  String get startBreakUpper => 'MULAI ISTIRAHAT';

  @override
  String get startFocusUpper => 'MULAI FOCUS';

  @override
  String get skipBreak => 'Lewati istirahat';

  @override
  String get sessionCompleteTitle => 'Session selesai';

  @override
  String get sessionSavedBody =>
      'Session tersimpan. Mulai lagi dengan tag yang sama, atau kembali ke beranda.';

  @override
  String get startAgainUpper => 'MULAI LAGI';

  @override
  String get doneUpper => 'SELESAI';

  @override
  String activeDuration(String duration) {
    return 'Aktif: $duration';
  }

  @override
  String cycleProgress(int completed, int total) {
    return 'Siklus $completed dari $total';
  }

  @override
  String get continueUpper => 'LANJUTKAN';

  @override
  String get loadingTags => 'Memuat tag…';

  @override
  String get loadTagsFailed => 'Gagal memuat tag';

  @override
  String get selectTag => 'Pilih tag';

  @override
  String get manageTags => 'Kelola tag';

  @override
  String get selectTagTitle => 'Pilih tag';

  @override
  String get recoveryDialogTitle => 'Lanjutkan session sebelumnya?';

  @override
  String get recoveryDialogBody =>
      'Kami menemukan session yang belum selesai. Ingin melanjutkannya?';

  @override
  String get resumeSession => 'Lanjutkan session';

  @override
  String get slideToStopSemantics => 'Geser untuk menghentikan session';

  @override
  String get releaseToStop => 'Lepas untuk berhenti';

  @override
  String get segmentFocus => 'Focus';

  @override
  String get segmentShortRest => 'Istirahat pendek';

  @override
  String get segmentLongRest => 'Istirahat panjang';

  @override
  String get segmentFlexible => 'Flexible';

  @override
  String get segmentSkipped => 'Dilewati';

  @override
  String get segmentRunning => 'Berjalan';

  @override
  String get segmentIncomplete => 'Belum selesai';

  @override
  String get modePomodoro => 'Pomodoro';

  @override
  String get modeFlexible => 'Flexible';

  @override
  String get errorTimerActiveSession => 'Sudah ada session yang aktif';

  @override
  String get errorNoActiveSession => 'Tidak ada session aktif';

  @override
  String get errorTimerInvalidTransition =>
      'Tindakan ini tidak diperbolehkan saat ini';

  @override
  String get errorTimerRecoveryExpired =>
      'Session sebelumnya sudah tidak dapat dipulihkan';

  @override
  String get errorTimerStopNotConfirmed => 'Berhenti belum dikonfirmasi';

  @override
  String get errorSaveFailedTryAgain => 'Gagal menyimpan, silakan coba lagi';

  @override
  String get errorTagNotFound => 'Tag tidak ditemukan';

  @override
  String get errorSessionNotActiveOrEnded =>
      'Session ini sudah tidak aktif atau telah berakhir';

  @override
  String get manageTagsTitle => 'Kelola tag';

  @override
  String get newTagTooltip => 'Tag baru';

  @override
  String get loadTagListFailed => 'Gagal memuat daftar tag';

  @override
  String get noTagsYet => 'Belum ada tag';

  @override
  String get loadTagFailed => 'Gagal memuat tag';

  @override
  String get tagNameLabel => 'Nama tag';

  @override
  String get color => 'Warna';

  @override
  String get newTag => 'Tag baru';

  @override
  String get editTag => 'Edit tag';

  @override
  String get focusDuration => 'Durasi focus';

  @override
  String get shortBreakDuration => 'Durasi istirahat pendek';

  @override
  String get longBreakDuration => 'Durasi istirahat panjang';

  @override
  String get focusBeforeLongBreak => 'Sesi focus sebelum istirahat panjang';

  @override
  String get totalCycles => 'Total siklus';

  @override
  String get minutesUnit => 'mnt';

  @override
  String get timesUnit => 'x';

  @override
  String get autoStartBreak => 'Mulai istirahat otomatis';

  @override
  String get autoStartFocus => 'Mulai focus otomatis';

  @override
  String get unlimitedDefaultDuration => 'Tanpa batas';

  @override
  String get defaultDuration => 'Durasi default';

  @override
  String get reminderEnabled => 'Pengingat aktif';

  @override
  String get reminderInterval => 'Interval pengingat';

  @override
  String get deleteTag => 'Hapus tag';

  @override
  String deleteTagConfirmTitle(String name) {
    return 'Hapus \"$name\"?';
  }

  @override
  String get deleteTagConfirmBody =>
      'Tag ini akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get errorTagNameDuplicate => 'Tag dengan nama ini sudah ada';

  @override
  String get errorTagEditBlockedActive =>
      'Tidak dapat mengedit tag ini saat session-nya aktif';

  @override
  String get errorTagDeleteLast =>
      'Tidak dapat menghapus tag terakhir yang tersisa';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get sessionDetailTitle => 'Detail session';

  @override
  String get filterMonthTooltip => 'Filter berdasarkan bulan';

  @override
  String get noSessionsOnDate => 'Tidak ada session pada tanggal ini';

  @override
  String focusDurationLabel(String duration) {
    return 'Durasi focus: $duration';
  }

  @override
  String sessionTagAndMode(String tagName, String mode) {
    return '$tagName · $mode';
  }

  @override
  String sessionStatusPrefix(String status) {
    return 'Status: $status';
  }

  @override
  String totalActive(String duration) {
    return 'Total aktif: $duration';
  }

  @override
  String totalPaused(String duration) {
    return 'Total dijeda: $duration';
  }

  @override
  String get segments => 'Segment';

  @override
  String get noSegmentsRecorded => 'Tidak ada segment yang tercatat';

  @override
  String plannedDuration(String duration) {
    return 'Rencana: $duration';
  }

  @override
  String actualDuration(String duration) {
    return 'Aktual: $duration';
  }

  @override
  String get statisticTitle => 'Statistic';

  @override
  String get loadStatisticFailed => 'Gagal memuat statistic';

  @override
  String get tagBreakdown => 'Rincian per tag';

  @override
  String get tag => 'Tag';

  @override
  String get allTags => 'Semua tag';

  @override
  String get mode => 'Mode';

  @override
  String get allModes => 'Semua mode';

  @override
  String get metricSessions => 'Session';

  @override
  String get metricFocus => 'Focus';

  @override
  String get metricBreak => 'Istirahat';

  @override
  String get metricTotal => 'Total';

  @override
  String get noTagBreakdown => 'Belum ada rincian tag';

  @override
  String sessionCount(int count) {
    return '$count session';
  }

  @override
  String get noDataForFilter => 'Tidak ada data untuk filter ini';

  @override
  String get noStatisticData => 'Belum ada data statistic';

  @override
  String get adjustFiltersHint => 'Coba sesuaikan filter Anda';

  @override
  String get startSessionHint =>
      'Mulai session untuk melihat statistic di sini';

  @override
  String get periodDaily => 'Harian';

  @override
  String get periodWeekly => 'Mingguan';

  @override
  String get periodMonthly => 'Bulanan';

  @override
  String get periodYearly => 'Tahunan';

  @override
  String get periodTotal => 'Total';

  @override
  String get settingsTitle => 'Setelan';

  @override
  String get loadSettingsFailed => 'Gagal memuat setelan';

  @override
  String get settingsSectionAlert => 'Notifikasi';

  @override
  String get alertTones => 'Nada notifikasi';

  @override
  String get settingsSectionFocus => 'Focus';

  @override
  String get focusMode => 'Mode focus';

  @override
  String get whitelistApps => 'Aplikasi di whitelist';

  @override
  String appCount(int count) {
    return '$count aplikasi';
  }

  @override
  String get settingsSectionAppearance => 'Tampilan';

  @override
  String get themeAndDisplay => 'Tema & tampilan';

  @override
  String themeAodSummary(String theme, String status) {
    return '$theme · AOD $status';
  }

  @override
  String get settingsSectionTimeLanguage => 'Waktu & bahasa';

  @override
  String get timeAndLanguage => 'Waktu & bahasa';

  @override
  String get settingsSectionStatistic => 'Statistic';

  @override
  String get statisticInclusion => 'Cakupan statistic';

  @override
  String statisticInclusionSummary(String failed) {
    return 'Session gagal: $failed';
  }

  @override
  String get settingsSectionPlatform => 'Platform';

  @override
  String get platformAndBattery => 'Platform & baterai';

  @override
  String get platformSubtitle =>
      'Perilaku khusus platform dan pengaturan baterai';

  @override
  String alertTonesSummary(String focus, String breakTone) {
    return 'Focus $focus · Istirahat $breakTone';
  }

  @override
  String get focusLoose => 'Loose';

  @override
  String get focusStrict => 'Strict';

  @override
  String get focusWhitelist => 'Whitelist';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeFollowSystem => 'Ikuti sistem';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get timeFormat12h => '12 jam';

  @override
  String get timeFormat24h => '24 jam';

  @override
  String get weekStartMonday => 'Senin';

  @override
  String get weekStartSunday => 'Minggu';

  @override
  String get language => 'Bahasa';

  @override
  String get timeFormat => 'Format waktu';

  @override
  String get weekStart => 'Awal minggu';

  @override
  String get timeLanguageTitle => 'Waktu & bahasa';

  @override
  String get alertTonesTitle => 'Alert';

  @override
  String get focusComplete => 'Focus selesai';

  @override
  String get breakComplete => 'Istirahat selesai';

  @override
  String get focusFailed => 'Focus gagal';

  @override
  String get alertTonePreviewHint => 'Ketuk nada untuk mendengarkan pratinjau';

  @override
  String get alertControlsSection => 'Kontrol alert';

  @override
  String get alertControlsHint =>
      'Haptic, suara, dan flash untuk fokus, istirahat, gagal & pengingat';

  @override
  String get alertHaptic => 'Haptic';

  @override
  String get alertSoundMute => 'Bisukan suara';

  @override
  String get alertFlash => 'Flash';

  @override
  String get alertFlashUnsupported => 'Flash tidak didukung di perangkat ini';

  @override
  String get alertControlsSheetTitle => 'Kontrol alert';

  @override
  String get muted => 'Bisu';

  @override
  String get unmuted => 'Aktif';

  @override
  String get focusModeTitle => 'Mode focus';

  @override
  String get focusModeDegradedBanner =>
      'Mode focus berjalan dalam kondisi terbatas';

  @override
  String get focusLooseSubtitle =>
      'Tanpa batasan, hanya pengingat lembut untuk tetap fokus';

  @override
  String get focusStrictSubtitle =>
      'Meninggalkan aplikasi dihitung sebagai pelanggaran';

  @override
  String get focusWhitelistSubtitle =>
      'Hanya aplikasi di whitelist yang diizinkan selama focus';

  @override
  String get usageAccessRequired => 'Izin akses penggunaan diperlukan';

  @override
  String get openSettings => 'Buka setelan';

  @override
  String get violationThreshold => 'Ambang batas pelanggaran';

  @override
  String get seconds => 'detik';

  @override
  String secondsCount(int sec) {
    return '${sec}d';
  }

  @override
  String get manageWhitelist => 'Kelola whitelist';

  @override
  String get notAvailableOnDevice => 'Tidak tersedia di perangkat ini';

  @override
  String get whitelistAppsTitle => 'Aplikasi di whitelist';

  @override
  String get installedAppsUnavailable =>
      'Daftar aplikasi terpasang tidak tersedia';

  @override
  String get selectApp => 'Pilih aplikasi';

  @override
  String get addApp => 'Tambah aplikasi';

  @override
  String get whitelistEmpty => 'Whitelist masih kosong';

  @override
  String get whitelistOnlyWhenActive =>
      'Whitelist hanya berlaku saat session focus aktif';

  @override
  String get appearanceTitle => 'Tampilan';

  @override
  String get theme => 'Tema';

  @override
  String get alwaysOnDisplay => 'Always-on display (AOD)';

  @override
  String get aodEnabledDescription =>
      'Tetap tampilkan timer di layar selama focus';

  @override
  String get notSupportedOnDevice => 'Tidak didukung di perangkat ini';

  @override
  String get statisticInclusionTitle => 'Cakupan statistic';

  @override
  String get trackFailedSessions => 'Lacak session gagal';

  @override
  String get trackFailedSessionsSubtitle =>
      'Sertakan session gagal dan waktu focus-nya dalam statistic Anda';

  @override
  String get platformBatteryTitle => 'Platform & baterai';

  @override
  String platformLabel(String label) {
    return 'Platform: $label';
  }

  @override
  String get segmentNotifications => 'Notifikasi segment';

  @override
  String get notificationDeepLinkAvailable =>
      'Notifikasi dapat langsung membuka aplikasi';

  @override
  String get deepLinkUnavailable => 'Deep link tidak tersedia di perangkat ini';

  @override
  String get flexibleReminders => 'Pengingat flexible';

  @override
  String get platformNotes => 'Catatan platform';

  @override
  String get batteryOptimization => 'Optimasi baterai';

  @override
  String get batteryOptimizationBody =>
      'Nonaktifkan optimasi baterai untuk aplikasi ini agar timer tetap berjalan andal di latar belakang';

  @override
  String get openBatterySettings => 'Buka setelan baterai';

  @override
  String get errorFocusPermissionDenied => 'Izin focus ditolak';

  @override
  String get errorSaveSettingsFailed => 'Gagal menyimpan setelan';

  @override
  String get errorStorageWriteFailed => 'Gagal menulis ke penyimpanan';

  @override
  String get sessionStatusCompleted => 'Selesai';

  @override
  String get sessionStatusAbandoned => 'Ditinggalkan';

  @override
  String get sessionStatusFailed => 'Gagal';

  @override
  String get sessionStatusManual => 'Manual';

  @override
  String get sessionStatusActive => 'Aktif';

  @override
  String get durationZero => '0m';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String todayDate(String date) {
    return 'Hari ini, $date';
  }

  @override
  String yesterdayDate(String date) {
    return 'Kemarin, $date';
  }

  @override
  String get deletedTag => 'Tag terhapus';

  @override
  String get languageUnsupported => 'Bahasa tidak didukung.';

  @override
  String get weekStartInvalid => 'Hari awal minggu tidak valid.';

  @override
  String violationThresholdOutOfRange(int min, int max) {
    return 'Ambang pelanggaran harus antara $min–$max detik.';
  }

  @override
  String get alertToneFocusSuccessInvalid => 'Nada fokus selesai tidak valid.';

  @override
  String get alertToneBreakOverInvalid => 'Nada istirahat selesai tidak valid.';

  @override
  String get alertToneFocusFailureInvalid => 'Nada fokus gagal tidak valid.';

  @override
  String get whitelistEntryEmpty => 'Entri whitelist tidak boleh kosong.';

  @override
  String get notificationFocusing => 'Sedang focus';

  @override
  String get notificationResting => 'Sedang istirahat';

  @override
  String get notificationExit => 'Ketuk untuk kembali ke session';

  @override
  String get notificationSessionStoppedTitle => 'Session dihentikan';

  @override
  String get notificationSessionStoppedBody => 'Session Anda telah dihentikan';

  @override
  String get notificationFocusCompleteTitle => 'Focus selesai';

  @override
  String get notificationBreakCompleteTitle => 'Istirahat selesai';

  @override
  String get notificationTimeForBreak => 'Waktunya istirahat';

  @override
  String get notificationTimeForFocus => 'Waktunya focus';

  @override
  String get notificationFocusFailedTitle => 'Session focus gagal';

  @override
  String get notificationFocusViolationBody =>
      'Anda meninggalkan aplikasi selama mode focus';

  @override
  String get notificationFocusReminderTitle => 'Pengingat focus';

  @override
  String get notificationFocusReminderBody =>
      'Tetap fokus, session Anda masih berjalan';

  @override
  String get capNotificationInitFailed =>
      'Layanan notifikasi gagal dimulai. Peringatan tidak tersedia; coba mulai ulang aplikasi.';

  @override
  String get capAndroidNeedsNotificationPermission =>
      'Notifikasi segment memerlukan izin notifikasi.';

  @override
  String get capIosStrictBackgroundOnly =>
      'iOS: deteksi app lain tidak tersedia — Strict hanya saat app ke background.';

  @override
  String get capIosBackgroundNotificationsBestEffort =>
      'Notifikasi background iOS bersifat best-effort.';

  @override
  String get capDesktopFocusLimited =>
      'Desktop: focus Strict/Whitelist terbatas.';

  @override
  String get capScheduledNotificationsUnreliable =>
      'Notifikasi terjadwal mungkin tidak andal saat app ditutup.';

  @override
  String get capWebFocusDowngradeToLoose =>
      'Web: Strict/Whitelist diturunkan ke Loose.';

  @override
  String get capWebNotificationsNeedActiveTab =>
      'Notifikasi web memerlukan tab aktif atau izin browser.';

  @override
  String get capWebAodWakeLock =>
      'AOD web via Wake Lock — layar harus tetap terlihat.';

  @override
  String get capFocusModesDegradedToLoose =>
      'Mode Strict/Whitelist tidak penuh — sesi berjalan sebagai Loose.';

  @override
  String get capAodUnsupported =>
      'Layar selalu hidup (AOD) tidak didukung di platform ini.';
}
