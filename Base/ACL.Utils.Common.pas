{*********************************************}
{*                                           *}
{*        Artem's Components Library         *}
{*             System Utilities              *}
{*                                           *}
{*            (c) Artem Izmaylov             *}
{*                 2006-2022                 *}
{*                www.aimp.ru                *}
{*                                           *}
{*********************************************}

unit ACL.Utils.Common;

{$I ACL.Config.inc}
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows,
  Messages,
{$IFNDEF ACL_BASE_NOVCL}
  Graphics,
  System.UITypes,
{$ENDIF}
  // System
  Types,
  SysUtils,
  Classes,
  Math;

const
  SIZE_ONE_KILOBYTE = 1024;
  SIZE_ONE_MEGABYTE = SIZE_ONE_KILOBYTE * SIZE_ONE_KILOBYTE;
  SIZE_ONE_GIGABYTE = SIZE_ONE_KILOBYTE * SIZE_ONE_MEGABYTE;

  InvalidPoint: TPoint = (X: -1; Y: -1);
  InvalidSize: TSize = (cx: -1; cy: -1);
  NullPoint: TPoint = (X: 0; Y: 0);
  NullRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);
  NullSize: TSize = (cx: 0; cy: 0);
  Signs: array[Boolean] of Integer = (-1, 1);

type
{$SCOPEDENUMS ON}
  TACLBoolean = (Default, False, True);
{$SCOPEDENUMS OFF}

const
  acDefault = TACLBoolean.Default;
  acFalse = TACLBoolean.False;
  acTrue = TACLBoolean.True;

type
  TObjectMethod = procedure of object;
  TProcedureRef = reference to procedure;

  _U = UnicodeString; // For short naming coversion

{$IFDEF FPC}
  TProc = reference to procedure;
  TProc<T> = reference to procedure (Arg1: T);
  TProc<T1,T2> = reference to procedure (Arg1: T1; Arg2: T2);
  TProc<T1,T2,T3> = reference to procedure (Arg1: T1; Arg2: T2; Arg3: T3);
  TProc<T1,T2,T3,T4> = reference to procedure (Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4);

  TFunc<TResult> = reference to function: TResult;
  TFunc<T,TResult> = reference to function (Arg1: T): TResult;
  TFunc<T1,T2,TResult> = reference to function (Arg1: T1; Arg2: T2): TResult;
  TFunc<T1,T2,T3,TResult> = reference to function (Arg1: T1; Arg2: T2; Arg3: T3): TResult;
  TFunc<T1,T2,T3,T4,TResult> = reference to function (Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4): TResult;

  TPredicate<T> = reference to function (Arg1: T): Boolean;
{$ENDIF}

  { IObject }

  IObject = interface
  ['{4944656C-7068-6954-6167-4F626A656374}']
    function GetObject: TObject;
  end;

  { IStringReceiver }

  IStringReceiver = interface
  ['{F07E42B3-2680-425D-9119-253D300AE4CF}']
    procedure Add(const S: UnicodeString);
  end;

  TACLStringEnumProc = reference to procedure (const S: UnicodeString);

  TACLFontData = array[0..3] of UnicodeString;

  TACLBooleanHelper = record helper for TACLBoolean
  public
    class function From(AValue: Boolean): TACLBoolean; static;
  end;

  { TProcessHelper }

  TExecuteOption = (eoWaitForTerminate, eoShowGUI);
  TExecuteOptions = set of TExecuteOption;

  TProcessHelper = class
  public
    class function Execute(const ACmdLine: UnicodeString; AOptions: TExecuteOptions = [eoShowGUI];
      AOutputData: TStream = nil; AErrorData: TStream = nil; AProcessInfo: PProcessInformation = nil;
      AExitCode: PCardinal = nil): LongBool; overload;
    class function Execute(const ACmdLine: UnicodeString; ALog: IStringReceiver;
      AOptions: TExecuteOptions = [eoShowGUI]): LongBool; overload;
    // Wow64
    class function IsWow64: LongBool; overload;
    class function IsWow64(AProcess: THandle): LongBool; overload;
    class function IsWow64Window(AWindow: HWND): LongBool;
    class function Wow64SetFileSystemRedirection(AValue: Boolean): LongBool;
  end;

  { TACLInterfaceHelper }

  TACLInterfaceHelper<T: IUnknown> = class
  public
    class function GetGuid: TGUID; static;
  end;

  { Safe }

  Safe = class
  public
    class function Cast(const AObject: TObject; const AClass: TClass; out AValue): Boolean; inline;
  end;

