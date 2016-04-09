unit dzIdeExplorerUtils;

// This are of some utility functions from dzlib.

interface

uses
  Windows,
  SysUtils,
  Types,
  Forms,
  Controls;

///<summary> centers a form on the given point, but makes sure the form is fully visible </summary>
procedure TForm_CenterOn(_frm: TForm; _Center: TPoint); overload;
///<summary> centers a form on the given component, but makes sure the form is fully visible </summary>
procedure TForm_CenterOn(_frm: TForm; _Center: TWinControl); overload;

///<summary> Sets the form's Constraints.MinWidth and .MinHeight to the form's current size. </summary>
procedure TForm_SetMinConstraints(_frm: TForm);

///<summary> @returns the filename of the current module </summary>
function GetModuleFilename: string; overload;
function GetModuleFilename(const _Module: Cardinal): string; overload;

function TApplication_GetRegistryPath: string;

implementation

uses
  StrUtils,
  Registry;

function _(const _s: string): string;
begin
  Result := _s;
end;

procedure TForm_SetMinConstraints(_frm: TForm);
begin
  _frm.Constraints.MinHeight := _frm.Height;
  _frm.Constraints.MinWidth := _frm.Width;
end;

procedure TForm_CenterOn(_frm: TForm; _Center: TPoint); overload;
var
  Monitor: TMonitor;
begin
  _frm.Position := poDesigned;
  _frm.DefaultMonitor := dmDesktop;
  _frm.Left := _Center.X - _frm.Width div 2;
  _frm.Top := _Center.Y - _frm.Height div 2;
  Monitor := Screen.MonitorFromPoint(_Center);
  _frm.MakeFullyVisible(Monitor);
end;

procedure TForm_CenterOn(_frm: TForm; _Center: TWinControl); overload;
begin
  if Assigned(_Center) then begin
    if Assigned(_Center.Parent) then
      TForm_CenterOn(_frm, _Center.ClientToScreen(Point(_Center.Width div 2, _Center.Height div 2)))
    else
      TForm_CenterOn(_frm, Point(_Center.Left + _Center.Width div 2, _Center.Top + _Center.Height div 2));
  end else begin
    TForm_CenterOn(_frm, Point(Screen.Width div 2, Screen.Height div 2));
  end;
end;

function GetModuleFilename(const _Module: Cardinal): string;
var
  Buffer: array[0..260] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFilename(_Module, Buffer, SizeOf(Buffer)))
end;

function GetModuleFilename: string;
begin
  Result := GetModuleFilename(HInstance);
end;

function TApplication_GetRegistryPath: string;
var
//  VerInfo: IFileInfo;
  Company: string;
begin
//  VerInfo := TApplicationInfo.Create;
//  VerInfo.AllowExceptions := False;
//  Company := VerInfo.Company;
//  if Company <> '' then
//    Company := Company + '\';
  Company := '';
  Result := 'Software\' + Company + ChangeFileExt(ExtractFileName(GetModuleFilename), '');
end;

function TForm_GetPlacementRegistryPath(const _FrmName: string): string;
var
//  VerInfo: IFileInfo;
  Company: string;
begin
//  VerInfo := TApplicationInfo.Create;
//  VerInfo.AllowExceptions := False;
//  Company := VerInfo.Company;
//  if Company <> '' then
//    Company := Company + '\';
  Company := '';
  Result := TApplication_GetRegistryPath + '\'
    + _FrmName + '\NormPos';
end;

end.

