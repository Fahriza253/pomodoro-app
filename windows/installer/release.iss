; End-user installer. Build with flutter build windows --release first.
; The release MSVC runtime DLLs are bundled app-local (see the build howto),
; so target machines need no Visual C++ prerequisites.
#define BundleDir AddBackslash(SourcePath) + "..\..\build\windows\x64\runner\Release"
#define AppExe "pomodoro_app.exe"
#define AppVersion GetVersionNumbersString(BundleDir + "\" + AppExe)

[Setup]
; Keep this identity stable so subsequent installers update in place.
AppId=com.dpzstudio.pomodoro
AppName=Pomodoro
AppVersion={#AppVersion}
AppPublisher=com.dpzstudio
DefaultDirName={localappdata}\Programs\Pomodoro
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#AppExe}
SetupIconFile=..\runner\resources\app_icon.ico
OutputDir=..\..\build\windows\installer
OutputBaseFilename=pomodoro_{#AppVersion}_setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Include data, plugin DLLs, native assets, and the app-local MSVC runtime with the executable.
Source: "{#BundleDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{userprograms}\Pomodoro"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"
Name: "{userdesktop}\Pomodoro"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: desktopicon

; App data lives outside {app}; uninstall intentionally preserves it.