var
  IsWin8OrLater: Boolean;
  IsWin10OrLater: Boolean;
  IsWin11OrLater: Boolean;
  IsWinSeven: Boolean;
  IsWinSevenOrLater: Boolean;
  IsWinVistaOrLater: Boolean;
  IsWinXP: Boolean;
  IsWine: Boolean;

  InvariantFormatSettings: TFormatSettings;

  acLangSizeSuffixB: UnicodeString = 'B';
  acLangSizeSuffixKB: UnicodeString = 'KB';
  acLangSizeSuffixMB: UnicodeString = 'MB';
  acLangSizeSuffixGB: UnicodeString = 'GB';

// Conversion
{$MESSAGE 'TODO-Move these functions to Utils.Strings'}
{$IFNDEF ACL_BASE_NOVCL}
function FontStyleDecode(const Style: TFontStyles): Byte;
function FontStyleEncode(Style: Integer): TFontStyles;
function FontToString(AFont: TFont): UnicodeString; overload;
function FontToString(const AName: UnicodeString; AColor: TColor; AHeight: Integer; AStyle: TFontStyles): UnicodeString; overload;
procedure StringToFont(const S: UnicodeString; const Font: TFont);
procedure StringToFontData(const S: UnicodeString; out AFontData: TACLFontData);
{$ENDIF}
function acPointToString(const P: TPoint): UnicodeString;
function acRectToString(const R: TRect): UnicodeString;
function acSizeToString(const S: TSize): UnicodeString;
function acStringToPoint(const S: UnicodeString): TPoint;
function acStringToRect(const S: UnicodeString): TRect;
function acStringToSize(const S: UnicodeString): TSize;

// Formatting
{$MESSAGE 'TODO-Move these functions to Utils.Strings'}
function FormatSize(const AValue: Int64; AAllowGigaBytes: Boolean = True): UnicodeString;
function TrackFormat(ATrack: Integer): UnicodeString;
function acFormatFloat(const AFormat: UnicodeString; const AValue: Double; AShowPlusSign: Boolean): UnicodeString; overload;
function acFormatFloat(const AFormat: UnicodeString; const AValue: Double; const ADecimalSeparator: Char = '.'): UnicodeString; overload;

// HMODULE
function acGetProcessFileName(const AWindowHandle: HWND; out AFileName: UnicodeString): Boolean;
function acGetProcAddress(ALibHandle: HMODULE; AProcName: PChar; var AResult: Boolean): Pointer;
function acLoadLibrary(const AFileName: UnicodeString; AFlags: Cardinal = 0): HMODULE;
function acModuleFileName(AModule: HMODULE): UnicodeString; inline;
function acModuleHandle(const AFileName: UnicodeString): HMODULE;

// Window Handles
function acGetWindowRect(AHandle: HWND): TRect;
function acFindWindow(const AClassName: UnicodeString): HWND;
function acGetClassName(Handle: HWND): UnicodeString;
function acGetWindowText(AHandle: HWND): UnicodeString;
procedure acSetWindowText(AHandle: HWND; const AText: UnicodeString);
procedure acSwitchToThisWindow(AHandle: HWND);

// System
procedure MinimizeMemoryUsage;

function GetExactTickCount: Int64;
function TickCountToTime(const ATicks: Int64): Cardinal;
function TimeToTickCount(const ATime: Cardinal): Int64;

// Interfaces
procedure acGetInterface(const Instance: IInterface; const IID: TGUID; out Intf); overload;
procedure acGetInterface(const Instance: TObject; const IID: TGUID; out Intf); overload;
function acGetInterfaceEx(const Instance: IInterface; const IID: TGUID; out Intf): HRESULT; overload;
function acGetInterfaceEx(const Instance: TObject; const IID: TGUID; out Intf): HRESULT; overload;

procedure acExchangeInt64(var AValue1, AValue2: Int64); inline;
procedure acExchangeIntegers(var AValue1, AValue2); inline;
procedure acExchangePointers(var AValue1, AValue2); inline;
function acBoolToHRESULT(AValue: Boolean): HRESULT; inline;
function acGenerateGUID: UnicodeString;
function acObjectUID(AObject: TObject): string;
function acSetThreadErrorMode(Mode: DWORD): DWORD;
procedure FreeMemAndNil(var P: Pointer);
function IfThen(AValue: Boolean; ATrue: TACLBoolean; AFalse: TACLBoolean): TACLBoolean; overload;
function LParamToPointer(const LParam: LPARAM): Pointer;
function PointerToLParam(const Ptr: Pointer): LPARAM;

