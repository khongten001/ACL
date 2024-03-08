﻿{*********************************************}
{*                                           *}
{*     Artem's Visual Components Library     *}
{*             Editors Controls              *}
{*                                           *}
{*            (c) Artem Izmaylov             *}
{*                 2006-2024                 *}
{*                www.aimp.ru                *}
{*                                           *}
{*********************************************}

unit ACL.UI.Controls.CheckComboBox;

{$I ACL.Config.inc} // FPC:OK

interface

uses
  {System.}Classes,
  {System.}SysUtils,
  {System.}Types,
  // VCL
  {Vcl.}Controls,
  {Vcl.}Graphics,
  {Vcl.}StdCtrls,
  // ACL
  ACL.Classes,
  ACL.Graphics,
  ACL.Graphics.SkinImage,
  ACL.MUI,
  ACL.UI.Controls.BaseControls,
  ACL.UI.Controls.BaseEditors,
  ACL.UI.Controls.ComboBox,
  ACL.UI.Controls.CompoundControl.SubClass,
  ACL.UI.Controls.TreeList,
  ACL.UI.Controls.TreeList.SubClass,
  ACL.UI.Controls.TreeList.Types,
  ACL.UI.Forms,
  ACL.UI.Insight,
  ACL.UI.Resources,
  ACL.Utils.Common,
  ACL.Utils.Strings;

type
  TACLCheckComboBox = class;

  { TACLCheckComboBoxItem }

  TACLCheckComboBoxItem = class(TACLCollectionItem)
  strict private
    FChecked: Boolean;
    FTag: NativeInt;
    FText: string;

    procedure SetChecked(AChecked: Boolean);
    procedure SetText(const Value: string);
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Checked: Boolean read FChecked write SetChecked default False;
    property Tag: NativeInt read FTag write FTag default 0;
    property Text: string read FText write SetText;
  end;

  { TACLCheckComboBoxItems }

  TACLCheckComboBoxItemsEnumProc = reference to procedure (const Item: TACLCheckComboBoxItem);

  TACLCheckComboBoxItems = class(TACLCollection)
  strict private
    FCombo: TACLCheckComboBox;

    function GetItem(Index: Integer): TACLCheckComboBoxItem;
    function GetState: TCheckBoxState;
    procedure SetState(const Value: TCheckBoxState);
  protected
    function GetOwner: TPersistent; override;
    procedure UpdateCore(Item: TCollectionItem); override;
  public
    constructor Create(ACombo: TACLCheckComboBox);
    function Add(const AText: string; AChecked: Boolean): TACLCheckComboBoxItem;
    procedure EnumChecked(AProc: TACLCheckComboBoxItemsEnumProc);
    function FindByTag(const ATag: NativeInt; out AItem: TACLCheckComboBoxItem): Boolean;
    function FindByText(const AText: string; out AItem: TACLCheckComboBoxItem): Boolean;
    //# Properties
    property Items[Index: Integer]: TACLCheckComboBoxItem read GetItem; default;
    property State: TCheckBoxState read GetState write SetState;
  end;

  { TACLCheckComboBoxDropDown }

  TACLCheckComboBoxDropDown = class(TACLCustomComboBoxDropDown)
  strict private
    function GetOwnerEx: TACLCheckComboBox;
    procedure HandlerGetGroupName(Sender: TObject; ANode: TACLTreeListNode; var AGroupName: string);
    procedure HandlerItemCheck(Sender: TObject; AItem: TACLTreeListNode);
    procedure HandlerUpdateState(Sender: TObject);
  protected
    procedure DoClick(AHitTest: TACLTreeListHitTest); override;
    procedure PopulateList(AList: TACLTreeList); override;
  public
    constructor Create(AOwner: TComponent); override;
    // Properties
    property Owner: TACLCheckComboBox read GetOwnerEx;
  end;

  { TACLCheckComboBox }

  TACLCheckComboBoxGetDisplayTextEvent = procedure (
    Sender: TObject; var AText: string) of object;
  TACLCheckComboBoxGetItemDisplayTextEvent = procedure (
    Sender: TObject; AItem: TACLCheckComboBoxItem; var AText: string) of object;

  TACLCheckComboBox = class(TACLCustomComboBox)
  strict private
    FItems: TACLCheckComboBoxItems;
    FSeparator: Char;

    FOnGetDisplayItemGroupName: TACLCheckComboBoxGetItemDisplayTextEvent;
    FOnGetDisplayItemName: TACLCheckComboBoxGetItemDisplayTextEvent;
    FOnGetDisplayText: TACLCheckComboBoxGetDisplayTextEvent;

    function GetCount: Integer;
    function IsSeparatorStored: Boolean;
    procedure SetItems(AValue: TACLCheckComboBoxItems);
    procedure SetSeparator(AValue: Char);
  protected
    function CreateDropDownWindow: TACLPopupWindow; override;
    procedure DoGetDisplayText(AItem: TACLCheckComboBoxItem; var AText: string); virtual;
    procedure DoGetGroupName(AItem: TACLCheckComboBoxItem; var AText: string); virtual;
    procedure SetTextCore(const AText: string); override;
    procedure UpdateText;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //# Properties
    property Count: Integer read GetCount;
  published
    property Borders;
    property Items: TACLCheckComboBoxItems read FItems write SetItems;
    property Separator: Char read FSeparator write SetSeparator stored IsSeparatorStored;
    property ResourceCollection;
    property Style;
    property StyleButton;
    property StyleDropDownList;
    property StyleDropDownListScrollBox;
    property Text;

    property OnChange;
    property OnGetDisplayItemGroupName: TACLCheckComboBoxGetItemDisplayTextEvent
      read FOnGetDisplayItemGroupName write FOnGetDisplayItemGroupName;
    property OnGetDisplayItemName: TACLCheckComboBoxGetItemDisplayTextEvent
      read FOnGetDisplayItemName write FOnGetDisplayItemName;
    property OnGetDisplayText: TACLCheckComboBoxGetDisplayTextEvent
      read FOnGetDisplayText write FOnGetDisplayText;
  end;

  { TACLCheckComboBoxUIInsightAdapter }

  TACLCheckComboBoxUIInsightAdapter = class(TACLBasicComboBoxUIInsightAdapter)
  public
    class procedure GetChildren(AObject: TObject; ABuilder: TACLUIInsightSearchQueueBuilder); override;
  end;

implementation

{ TACLCheckComboBoxItem }

procedure TACLCheckComboBoxItem.Assign(Source: TPersistent);
begin
  if Source is TACLCheckComboBoxItem then
  begin
    FChecked := TACLCheckComboBoxItem(Source).Checked;
    FText := TACLCheckComboBoxItem(Source).FText;
    FTag := TACLCheckComboBoxItem(Source).Tag;
    Changed(False);
  end;
end;

procedure TACLCheckComboBoxItem.SetChecked(AChecked: Boolean);
begin
  if AChecked <> FChecked then
  begin
    FChecked := AChecked;
    Changed(False);
  end;
end;

procedure TACLCheckComboBoxItem.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    Changed(False);
  end;
end;

{ TACLCheckComboBoxItems }

constructor TACLCheckComboBoxItems.Create(ACombo: TACLCheckComboBox);
begin
  FCombo := ACombo;
  inherited Create(TACLCheckComboBoxItem);
end;

function TACLCheckComboBoxItems.Add(const AText: string; AChecked: Boolean): TACLCheckComboBoxItem;
begin
  BeginUpdate;
  try
    Result := TACLCheckComboBoxItem(inherited Add);
    Result.Text := AText;
    Result.Checked := AChecked;
  finally
    EndUpdate;
  end;
end;

procedure TACLCheckComboBoxItems.EnumChecked(AProc: TACLCheckComboBoxItemsEnumProc);
var
  AItem: TACLCheckComboBoxItem;
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    AItem := Items[I];
    if AItem.Checked then
      AProc(AItem);
  end;
end;

function TACLCheckComboBoxItems.FindByTag(const ATag: NativeInt; out AItem: TACLCheckComboBoxItem): Boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].Tag = ATag then
    begin
      AItem := Items[I];
      Exit(True);
    end;
  Result := False;
