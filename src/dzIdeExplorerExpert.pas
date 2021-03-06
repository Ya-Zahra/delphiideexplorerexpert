unit dzIdeExplorerExpert;

{$INCLUDE 'jedi.inc'}

interface

{$IFNDEF DelphiXE3_Up}
// My Delphi XE2 installation does not have Firemonkey support
// and XE didn't support it. So this define removes any code referencing it.
{$DEFINE nodzFmxSupport}
{$ENDIF ~DelphiXE3_Up}

{$DEFINE testWizard}

uses
  Windows,
  Classes,
  Dialogs,
  ActnList,
  Menus,
  ExtCtrls,
  StdCtrls,
  Forms,
  ToolsAPI,
  dzIdeExplorerMainForm;

type
  TDGHIDEExplorer = class(TNotifierObject, IOTAWizard)
  private // IOTAWizard
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  private
    FExplorerAction: TAction;
    FExplorerMenuItem: TMenuItem;
    FExplorerForm: Tf_dzIdeExplorerMain;
{$IFDEF DELPHI2005_UP}
    FAboutPluginIndex: Integer;
{$ENDIF DELPHI2005_UP}
{$IFDEF testWizard}
    FTestItem: TMenuItem;
    procedure TestClick(_Sender: TObject);
{$ENDIF testWizard}
    procedure ShowExplorer(_Sender: TObject);
    class procedure InitSplashScreen; // static;
    class procedure DoneSplashScreen; // static;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  Graphics,
  Controls,
  dzIdeExplorerVcl,
  dzIdeExplorerdzVclUtils;

{ TDGHIDEExplorer Class Methods }

{$R 'SplashscreenIcon.RES'}

constructor TDGHIDEExplorer.Create;
var
  NTAServices: INTAServices;
{$IFDEF DELPHI2005_UP}
  AboutBoxServices: IOTAAboutBoxServices;
  bmSplashScreen: HBITMAP;
{$ENDIF DELPHI2005_UP}
  MainMenu: TMainMenu;
  i: Integer;
begin
  inherited Create;

{$IFDEF DELPHI2005_UP}
  if Supports(BorlandIDEServices, IOTAAboutBoxServices, AboutBoxServices) then begin
    bmSplashScreen := LoadBitmap(HInstance, 'SplashScreenBitMap');
    FAboutPluginIndex := AboutBoxServices.AddPluginInfo(
      GetName,
      'Explorer window for the Delphi IDE components'#13#10
      + '(c) 2014 by Thomas Mueller'#13#10
      + 'http://blog.dummzeuch.de'#13#10
      + 'based on a Delphi 3/4 version by David Hoyle',
      bmSplashScreen,
      False,
      '',
      'Mozilla Public License 1.1');
  end;
{$ENDIF DELPHI2005_UP}

  if Supports(BorlandIDEServices, INTAServices, NTAServices) then begin
    FExplorerAction := TAction.Create(nil);
    FExplorerAction.ActionList := NTAServices.ActionList;
    FExplorerAction.Caption := GetName;
    FExplorerAction.Hint := 'Show the Delphi IDE explorer window';
    FExplorerAction.OnExecute := ShowExplorer;

    MainMenu := NTAServices.MainMenu;
    for i := 0 to MainMenu.Items.Count - 1 do begin
      if SameText(MainMenu.Items[i].Name, 'ToolsMenu') then begin
        FExplorerMenuItem := TMenuItem.Create(MainMenu);
        FExplorerMenuItem.Action := FExplorerAction;
        MainMenu.Items[i].Insert(0, FExplorerMenuItem);

{$IFDEF testWizard}
        FTestItem := TMenuItem.Create(MainMenu);
        FTestItem.Caption := 'Test';
        FTestItem.OnClick := TestClick;
        MainMenu.Items[i].Insert(0, FTestItem);
{$ENDIF testWizard}
      end;
    end;
  end;
end;

destructor TDGHIDEExplorer.Destroy;
{$IFDEF DELPHI2005_UP}
var
  AboutBoxServices: IOTAAboutBoxServices;
{$ENDIF DELPHI2005_UP}
begin
  try
{$IFDEF testWizard}
    FreeAndNil(FTestItem);
{$ENDIF testWizard}

    FreeAndNil(FExplorerMenuItem);
    FreeAndNil(FExplorerAction);
    FreeAndNil(FExplorerForm);