{$IFDEF FPC}
function InterlockedExchangePointer(var ATarget: Pointer; const ASource: Pointer): Pointer;
{$ENDIF}
implementation

uses
{$IFNDEF ACL_BASE_NOVCL}
  Vcl.Forms,
{$ENDIF}
  TypInfo,
  // ACL
  ACL.Utils.FileSystem,
  ACL.Utils.Strings;

type
  TGetThreadErrorMode = function: DWORD; stdcall;
  TSetThreadErrorMode = function (NewMode: DWORD; out OldMode: DWORD): LongBool; stdcall;
  TGetModuleFileNameExW = function (hProcess: THandle; hModule: HMODULE; lpFilename: LPCWSTR; nSize: DWORD): DWORD; stdcall;

var
  FPerformanceCounterFrequency: Int64 = 0;
  FGetModuleFileNameEx: TGetModuleFileNameExW = nil;
  FGetThreadErrorMode: TGetThreadErrorMode = nil;
  FSetThreadErrorMode: TSetThreadErrorMode = nil;

procedure CheckWindowsVersion;
begin
  IsWine := GetProcAddress(GetModuleHandle('ntdll.dll'), 'wine_get_version') <> nil;
  IsWinVistaOrLater := CheckWin32Version(6, 0);
  IsWinSevenOrLater := CheckWin32Version(6, 1);
  IsWin8OrLater := CheckWin32Version(6, 2);
  IsWinXP := CheckWin32Version(5, 1) and not IsWinVistaOrLater;
  IsWinSeven := IsWinSevenOrLater and not IsWin8OrLater;
  IsWin10OrLater := CheckWin32Version(10, 0);
  IsWin11OrLater := CheckWin32Version(10, 0) and (Win32BuildNumber >= 22000);
end;

function acSetThreadErrorMode(Mode: DWORD): DWORD;
begin
 if Assigned(FSetThreadErrorMode) then
 begin
   if not FSetThreadErrorMode(Mode, Result) then
     Result := FGetThreadErrorMode;
 end
 else
   Result := SetErrorMode(Mode);
end;

{$IFDEF FPC}
function InterlockedExchangePointer(var ATarget: Pointer; const ASource: Pointer): Pointer;
begin
{$push}
  {$hints off}
  {$IFDEF CPUX64}
    Result := Pointer(InterlockedExchange64(QWORD(ATarget), QWORD(ASource)));
  {$ELSE}
    Result := Pointer(InterlockedExchange(DWORD(ATarget), DWORD(ASource)));
  {$ENDIF}
{$pop}
end;

{$ENDIF}

// ---------------------------------------------------------------------------------------------------------------------
// Conversion
// ---------------------------------------------------------------------------------------------------------------------

function acStringToPoint(const S: UnicodeString): TPoint;
begin
  Result := NullPoint;
  acExplodeStringAsIntegerArray(S, ',', @Result.X, 2);
end;

function acStringToSize(const S: UnicodeString): TSize;
begin
  Result := NullSize;
  acExplodeStringAsIntegerArray(S, ',', @Result.cx, 2);
end;

function acStringToRect(const S: UnicodeString): TRect;
begin
  Result := NullRect;
  acExplodeStringAsIntegerArray(S, ',', @Result.Left, 4);
end;

function acPointToString(const P: TPoint): UnicodeString;
begin
  Result := Format('%d,%d', [P.X, P.Y]);
end;

function acSizeToString(const S: TSize): UnicodeString;
begin
  Result := Format('%d,%d', [S.cx, S.cy]);
end;

function acRectToString(const R: TRect): UnicodeString;
begin
  Result := Format('%d,%d,%d,%d', [R.Left, R.Top, R.Right, R.Bottom]);
end;

{$IFNDEF ACL_BASE_NOVCL}
function FontStyleEncode(Style: Integer): TFontStyles;
begin
  Result := [];
  if 1 and Style = 1 then
    Result := Result + [fsItalic];
  if 2 and Style = 2 then
    Result := Result + [fsBold];
  if 4 and Style = 4 then
    Result := Result + [fsUnderline];
  if 8 and Style = 8 then
    Result := Result + [fsStrikeOut];