end;

function TACLCheckComboBoxItems.FindByText(const AText: string; out AItem: TACLCheckComboBoxItem): Boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].Text = AText then
    begin
      AItem := Items[I];
      Exit(True);
    end;
  Result := False;
end;

function TACLCheckComboBoxItems.GetOwner: TPersistent;
begin
  Result := FCombo;
end;

procedure TACLCheckComboBoxItems.UpdateCore(Item: TCollectionItem);
begin
  inherited UpdateCore(Item);
  FCombo.UpdateText; // before change
  FCombo.Changed;
end;

function TACLCheckComboBoxItems.GetItem(Index: Integer): TACLCheckComboBoxItem;
begin
  Result := TACLCheckComboBoxItem(inherited Items[Index]);
end;

function TACLCheckComboBoxItems.GetState: TCheckBoxState;
var
  AHasChecked, AHasUnchecked: Boolean;
  I: Integer;
begin
  AHasChecked := False;
  AHasUnchecked := False;
  for I := 0 to Count - 1 do
  begin
    if Items[I].Checked then
      AHasChecked := True
    else
      AHasUnchecked := True;
    if AHasUnchecked and AHasChecked then Break;
  end;
  Result := TCheckBoxState.Create(AHasChecked, AHasUnchecked);
end;

procedure TACLCheckComboBoxItems.SetState(const Value: TCheckBoxState);
var
  I: Integer;
