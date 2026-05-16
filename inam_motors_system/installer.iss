; Inno Setup script for Inam Motors System
; Build the Flutter release first:  flutter build windows --release
; Then compile this script with Inno Setup (ISCC.exe) or the Inno Setup IDE.

#define MyAppName "Inam Motors System"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Inam Motors"
#define MyAppExeName "inam_motors_system.exe"
#define MyAppSourceDir "build\windows\x64\runner\Release"
#define MyAppIcon "windows\runner\resources\app_icon.ico"

[Setup]
AppId={{B4E7C9F2-3D1A-4B8E-9A2F-7C5D8E1F3A6B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=installer_output
OutputBaseFilename=InamMotorsSystem_Setup_v{#MyAppVersion}
SetupIconFile={#MyAppIcon}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce

[Files]
; Main executable
Source: "{#MyAppSourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; All DLLs in the release folder
Source: "{#MyAppSourceDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion
; The 'data' folder (Flutter assets, ICU data, etc.) — recursive
Source: "{#MyAppSourceDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