end;

function FontStyleDecode(const Style: TFontStyles): Byte;
begin
  Result := 0;
  if fsItalic in Style then
    Result := 1;
  if fsBold in Style then
    Result := Result or 2;
  if fsUnderline in Style then
    Result := Result or 4;
  if fsStrikeOut in Style then
    Result := Result or 8;
end;

function FontToString(const AName: UnicodeString;
  AColor: TColor; AHeight: Integer; AStyle: TFontStyles): UnicodeString; overload;
begin
  Result := Format('%s,%d,%d,%d', [AName, AColor, AHeight, FontStyleDecode(AStyle)]);
end;

function FontToString(AFont: TFont): UnicodeString; overload;
begin
  Result := FontToString(AFont.Name, AFont.Color, AFont.Height, AFont.Style);
end;

procedure StringToFont(const S: UnicodeString; const Font: TFont);
var
  AFontData: TACLFontData;
begin
  StringToFontData(S, AFontData);
  Font.Name := AFontData[0];
  Font.Color := StrToIntDef(AFontData[1], 0);
  Font.Height := StrToIntDef(AFontData[2], 0);
  Font.Style := FontStyleEncode(StrToIntDef(AFontData[3], 0));
end;

procedure StringToFontData(const S: UnicodeString; out AFontData: TACLFontData);
var
  ALen: Integer;
  APos: Integer;
  AStart, AScan: PWideChar;
begin
  AScan := PWideChar(S);
  ALen := Length(S);
  AStart := AScan;
  APos := 0;
  while (ALen >= 0) and (APos <= High(AFontData)) do
  begin
    if (AScan^ = ',') or (ALen = 0) then
    begin
      SetString(AFontData[APos], AStart, (NativeUInt(AScan) - NativeUInt(AStart)) div SizeOf(WideChar));
      AStart := AScan;
      Inc(AStart);
      Inc(APos);
    end;
    Dec(ALen);
    Inc(AScan);
  end;
end;
{$ENDIF}

// ---------------------------------------------------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------------------------------------------------

function FormatSize(const AValue: Int64; AAllowGigaBytes: Boolean = True): UnicodeString;
begin
  if AValue < 0 then
    Exit('-' + FormatSize(-AValue, AAllowGigaBytes));

  if AValue < SIZE_ONE_KILOBYTE then
    Result := acIntToStr(AValue) + ' ' + acLangSizeSuffixB
  else if AValue < SIZE_ONE_MEGABYTE then
    Result := acFormatFloat('0.00', AValue / SIZE_ONE_KILOBYTE) + ' ' + acLangSizeSuffixKB
  else if not AAllowGigaBytes or (AValue < SIZE_ONE_GIGABYTE)then
    Result := acFormatFloat('0.00', AValue / SIZE_ONE_MEGABYTE) + ' ' + acLangSizeSuffixMB
  else
    Result := acFormatFloat('0.00', AValue / SIZE_ONE_GIGABYTE) + ' ' + acLangSizeSuffixGB;
end;

function TrackFormat(ATrack: Integer): UnicodeString;
begin
  if (ATrack >= 0) and (ATrack < 10) then
    Result := '0' + acIntToStr(ATrack)
  else
    Result := acIntToStr(ATrack);
end;

function acFormatFloat(const AFormat: UnicodeString; const AValue: Double; const ADecimalSeparator: Char = '.'): UnicodeString;
var
  AFormatSettings: TFormatSettings;
begin
  AFormatSettings := FormatSettings;
  AFormatSettings.DecimalSeparator := ADecimalSeparator;
{$IFDEF FPC}
  Result := acStringToUnicode(FormatFloat(acUnicodeToString(AFormat), AValue, AFormatSettings));
{$ELSE}
  Result := FormatFloat(AFormat, AValue, AFormatSettings);
{$ENDIF}
end;

function acFormatFloat(const AFormat: UnicodeString; const AValue: Double; AShowPlusSign: Boolean): UnicodeString;
const
  SignsMap: array[Boolean] of UnicodeString = ('', '+');
begin
  Result := SignsMap[(AValue >= 0) and AShowPlusSign] + acFormatFloat(AFormat, AValue);
end;

//==============================================================================
// HMODULE
//==============================================================================

