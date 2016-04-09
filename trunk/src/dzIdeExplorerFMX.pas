unit dzIdeExplorerFMX;

interface

uses
  FMX.Forms,
  System.Classes;

type
  TFmxUtils = class
    class function Screen: TScreen; static;
    class procedure Click(_ctrl: TComponent); static;
    class function CanClick(_ctrl: TComponent): boolean; static;
    class function CanShow(_ctrl: TComponent): boolean; static;
    class procedure Show(_ctrl: TComponent); static;
    class function IsPressed(_ctrl: TComponent): boolean; static;
  end;

implementation

uses
  FMX.StdCtrls,
  FMX.Menus;

class function TFmxUtils.Screen: TScreen;
begin
  Result := FMX.Forms.Screen;
end;

type
  THackButton = class(TButton)
  end;

  THackMenuItem = class(TMenuItem)
  end;

  THackSpeedButton = class(TSpeedButton)
  end;

class function TFmxUtils.CanClick(_ctrl: TComponent): boolean;
begin
  Result := (_ctrl is TButton)
    or (_ctrl is TMenuItem)
    or (_ctrl is TSpeedButton);
end;

class procedure TFmxUtils.Click(_ctrl: TComponent);
begin
  if _ctrl is TButton then
    THackButton(_ctrl).Click
  else if _ctrl is TMenuItem then
    THackMenuItem(_ctrl).Click
  else if _ctrl is TSpeedButton then
    THackSpeedButton(_ctrl).Click;
end;

class function TFmxUtils.IsPressed(_ctrl: TComponent): boolean;
begin
  if _ctrl is TButton then
    Result := TButton(_ctrl).IsPressed
  else
    Result := false;
end;

class function TFmxUtils.CanShow(_ctrl: TComponent): boolean;
begin
  Result := (_ctrl is TForm);
end;

class procedure TFmxUtils.Show(_ctrl: TComponent);
begin
  if _ctrl is TForm then
    TForm(_ctrl).Show;
end;

end.

