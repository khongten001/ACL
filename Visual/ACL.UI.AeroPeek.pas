////////////////////////////////////////////////////////////////////////////////
//
//  Project:   Artem's Controls Library aka ACL
//             v7.0
//
//  Purpose:   Integration with the
//             + Unity Lauch Entry (KDE, Gnome)
//             + Windows 7 Aero Peek
//
//  Author:    Artem Izmaylov
//             © 2006-2026
//             www.aimp.ru
//
//  FPC:       OK
//
unit ACL.UI.AeroPeek;

{$I ACL.Config.inc}

interface

uses
{$IFDEF FPC}
  LCLIntf,
  LCLType,
  Messages,
{$ELSE}
  Winapi.ActiveX,
  Winapi.DwmApi,
  Winapi.Messages,
  Winapi.ObjectArray,
  Winapi.ShlObj,
  Winapi.Windows,
{$ENDIF}
  // System
  {System.}Classes,
  {System.}Math,
  {System.}SysUtils,
  {System.}Types,
  // Vcl
  {Vcl.}Controls,
  {Vcl.}Graphics,
  {Vcl.}ImgList,
  // ACL
  ACL.Classes,
  ACL.Classes.Collections,
  ACL.FileFormats.INI,
  ACL.Geometry,
  ACL.Graphics,
  ACL.Graphics.Images,
  ACL.Timers,
  ACL.UI.Application,
  ACL.UI.Controls.Base,
  ACL.UI.ImageList,
  ACL.Utils.Common,
  ACL.Utils.Shell;

{$IFDEF FPC}
type
  TThumbButton = record end;
  ITaskbarList3 = interface end;
{$ENDIF}

type
  TACLAeroPeek = class;

  { TACLAeroPeekButton }

  TACLAeroPeekButton = class(TCollectionItem)
  strict private
    FEnabled: Boolean;
    FHint: string;
    FImageIndex: Integer;

    procedure SetEnabled(AValue: Boolean);
    procedure SetHint(const AValue: string);
    procedure SetImageIndex(AIndex: Integer);
  public
    constructor Create(Collection: TCollection); override;
    //# Properties
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Hint: string read FHint write SetHint;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
  end;

  { TACLAeroPeekButtons }

  TACLAeroPeekButtons = class(TCollection)
  strict private
    FOwner: TACLAeroPeek;

    function GetItem(Index: Integer): TACLAeroPeekButton;
  protected
    procedure CheckForInitialization;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TACLAeroPeek);
    function Add(const AHint: string; AImageIndex: Integer = -1): TACLAeroPeekButton;
    procedure Clear;
    procedure Delete(Index: Integer);
    //# Properties
    property Items[Index: Integer]: TACLAeroPeekButton read GetItem; default;
  end;

  { TACLAeroPeek }

  TACLAeroPeekProgressState = (appsNormal, appsPaused, appsStopped);

  TACLAeroPeekButtonClickEvent = procedure (Sender: TObject; AButtonIndex: Integer) of object;
  TACLAeroPeekDrawPreviewEvent = procedure (Sender: TObject; ABitmap: TACLBitmap) of object;

  TACLAeroPeek = class(TACLUnknownObject)
  strict private
    FButtons: TACLAeroPeekButtons;
    FForceCustomPreview: Boolean;
    FImageList: TACLImageList;
    FLivePreviewTimer: TACLTimer;
    FOwnerWindow: TWinControl;
    FPrevWndProc: TWndMethod;
    FProgress: Int64;
    FProgressState: TACLAeroPeekProgressState;
    FProgressTotal: Int64;
    FShowProgress: Boolean;
    FShowProgressCanBeIndeterminate: Boolean;
    FShowStatusAsColor: Boolean;
    FTaskBarList: ITaskbarList3;
    FThumbnailSize: TSize;

    FOnButtonClick: TACLAeroPeekButtonClickEvent;
    FOnDrawPreview: TACLAeroPeekDrawPreviewEvent;

    procedure ImageListChanged(Sender: TObject);
    procedure LivePreviewTimerHandler(Sender: TObject);
    procedure OwnerWindowWndProc(var AMessage: TMessage);
    procedure SetForceCustomPreview(AValue: Boolean);
    procedure SetOnDrawPreview(AValue: TACLAeroPeekDrawPreviewEvent);
    procedure SetProgressState(AValue: TACLAeroPeekProgressState);
    procedure SetShowProgress(AValue: Boolean);
    procedure SetShowProgressCanBeIndeterminate(AValue: Boolean);
    procedure SetShowStatusAsColor(AValue: Boolean);
    procedure SetWindowAttribute(AAttr: Cardinal; AValue: LongBool);
  private
  {$IFDEF MSWINDOWS}
    FTaskBarButtons: array [0..6] of TThumbButton;
    FTaskBarButtonsInitialized: Boolean;
  {$ENDIF}
    procedure StartLivePreviewTimer;
    procedure StopLivePreviewTimer;
    procedure SyncButtons;
    procedure SyncProgress;
    procedure SyncState;
    procedure UpdateForceIconicRepresentation;
    procedure UpdateLivePreviews;
  protected
    function CreatePeekPreview(out AHasFrame: Boolean): TACLBitmap;
    procedure DoInitialize; virtual;
    //# Properties
    property OwnerWindow: TWinControl read FOwnerWindow;
    property TaskBarList: ITaskbarList3 read FTaskBarList;
  public
    constructor Create(AOwnerWindow: TWinControl);
    destructor Destroy; override;
    procedure UpdateOverlay(AIcon: HICON; const AHint: string);
    procedure UpdatePreview;
    procedure UpdateProgress(const AProgress, AProgressTotal: Int64);
    //# Properties
    property Buttons: TACLAeroPeekButtons read FButtons;
    property ForceCustomPreview: Boolean read FForceCustomPreview write SetForceCustomPreview;
    property ImageList: TACLImageList read FImageList;
    property ProgressState: TACLAeroPeekProgressState read FProgressState write SetProgressState;
    property ShowProgress: Boolean read FShowProgress write SetShowProgress;
    property ShowProgressCanBeIndeterminate: Boolean read FShowProgressCanBeIndeterminate write SetShowProgressCanBeIndeterminate;
    property ShowStatusAsColor: Boolean read FShowStatusAsColor write SetShowStatusAsColor;
    //# Events
    property OnButtonClick: TACLAeroPeekButtonClickEvent read FOnButtonClick write FOnButtonClick;
    property OnDrawPreview: TACLAeroPeekDrawPreviewEvent read FOnDrawPreview write SetOnDrawPreview;
  public
    class function IsAvailable: Boolean;
  end;