function acGetProcessFileName(const AWindowHandle: HWND; out AFileName: UnicodeString): Boolean;
var
  AProcess: THandle;
  AProcessID: Cardinal;
begin
  Result := False;
  if (AWindowHandle <> 0) and Assigned(FGetModuleFileNameEx) then
  begin
  {$IFDEF FPC}
    AProcessID := 0;
  {$ENDIF}
    if GetWindowThreadProcessId(AWindowHandle, AProcessID) > 0 then
    begin
      AProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, True, AProcessID);
      if AProcess <> 0 then
      try
      {$IFDEF FPC}
        AFileName := EmptyStrU;
      {$ENDIF}
        SetLength(AFileName, MAX_PATH);
        SetLength(AFileName, FGetModuleFileNameEx(AProcess, 0, PWideChar(AFileName), Length(AFileName)));
        Result := True;
      finally
        CloseHandle(AProcess);
      end;
    end;
  end;
end;

function acGetProcAddress(ALibHandle: HMODULE; AProcName: PChar; var AResult: Boolean): Pointer;
begin
  Result := GetProcAddress(ALibHandle, AProcName);
  AResult := AResult and (Result <> nil);
end;

function acLoadLibrary(const AFileName: UnicodeString; AFlags: Cardinal = 0): HMODULE;
var
  AErrorMode: Integer;
  APrevCurPath: UnicodeString;
begin
  AErrorMode := SetErrorMode(SEM_FailCriticalErrors);
  try
    APrevCurPath := acGetCurrentDir;
    try
      acSetCurrentDir(acExtractFilePath(AFileName));
      if AFlags <> 0 then
        Result := LoadLibraryExW(PWideChar(AFileName), 0, AFlags)
      else
        Result := LoadLibraryW(PWideChar(AFileName));
    finally
      acSetCurrentDir(APrevCurPath);
    end;
  finally
    SetErrorMode(AErrorMode);
  end;
end;

function acModuleHandle(const AFileName: UnicodeString): HMODULE;
begin
  Result := GetModuleHandleW(PWideChar(AFileName));
end;

function acModuleFileName(AModule: HMODULE): UnicodeString;
begin
  Result := acStringToUnicode(GetModuleName(AModule));
end;

// ---------------------------------------------------------------------------------------------------------------------
// Internal Tools
// ---------------------------------------------------------------------------------------------------------------------

function GetExactTickCount: Int64;
begin
  //# https://docs.microsoft.com/ru-ru/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter?redirectedfrom=MSDN
  //# On systems that run Windows XP or later, the function will always succeed and will thus never return zero.
  if not QueryPerformanceCounter(Result) then
    Result := GetTickCount64;
end;

function TickCountToTime(const ATicks: Int64): Cardinal;
begin
  if FPerformanceCounterFrequency = 0 then
    QueryPerformanceFrequency(FPerformanceCounterFrequency);
  Result := (ATicks * 1000) div FPerformanceCounterFrequency;
end;

function TimeToTickCount(const ATime: Cardinal): Int64;
begin
  if FPerformanceCounterFrequency = 0 then
    QueryPerformanceFrequency(FPerformanceCounterFrequency);
  Result := (Int64(ATime) * FPerformanceCounterFrequency) div 1000;
end;

procedure FreeMemAndNil(var P: Pointer);
begin
  if P <> nil then
  begin
    FreeMem(P);
    P := nil;
  end;
end;

function IfThen(AValue: Boolean; ATrue: TACLBoolean; AFalse: TACLBoolean): TACLBoolean;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function LParamToPointer(const LParam: LPARAM): Pointer;
begin
{$IFDEF FPC}
  {$push}
  {$hints off}
{$ENDIF}
  Result := Pointer(LParam);
{$IFDEF FPC}
  {$pop}
{$ENDIF}
end;

function PointerToLParam(const Ptr: Pointer): LPARAM;
begin
{$IFDEF FPC}
  {$push}
  {$hints off}
{$ENDIF}
  Result := LPARAM(Ptr);
{$IFDEF FPC}
  {$pop}
{$ENDIF}
end;

procedure acGetInterface(const Instance: IInterface; const IID: TGUID; out Intf);
begin
  if not Supports(Instance, IID, Intf) then
    Pointer(Intf) := nil;
end;

