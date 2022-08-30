program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  LCLIntf,
  Interfaces, // this includes the LCL widgetset

  //ACL.UI.HintWindow in 'Visual/ACL.UI.HintWindow.pas',
  ACL.UI.Application in 'Visual/ACL.UI.Application.pas',
  ACL.UI.Resources in 'Visual/ACL.UI.Resources.pas',
  ACL.UI.Forms in 'Visual/ACL.UI.Forms.pas',
  ACL.UI.Animation in 'Visual/ACL.UI.Animation.pas',
  ACL.UI.ImageList in 'Visual/ACL.UI.ImageList.pas',
  //ACL.UI.PopupMenu in 'Visual/ACL.UI.PopupMenu.pas',
  ACL.UI.Controls.BaseControls in 'Visual/ACL.UI.Controls.BaseControls.pas',
  ACL.UI.Controls.buttons in 'Visual/ACL.UI.Controls.Buttons.pas',
  ACL.UI.Controls.Labels in 'Visual/ACL.UI.Controls.Labels.pas',
  ACL.Web in 'Base/ACL.Web.pas',
  ACL.Web.Http in 'Base/ACL.Web.Http.pas',
  ACL.Classes in 'Base/ACL.Classes.pas',
  ACL.Classes.ByteBuffer in 'Base/ACL.Classes.ByteBuffer.pas',
  ACL.Classes.Collections in 'Base/ACL.Classes.Collections.pas',
  ACL.Classes.StringList in 'Base/ACL.Classes.StringList.pas',
  ACL.Classes.Timer in 'Base/ACL.Classes.Timer.pas',
  ACL.Crypto in 'Base/ACL.Crypto.pas',
  ACL.DataBroadcaster in 'Base/ACL.DataBroadcaster.pas',
  ACL.Expressions in 'Base/ACL.Expressions.pas',
  ACL.Expressions.FormatString in 'Base/ACL.Expressions.FormatString.pas',
  ACL.Expressions.Math in 'Base/ACL.Expressions.Math.pas',
  ACL.FastCode in 'Base/ACL.FastCode.pas',
  ACL.FileFormats.CSV in 'Base/ACL.FileFormats.CSV.pas',
  ACL.FileFormats.INI in 'Base/ACL.FileFormats.INI.pas',
  ACL.FileFormats.XML in 'Base/ACL.FileFormats.XML.pas',
  ACL.FileFormats.XML.Reader in 'Base/ACL.FileFormats.XML.Reader.pas',
  ACL.FileFormats.XML.Writer in 'Base/ACL.FileFormats.XML.Writer.pas',
  ACL.FileFormats.XML.Types in 'Base/ACL.FileFormats.XML.Types.pas',
  ACL.Geometry in 'Base/ACL.Geometry.pas',
  ACL.Graphics in 'Base/ACL.Graphics.pas',
  ACL.Graphics.Palette in 'Base/ACL.Graphics.Palette.pas',
  ACL.Graphics.Images in 'Base/ACL.Graphics.Images.pas',
  ACL.Graphics.Layers in 'Base/ACL.Graphics.Layers.pas',
  ACL.Graphics.Layers.Software in 'Base/ACL.Graphics.Layers.Software.pas',
  ACL.Graphics.Gdiplus in 'Base/ACL.Graphics.Gdiplus.pas',
  ACL.Graphics.FontCache in 'Base/ACL.Graphics.FontCache.pas',
  ACL.Graphics.TextLayout in 'Base/ACL.Graphics.TextLayout.pas',
  ACL.Graphics.TextLayout32 in 'Base/ACL.Graphics.TextLayout32.pas',
  ACL.Graphics.SkinImage in 'Base/ACL.Graphics.SkinImage.pas',
  ACL.Graphics.SkinImageSet in 'Base/ACL.Graphics.SkinImageSet.pas',
  ACL.Hashes in 'Base/ACL.Hashes.pas',
  ACL.Math in 'Base/ACL.Math.pas',
  ACL.Math.Complex in 'Base/ACL.Math.Complex.pas',
  ACL.MUI in 'Base/ACL.MUI.pas',
  ACL.ObjectLinks in 'Base/ACL.ObjectLinks.pas',
  ACL.Parsers in 'Base/ACL.Parsers.pas',
  ACL.Parsers.Ripper in 'Base/ACL.Parsers.Ripper.pas',
  ACL.Threading in 'Base/ACL.Threading.pas',
  ACL.Threading.Pool in 'Base/ACL.Threading.Pool.pas',
  ACL.Threading.Sorting in 'Base/ACL.Threading.Sorting.pas',
  ACL.Utils.Registry in 'Base/ACL.Utils.Registry.pas',
  ACL.Utils.Common in 'Base/ACL.Utils.Common.pas',
  ACL.Utils.CommandLine in 'Base/ACL.Utils.CommandLine.pas',
  ACL.Utils.Clipboard in 'Base/ACL.Utils.Clipboard.pas',
  ACL.Utils.Date in 'Base/ACL.Utils.Date.pas',
  ACL.Utils.FileSystem in 'Base/ACL.Utils.FileSystem.pas',
  ACL.Utils.FileSystem.Watcher in 'Base/ACL.Utils.FileSystem.Watcher.pas',
  ACL.Utils.Messaging in 'Base/ACL.Utils.Messaging.pas',
  ACL.Utils.Stream in 'Base/ACL.Utils.Stream.pas',
  ACL.Utils.Strings in 'Base/ACL.Utils.Strings.pas',
  ACL.Utils.Strings.Transcode in 'Base/ACL.Utils.Strings.Transcode.pas',
  ACL.Utils.Desktop in 'Base/ACL.Utils.Desktop.pas',
  ACL.Utils.RTTI in 'Base/ACL.Utils.RTTI.pas',
  ACL.Utils.DPIAware in 'Base/ACL.Utils.DPIAware.pas',
  ACL.Utils.Logger in 'Base/ACL.Utils.Logger.pas',
  ACL.Utils.Shell in 'Base/ACL.Utils.Shell.pas',
  ACL.Utils.Shell.UserAccounts in 'Base/ACL.Utils.Shell.UserAccounts.pas',
  ACL.Utils.Shell.FileTypeRegistrar in 'Base/ACL.Utils.Shell.FileTypeRegistrar.pas',

  Forms, Unit1
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