implementation

uses
{$IFDEF LINUX}
  GLib2,
  ACL.Utils.FileSystem.GIO,
{$ENDIF}
  ACL.Utils.Desktop,
  ACL.Utils.Strings;

{$IFDEF FPC}
const
  DWMWA_FORCE_ICONIC_REPRESENTATION = 0;
  DWMWA_HAS_ICONIC_BITMAP           = 0;
{$ELSE}
var
  WM_TASKBARBUTTONCREATED: Cardinal = 0;
{$ENDIF}

{ TACLAeroPeekButton }

constructor TACLAeroPeekButton.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
end;

procedure TACLAeroPeekButton.SetEnabled(AValue: Boolean);
begin
  if AValue <> FEnabled then
  begin
    FEnabled := AValue;
    Changed(True);
  end;
end;

procedure TACLAeroPeekButton.SetHint(const AValue: string);
begin
  if AValue <> FHint then
  begin
    FHint := AValue;
    Changed(True);
  end;
end;

procedure TACLAeroPeekButton.SetImageIndex(AIndex: Integer);
begin
  if AIndex <> FImageIndex then
  begin
    FImageIndex := AIndex;
    Changed(True);
  end;
end;

{ TACLAeroPeekButtons }

constructor TACLAeroPeekButtons.Create(AOwner: TACLAeroPeek);
begin
  inherited Create(TACLAeroPeekButton);
  FOwner := AOwner;
end;

procedure TACLAeroPeekButtons.CheckForInitialization;
begin
{$IFDEF MSWINDOWS}
  if FOwner.FTaskBarButtonsInitialized then
    raise Exception.Create('You cannot add or remove thumb buttons after aero peek initialization');
{$ENDIF}
end;

procedure TACLAeroPeekButtons.Clear;
begin
  CheckForInitialization;
  inherited Clear;
end;

procedure TACLAeroPeekButtons.Delete(Index: Integer);
begin
  CheckForInitialization;
  inherited Delete(Index);
end;