procedure acGetInterface(const Instance: TObject; const IID: TGUID; out Intf);
begin
  if not Supports(Instance, IID, Intf) then
    Pointer(Intf) := nil;
end;

function acGetInterfaceEx(const Instance: IInterface; const IID: TGUID; out Intf): HRESULT;
begin
  if Instance <> nil then
    Result := Instance.QueryInterface(IID, Intf)
  else
    Result := E_NOINTERFACE;
end;

function acGetInterfaceEx(const Instance: TObject; const IID: TGUID; out Intf): HRESULT;
begin
  if Instance = nil then
    Result := E_HANDLE
  else
    if Supports(Instance, IID, Intf) then
      Result := S_OK
    else
      Result := E_NOINTERFACE;
end;

procedure acExchangeInt64(var AValue1, AValue2: Int64);
var
  ATempValue: Int64;
begin
  ATempValue := AValue1;
  AValue1 := AValue2;
  AValue2 := ATempValue;
end;

procedure acExchangeIntegers(var AValue1, AValue2);
var
  ATempValue: Integer;
begin
  ATempValue := Integer(AValue1);
  Integer(AValue1) := Integer(AValue2);
  Integer(AValue2) := ATempValue;
end;

procedure acExchangePointers(var AValue1, AValue2);
var
  ATempValue: Pointer;
begin
  ATempValue := Pointer(AValue1);
  Pointer(AValue1) := Pointer(AValue2);
  Pointer(AValue2) := ATempValue;
end;

function acBoolToHRESULT(AValue: Boolean): HRESULT;
begin
  if AValue then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function acGenerateGUID: UnicodeString;
var
  G: TGUID;
begin
  CreateGUID(G);
  Result := acStringToUnicode(GUIDToString(G));
end;

function acObjectUID(AObject: TObject): string;
begin
  Result := IntToHex(NativeUInt(AObject), SizeOf(Pointer) * 2);
end;

procedure MinimizeMemoryUsage;
begin
  SetProcessWorkingSetSize(GetCurrentProcess, NativeUInt(-1), NativeUInt(-1));
end;

//==============================================================================
// Window Handle
//==============================================================================

function acGetClassName(Handle: HWND): UnicodeString;
var
  ABuf: array[0..64] of WideChar;
begin
  ZeroMemory(@ABuf[0], SizeOf(ABuf));
  GetClassNameW(Handle, @ABuf[0], Length(ABuf));
  Result := ABuf;
end;

function acGetWindowRect(AHandle: HWND): TRect;
begin
{$IFDEF FPC}
  Result := NullRect;
{$ENDIF}
  if not GetWindowRect(AHandle, Result) then
    Result := NullRect;
end;

function acFindWindow(const AClassName: UnicodeString): HWND;
begin
  Result := FindWindowW(PWideChar(AClassName), nil);
end;

function acGetWindowText(AHandle: HWND): UnicodeString;
var
  B: array[BYTE] of WideChar;
begin
  GetWindowTextW(AHandle, @B[0], Length(B));
  Result := B;
end;

procedure acSetWindowText(AHandle: HWND; const AText: UnicodeString);
begin
  if AHandle <> 0 then
  begin
    if IsWindowUnicode(AHandle) then
      SetWindowTextW(AHandle, PWideChar(AText))
    else
      DefWindowProcW(AHandle, WM_SETTEXT, 0, PointerToLParam(PWideChar(AText))); // fix for app handle
  end;
end;

procedure acSwitchToThisWindow(AHandle: HWND);
var
  AInput: TInput;
begin
  ZeroMemory(@AInput, SizeOf(AInput));
  SendInput(INPUT_KEYBOARD, {$IFDEF FPC}@{$ENDIF}AInput, SizeOf(AInput));
  SetForegroundWindow(AHandle);
  SetFocus(AHandle);
end;

{ TACLBooleanHelper }

class function TACLBooleanHelper.From(AValue: Boolean): TACLBoolean;
begin
  if AValue then
    Result := TACLBoolean.True
  else
    Result := TACLBoolean.False;
end;

{ TProcessHelper }

