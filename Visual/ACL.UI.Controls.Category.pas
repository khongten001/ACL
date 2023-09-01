﻿{*********************************************}
{*                                           *}
{*     Artem's Visual Components Library     *}
{*             Category Controls             *}
{*                                           *}
{*            (c) Artem Izmaylov             *}
{*                 2006-2023                 *}
{*                www.aimp.ru                *}
{*                                           *}
{*********************************************}

unit ACL.UI.Controls.Category;

{$I ACL.Config.inc}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  // System
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  // Vcl
  Vcl.Controls,
  Vcl.Graphics,
  // ACL
  ACL.Classes,
  ACL.Geometry,
  ACL.Graphics,
  ACL.UI.Controls.BaseControls,
  ACL.UI.Resources,
  ACL.Utils.Common,
  ACL.Utils.DPIAware;

type

  { TACLStyleCategory }

  TACLStyleCategory = class(TACLStyleBackground)
  strict private
    FHeaderTextAlignment: TAlignment;

    procedure SetHeaderTextAlignment(AValue: TAlignment);
  protected
    procedure DoAssign(ASource: TPersistent); override;
    procedure InitializeResources; override;
  public
    procedure DrawHeader(DC: HDC; const R: TRect);
    procedure DrawHeaderText(ACanvas: TCanvas; const R: TRect; const AText: UnicodeString);
    function MeasureHeaderHeight: Integer;
  published
    property HeaderColorContent1: TACLResourceColor index 4 read GetColor write SetColor stored IsColorStored;
    property HeaderColorContent2: TACLResourceColor index 5 read GetColor write SetColor stored IsColorStored;
    property HeaderTextAlignment: TAlignment read FHeaderTextAlignment write SetHeaderTextAlignment default taCenter;
    property HeaderTextFont: TACLResourceFont index 0 read GetFont write SetFont stored IsFontStored;
  end;

  { TACLCategory }

  TACLCategory = class(TACLContainer)
  strict private
    FCaptionRect: TRect;

    function GetStyle: TACLStyleCategory;
    procedure SetStyle(AValue: TACLStyleCategory);
    procedure WMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  protected
    procedure BoundsChanged; override;
    function CreatePadding: TACLPadding; override;
    function CreateStyle: TACLStyleBackground; override;
    function GetContentOffset: TRect; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AutoSize;
    property Borders;
    property Caption;
    property Padding;
    property Style: TACLStyleCategory read GetStyle write SetStyle;
  end;

implementation

{ TACLStyleCategory }

procedure TACLStyleCategory.DoAssign(ASource: TPersistent);
begin
  inherited DoAssign(ASource);
  if ASource is TACLStyleCategory then
    HeaderTextAlignment := TACLStyleCategory(ASource).HeaderTextAlignment;
end;

procedure TACLStyleCategory.InitializeResources;
begin
  HeaderTextAlignment := taCenter;
  ColorBorder1.InitailizeDefaults('Category.Colors.Border1', True);
  ColorBorder2.InitailizeDefaults('Category.Colors.Border2', True);
  ColorContent1.InitailizeDefaults('Category.Colors.Background1', True);
  ColorContent2.InitailizeDefaults('Category.Colors.Background2', True);
  HeaderColorContent1.InitailizeDefaults('Category.Colors.Header1', True);
  HeaderColorContent2.InitailizeDefaults('Category.Colors.Header2', True);
  HeaderTextFont.InitailizeDefaults('Category.Fonts.Header');
end;

procedure TACLStyleCategory.DrawHeader(DC: HDC; const R: TRect);
begin
  acDrawGradient(DC, R, HeaderColorContent1.AsColor, HeaderColorContent2.AsColor);
  acDrawFrame(DC, R, ColorBorder1.AsColor);
end;

procedure TACLStyleCategory.DrawHeaderText(ACanvas: TCanvas; const R: TRect; const AText: UnicodeString);
begin
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Assign(HeaderTextFont);
  acTextDraw(ACanvas, AText, acRectInflate(R, -4, 0), HeaderTextAlignment, taVerticalCenter, True, True);
end;

function TACLStyleCategory.MeasureHeaderHeight: Integer;
begin
  MeasureCanvas.Font.Assign(HeaderTextFont);
  Result := Max(acFontHeight(MeasureCanvas) + 8, 22);
end;

procedure TACLStyleCategory.SetHeaderTextAlignment(AValue: TAlignment);
begin
  if AValue <> FHeaderTextAlignment then
  begin
    FHeaderTextAlignment := AValue;
    Changed;
  end;
end;

{ TACLCategory }

constructor TACLCategory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csSetCaption];
end;

procedure TACLCategory.BoundsChanged;
begin
  inherited;
  FCaptionRect := acRectSetHeight(ClientRect, Style.MeasureHeaderHeight);
  Realign;
end;

function TACLCategory.CreatePadding: TACLPadding;
begin
  Result := TACLPadding.Create(5);
end;

function TACLCategory.CreateStyle: TACLStyleBackground;
begin
  Result := TACLStyleCategory.Create(Self);
end;

function TACLCategory.GetContentOffset: TRect;
begin
  Result := inherited;
  Result.Top := FCaptionRect.Bottom + 1{visual border};
end;

function TACLCategory.GetStyle: TACLStyleCategory;
begin
  Result := TACLStyleCategory(inherited Style);
end;

procedure TACLCategory.Paint;
begin
  inherited;
  Style.DrawHeader(Canvas.Handle, FCaptionRect);
  Style.DrawHeaderText(Canvas, FCaptionRect, Caption);
end;

procedure TACLCategory.SetStyle(AValue: TACLStyleCategory);
begin
  Style.Assign(AValue);
end;

procedure TACLCategory.WMTextChanged(var Message: TMessage);
begin
  inherited;
  FullRefresh;
end;

end.
