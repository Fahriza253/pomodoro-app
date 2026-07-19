import 'package:pomodoro_app/domain/common/app_error.dart';

/// Application-layer result alias ([API_CONTRACT](../docs/system/implementation/API_CONTRACT.md)).
typedef AppResult<T> = ({T? value, AppError? error});

extension AppResultX<T> on AppResult<T> {
  bool get isOk => error == null;
  bool get isErr => error != null;
}

AppResult<T> ok<T>([T? value]) => (value: value, error: null);

AppResult<T> err<T>(AppError error) => (value: null, error: error);