class function TProcessHelper.Execute(const ACmdLine: UnicodeString;
  AOptions: TExecuteOptions = [eoShowGUI]; AOutputData: TStream = nil; AErrorData: TStream = nil;
  AProcessInfo: PProcessInformation = nil; AExitCode: PCardinal = nil): LongBool;

  function CreateProcess(var PI: TProcessInformation; var SI: TStartupInfoW): LongBool;
  var
    ATempCmdLine: WideString; // must be WideString!
  begin
    ATempCmdLine := ACmdLine;
    Result := CreateProcessW(nil, PWideChar(ATempCmdLine), nil, nil, True, 0, nil, nil, SI, PI);
    Result := Result and (WaitForInputIdle(PI.hProcess, 5000) <> WAIT_TIMEOUT); // Function returns WAIT_FAILED for console app
  end;

  procedure ReadData(AInputStream: THandleStream; AOutputStream: TStream);
  var
    AAvailable: Cardinal;
    ATempData: array of Byte;
  begin
    ATempData := nil;
    if (AInputStream <> nil) and (AOutputStream <> nil) then
    repeat
      AAvailable := 0;
      if PeekNamedPipe(AInputStream.Handle, nil, 0, nil, @AAvailable, nil) and (AAvailable > 0) then
      begin
        if AAvailable > Cardinal(Length(ATempData)) then
          SetLength(ATempData, AAvailable);
        AInputStream.ReadBuffer(ATempData[0], AAvailable);
        AOutputStream.WriteBuffer(ATempData[0], AAvailable);
      end;
    until AAvailable = 0;
  end;

var
  AProcessInformation: TProcessInformation;
  ASecurityAttrs: TSecurityAttributes;
  AStartupInfo: TStartupInfoW;
  AStdErrorRead, AStdErrorWrite: THandle;
  AStdErrorStream: THandleStream;
  AStdOutputRead, AStdOutputWrite: THandle;
  AStdOutputStream: THandleStream;
begin
  AStdErrorRead := 0;
  AStdErrorWrite := 0;
  AStdOutputRead := 0;
  AStdOutputWrite := 0;
  Result := False;

  ZeroMemory(@AStartupInfo, SizeOf(AStartupInfo));
  ZeroMemory(@AProcessInformation, SizeOf(AProcessInformation));
  AStartupInfo.cb := SizeOf(TStartupInfo);
  AStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  AStartupInfo.wShowWindow := IfThen(eoShowGUI in AOptions, SW_SHOW, SW_HIDE);

  if (eoWaitForTerminate in AOptions) and ((AOutputData <> nil) or (AErrorData <> nil)) then
  begin
    ZeroMemory(@ASecurityAttrs, SizeOf(ASecurityAttrs));
    ASecurityAttrs.nLength := SizeOf(SECURITY_ATTRIBUTES);
    ASecurityAttrs.bInheritHandle := True;
    if not CreatePipe(AStdOutputRead, AStdOutputWrite, @ASecurityAttrs, 0) then Exit;
    if not CreatePipe(AStdErrorRead, AStdErrorWrite, @ASecurityAttrs, 0) then Exit;

    AStartupInfo.dwFlags := AStartupInfo.dwFlags or STARTF_USESTDHANDLES;
    AStartupInfo.hStdOutput := AStdOutputWrite;
    AStartupInfo.hStdError := AStdErrorWrite;
  end;

  // Warning! The Unicode version of this function, CreateProcessW, can modify the
  // contents of this string. Therefore, this parameter cannot be a pointer to
  // read-only memory (such as a const variable or a literal string). If this
  // parameter is a constant string, the function may cause an access violation.
  Result := CreateProcess(AProcessInformation, AStartupInfo);
  if Result then
  begin
    if Assigned(AProcessInfo) then
      AProcessInfo^ := AProcessInformation;
    if eoWaitForTerminate in AOptions then
    try
      if (AOutputData <> nil) or (AErrorData <> nil) then
      begin
        AStdErrorStream := THandleStream.Create(AStdErrorRead);
        AStdOutputStream := THandleStream.Create(AStdOutputRead);
        try
          repeat
            ReadData(AStdErrorStream, AErrorData);
            ReadData(AStdOutputStream, AOutputData);
          until WaitForSingleObject(AProcessInformation.hProcess, 10) = WAIT_OBJECT_0;
          ReadData(AStdErrorStream, AErrorData);
          ReadData(AStdOutputStream, AOutputData);
        finally
          AStdOutputStream.Free;
          AStdErrorStream.Free;
        end;
      end
      else
        WaitForSingleObject(AProcessInformation.hProcess, INFINITE);

      if AExitCode <> nil then
        GetExitCodeProcess(AProcessInformation.hProcess, AExitCode^);
    finally
      CloseHandle(AProcessInformation.hThread);
      CloseHandle(AProcessInformation.hProcess);
    end;
  end;

  CloseHandle(AStdOutputRead);
  CloseHandle(AStdOutputWrite);
  CloseHandle(AStdErrorRead);
  CloseHandle(AStdErrorWrite);
