unit dzIdeExplorerVCL;

interface

uses
  Classes,
  Forms;

type
  TVclUtils = class
    class function Screen: TScreen; // static;
    class procedure Click(_Ctrl: TComponent); // static;
    class function CanClick(_Ctrl: TComponent): Boolean; // static;
    class function CanShow(_Ctrl: TComponent): Boolean; // static;
    class procedure Show(_Ctrl: TComponent); // static;
  end;

implementation

uses
  StdCtrls,
  Menus,
  Buttons;

class function TVclUtils.Screen: TScreen;
begin
  Result := Forms.Screen;
end;

class function TVclUtils.CanClick(_Ctrl: TComponent): Boolean;
begin
  Result := (_Ctrl is TButton)
    or (_Ctrl is TMenuItem)
    or (_Ctrl is TBitBtn);
end;

class procedure TVclUtils.Click(_Ctrl: TComponent);
begin
  if _Ctrl is TButton then
    TButton(_Ctrl).Click
  else if _Ctrl is TMenuItem then
    TMenuItem(_Ctrl).Click
  else if _Ctrl is TBitBtn then
    TBitBtn(_Ctrl).Click;
end;

class function TVclUtils.CanShow(_Ctrl: TComponent): Boolean;
begin
  Result := (_Ctrl is TForm);
end;

class procedure TVclUtils.Show(_Ctrl: TComponent);
begin
  if _Ctrl is TForm then
    TForm(_Ctrl).Show;
end;

end.