begin
  if Value <> cbGrayed then
  begin
    BeginUpdate;
    try
      for I := 0 to Count - 1 do
        Items[I].Checked := Value = cbChecked;
    finally
      EndUpdate;
    end;
  end;
end;

{ TACLCheckComboBoxDropDown }

constructor TACLCheckComboBoxDropDown.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Control.OptionsView.CheckBoxes := True;
  Control.OptionsView.Columns.AutoWidth := True;
  Control.OptionsView.Columns.Visible := Control.RootNode.ChildrenCount > 1;
  Control.Columns.Add;

  // must be last
  Control.OnNodeChecked := HandlerItemCheck;
  Control.OnUpdateState := HandlerUpdateState;
end;

procedure TACLCheckComboBoxDropDown.DoClick(AHitTest: TACLTreeListHitTest);
begin
  if AHitTest.HitAtNode and not AHitTest.IsCheckable then
    AHitTest.Node.Checked := not AHitTest.Node.Checked;
end;

procedure TACLCheckComboBoxDropDown.PopulateList(AList: TACLTreeList);
var
  LItem: TACLCheckComboBoxItem;
  LNode: TACLTreeListNode;
  LText: string;
  I: Integer;
begin
  if Assigned(Owner.OnGetDisplayItemGroupName) then
  begin
    AList.OnGetNodeGroup := HandlerGetGroupName;
    AList.OptionsBehavior.Groups := True;
  end;
  for I := 0 to Owner.Count - 1 do
  begin
    LItem := Owner.Items.Items[I];
    LText := LItem.Text;
    Owner.DoGetDisplayText(LItem, LText);
    LNode := AList.RootNode.AddChild;
    LNode.Data := LItem;
    LNode.Checked := LItem.Checked;
    LNode.Caption := LText;
  end;
end;

function TACLCheckComboBoxDropDown.GetOwnerEx: TACLCheckComboBox;
begin
  Result := TACLCheckComboBox(inherited Owner);
end;