function TACLAeroPeekButtons.Add(const AHint: string; AImageIndex: Integer = -1): TACLAeroPeekButton;
begin
  CheckForInitialization;
  BeginUpdate;
  try
    Result := TACLAeroPeekButton(inherited Add);
    Result.ImageIndex := AImageIndex;
    Result.Hint := AHint;
  finally
    EndUpdate;
  end;
end;

procedure TACLAeroPeekButtons.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  FOwner.SyncButtons;
end;

function TACLAeroPeekButtons.GetItem(Index: Integer): TACLAeroPeekButton;
begin
  Result := TACLAeroPeekButton(inherited Items[Index]);
end;

{ TACLAeroPeek }

constructor TACLAeroPeek.Create(AOwnerWindow: TWinControl);
begin
  inherited Create;
  FShowProgress := True;
  FShowStatusAsColor := True;
  FShowProgressCanBeIndeterminate := True;
  FProgressState := appsNormal;
  FOwnerWindow := AOwnerWindow;
  FImageList := TACLImageList.Create(nil);
  FImageList.OnChange := ImageListChanged;
  FButtons := TACLAeroPeekButtons.Create(Self);
  FThumbnailSize := TSize.Create(0, 0);
{$IFDEF MSWINDOWS}
  if IsAvailable then
  begin
    if Succeeded(CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER, IID_ITaskbarList3, FTaskBarList)) then
    begin
      FPrevWndProc := FOwnerWindow.WindowProc;
      FOwnerWindow.WindowProc := OwnerWindowWndProc;
    end
    else
      FTaskBarList := nil;
  end;
{$ENDIF}
  if OwnerWindow.HandleAllocated then
    DoInitialize;
end;

destructor TACLAeroPeek.Destroy;
begin
  if Assigned(FPrevWndProc) then
  begin
    SetWindowAttribute(DWMWA_HAS_ICONIC_BITMAP, False);
    FOwnerWindow.WindowProc := FPrevWndProc;
  end;
  StopLivePreviewTimer;
  FImageList.OnChange := nil;
  FTaskBarList := nil;
  FreeAndNil(FImageList);
  FreeAndNil(FButtons);
  inherited Destroy;
end;

class function TACLAeroPeek.IsAvailable: Boolean;
begin
{$IFDEF MSWINDOWS}
  Result := acOSCheckVersion(6, 1) and not IsWine;
{$ELSE}
  Result := ShellDesktopEnv = sdeKDE; // +Ubuntu, but not Gnome
{$ENDIF}
end;

procedure TACLAeroPeek.UpdateOverlay(AIcon: HICON; const AHint: string);
begin
{$IFDEF MSWINDOWS}
  if TaskBarList <> nil then
    TaskBarList.SetOverlayIcon(OwnerWindow.Handle, AIcon, PWideChar(AHint));
{$ENDIF}
end;

procedure TACLAeroPeek.UpdatePreview;
begin
{$IFDEF MSWINDOWS}
  if TaskBarList <> nil then
  begin
    if FLivePreviewTimer <> nil then
      UpdateLivePreviews
    else
      DwmInvalidateIconicBitmaps(OwnerWindow.Handle);
  end;
{$ENDIF}
end;

procedure TACLAeroPeek.UpdateProgress(const AProgress, AProgressTotal: Int64);
begin
  if (AProgress <> FProgress) or (AProgressTotal <> FProgressTotal) then
  begin
    FProgress := AProgress;
    FProgressTotal := AProgressTotal;
    SyncProgress;
  end;
end;

procedure TACLAeroPeek.StartLivePreviewTimer;
begin
  if FLivePreviewTimer = nil then
    FLivePreviewTimer := TACLTimer.CreateEx(LivePreviewTimerHandler, 40).Start;
  UpdatePreview;
end;

procedure TACLAeroPeek.StopLivePreviewTimer;
begin
  FreeAndNil(FLivePreviewTimer);
end;

