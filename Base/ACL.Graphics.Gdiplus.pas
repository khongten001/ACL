{*********************************************}
{*                                           *}
{*        Artem's Components Library         *}
{*             Gdiplus Wrappers              *}
{*                                           *}
{*            (c) Artem Izmaylov             *}
{*                 2006-2022                 *}
{*                www.aimp.ru                *}
{*                                           *}
{*********************************************}

unit ACL.Graphics.Gdiplus;

{$I ACL.Config.inc}

{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses
  ActiveX,
  Windows,
  // System
  Classes,
  Contnrs,
  Types,
  SysUtils,
  // Vcl
  Graphics,
  // ACL
  ACL.Classes.Collections,
  ACL.Graphics;

{$REGION 'GDI+ API - Types'}

const
  GdiPlusDll = 'gdiplus.dll';

const
  ImageFormatUndefined : TGUID = '{b96b3ca9-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatUndefined}
  ImageFormatMemoryBMP : TGUID = '{b96b3caa-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatMemoryBMP}
  ImageFormatBMP       : TGUID = '{b96b3cab-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatBMP}
  ImageFormatEMF       : TGUID = '{b96b3cac-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEMF}
  ImageFormatWMF       : TGUID = '{b96b3cad-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatWMF}
  ImageFormatJPEG      : TGUID = '{b96b3cae-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatJPEG}
  ImageFormatPNG       : TGUID = '{b96b3caf-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatPNG}
  ImageFormatGIF       : TGUID = '{b96b3cb0-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatGIF}
  ImageFormatTIFF      : TGUID = '{b96b3cb1-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatTIFF}
  ImageFormatEXIF      : TGUID = '{b96b3cb2-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEXIF}
  ImageFormatIcon      : TGUID = '{b96b3cb5-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatIcon}

  ImageLockModeRead         = 0;
  ImageLockModeWrite        = 1;
  ImageLockModeUserInputBuf = 2;

type
  TGpPixelFormat = Integer;
  TGPStringFormatFlags = Integer;

const
  PixelFormatIndexed         = $00010000; // Indexes into a palette
  PixelFormatGDI             = $00020000; // Is a GDI-supported format
  PixelFormatAlpha           = $00040000; // Has an alpha component
  PixelFormatPAlpha          = $00080000; // Pre-multiplied alpha
  PixelFormatExtended        = $00100000; // Extended color 16 bits/channel
  PixelFormatCanonical       = $00200000;

  PixelFormatUndefined       = 0;
  PixelFormatDontCare        = 0;

  PixelFormat1bppIndexed     = ( 1 or ( 1 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat4bppIndexed     = ( 2 or ( 4 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat8bppIndexed     = ( 3 or ( 8 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat16bppGrayScale  = ( 4 or (16 shl 8) or PixelFormatExtended);
  PixelFormat16bppRGB555     = ( 5 or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppRGB565     = ( 6 or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppARGB1555   = ( 7 or (16 shl 8) or PixelFormatAlpha or PixelFormatGDI);
  PixelFormat24bppRGB        = ( 8 or (24 shl 8) or PixelFormatGDI);
  PixelFormat32bppRGB        = ( 9 or (32 shl 8) or PixelFormatGDI);
  PixelFormat32bppARGB       = (10 or (32 shl 8) or PixelFormatAlpha or PixelFormatGDI or PixelFormatCanonical);
  PixelFormat32bppPARGB      = (11 or (32 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatGDI);
  PixelFormat48bppRGB        = (12 or (48 shl 8) or PixelFormatExtended);
  PixelFormat64bppARGB       = (13 or (64 shl 8) or PixelFormatAlpha  or PixelFormatCanonical or PixelFormatExtended);
  PixelFormat64bppPARGB      = (14 or (64 shl 8) or PixelFormatAlpha  or PixelFormatPAlpha or PixelFormatExtended);
  PixelFormat32bppCMYK       = (15 or (32 shl 8));
  PixelFormatMax             = 16;

  StringFormatFlagsDirectionRightToLeft        = $00000001;
  {$EXTERNALSYM StringFormatFlagsDirectionRightToLeft}
  StringFormatFlagsDirectionVertical           = $00000002;
  {$EXTERNALSYM StringFormatFlagsDirectionVertical}
  StringFormatFlagsNoFitBlackBox               = $00000004;
  {$EXTERNALSYM StringFormatFlagsNoFitBlackBox}
  StringFormatFlagsDisplayFormatControl        = $00000020;
  {$EXTERNALSYM StringFormatFlagsDisplayFormatControl}
  StringFormatFlagsNoFontFallback              = $00000400;
  {$EXTERNALSYM StringFormatFlagsNoFontFallback}
  StringFormatFlagsMeasureTrailingSpaces       = $00000800;
  {$EXTERNALSYM StringFormatFlagsMeasureTrailingSpaces}
  StringFormatFlagsNoWrap                      = $00001000;
  {$EXTERNALSYM StringFormatFlagsNoWrap}
  StringFormatFlagsLineLimit                   = $00002000;
  {$EXTERNALSYM StringFormatFlagsLineLimit}
  StringFormatFlagsNoClip                      = $00004000;
  {$EXTERNALSYM StringFormatFlagsNoClip}

type
  GpGraphics = Pointer;
  {$EXTERNALSYM GpGraphics}
  GpBrush = Pointer;
  {$EXTERNALSYM GpBrush}
  GpBitmap = Pointer;
  {$EXTERNALSYM GpBitmap}
  GpTexture = Pointer;
  {$EXTERNALSYM GpTexture}
  GpSolidFill = Pointer;
  {$EXTERNALSYM GpSolidFill}
  GpLineGradient = Pointer;
  {$EXTERNALSYM GpLineGradient}
  GpPathGradient = Pointer;
  {$EXTERNALSYM GpPathGradient}
  GpHatch = Pointer;
  {$EXTERNALSYM GpHatch}
  GpImage = Pointer;
  {$EXTERNALSYM GpImage}
  GpImageAttributes = Pointer;
  {$EXTERNALSYM GpImageAttributes}
  GpPen = Pointer;
  {$EXTERNALSYM GpPen}
  GpFont = Pointer;
  {$EXTERNALSYM GpFont}
  GpStringFormat = Pointer;
  {$EXTERNALSYM GpStringFormat}
  GpFontFamily = Pointer;
  {$EXTERNALSYM GpFontFamily}

  TGpDebugEventLevel = (
    DebugEventLevelFatal,
    DebugEventLevelWarning
  );

  TGpDebugEventProc = procedure(level: TGpDebugEventLevel; message: PChar); stdcall;

  PGdiplusStartupInput = ^TGdiplusStartupInput;
  TGdiplusStartupInput = record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : TGpDebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL;           // FALSE unless you're prepared to call the hook/unhook functions properly
    SuppressExternalCodecs  : BOOL;           // FALSE unless you want GDI+ only to use its internal image codecs.
  end;

  TGpStringAlignment = (
    // Left edge for left-to-right text,
    // right for right-to-left text,
    // and top for vertical
    StringAlignmentNear,
    StringAlignmentCenter,
    StringAlignmentFar
  );

  PGpBitmapData = ^TGpBitmapData;
  TGpBitmapData = packed record
    Width       : UINT;
    Height      : UINT;
    Stride      : Integer;
    PixelFormat : TGpPixelFormat;
    Scan0       : Pointer;
    Reserved    : UINT_PTR;
  end;

  TGPImageAbort = function(CallbackData: Pointer): BOOL; stdcall;

  PGpColorMatrix = ^TGpColorMatrix;
  TGpColorMatrix = packed array[0..4, 0..4] of Single;

  TGpStatus = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiplusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported
  );

  TGPWrapMode = (
    WrapModeTile,        // 0
    WrapModeTileFlipX,   // 1
    WrapModeTileFlipY,   // 2
    WrapModeTileFlipXY,  // 3
    WrapModeClamp);      // 4

  TGPUnit = (
    UnitWorld,       // 0 -- World coordinate (non-physical unit)
    UnitDisplay,     // 1 -- Variable -- for PageTransform only
    UnitPixel,       // 2 -- Each unit is one device pixel.
    UnitPoint,       // 3 -- Each unit is a printer's point, or 1/72 inch.
    UnitInch,        // 4 -- Each unit is 1 inch.
    UnitDocument,    // 5 -- Each unit is 1/300 inch.
    UnitMillimeter); // 6 -- Each unit is 1 millimeter.

  TGPColorAdjustType = (
    ColorAdjustTypeDefault,
    ColorAdjustTypeBitmap,
    ColorAdjustTypeBrush,
    ColorAdjustTypePen,
    ColorAdjustTypeText,
    ColorAdjustTypeCount,
    ColorAdjustTypeAny);  // Reserved

  TGPColorMatrixFlags = (
    ColorMatrixFlagsDefault   = 0,
    ColorMatrixFlagsSkipGrays = 1,
    ColorMatrixFlagsAltGray   = 2);

  PGpImageCodecInfo = ^TGpImageCodecInfo;
  TGpImageCodecInfo = record
    ClsId: TGUID;
    FormatId: TGUID;
    CodecName: PWideChar;
    DllName: PWideChar;
    FormatDescription: PWideChar;
    FilenameExtension: PWideChar;
    MimeType: PWideChar;
    Flags: DWORD;
    Version: DWORD;
    SigCount: DWORD;
    SigSize: DWORD;
    SigPattern: PByte;
    SigMask: PByte;
  end;

  TGPDashStyle = (
    DashStyleSolid,          // 0
    DashStyleDash,           // 1
    DashStyleDot,            // 2
    DashStyleDashDot,        // 3
    DashStyleDashDotDot,     // 4
    DashStyleCustom);        // 5

  TGPFillMode = (
    FillModeAlternate,        // 0
    FillModeWinding);         // 1

  TGPPoint = TPointF;
  PGPPoint = PPointF;

  PGPRect = ^TGPRect;
  TGPRect = record
    X     : Integer;
    Y     : Integer;
    Width : Integer;
    Height: Integer;
  end;

  PGPRectF = ^TGPRectF;
  TGPRectF = record
    X     : Single;
    Y     : Single;
    Width : Single;
    Height: Single;
  end;
{$ENDREGION}

type
  GpHandle = type Pointer;

  TGpSmoothingMode = (
    smInvalid      = -1,
    smDefault      = 0,
    smHighSpeed    = 1,
    smHighQuality  = 2,
    smNone         = 3,
    smAntiAlias    = 4
  );

  TGpInterpolationMode = (
    imDefault             = 0,
    imLowQuality          = 1,
    imHighQuality         = 2,
    imBilinear            = 3,
    imBicubic             = 4,
    imNearestNeighbor     = 5,
    imHighQualityBilinear = 6,
    imHighQualityBicubic  = 7
  );

  TGpPixelOffsetMode = (
    pomInvalid     = -1,
    pomDefault     = 0,
    pomHighSpeed   = 1,
    pomHighQuality = 2,
    pomNone        = 3, // No pixel offset
    pomHalf        = 4  // Offset by -0.5, -0.5 for fast anti-alias perf
  );

  TGpCompositingMode = (
    cmSourceOver = 0,
    cmSourceCopy = 1
  );

  TGpLinearGradientMode = (
    gmHorizontal = 0,
    gmVertical = 1,
    gmForwardDiagonal = 2,
    gmBackwardDiagonal = 3
  );

  TGpTextRenderingHint = (
    trhSystemDefault,                // Glyph with system default rendering hint
    trhSingleBitPerPixelGridFit,     // Glyph bitmap with hinting
    trhSingleBitPerPixel,            // Glyph bitmap without hinting
    trhAntiAliasGridFit,             // Glyph anti-alias bitmap with hinting
    trhAntiAlias,                    // Glyph anti-alias bitmap without hinting
    trhClearTypeGridFit              // Glyph CT bitmap with hinting
  );

type

  { EGdipException }

  EGdipException = class(Exception)
  strict private
    FStatus: TGPStatus;
  public
    constructor Create(AStatus: TGPStatus);
    //
    property Status: TGPStatus read FStatus;
  end;

  { TACLGdiplusObject }

  TACLGdiplusObject = class
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;

  { TACLGdiplusCustomGraphicObject }

  TACLGdiplusCustomGraphicObject = class(TACLGdiplusObject)
  strict private
    FChangeLockCount: Integer;
    FHandle: GpHandle;

    FOnChange: TNotifyEvent;

    function GetHandle: GpHandle;
    function GetHandleAllocated: Boolean;
  protected
    procedure Changed; virtual;
    procedure DoCreateHandle(out AHandle: GpHandle); virtual; abstract;
    procedure DoFreeHandle(AHandle: GpHandle); virtual; abstract;
  public
    procedure BeforeDestruction; override;
    procedure FreeHandle;
    procedure HandleNeeded; virtual;
    //
    property Handle: GpHandle read GetHandle;
    property HandleAllocated: Boolean read GetHandleAllocated;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  { TACLGdiplusBrush }

  TACLGdiplusBrush = class(TACLGdiplusCustomGraphicObject)
  strict private
    FColor: TAlphaColor;

    procedure SetColor(AValue: TAlphaColor);
  protected
    procedure DoCreateHandle(out AHandle: GpHandle); override;
    procedure DoFreeHandle(AHandle: GpHandle); override;
  public
    procedure AfterConstruction; override;
    //
    property Color: TAlphaColor read FColor write SetColor;
  end;

  { TACLGdiplusPen }

  TACLGdiplusPenStyle = (gpsSolid, gpsDash, gpsDot, gpsDashDot, gpsDashDotDot);

  TACLGdiplusPen = class(TACLGdiplusCustomGraphicObject)
  strict private
    FColor: TAlphaColor;
    FStyle: TACLGdiplusPenStyle;
    FWidth: Single;

    procedure SetColor(AValue: TAlphaColor);
    procedure SetStyle(AValue: TACLGdiplusPenStyle);
    procedure SetWidth(AValue: Single);
  protected
    procedure DoCreateHandle(out AHandle: GpHandle); override;
    procedure DoFreeHandle(AHandle: GpHandle); override;
    procedure DoSetDashStyle(AHandle: GpHandle);
  public
    procedure AfterConstruction; override;
    //
    property Color: TAlphaColor read FColor write SetColor;
    property Style: TACLGdiplusPenStyle read FStyle write SetStyle;
    property Width: Single read FWidth write SetWidth;
  end;

  { TACLGdiplusCanvas }

  TACLGdiplusCanvas = class(TACLGdiplusObject)
  strict private
    FBrush: TACLGdiplusBrush;
    FPen: TACLGdiplusPen;

    function GetInterpolationMode: TGpInterpolationMode;
    function GetPixelOffsetMode: TGpPixelOffsetMode;
    function GetSmoothingMode: TGpSmoothingMode;
    procedure SetInterpolationMode(const Value: TGpInterpolationMode);
    procedure SetSmoothingMode(const Value: TGpSmoothingMode);
    procedure SetPixelOffsetMode(const Value: TGpPixelOffsetMode);
  protected
    FHandle: GpGraphics;
  public
    constructor Create; overload; virtual;
    constructor Create(DC: HDC); overload;
    constructor Create(AHandle: GpGraphics); overload;
    destructor Destroy; override;

    // Closed Curve
    procedure FillClosedCurve2(ABrush: TACLGdiplusBrush; const APoints: array of TPoint; ATension: Single); overload;
    procedure FillClosedCurve2(AColor: TAlphaColor; const APoints: array of TPoint; ATension: Single); overload;
    procedure DrawClosedCurve2(APen: TACLGdiplusPen; const APoints: array of TPoint; ATension: Single); overload;
    procedure DrawClosedCurve2(APenColor: TAlphaColor; const APoints: array of TPoint; ATension: Single;
      APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0); overload;

    // Curve
    procedure DrawCurve2(APen: TACLGdiplusPen; APoints: array of TPoint; ATension: Single); overload;
    procedure DrawCurve2(APenColor: TAlphaColor; APoints: array of TPoint; ATension: Single;
      APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0); overload;

    // Lines
    procedure DrawLine(APen: TACLGdiplusPen; X1, Y1, X2, Y2: Integer); overload;
    procedure DrawLine(APenColor: TAlphaColor; X1, Y1, X2, Y2: Integer;
      APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0); overload;
    procedure DrawLine(APenColor: TAlphaColor; const APoints: array of TPoint;
      APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0); overload;

    // Ellipse
    procedure DrawEllipse(APen: TACLGdiplusPen; const R: TRect); overload;
    procedure DrawEllipse(APenColor: TAlphaColor; const R: TRect;
      APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0); overload;
    procedure FillEllipse(ABrush: TACLGdiplusBrush; const R: TRect); overload;
    procedure FillEllipse(AColor: TAlphaColor; const R: TRect); overload;

    // Rectangle
    procedure FillRectangle(ABrush: TACLGdiplusBrush; const R: TRect; AMode: TGpCompositingMode = cmSourceOver); overload;
    procedure FillRectangle(AColor: TAlphaColor; const R: TRect; AMode: TGpCompositingMode = cmSourceOver); overload;
    procedure FillRectangleByGradient(AColor1, AColor2: TAlphaColor; const R: TRect; AMode: TGpLinearGradientMode);
    procedure DrawRectangle(APen: TACLGdiplusPen; const R: TRect); overload;
    procedure DrawRectangle(APenColor: TAlphaColor; const R: TRect;
      APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0); overload;

    // Text
    procedure TextOut(const AText: UnicodeString; const R: TRect; AFont: TFont; AHorzAlign: TAlignment;
      AVertAlign: TVerticalAlignment; AWordWrap: Boolean; ATextColor: TAlphaColor;
      ARendering: TGpTextRenderingHint = trhSystemDefault);

    property Handle: GpGraphics read FHandle;
    property InterpolationMode: TGpInterpolationMode read GetInterpolationMode write SetInterpolationMode;
    property PixelOffsetMode: TGpPixelOffsetMode read GetPixelOffsetMode write SetPixelOffsetMode;
    property SmoothingMode: TGpSmoothingMode read GetSmoothingMode write SetSmoothingMode;
  end;

  { TACLGdiplusPaintCanvas }

  TACLGdiplusPaintCanvas = class(TACLGdiplusCanvas)
  strict private
    FSavedHandles: TStack;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure BeginPaint(DC: HDC);
    procedure EndPaint;
  end;

  { TACLGdiplusStream }

  TACLGdiplusStream = class(TStreamAdapter)
  public
    function Stat(out AStatStg: TStatStg; AStatFlag: DWORD): HResult; override; stdcall;
  end;

  { TACLGdiplusSolidBrushCache }

  TACLGdiplusSolidBrushCache = class
  strict private
    class var FInstance: TACLValueCacheManager<TAlphaColor, GpBrush>;

    class procedure RemoveValueHandler(Sender: TObject; const ABrush: GpBrush);
  public
    class destructor Destroy;
    class procedure Flush;
    class function GetOrCreate(AColor: TAlphaColor): GpBrush;
  end;

procedure GdipCheck(AStatus: TGPStatus);
function GpPaintCanvas: TACLGdiplusPaintCanvas;

function GpCreateBitmap(AWidth, AHeight: Integer; ABits: PByte = nil; APixelFormat: Integer = PixelFormat32bppPARGB): GpImage;
function GpGetCodecByMimeType(const AMimeType: UnicodeString; out ACodecID: TGUID): Boolean;
procedure GpFillRect(DC: HDC; const R: TRect; AColor: TAlphaColor; AMode: TGpCompositingMode = cmSourceOver);
procedure GpFocusRect(DC: HDC; const R: TRect; AColor: TAlphaColor);
procedure GpFrameRect(DC: HDC; const R: TRect; AColor: TAlphaColor; AFrameSize: Integer);
procedure GpDrawImage(AGraphics: GpGraphics; AImage: GpImage; AImageAttributes: GpImageAttributes;
  const ADestRect, ASourceRect: TRect; ATileDrawingMode: Boolean); overload;
procedure GpDrawImage(AGraphics: GpGraphics; AImage: GpImage;
  const ADestRect, ASourceRect: TRect; ATileDrawingMode: Boolean; const AAlpha: Byte = $FF); overload;

{$REGION 'GDI+ API - Functions'}
var
  GdiplusStartupInput: TGDIPlusStartupInput;
  GdiplusToken: ULONG_PTR;

function GdipAlloc(Size: Integer): Pointer; stdcall; external GdiPlusDll;
procedure GdipFree(Ptr: Pointer); stdcall; external GdiPlusDll;
function GdiplusStartup(out token: ULONG_PTR; input: PGdiplusStartupInput; output: {PGdiplusStartupOutput}Pointer): TGpStatus; stdcall; external GdiPlusDll;
procedure GdiplusShutdown(token: ULONG_PTR); stdcall; external GdiPlusDll;

function GdipCloneImage(Image: GpImage; out CloneImage: GpImage): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateFromHDC(Hdc: HDC; out Graphics: GpGraphics): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateHBITMAPFromBitmap(Bitmap: GpBitmap; out HbmReturn: HBitmap; Background: TAlphaColor): TGPStatus; stdcall; external GdiPlusDll;
function GdipDeleteGraphics(Graphics: GpGraphics): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImageGraphicsContext(Image: GpImage; out Graphics: GpGraphics): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImageHeight(Image: GpImage; out Height: Cardinal): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImageWidth(Image: GpImage; out Width: Cardinal): TGPStatus; stdcall; external GdiPlusDll;
function GdipBitmapUnlockBits(Bitmap: GpBitmap; LockedBitmapData: PGPBitmapData): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetPixelOffsetMode(Graphics: GpGraphics; PixelOffsetMode: TGpPixelOffsetMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateBitmapFromHBITMAP(Hbm: HBitmap; Hpal: HPalette; out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;
function GdipDisposeImage(Image: GpImage): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImageRawFormat(Image: GpImage; out Format: TGUID): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImageDimension(Image: GpImage; out Width: Single; out Height: Single): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateBitmapFromStream(const Stream: IStream; out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;
function GdipSaveImageToStream(image: GPIMAGE; stream: ISTREAM;  clsidEncoder: PGUID; EncoderParams: Pointer): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateBitmapFromScan0(Width: Integer; Height: Integer; Stride: Integer; Format: TGPPixelFormat; Scan0: PByte; out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;
function GdipFillRectangleI(graphics: GPGRAPHICS; brush: GPBRUSH; x, y, width, height: Integer): TGpStatus; stdcall; external GdiPlusDll;
function GdipIsVisibleRectI(Graphics: GpGraphics; X, Y, Width, Height: Integer; out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateTexture2I(Image: GpImage; Wrapmode: TGPWrapMode; X, Y, Width, Height: Integer; out Texture: GpTexture): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetPixelOffsetMode(Graphics: GpGraphics; out PixelOffsetMode: TGPPixelOffsetMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawImageRectRectI(Graphics: GpGraphics; Image: GpImage;
  Dstx: Integer; Dsty: Integer; Dstwidth: Integer; Dstheight: Integer;
  Srcx: Integer; Srcy: Integer; Srcwidth: Integer; Srcheight: Integer;
  SrcUnit: TGPUnit; const ImageAttributes: GpImageAttributes;
  Callback: TGPImageAbort; CallbackData: Pointer): TGPStatus; stdcall; external GdiPlusDll;

function GdipCreateImageAttributes(out Imageattr: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetImageAttributesColorMatrix(Imageattr: GpImageAttributes; AType: TGPColorAdjustType; EnableFlag: Bool;
  const ColorMatrix: PGPColorMatrix; const GrayMatrix: PGPColorMatrix; Flags: TGPColorMatrixFlags): TGPStatus; stdcall; external GdiPlusDll;

function GdipCreateStringFormat(FormatAttributes: TGPStringFormatFlags; Language: LANGID; out Format: GpStringFormat): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateLineBrushFromRectI(const Rect: PGPRect; Color1, Color2: TAlphaColor; Mode: TGPLinearGradientMode; WrapMode: TGPWrapMode; out LineGradient: GpLineGradient): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreatePen1(Color: TAlphaColor; Width: Single; AUnit: TGPUnit; out Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;
function GdipCreateSolidFill(Color: TAlphaColor; out Brush: GpSolidFill): TGPStatus; stdcall; external GdiPlusDll;
function GdipDeleteBrush(Brush: GpBrush): TGPStatus; stdcall; external GdiPlusDll;
function GdipDeletePen(Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;
function GdipDisposeImageAttributes(Imageattr: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawClosedCurve2I(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPoint; Count: Integer; Tension: Single): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawCurve2I(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPoint; Count: Integer; Tension: Single): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawEllipseI(Graphics: GpGraphics; Pen: GpPen; X, Y, W, H: Integer): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawImageRectI(Graphics: GpGraphics; Image: GpImage; X, Y, W, H: Integer): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawLineI(Graphics: GpGraphics; Pen: GpPen; X1, Y1, X2, Y2: Integer): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawLinesI(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPoint; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawRectangleI(Graphics: GpGraphics; Pen: GpPen; X, Y, W, H: Integer): TGPStatus; stdcall; external GdiPlusDll;
function GdipFillClosedCurve2I(Graphics: GpGraphics; Brush: GpBrush; const Points: PGPPoint; Count: Integer; Tension: Single; FillMode: TGPFillMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipFillEllipseI(Graphics: GpGraphics; Brush: GpBrush; X, Y, W, H: Integer): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetCompositingMode(Graphics: GpGraphics; out CompositingMode: TGPCompositingMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImageEncoders(NumEncoders: Cardinal; Size: Cardinal; Encoders: PGpImageCodecInfo): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImageEncodersSize(out NumEncoders: Cardinal; out Size: Cardinal): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetInterpolationMode(Graphics: GpGraphics; out InterpolationMode: TGPInterpolationMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetSmoothingMode(Graphics: GpGraphics; out SmoothingMode: TGPSmoothingMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetCompositingMode(Graphics: GpGraphics; CompositingMode: TGPCompositingMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetInterpolationMode(Graphics: GpGraphics; InterpolationMode: TGPInterpolationMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetPenColor(Pen: GpPen; Argb: TAlphaColor): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetPenDashStyle(Pen: GpPen; Dashstyle: TGPDashStyle): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetPenWidth(Pen: GpPen; Width: Single): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetSmoothingMode(Graphics: GpGraphics; SmoothingMode: TGPSmoothingMode): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetSolidFillColor(Brush: GpSolidFill; Color: TAlphaColor): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetTextRenderingHint(Graphics: GpGraphics; Mode: TGPTextRenderingHint): TGPStatus; stdcall; external GdiPlusDll;

function GdipCreateFontFromLogfontW(Hdc: HDC; const Logfont: PLogFontW; out Font: GpFont): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetStringFormatAlign(Format: GpStringFormat; Align: TGPStringAlignment): TGPStatus; stdcall; external GdiPlusDll;
function GdipSetStringFormatLineAlign(Format: GpStringFormat; Align: TGPStringAlignment): TGPStatus; stdcall; external GdiPlusDll;
function GdipDrawString(Graphics: GpGraphics; const Str: PWideChar; Length: Integer; const Font: GpFont;
  const LayoutRect: PGPRectF; const StringFormat: GpStringFormat; const Brush: GpBrush): TGPStatus; stdcall; external GdiPlusDll;
function GdipDeleteStringFormat(Format: GpStringFormat): TGPStatus; stdcall; external GdiPlusDll;
function GdipDeleteFont(Font: GpFont): TGPStatus; stdcall; external GdiPlusDll;
function GdipGetImagePixelFormat(Image: GpImage; out Format: TGPPixelFormat): TGPStatus; stdcall; external GdiPlusDll;
function GdipBitmapLockBits(Bitmap: GpBitmap; const Rect: PGPRect; Flags: DWORD; Format: TGPPixelFormat; LockedBitmapData: PGPBitmapData): TGPStatus; stdcall; external GdiPlusDll;
{$ENDREGION}
implementation

uses
  Math,
  // ACL
  ACL.Classes,
  ACL.FastCode,
  ACL.Geometry,
  ACL.Utils.Common,
  ACL.Utils.Strings;

const
  sErrorInvalidGdipOperation = 'Invalid operation in GDI+ (Code: %d)';
  sErrorPaintCanvasAlreadyBusy = 'PaintCanvas is already busy!';

  GpDefaultColorMatrix: TGpColorMatrix = (
    (1.0, 0.0, 0.0, 0.0, 0.0),
    (0.0, 1.0, 0.0, 0.0, 0.0),
    (0.0, 0.0, 1.0, 0.0, 0.0),
    (0.0, 0.0, 0.0, 1.0, 0.0),
    (0.0, 0.0, 0.0, 0.0, 1.0)
  );

var
  FPaintCanvas: TACLGdiplusPaintCanvas;

procedure GdipCheck(AStatus: TGPStatus);
begin
  if AStatus <> Ok then
    raise EGdipException.Create(AStatus);
end;

function GpPaintCanvas: TACLGdiplusPaintCanvas;
begin
  if FPaintCanvas = nil then
    FPaintCanvas := TACLGdiplusPaintCanvas.Create;
  Result := FPaintCanvas;
end;

//----------------------------------------------------------------------------------------------------------------------
// Internal Routines
//----------------------------------------------------------------------------------------------------------------------

function GpCreateBitmap(AWidth, AHeight: Integer; ABits: PByte = nil; APixelFormat: Integer = PixelFormat32bppPARGB): GpImage;
begin
  if GdipCreateBitmapFromScan0(AWidth, AHeight, AWidth * 4, APixelFormat, ABits, Result) <> Ok then
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------
// Fill Rect
//----------------------------------------------------------------------------------------------------------------------

procedure GpFillRect(DC: HDC; const R: TRect; AColor: TAlphaColor; AMode: TGpCompositingMode = cmSourceOver);
begin
  if (AColor <> TAlphaColor.None) or (AMode = cmSourceCopy) then
  begin
    GpPaintCanvas.BeginPaint(DC);
    try
      GpPaintCanvas.FillRectangle(AColor, R, AMode);
    finally
      GpPaintCanvas.EndPaint;
    end;
  end;
end;

procedure GpFrameRect(DC: HDC; const R: TRect; AColor: TAlphaColor; AFrameSize: Integer);
begin
  if AColor <> TAlphaColor.None then
  begin
    GpPaintCanvas.BeginPaint(DC);
    try
      GpPaintCanvas.DrawRectangle(AColor, R, gpsSolid, AFrameSize);
    finally
      GpPaintCanvas.EndPaint;
    end;
  end;
end;

procedure GpFocusRect(DC: HDC; const R: TRect; AColor: TAlphaColor);
var
  APrevOrg, AOrg: TPoint;
begin
  if AColor <> TAlphaColor.None then
  begin
  {$IFDEF FPC}
    AOrg := NullPoint;
  {$ENDIF}
    GetWindowOrgEx(DC, AOrg);
    SetBrushOrgEx(DC, AOrg.X, AOrg.Y, @APrevOrg);
    try
      GpPaintCanvas.BeginPaint(DC);
      try
        GpPaintCanvas.DrawRectangle(AColor, R, gpsDot);
      finally
        GpPaintCanvas.EndPaint;
      end;
    finally
      SetBrushOrgEx(DC, APrevOrg.X, APrevOrg.Y, nil);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------
// DrawImage
//----------------------------------------------------------------------------------------------------------------------

procedure GpDrawImage(AGraphics: GpGraphics; AImage: GpImage; AImageAttributes: GpImageAttributes;
  const ADestRect, ASourceRect: TRect; ATileDrawingMode: Boolean); overload;

  function GpIsRectVisible(AGraphics: GpGraphics; const R: TRect): LongBool;
  begin
    Result := GdipIsVisibleRectI(AGraphics, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, Result) = Ok;
  end;

  function CreateTextureBrush(const R: TRect; out ATexture: GpTexture): Boolean;
  begin
    Result := GdipCreateTexture2I(AImage, WrapModeTile, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, ATexture) = Ok;
  end;

  procedure StretchPart(const ADstRect, ASrcRect: TRect);
  var
    APixelOffsetMode: TGpPixelOffsetMode;
    SW, SH, DW, DH: Integer;
  begin
    if GpIsRectVisible(AGraphics, ADstRect) then
    begin
      SH := ASrcRect.Bottom - ASrcRect.Top;
      SW := ASrcRect.Right - ASrcRect.Left;
      DW := ADstRect.Right - ADstRect.Left;
      DH := ADstRect.Bottom - ADstRect.Top;

      GdipCheck(GdipGetPixelOffsetMode(AGraphics, APixelOffsetMode));
      if APixelOffsetMode <> pomHalf then
      begin
        if (DH > SH) and (SH > 1) then Dec(SH);
        if (DW > SW) and (SW > 1) then Dec(SW);
      end;

      GdipDrawImageRectRectI(AGraphics, AImage, ADstRect.Left, ADstRect.Top, DW, DH,
        ASrcRect.Left, ASrcRect.Top, SW, SH, UnitPixel, AImageAttributes, nil, nil);
    end;
  end;

  procedure TilePartManual(const ADest: TRect; ADestWidth, ADestHeight, ASourceWidth, ASourceHeight: Integer);
  var
    AColumn, ARow: Integer;
    AColumnCount, ARowCount: Integer;
    R: TRect;
  begin
    ARowCount := acCalcPatternCount(ADestHeight, ASourceHeight);
    AColumnCount := acCalcPatternCount(ADestWidth, ASourceWidth);
    for ARow := 0 to ARowCount - 1 do
    begin
      R.Top := ADest.Top + ASourceHeight * ARow;
      R.Bottom := Min(ADest.Bottom, R.Top + ASourceHeight);
      for AColumn := 0 to AColumnCount - 1 do
      begin
        R.Left := ADest.Left + ASourceWidth * AColumn;
        R.Right := Min(ADest.Right, R.Left + ASourceWidth);
        StretchPart(R, acRectSetSize(ASourceRect, R.Right - R.Left, R.Bottom - R.Top));
      end;
    end;
  end;

  function TilePartBrush(const R, ASource: TRect): Boolean;
  var
    ABitmap: GpBitmap;
    ABitmapGraphics: GpGraphics;
    ATexture: GpTexture;
    AWidth, AHeight: Integer;
  begin
    Result := (AImageAttributes = nil) and CreateTextureBrush(ASource, ATexture);
    if Result then
    try
      AWidth := R.Right - R.Left;
      AHeight := R.Bottom - R.Top;
      ABitmap := GpCreateBitmap(AWidth, AHeight);
      if ABitmap <> nil then
      try
        GdipCheck(GdipGetImageGraphicsContext(ABitmap, ABitmapGraphics));
        GdipCheck(GdipFillRectangleI(ABitmapGraphics, ATexture, 0, 0, AWidth, AHeight));
        GdipCheck(GdipDrawImageRectI(AGraphics, ABitmap, R.Left, R.Top, AWidth, AHeight));
        GdipCheck(GdipDeleteGraphics(ABitmapGraphics));
      finally
        GdipCheck(GdipDisposeImage(ABitmap));
      end;
    finally
      GdipCheck(GdipDeleteBrush(ATexture));
    end;
  end;

var
  DW, DH, SW, SH: Integer;
begin
  DW := ADestRect.Right - ADestRect.Left;
  DH := ADestRect.Bottom - ADestRect.Top;
  SW := ASourceRect.Right - ASourceRect.Left;
  SH := ASourceRect.Bottom - ASourceRect.Top;
  if (SH <> 0) and (SW <> 0) and (DW <> 0) and (DH <> 0) then
  begin
    if ATileDrawingMode and ((DW <> SW) or (DH <> SH)) then
    begin
      if not TilePartBrush(ADestRect, ASourceRect) then
        TilePartManual(ADestRect, DW, DH, SW, SH);
    end
    else
      StretchPart(ADestRect, ASourceRect);
  end;
end;

procedure GpDrawImage(AGraphics: GpGraphics; AImage: GpImage;
  const ADestRect, ASourceRect: TRect; ATileDrawingMode: Boolean; const AAlpha: Byte = $FF); overload;
var
  AColorMatrix: PGpColorMatrix;
  AImageAttributes: GpImageAttributes;
begin
  if AAlpha = $FF then
  begin
    GpDrawImage(AGraphics, AImage, nil, ADestRect, ASourceRect, ATileDrawingMode);
    Exit;
  end;

  GdipCreateImageAttributes(AImageAttributes);
  try
    AColorMatrix := GdipAlloc(SizeOf(TGpColorMatrix));
    try
      AColorMatrix^ := GpDefaultColorMatrix;
      AColorMatrix[3, 3] := AAlpha / $FF;
      GdipSetImageAttributesColorMatrix(AImageAttributes, ColorAdjustTypeBitmap, True, AColorMatrix, nil, ColorMatrixFlagsDefault);
      GpDrawImage(AGraphics, AImage, AImageAttributes, ADestRect, ASourceRect, ATileDrawingMode);
    finally
      GdipFree(AColorMatrix);
    end;
  finally
    GdipDisposeImageAttributes(AImageAttributes);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------
// Codec
//----------------------------------------------------------------------------------------------------------------------

function GpGetCodecByMimeType(const AMimeType: UnicodeString; out ACodecID: TGUID): Boolean;
var
  ACodecInfo, AStartInfo: PGpImageCodecInfo;
  ACount: Cardinal;
  ASize, I: Cardinal;
begin
  Result := False;
  if (GdipGetImageEncodersSize(ACount, ASize) = Ok) and (ASize > 0) then
  begin
    GetMem(AStartInfo, ASize);
    try
      ACodecInfo := AStartInfo;
      if GdipGetImageEncoders(ACount, ASize, ACodecInfo) = Ok then
      begin
        for I := 1 to ACount do
        begin
          if acSameText(PWideChar(ACodecInfo^.MimeType), AMimeType) then
          begin
            ACodecID := ACodecInfo^.Clsid;
            Exit(True);
          end;
          Inc(ACodecInfo);
        end;
      end;
    finally
      FreeMem(AStartInfo, ASize);
    end;
    if acSameText(AMimeType, _U('image/jpg')) then
      Result := GpGetCodecByMimeType('image/jpeg', ACodecID)
  end;
end;

{ EGdipException }

constructor EGdipException.Create(AStatus: TGPStatus);
begin
  CreateFmt(sErrorInvalidGdipOperation, [Ord(AStatus)]);
  FStatus := AStatus;
end;

{ TACLGdiplusObject }

class function TACLGdiplusObject.NewInstance: TObject;
begin
  Result := InitInstance(GdipAlloc(InstanceSize));
end;

procedure TACLGdiplusObject.FreeInstance;
begin
  CleanupInstance;
  GdipFree(Self);
end;

{ TACLGdiplusCustomGraphicObject }

procedure TACLGdiplusCustomGraphicObject.BeforeDestruction;
begin
  inherited BeforeDestruction;
  FreeHandle;
end;

procedure TACLGdiplusCustomGraphicObject.FreeHandle;
begin
  if HandleAllocated then
  begin
    DoFreeHandle(FHandle);
    FHandle := nil;
  end;
end;

procedure TACLGdiplusCustomGraphicObject.HandleNeeded;
begin
  if FHandle = nil then
  begin
    Inc(FChangeLockCount);
    try
      DoCreateHandle(FHandle);
    finally
      Dec(FChangeLockCount);
    end;
  end;
end;

procedure TACLGdiplusCustomGraphicObject.Changed;
begin
  if FChangeLockCount = 0 then
    CallNotifyEvent(Self, OnChange);
end;

function TACLGdiplusCustomGraphicObject.GetHandle: GpHandle;
begin
  HandleNeeded;
  Result := FHandle;
end;

function TACLGdiplusCustomGraphicObject.GetHandleAllocated: Boolean;
begin
  Result := FHandle <> nil;
end;

{ TACLGdiplusBrush }

procedure TACLGdiplusBrush.AfterConstruction;
begin
  inherited AfterConstruction;
  FColor := TAlphaColor.Black;
end;

procedure TACLGdiplusBrush.DoCreateHandle(out AHandle: GpHandle);
begin
  GdipCheck(GdipCreateSolidFill(Color, GpBrush(AHandle)));
end;

procedure TACLGdiplusBrush.DoFreeHandle(AHandle: GpHandle);
begin
  GdipCheck(GdipDeleteBrush(AHandle));
end;

procedure TACLGdiplusBrush.SetColor(AValue: TAlphaColor);
begin
  if FColor <> AValue then
  begin
    FColor := AValue;
    if HandleAllocated then
      GdipCheck(GdipSetSolidFillColor(Handle, Color));
    Changed;
  end;
end;

{ TACLGdiplusPen }

procedure TACLGdiplusPen.AfterConstruction;
begin
  inherited AfterConstruction;
  FColor := TAlphaColor.Black;
  FWidth := 1.0;
end;

procedure TACLGdiplusPen.DoCreateHandle(out AHandle: GpHandle);
begin
  GdipCheck(GdipCreatePen1(Color, Width, UnitPixel, GpPen(AHandle)));
  DoSetDashStyle(AHandle);
end;

procedure TACLGdiplusPen.DoFreeHandle(AHandle: GpHandle);
begin
  GdipCheck(GdipDeletePen(AHandle));
end;

procedure TACLGdiplusPen.DoSetDashStyle(AHandle: GpHandle);
const
  Map: array[TACLGdiplusPenStyle] of TGpDashStyle = (
    DashStyleSolid, DashStyleDash, DashStyleDot, DashStyleDashDot, DashStyleDashDotDot
  );
begin
  GdipCheck(GdipSetPenDashStyle(AHandle, Map[Style]));
end;

procedure TACLGdiplusPen.SetColor(AValue: TAlphaColor);
begin
  if FColor <> AValue then
  begin
    FColor := AValue;
    if HandleAllocated then
      GdipCheck(GdipSetPenColor(Handle, Color));
    Changed;
  end;
end;

procedure TACLGdiplusPen.SetStyle(AValue: TACLGdiplusPenStyle);
begin
  if FStyle <> AValue then
  begin
    FStyle := AValue;
    if HandleAllocated then
      DoSetDashStyle(Handle);
    Changed;
  end;
end;

procedure TACLGdiplusPen.SetWidth(AValue: Single);
begin
  AValue := Max(0, AValue);
  if AValue <> FWidth then
  begin
    FWidth := AValue;
    if HandleAllocated then
      GdipCheck(GdipSetPenWidth(Handle, Width));
    Changed;
  end;
end;

{ TACLGdiplusCanvas }

constructor TACLGdiplusCanvas.Create;
begin
  inherited Create;
  FPen := TACLGdiplusPen.Create;
  FBrush := TACLGdiplusBrush.Create;
end;

constructor TACLGdiplusCanvas.Create(DC: HDC);
begin
  Create;
  GdipCheck(GdipCreateFromHDC(DC, FHandle));
end;

constructor TACLGdiplusCanvas.Create(AHandle: GpGraphics);
begin
  Create;
  FHandle := AHandle;
end;

destructor TACLGdiplusCanvas.Destroy;
begin
  FreeAndNil(FPen);
  FreeAndNil(FBrush);
  if Handle <> nil then
    GdipCheck(GdipDeleteGraphics(Handle));
  inherited Destroy;
end;

procedure TACLGdiplusCanvas.DrawLine(APen: TACLGdiplusPen; X1, Y1, X2, Y2: Integer);
begin
  GdipCheck(GdipDrawLineI(Handle, APen.Handle, X1, Y1, X2, Y2));
end;

procedure TACLGdiplusCanvas.FillClosedCurve2(ABrush: TACLGdiplusBrush; const APoints: array of TPoint; ATension: Single);
begin
  GdipCheck(GdipFillClosedCurve2I(Handle, ABrush.Handle, @APoints[0], Length(APoints), ATension, FillModeWinding));
end;

procedure TACLGdiplusCanvas.FillClosedCurve2(AColor: TAlphaColor; const APoints: array of TPoint; ATension: Single);
begin
  FBrush.Color := AColor;
  FillClosedCurve2(FBrush, APoints, ATension);
end;

procedure TACLGdiplusCanvas.DrawClosedCurve2(APen: TACLGdiplusPen; const APoints: array of TPoint; ATension: Single);
begin
  GdipCheck(GdipDrawClosedCurve2I(Handle, APen.Handle, @APoints[0], Length(APoints), ATension));
end;

procedure TACLGdiplusCanvas.DrawClosedCurve2(APenColor: TAlphaColor; const APoints: array of TPoint;
  ATension: Single; APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0);
begin
  FPen.Color := APenColor;
  FPen.Style := APenStyle;
  FPen.Width := APenWidth;
  DrawClosedCurve2(FPen, APoints, ATension);
end;

procedure TACLGdiplusCanvas.DrawCurve2(APen: TACLGdiplusPen; APoints: array of TPoint; ATension: Single);
begin
  GdipCheck(GdipDrawCurve2I(Handle, APen.Handle, @APoints[0], Length(APoints), ATension));
end;

procedure TACLGdiplusCanvas.DrawCurve2(APenColor: TAlphaColor; APoints: array of TPoint; ATension: Single;
  APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0);
begin
  FPen.Color := APenColor;
  FPen.Style := APenStyle;
  FPen.Width := APenWidth;
  DrawCurve2(FPen, APoints, ATension);
end;

procedure TACLGdiplusCanvas.DrawLine(APenColor: TAlphaColor; X1, Y1, X2, Y2: Integer;
  APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0);
begin
  FPen.Color := APenColor;
  FPen.Style := APenStyle;
  FPen.Width := APenWidth;
  DrawLine(FPen, X1, Y1, X2, Y2);
end;

procedure TACLGdiplusCanvas.DrawLine(APenColor: TAlphaColor; const APoints: array of TPoint;
  APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0);
begin
  FPen.Color := APenColor;
  FPen.Style := APenStyle;
  FPen.Width := APenWidth;
  GdipDrawLinesI(Handle, FPen.Handle, @APoints[0], Length(APoints));
end;

procedure TACLGdiplusCanvas.DrawEllipse(APen: TACLGdiplusPen; const R: TRect);
begin
  GdipDrawEllipseI(Handle, APen.Handle, R.Left, R.Top, R.Width, R.Height);
end;

procedure TACLGdiplusCanvas.DrawEllipse(APenColor: TAlphaColor; const R: TRect;
  APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0);
begin
  FPen.Color := APenColor;
  FPen.Style := APenStyle;
  FPen.Width := APenWidth;
  DrawEllipse(FPen, R);
end;

procedure TACLGdiplusCanvas.FillEllipse(ABrush: TACLGdiplusBrush; const R: TRect);
begin
  GdipFillEllipseI(Handle, ABrush.Handle, R.Left, R.Top, R.Width, R.Height);
end;

procedure TACLGdiplusCanvas.FillEllipse(AColor: TAlphaColor; const R: TRect);
begin
  FBrush.Color := AColor;
  FillEllipse(FBrush, R);
end;

procedure TACLGdiplusCanvas.FillRectangle(ABrush: TACLGdiplusBrush; const R: TRect; AMode: TGpCompositingMode = cmSourceOver);
var
  APrevMode: TGpCompositingMode;
begin
  if not acRectIsEmpty(R) then
  begin
    GdipGetCompositingMode(Handle, APrevMode);
    try
      GdipSetCompositingMode(Handle, AMode);
      GdipFillRectangleI(Handle, ABrush.Handle, R.Left, R.Top, R.Width, R.Height);
    finally
      GdipSetCompositingMode(Handle, APrevMode);
    end;
  end;
end;

procedure TACLGdiplusCanvas.FillRectangle(AColor: TAlphaColor; const R: TRect; AMode: TGpCompositingMode = cmSourceOver);
begin
  if (AColor <> TAlphaColor.None) or (AMode = cmSourceCopy) then
  begin
    FBrush.Color := AColor;
    FillRectangle(FBrush, R, AMode);
  end;
end;

procedure TACLGdiplusCanvas.FillRectangleByGradient(AColor1, AColor2: TAlphaColor; const R: TRect; AMode: TGpLinearGradientMode);
var
  ABrush: GpBrush;
  ABrushRect: TGpRect;
begin
  ABrushRect.X := R.Left - 1;
  ABrushRect.Y := R.Top - 1;
  ABrushRect.Width := acRectWidth(R) + 2;
  ABrushRect.Height := acRectHeight(R) + 2;
  GdipCheck(GdipCreateLineBrushFromRectI(@ABrushRect, AColor1, AColor2, AMode, WrapModeTile, ABrush));
  GdipCheck(GdipFillRectangleI(Handle, ABrush, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top));
  GdipCheck(GdipDeleteBrush(ABrush));
end;

procedure TACLGdiplusCanvas.DrawRectangle(APen: TACLGdiplusPen; const R: TRect);
begin
  if not acRectIsEmpty(R) then
    GdipDrawRectangleI(Handle, APen.Handle, R.Left, R.Top, R.Width - 1, R.Height - 1);
end;

procedure TACLGdiplusCanvas.DrawRectangle(APenColor: TAlphaColor;
  const R: TRect; APenStyle: TACLGdiplusPenStyle = gpsSolid; APenWidth: Single = 1.0);
begin
  FPen.Color := APenColor;
  FPen.Style := APenStyle;
  FPen.Width := APenWidth;
  DrawRectangle(FPen, R);
end;

procedure TACLGdiplusCanvas.TextOut(const AText: UnicodeString; const R: TRect; AFont: TFont;
  AHorzAlign: TAlignment; AVertAlign: TVerticalAlignment; AWordWrap: Boolean; ATextColor: TAlphaColor;
  ARendering: TGpTextRenderingHint = trhSystemDefault);
const
  HorzAlignMap: array[TAlignment] of TGpStringAlignment = (StringAlignmentNear, StringAlignmentFar, StringAlignmentCenter);
  VertAlignMap: array[TVerticalAlignment] of TGpStringAlignment = (StringAlignmentNear, StringAlignmentFar, StringAlignmentCenter);
  WordWrapMap: array[Boolean] of Integer = (StringFormatFlagsNoWrap, 0);
var
  ABrush: GpBrush;
  AFontHandle: GpFont;
  AFontInfo: TLogFontW;
  ARect: TGPRectF;
  AStringFormat: GpStringFormat;
begin
  if acRectIsEmpty(R) or (AText = '') then Exit;

  if ATextColor = TAlphaColor.Default then
    ATextColor := TAlphaColor.FromColor(AFont.Color);

  ZeroMemory(@AFontInfo, SizeOf(AFontInfo));
  GetObjectW(AFont.Handle, SizeOf(AFontInfo), @AFontInfo);
  GdipCheck(GdipCreateFontFromLogfontW(MeasureCanvas.Handle, @AFontInfo, AFontHandle));
  try
    GdipCheck(GdipSetTextRenderingHint(Handle, ARendering));
    GdipCheck(GdipCreateStringFormat(WordWrapMap[AWordWrap], LANG_NEUTRAL, AStringFormat));
    try
      GdipCheck(GdipSetStringFormatAlign(AStringFormat, HorzAlignMap[AHorzAlign]));
      GdipCheck(GdipSetStringFormatLineAlign(AStringFormat, VertAlignMap[AVertAlign]));
      GdipCheck(GdipCreateSolidFill(ATextColor, ABrush));
      try
        ARect.X := R.Left;
        ARect.Y := R.Top;
        ARect.Width := R.Width;
        ARect.Height := R.Height;
        GdipCheck(GdipDrawString(Handle, PWideChar(AText), acStringLength(AText), AFontHandle, @ARect, AStringFormat, ABrush));
      finally
        GdipCheck(GdipDeleteBrush(ABrush));
      end;
    finally
      GdipCheck(GdipDeleteStringFormat(AStringFormat));
    end;
  finally
    GdipCheck(GdipDeleteFont(AFontHandle));
  end;
end;

function TACLGdiplusCanvas.GetInterpolationMode: TGpInterpolationMode;
begin
  GdipCheck(GdipGetInterpolationMode(Handle, Result));
end;

function TACLGdiplusCanvas.GetPixelOffsetMode: TGpPixelOffsetMode;
begin
  GdipCheck(GdipGetPixelOffsetMode(Handle, Result));
end;

function TACLGdiplusCanvas.GetSmoothingMode: TGpSmoothingMode;
begin
  GdipCheck(GdipGetSmoothingMode(Handle, Result));
end;

procedure TACLGdiplusCanvas.SetInterpolationMode(const Value: TGpInterpolationMode);
begin
  GdipCheck(GdipSetInterpolationMode(Handle, Value));
end;

procedure TACLGdiplusCanvas.SetPixelOffsetMode(const Value: TGpPixelOffsetMode);
begin
  GdipCheck(GdipSetPixelOffsetMode(Handle, Value));
end;

procedure TACLGdiplusCanvas.SetSmoothingMode(const Value: TGpSmoothingMode);
begin
  GdipCheck(GdipSetSmoothingMode(Handle, Value));
end;

{ TACLGdiplusPaintCanvas }

constructor TACLGdiplusPaintCanvas.Create;
begin
  inherited Create;
  FSavedHandles := TStack.Create;
end;

destructor TACLGdiplusPaintCanvas.Destroy;
begin
  FreeAndNil(FSavedHandles);
  inherited Destroy;
end;

procedure TACLGdiplusPaintCanvas.BeginPaint(DC: HDC);
begin
  if FHandle <> nil then
    FSavedHandles.Push(FHandle);
  GdipCheck(GdipCreateFromHDC(DC, FHandle));
end;

procedure TACLGdiplusPaintCanvas.EndPaint;
begin
  try
    GdipDeleteGraphics(FHandle);
  finally
    if FSavedHandles.Count > 0 then
      FHandle := FSavedHandles.Pop
    else
      FHandle := nil;
  end;
end;

{ TACLGdiplusStream }

function TACLGdiplusStream.Stat(out AStatStg: TStatStg; AStatFlag: DWORD): HResult; stdcall;
begin
  ZeroMemory(@AStatStg, SizeOf(AStatStg));
  Result := inherited Stat(AStatStg, AStatFlag);
end;

{ TACLGdiplusSolidBrushCache }

class destructor TACLGdiplusSolidBrushCache.Destroy;
begin
  FreeAndNil(FInstance);
end;

class procedure TACLGdiplusSolidBrushCache.Flush;
begin
  if FInstance <> nil then
    FInstance.Clear;
end;

class function TACLGdiplusSolidBrushCache.GetOrCreate(AColor: TAlphaColor): GpBrush;
begin
  if FInstance = nil then
  begin
    FInstance := TACLValueCacheManager<TAlphaColor, GpBrush>.Create(512);
    FInstance.OnRemove := RemoveValueHandler;
  end;
  if not FInstance.Get(AColor, Result) then
  begin
    GdipCheck(GdipCreateSolidFill(AColor, Result));
    FInstance.Add(AColor, Result);
  end;
end;

class procedure TACLGdiplusSolidBrushCache.RemoveValueHandler(Sender: TObject; const ABrush: GpBrush);
begin
  GdipDeleteBrush(ABrush);
end;

initialization
  if not IsLibrary then
  begin
    GdiplusStartupInput.GdiplusVersion := 1;
    GdiplusStartupInput.DebugEventCallback := nil;
    GdiplusStartupInput.SuppressBackgroundThread := False;
    GdiplusStartupInput.SuppressExternalCodecs := False;
    GdiplusStartup(GdiplusToken, @GdiplusStartupInput, nil);
  end;

finalization
  FreeAndNil(FPaintCanvas);
  TACLGdiplusSolidBrushCache.Flush;
  if not IsLibrary then
    GdiplusShutdown(GdiplusToken);
end.
