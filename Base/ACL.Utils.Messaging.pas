{*********************************************}
{*                                           *}
{*        Artem's Components Library         *}
{*             Messaging Routines            *}
{*                                           *}
{*            (c) Artem Izmaylov             *}
{*                 2006-2022                 *}
{*                www.aimp.ru                *}
{*                                           *}
{*********************************************}

unit ACL.Utils.Messaging;

{$I ACL.Config.INC}

interface

uses
  Windows,
  Messages,
  // System
  Classes,
  SyncObjs;

type

  { TMessagesHelper }

  TMessagesHelper = class
  public
    class function IsInQueue(AWndHandle: HWND; AMessage: Cardinal): Boolean;
    class procedure Process(AFromMessage, AToMessage: Cardinal; AWndHandle: HWND = 0); overload;
    class procedure Process(AMessage: Cardinal; AWndHandle: HWND = 0); overload;
    class procedure Remove(AMessage: Cardinal; AWndHandle: HWND = 0);
  end;

  { TACLMessaging }

  TACLMessageHandler = procedure (var AMessage: TMessage; var AHandled: Boolean) of object;

  TACLMessaging = class sealed
  strict private
    class var FCustomMessages: TObject;
    class var FHandle: HWND;
    class var FHandlers: TObject;
    class var FLock: TCriticalSection;

    class procedure WndProc(var AMessage: TMessage);
  public
    class constructor Create;
    class destructor Destroy;
    // Handlers
    class procedure HandlerAdd(AHandler: TACLMessageHandler);
    class procedure HandlerRemove(AHandler: TACLMessageHandler);
    // Messages
    class function RegisterMessage(const AName: UnicodeString): Cardinal;
    class procedure PostMessage(AMessage: Cardinal; AParamW: WPARAM; AParamL: LPARAM);
    class procedure SendMessage(AMessage: Cardinal; AParamW: WPARAM; AParamL: LPARAM);
    // Properties
    class property Handle: HWND read FHandle;
  end;

function WndCreate(Method: TWndMethod; const ClassName: UnicodeString;
  IsMessageOnly: Boolean = False; const Name: UnicodeString = ''): HWND;
procedure WndDefaultProc(W: HWND; var Message: TMessage);
procedure WndFree(W: HWND);
implementation

uses
  Math,
  SysUtils,
  Types,
  // ACL
  ACL.Classes.Collections,
  ACL.Classes.StringList,
  ACL.Threading;

{$IFDEF FPC}
const
  HWND_MESSAGE = HWND(-3);
{$ENDIF}

var
  UtilWindowClass: TWndClassW = (Style: 0; lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0; cbWndExtra: 0; hInstance: 0; hIcon: 0; hCursor: 0;
    hbrBackground: 0; lpszMenuName: nil; lpszClassName: 'TPUtilWindow');
  UtilWindowClassName: UnicodeString;

function WndCreate(Method: TWndMethod; const ClassName: UnicodeString;
  IsMessageOnly: Boolean = False; const Name: UnicodeString = ''): HWND;
var
  ClassRegistered: Boolean;
  TempClass: TWndClassW;
  ParentWnd: HWND;
begin
  if not IsMainThread then
    raise EInvalidOperation.Create('Cannot create window in non-main thread');
  UtilWindowClassName := ClassName;
  UtilWindowClass.hInstance := HInstance;
  UtilWindowClass.lpszClassName := PWideChar(UtilWindowClassName);
  ClassRegistered := GetClassInfoW(HInstance, UtilWindowClass.lpszClassName, {$IFDEF FPC}@{$ENDIF}TempClass);
  if not ClassRegistered or (@TempClass.lpfnWndProc <> @DefWindowProc) then
  begin
    if ClassRegistered then
      Windows.UnregisterClassW(UtilWindowClass.lpszClassName, HInstance);
    Windows.RegisterClassW(UtilWindowClass);
  end;
  ParentWnd := 0;
  if IsMessageOnly then
    ParentWnd := HWND_MESSAGE;
  Result := CreateWindowExW(WS_EX_TOOLWINDOW, UtilWindowClass.lpszClassName,
    PWideChar(Name), WS_POPUP {!0}, 0, 0, 0, 0, ParentWnd, 0, HInstance, nil);
  if Assigned(Method) then
    SetWindowLong(Result, GWL_WNDPROC, NativeUInt(Classes.MakeObjectInstance(Method)));
end;

procedure WndDefaultProc(W: HWND; var Message: TMessage);
begin
  Message.Result := DefWindowProc(W, Message.Msg, Message.WParam, Message.LParam);
end;

procedure WndFree(W: HWND);
var
  AInstance: Pointer;
begin
  if W <> 0 then
  begin
    AInstance := Pointer(GetWindowLong(W, GWL_WNDPROC));
    DestroyWindow(W);
    if AInstance <> @DefWindowProc then
      Classes.FreeObjectInstance(AInstance);
  end;
end;

{ TMessagesHelper }

class function TMessagesHelper.IsInQueue(AWndHandle: HWND; AMessage: Cardinal): Boolean;
var
  AMsg: TMSG;
begin
  Result := PeekMessage(AMsg, AWndHandle, AMessage, AMessage, PM_NOREMOVE) and (AMsg.hwnd = AWndHandle);
end;

class procedure TMessagesHelper.Process(AFromMessage, AToMessage: Cardinal; AWndHandle: HWND = 0);
var
  AMsg: TMsg;
begin
  while PeekMessage(AMsg, AWndHandle, AFromMessage, AToMessage, PM_REMOVE) do
  begin
    TranslateMessage(AMsg);
    DispatchMessage(AMsg);
  end;
end;

class procedure TMessagesHelper.Process(AMessage: Cardinal; AWndHandle: HWND = 0);
begin
  Process(AMessage, AMessage, AWndHandle);
end;

class procedure TMessagesHelper.Remove(AMessage: Cardinal; AWndHandle: HWND = 0);
var
  AMsg: TMsg;
begin
  while PeekMessage(AMsg, AWndHandle, AMessage, AMessage, PM_REMOVE) do ;
end;

{ TACLMessaging }

class constructor TACLMessaging.Create;
begin
  FLock := TCriticalSection.Create;
  FCustomMessages := TACLStringList.Create;
  FHandlers := TACLList<TACLMessageHandler>.Create;
  FHandle := WndCreate(WndProc, ClassName, True);
end;

class destructor TACLMessaging.Destroy;
begin
  WndFree(FHandle);
  FreeAndNil(FCustomMessages);
  FreeAndNil(FHandlers);
  FreeAndNil(FLock);
end;

class procedure TACLMessaging.HandlerAdd(AHandler: TACLMessageHandler);
begin
  FLock.Enter;
  try
    TACLList<TACLMessageHandler>(FHandlers).Add(AHandler);
  finally
    FLock.Leave;
  end;
end;

class procedure TACLMessaging.HandlerRemove(AHandler: TACLMessageHandler);
begin
  FLock.Enter;
  try
    TACLList<TACLMessageHandler>(FHandlers).Remove(AHandler);
  finally
    FLock.Leave;
  end;
end;

class procedure TACLMessaging.PostMessage(AMessage: Cardinal; AParamW: WPARAM; AParamL: LPARAM);
begin
  Windows.PostMessage(FHandle, AMessage, AParamW, AParamL);
end;

class procedure TACLMessaging.SendMessage(AMessage: Cardinal; AParamW: WPARAM; AParamL: LPARAM);
begin
  Windows.SendMessage(FHandle, AMessage, AParamW, AParamL);
end;

class function TACLMessaging.RegisterMessage(const AName: UnicodeString): Cardinal;
var
  AIndex: Integer;
begin
  FLock.Enter;
  try
    AIndex := TACLStringList(FCustomMessages).IndexOf(AName);
    if AIndex < 0 then
      AIndex := TACLStringList(FCustomMessages).Add(AName);
    Result := WM_USER + AIndex + 1;
  finally
    FLock.Leave;
  end;
end;

class procedure TACLMessaging.WndProc(var AMessage: TMessage);
var
  AHandled: Boolean;
  AHandlers: TACLList<TACLMessageHandler>;
  I: Integer;
begin
  FLock.Enter;
  try
    AHandlers := TACLList<TACLMessageHandler>(FHandlers);
    for I := AHandlers.Count - 1 downto 0 do
    begin
      AHandled := False;
      AHandlers[I](AMessage, AHandled);
      if AHandled then Exit;
    end;
    WndDefaultProc(FHandle, AMessage);
  finally
    FLock.Leave;
  end;
end;

end.