function TACLAeroPeek.CreatePeekPreview(out AHasFrame: Boolean): TACLBitmap;
{$IFDEF MSWINDOWS}
var
  AIcon: TIcon;
  AWindowInfo: TWindowInfo;
  AWindowPlacement: TWindowPlacement;
{$ENDIF}
begin
  Result := nil;
  AHasFrame := False;
{$IFDEF MSWINDOWS}
  if IsIconic(OwnerWindow.Handle) then
  try
    AWindowPlacement.length := SizeOf(AWindowPlacement);
    GetWindowPlacement(OwnerWindow.Handle, AWindowPlacement);
    Result := TACLBitmap.CreateEx(AWindowPlacement.rcNormalPosition, pf32bit, True);
    acFillRect(Result.Canvas, Result.ClientRect,
      TAlphaColor.FromColor(acDragImageColor, acDragImageAlpha));

    AIcon := TIcon.Create;
    try
      AIcon.Handle := SendMessage(OwnerWindow.Handle, WM_GETICON, ICON_BIG, 0);
      if AIcon.HandleAllocated then
        Result.Canvas.Draw((Result.Width - AIcon.Width) div 2, (Result.Height - AIcon.Height) div 2, AIcon);
    finally
      AIcon.Free;
    end;
  except
    FreeAndNil(Result);
  end
  else
  try
    AWindowInfo.cbSize := SizeOf(AWindowInfo);
    GetWindowInfo(OwnerWindow.Handle, AWindowInfo);

    Result := TACLBitmap.CreateEx(AWindowInfo.rcClient, pf32bit, True);
    Result.Canvas.Lock;
    try
      SetWindowOrgEx(Result.Canvas.Handle,
        AWindowInfo.rcClient.Left - AWindowInfo.rcWindow.Left,
        AWindowInfo.rcClient.Top - AWindowInfo.rcWindow.Top, nil);
      SendMessage(OwnerWindow.Handle, WM_PRINT, Result.Canvas.Handle,
        PRF_NONCLIENT or PRF_ERASEBKGND or PRF_CLIENT or PRF_CHILDREN);
    finally
      Result.Canvas.Unlock;
    end;

    AHasFrame :=
      (AWindowInfo.rcWindow <> AWindowInfo.rcClient) and
      (GetWindowLong(OwnerWindow.Handle, GWL_STYLE) and WS_BORDER <> 0) and
      (GetWindowLong(OwnerWindow.Handle, GWL_EXSTYLE) and WS_EX_LAYERED = 0);
  except
    FreeAndNil(Result);
  end
{$ENDIF}
end;

procedure TACLAeroPeek.DoInitialize;
begin
  SyncProgress;
  SyncButtons;
  SyncState;
  UpdatePreview;
  UpdateForceIconicRepresentation;
end;

procedure TACLAeroPeek.SetWindowAttribute(AAttr: Cardinal; AValue: LongBool);
begin
{$IFDEF MSWINDOWS}
  if (TaskBarList <> nil) and OwnerWindow.HandleAllocated then
    DwmSetWindowAttribute(OwnerWindow.Handle, AAttr, @AValue, SizeOf(AValue));
{$ENDIF}
end;

procedure TACLAeroPeek.ImageListChanged(Sender: TObject);
begin
  if Buttons.UpdateCount = 0 then
    SyncButtons;
end;

procedure TACLAeroPeek.OwnerWindowWndProc(var AMessage: TMessage);
begin
{$IFDEF MSWINDOWS}
  case AMessage.Msg of
    WM_COMMAND:
      if HiWord(AMessage.WParam) = THBN_CLICKED then
      begin
        if Assigned(OnButtonClick) then
          OnButtonClick(Self, LoWord(AMessage.WParam));
        Exit;
      end;

    WM_DWMSENDICONICLIVEPREVIEWBITMAP:
      begin
        StartLivePreviewTimer;
        Exit;
      end;

    WM_DWMSENDICONICTHUMBNAIL:
      begin
        FThumbnailSize.cx := HiWord(AMessage.LParam);
        FThumbnailSize.cy := LoWord(AMessage.LParam);
        StartLivePreviewTimer;
        Exit;
      end;
  end;
  FPrevWndProc(AMessage);
  if AMessage.Msg = WM_CREATE then
    DoInitialize;
  if AMessage.Msg = WM_TASKBARBUTTONCREATED then
  begin
    FTaskBarButtonsInitialized := False;
    for var I := Low(FTaskBarButtons) to High(FTaskBarButtons) do
      FTaskBarButtons[I] := Default(TThumbButton);
    DoInitialize;
  end;
{$ENDIF}
end;

procedure TACLAeroPeek.LivePreviewTimerHandler(Sender: TObject);
begin
  if acContains(acGetClassName(MouseCurrentWindow), ['TaskListThumbnailWnd', 'MSTaskListWClass', 'ToolbarWindow32'], True) then
    UpdateLivePreviews
  else
    StopLivePreviewTimer;
end;

procedure TACLAeroPeek.SetForceCustomPreview(AValue: Boolean);
begin
  if FForceCustomPreview <> AValue then
  begin
    FForceCustomPreview := AValue;
    UpdateForceIconicRepresentation;
  end;