procedure TACLCheckComboBoxDropDown.HandlerGetGroupName(
  Sender: TObject; ANode: TACLTreeListNode; var AGroupName: string);
begin
  Owner.DoGetGroupName(ANode.Data, AGroupName);
end;

procedure TACLCheckComboBoxDropDown.HandlerItemCheck(Sender: TObject; AItem: TACLTreeListNode);
begin
  TACLCheckComboBoxItem(AItem.Data).Checked := AItem.Checked;
end;

procedure TACLCheckComboBoxDropDown.HandlerUpdateState(Sender: TObject);
begin
  if Control.IsUpdateLocked then
    Owner.Items.BeginUpdate
  else
    Owner.Items.EndUpdate;
end;

{ TACLCustomCombo }

constructor TACLCheckComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSeparator := ';';
  FItems := TACLCheckComboBoxItems.Create(Self);
end;

destructor TACLCheckComboBox.Destroy;
begin
  FreeAndNil(FItems);
  inherited Destroy;
end;

function TACLCheckComboBox.CreateDropDownWindow: TACLPopupWindow;
begin
  Result := TACLCheckComboBoxDropDown.Create(Self);
end;

procedure TACLCheckComboBox.SetTextCore(const AText: string);
var
  LItem: TACLCheckComboBoxItem;
  LStrings: TStringDynArray;
  I: Integer;
begin
  Items.BeginUpdate;
  try
    Items.State := cbUnchecked;
    acExplodeString(AText, Separator, LStrings);
    for I := 0 to Length(LStrings) - 1 do
    begin
      if Items.FindByText(LStrings[I], LItem) then
        LItem.Checked := True;
    end;
    UpdateText;
  finally
    Items.EndUpdate;
  end;
end;

procedure TACLCheckComboBox.UpdateText;
var
  AText: TACLStringBuilder;
begin
  AText := TACLStringBuilder.Get;
  try
    Items.EnumChecked(
      procedure (const Item: TACLCheckComboBoxItem)
      begin
        AText.Append(Item.Text).Append(Separator);
      end);

    FText := AText.ToString;
    if Assigned(OnGetDisplayText) then
      OnGetDisplayText(Self, FText);
  finally
    AText.Release;
  end;
  Invalidate;
end;

function TACLCheckComboBox.GetCount: Integer;
begin
  Result := Items.Count;
end;

procedure TACLCheckComboBox.DoGetDisplayText(AItem: TACLCheckComboBoxItem; var AText: string);
begin
  if Assigned(OnGetDisplayItemName) then
    OnGetDisplayItemName(Self, AItem, AText);
end;

procedure TACLCheckComboBox.DoGetGroupName(AItem: TACLCheckComboBoxItem; var AText: string);
begin
  if Assigned(OnGetDisplayItemGroupName) then
    OnGetDisplayItemGroupName(Self, AItem, AText);
end;

function TACLCheckComboBox.IsSeparatorStored: Boolean;
begin
  Result := FSeparator <> ';';
end;

procedure TACLCheckComboBox.SetItems(AValue: TACLCheckComboBoxItems);
begin
  Items.Assign(AValue);
end;

procedure TACLCheckComboBox.SetSeparator(AValue: Char);
begin
  if FSeparator <> AValue then
  begin
    FSeparator := AValue;
    UpdateText;
  end;
end;

{ TACLCheckComboBoxUIInsightAdapter }

class procedure TACLCheckComboBoxUIInsightAdapter.GetChildren(
  AObject: TObject; ABuilder: TACLUIInsightSearchQueueBuilder);
var
  LCheckComboBox: TACLCheckComboBox absolute AObject;
  I: Integer;
begin
  for I := 0 to LCheckComboBox.Count - 1 do
    ABuilder.AddCandidate(LCheckComboBox, LCheckComboBox.Items[I].Text);
end;

initialization
  TACLUIInsight.Register(TACLCheckComboBox, TACLCheckComboBoxUIInsightAdapter);
end.