{$IFDEF DELPHI2005_UP}
    if Supports(BorlandIDEServices, IOTAAboutBoxServices, AboutBoxServices) then begin
      AboutBoxServices.RemovePluginInfo(FAboutPluginIndex);
    end;
{$ENDIF DELPHI2005_UP}

  except
    // ignore any exceptions, we don't want to crash the ide, better risk a memory leak
  end;
  inherited Destroy;
end;

procedure TDGHIDEExplorer.ShowExplorer(_Sender: TObject);
begin
  Execute;
end;

{$IFDEF testWizard}

procedure TDGHIDEExplorer.TestClick(_Sender: TObject);
begin

end;

{$ENDIF testWizard}

procedure TDGHIDEExplorer.Execute;
begin
  if not Assigned(FExplorerForm) then
    FExplorerForm := Tf_dzIdeExplorerMain.Create(nil);
  FExplorerForm.Show;
end;

function TDGHIDEExplorer.GetIDString: string;
begin
  Result := 'de.dummzeuch.DelphiIdeExplorer';
end;

const
  ExpertName = 'Delphi IDE Explorer';

function TDGHIDEExplorer.GetName: string;
begin
  Result := ExpertName;
end;

function TDGHIDEExplorer.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure AddPluginToSplashScreen(_Icon: HBITMAP; const _Title: string; const _Version: string);
{$IFDEF DELPHI2005_UP}
// Only Delphi 2005 and up support the splash screen services
begin
  if Assigned(SplashScreenServices) then
    SplashScreenServices.AddPluginBitmap(_Title,
      _Icon, False, _Version);
end;
{$ELSE DELPHI2005_UP}
const
  XPOS = 140;
  YPOS = 150;
  PluginLogoStr = 'PluginLogo';
var
  imgLogo: TImage;
  lblTitle: TLabel;
  lblVersion: TLabel;
  i: integer;
  PluginIdx: integer;
  frm: TCustomForm;
begin
  for i := 0 to Screen.FormCount - 1 do begin
    frm := Screen.Forms[i];
    if (frm.Name = 'SplashScreen') and frm.ClassNameIs('TForm') then begin
      PluginIdx := 0;
      while frm.FindComponent(PluginLogoStr + IntToStr(PluginIdx)) <> nil do
        Inc(PluginIdx);

      imgLogo := TImage.Create(frm);
      imgLogo.Name := PluginLogoStr + IntToStr(PluginIdx);
      imgLogo.Parent := frm;
      imgLogo.AutoSize := True;
      imgLogo.Picture.Bitmap.Handle := _Icon;
      imgLogo.Left := XPOS + (32 - imgLogo.Width) div 2;
      imgLogo.Top := YPOS + (32 * PluginIdx) + (32 - imgLogo.Height) div 2;

      lblTitle := TLabel.Create(frm);
      lblTitle.Name := 'PluginTitle' + IntToStr(PluginIdx);
      lblTitle.Parent := frm;
      lblTitle.Caption := _Title;
      lblTitle.Top := imgLogo.Top;
      lblTitle.Left := imgLogo.Left + 32 + 8;
      lblTitle.Transparent := True;
      lblTitle.Font.Color := clWhite;
      lblTitle.Font.Style := [fsbold];

      lblVersion := TLabel.Create(frm);
      lblVersion.Name := 'PluginVersion' + IntToStr(PluginIdx);
      lblVersion.Parent := frm;
      lblVersion.Caption := _Version;
      lblVersion.Top := imgLogo.Top + lblTitle.Height;
      lblVersion.Left := imgLogo.Left + 32 + 20;
      lblVersion.Transparent := True;
      lblVersion.Font.Color := clWhite;
    end;
  end;
end;
{$ENDIF DELPHI2005_UP}

class procedure TDGHIDEExplorer.InitSplashScreen;
var
  bmSplashScreen: HBITMAP;
begin
  bmSplashScreen := LoadBitmap(HInstance, 'SplashScreenBitMap');
  AddPluginToSplashScreen(bmSplashScreen,
    ExpertName,
    'Mozilla Public License 1.1');
end;

class procedure TDGHIDEExplorer.DoneSplashScreen;
begin

end;

initialization
  TDGHIDEExplorer.InitSplashScreen;
finalization
  TDGHIDEExplorer.DoneSplashScreen;
end.