end;

procedure TACLAeroPeek.SetOnDrawPreview(AValue: TACLAeroPeekDrawPreviewEvent);
begin
  FOnDrawPreview := AValue;
  UpdateForceIconicRepresentation;
  UpdatePreview;
end;

procedure TACLAeroPeek.SetProgressState(AValue: TACLAeroPeekProgressState);
begin
  if AValue <> FProgressState then
  begin
    FProgressState := AValue;
    SyncProgress;
  end;
end;

procedure TACLAeroPeek.SetShowProgress(AValue: Boolean);
begin
  if AValue <> FShowProgress then
  begin
    FShowProgress := AValue;
    SyncProgress;
  end;
end;

procedure TACLAeroPeek.SetShowProgressCanBeIndeterminate(AValue: Boolean);
begin
  if FShowProgressCanBeIndeterminate <> AValue then
  begin
    FShowProgressCanBeIndeterminate := AValue;
    SyncProgress;
  end;
end;

procedure TACLAeroPeek.SetShowStatusAsColor(AValue: Boolean);
begin
  if AValue <> FShowStatusAsColor then
  begin
    FShowStatusAsColor := AValue;
    SyncProgress;
  end;
end;

procedure TACLAeroPeek.SyncButtons;
{$IFDEF MSWINDOWS}

  procedure PrepareButton(var B: TThumbButton; AItem: TACLAeroPeekButton; AIndex: Integer);
  begin
    B := Default(TThumbButton);
    B.dwMask := THB_BITMAP or THB_FLAGS or THB_TOOLTIP;
    acStrLCopy(@B.szTip[0], AItem.Hint, Length(B.szTip));
    B.dwFlags := IfThen(AItem.Enabled, THBF_ENABLED, THBF_DISABLED);
    B.iBitmap := AItem.ImageIndex;
    B.iId := AIndex;
  end;

var
  LButtonCount: Integer;
begin
  if FTaskBarButtonsInitialized or (Buttons.Count <> 0) then
  begin
    LButtonCount := Min(Buttons.Count, Length(FTaskBarButtons));
    for var I := 0 to LButtonCount - 1 do
      PrepareButton(FTaskBarButtons[I], Buttons[I], I);
    if TaskBarList <> nil then
    try
      if ImageList <> nil then
        TaskBarList.ThumbBarSetImageList(OwnerWindow.Handle, ImageList.Handle);
      if FTaskBarButtonsInitialized then
        TaskBarList.ThumbBarUpdateButtons(OwnerWindow.Handle, LButtonCount, @FTaskBarButtons[0])
      else
      begin
        TaskBarList.ThumbBarAddButtons(OwnerWindow.Handle, LButtonCount, @FTaskBarButtons[0]);
        FTaskBarButtonsInitialized := True;
      end;
    except
      // do nothing
    end;
  end;
{$ELSE}
begin
{$ENDIF}
end;

procedure TACLAeroPeek.SyncProgress;
{$IFDEF MSWINDOWS}
const
  StateMap: array[TACLAeroPeekProgressState] of Integer = (TBPF_NORMAL, TBPF_PAUSED, TBPF_ERROR);
var
  LState: Cardinal;
begin
  if TaskBarList = nil then
    Exit;

  if (FProgress > 0) or (FProgressTotal > 0) then
  begin
    if ShowProgress then
    begin
      if (FProgressTotal = 0) and ShowProgressCanBeIndeterminate then
        LState := TBPF_INDETERMINATE
      else if ShowStatusAsColor then
        LState := StateMap[ProgressState]
      else if FProgressTotal = 0 then
        LState := TBPF_NOPROGRESS
      else
        LState := TBPF_NORMAL;

      TaskBarList.SetProgressState(OwnerWindow.Handle, LState);
      if (LState <> TBPF_NOPROGRESS) and (LState <> TBPF_INDETERMINATE) then
        TaskBarList.SetProgressValue(OwnerWindow.Handle, FProgress, FProgressTotal);
      Exit;
    end;

    if ShowStatusAsColor then
    begin
      TaskBarList.SetProgressState(OwnerWindow.Handle, StateMap[ProgressState]);
      TaskBarList.SetProgressValue(OwnerWindow.Handle, 100, 100);
      Exit;
    end;
  end;

  TaskBarList.SetProgressState(OwnerWindow.Handle, TBPF_NOPROGRESS);
{$ELSEIF DEFINED(LINUX)}
var
  LAppDesktop: string;
  LAppObjPath: string;
  LBuilder: PGVariantBuilder;
  LError: PGError;
  LHandle: PGDBusConnection;