end;

class function TProcessHelper.Execute(const ACmdLine: UnicodeString;
  ALog: IStringReceiver; AOptions: TExecuteOptions = [eoShowGUI]): LongBool;

  procedure Log(const S: string);
  begin
    if ALog <> nil then
      ALog.Add(acStringToUnicode(S));
  end;

var
  AErrorData: TStringStream;
  AOutputData: TStringStream;
begin
  AErrorData := TStringStream.Create;
  AOutputData := TStringStream.Create;
  try
    Log('Executing: ' + acUnicodeToString(ACmdLine));
    Result := Execute(ACmdLine, AOptions, AOutputData, AErrorData);
    if Result then
    begin
      Log(AOutputData.DataString);
      Log(AErrorData.DataString);
    end
    else
      Log(SysErrorMessage(GetLastError));
  finally
    AOutputData.Free;
    AErrorData.Free;
  end;
end;

class function TProcessHelper.IsWow64(AProcess: THandle): LongBool;
type
  TIsWow64ProcessProc = function (hProcess: THandle; out AValue: LongBool): LongBool; stdcall;
var
  ALibHandle: THandle;
  AWow64Proc: TIsWow64ProcessProc;
begin
  ALibHandle := GetModuleHandle(kernel32);
  AWow64Proc := TIsWow64ProcessProc(GetProcAddress(ALibHandle, 'IsWow64Process'));
  if not (Assigned(AWow64Proc) and AWow64Proc(AProcess, Result)) then
    Result := False;
end;

class function TProcessHelper.IsWow64: LongBool;
begin
{$IFDEF CPUX64}
  Result := False;
{$ELSE}
  Result := IsWow64(GetCurrentProcess);
{$ENDIF}
end;

class function TProcessHelper.IsWow64Window(AWindow: HWND): LongBool;
var
  AProcessID: Cardinal;
  AProcessHandle: THandle;
begin
  Result := False;
{$IFDEF FPC}
  AProcessID := 0;
{$ENDIF}
  if GetWindowThreadProcessId(AWindow, AProcessID) <> 0 then
  begin
    AProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION, True, AProcessID);
    if AProcessHandle <> 0 then
    try
      Result := IsWow64(AProcessHandle);
    finally
      CloseHandle(AProcessHandle);
    end;
  end;
end;

class function TProcessHelper.Wow64SetFileSystemRedirection(AValue: Boolean): LongBool;
type
  TWow64SetProc = function (AValue: LongBool): LongBool; stdcall;
var
  ALibHandle: THandle;
  AWow64SetProc: TWow64SetProc;
begin
  ALibHandle := GetModuleHandle(kernel32);
  AWow64SetProc := TWow64SetProc(GetProcAddress(ALibHandle, 'Wow64EnableWow64FsRedirection'));
  Result := Assigned(AWow64SetProc) and AWow64SetProc(AValue);
end;

{ TACLInterfaceHelper }

class function TACLInterfaceHelper<T>.GetGuid: TGUID;
begin
  Result := GetTypeData(TypeInfo(T))^.GUID;
end;

{ Safe }

class function Safe.Cast(const AObject: TObject; const AClass: TClass; out AValue): Boolean;
begin
  Result := (AObject <> nil) and AObject.InheritsFrom(AClass);
  if Result then
    TObject(AValue) := AObject
  else
    TObject(AValue) := nil;
end;

initialization
  FGetThreadErrorMode := GetProcAddress(GetModuleHandle(kernel32), 'GetThreadErrorMode');
  FSetThreadErrorMode := GetProcAddress(GetModuleHandle(kernel32), 'SetThreadErrorMode');
  FGetModuleFileNameEx := GetProcAddress(LoadLibrary('PSAPI.dll'), 'GetModuleFileNameExW');
{$IFDEF FPC}
  GetLocaleFormatSettings(LOCALE_INVARIANT, InvariantFormatSettings);
{$ELSE}
  InvariantFormatSettings := TFormatSettings.Invariant;
{$ENDIF}
  CheckWindowsVersion;
end.