begin
  if (TACLApplication.DesktopId = '') or not IsAvailable then Exit;
  LError := nil;
  LHandle := g_bus_get_sync(G_BUS_TYPE_SESSION, nil, @LError);
  if LHandle <> nil then
  try
    LAppObjPath := '/app/' + acReplaceChars(TACLApplication.DesktopId, ' -_.', '/');
    LAppDesktop := 'application://' + TACLApplication.DesktopId + '.desktop';
    LBuilder := g_variant_builder_new(g_variant_type_new('a{sv}'));
    // https://wiki.ubuntu.com/Unity/LauncherAPI#Low_level_DBus_API:_com.canonical.Unity.LauncherEntry
    if ShowProgress and (FProgressTotal > 0) then
    begin
      g_variant_builder_add_pair(LBuilder, 'progress', g_variant_new_double(FProgress / FProgressTotal));
      g_variant_builder_add_pair(LBuilder, 'progress-visible', g_variant_new_boolean(True));
    end
    else
    begin
      g_variant_builder_add_pair(LBuilder, 'progress', g_variant_new_double(0));
      g_variant_builder_add_pair(LBuilder, 'progress-visible', g_variant_new_boolean(False));
    end;
    g_variant_builder_add_pair(LBuilder, 'urgent',
      g_variant_new_boolean(ShowStatusAsColor and (ProgressState <> appsNormal)));
    g_dbus_connection_emit_signal(LHandle, nil, Pgchar(LAppObjPath),
      'com.canonical.Unity.LauncherEntry', 'Update',
      g_variant_new('(sa{sv})', [Pgchar(LAppDesktop), LBuilder]), @LError);
  finally
    g_object_unref(LHandle);
  end;
  if LError <> nil then
    g_error_free(LError);
{$ELSE}
begin
{$ENDIF}
end;

procedure TACLAeroPeek.SyncState;
begin
  SetWindowAttribute(DWMWA_HAS_ICONIC_BITMAP, True);
end;

procedure TACLAeroPeek.UpdateForceIconicRepresentation;
begin
  SetWindowAttribute(DWMWA_FORCE_ICONIC_REPRESENTATION, Assigned(OnDrawPreview) or ForceCustomPreview);
end;

procedure TACLAeroPeek.UpdateLivePreviews;
{$IFDEF MSWINDOWS}
var
  LHasBorder: Boolean;
  LPreview: TACLBitmap;
  LPreviewImage: TACLImage;
  LThumbnailRect: TRect;
begin
  if Assigned(OnDrawPreview) and not FThumbnailSize.IsEmpty then
  try
    LPreview := TACLBitmap.CreateEx(FThumbnailSize, pf32bit, True);
    try
      OnDrawPreview(Self, LPreview);
      DwmSetIconicThumbnail(OwnerWindow.Handle, LPreview.Handle, 0);
    finally
      LPreview.Free;
    end;
  except
    // do nothing
  end;

  LPreview := CreatePeekPreview(LHasBorder);
  if LPreview <> nil then
  try
    DwmSetIconicLivePreviewBitmap(OwnerWindow.Handle,
      LPreview.Handle, nil, IfThen(LHasBorder, DWM_SIT_DISPLAYFRAME));
    if not Assigned(OnDrawPreview) and not FThumbnailSize.IsEmpty then
    try
      LThumbnailRect := acFitRect(FThumbnailSize,
        LPreview.Width, LPreview.Height, afmProportionalStretch);
      LPreviewImage := TACLImage.Create(LPreview);
      try
        LPreview.SetSize(FThumbnailSize);
        LPreview.Reset;
        LPreviewImage.Draw(LPreview.Canvas, LThumbnailRect);
      finally
        LPreviewImage.Free;
      end;
      DwmSetIconicThumbnail(OwnerWindow.Handle, LPreview.Handle, 0);
    except
      // do nothing
    end;
  finally
    LPreview.Free;
  end;
{$ELSE}
begin
{$ENDIF}
end;

{$IFDEF MSWINDOWS}
initialization
  WM_TASKBARBUTTONCREATED := RegisterWindowMessage('TaskbarButtonCreated');
{$ENDIF}
end.
