unit dzIdeExplorerSearchForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls;

type
  TComponentSearchOptions = (csoComponentName, csoTypeName, csoRecursive, csoEntireScope);
  TComponentSearchOptionSet = set of TComponentSearchOptions;

type
  Tf_dzIdeExplorerSearch = class(TForm)
    ed_Name: TEdit;
    SearchForLabel: TLabel;
    rb_ComponentName: TRadioButton;
    rb_TypeName: TRadioButton;
    b_Ok: TButton;
    b_Cancel: TButton;
    chk_Recursive: TCheckBox;
    chk_EntireScope: TCheckBox;
  private
    procedure SetData(const _Name: string; _Options: TComponentSearchOptionSet);
    procedure GetData(out _Name: string; out _Options: TComponentSearchOptionSet);
  public
    class function Execute(_Owner: TWinControl;
      var _Name: string; var _Options: TComponentSearchOptionSet): Boolean;
    constructor Create(_Owner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  dzIdeExplorerUtils;

{ TSearchForm }

constructor Tf_dzIdeExplorerSearch.Create(_Owner: TComponent);
begin
  inherited;
  TForm_SetMinConstraints(Self);
  Constraints.MaxHeight := Constraints.MinHeight;
end;

class function Tf_dzIdeExplorerSearch.Execute(_Owner: TWinControl;
  var _Name: string; var _Options: TComponentSearchOptionSet): Boolean;
var
  frm: Tf_dzIdeExplorerSearch;
begin
  frm := Tf_dzIdeExplorerSearch.Create(_Owner);
  try
    frm.SetData(_Name, _Options);
    Result := (mrOK = frm.ShowModal);
    if Result then
      frm.GetData(_Name, _Options);
  finally
    FreeAndNil(frm);
  end;
end;

procedure Tf_dzIdeExplorerSearch.GetData(out _Name: string; out _Options: TComponentSearchOptionSet);
begin

  _Name := ed_Name.Text;
  if rb_ComponentName.Checked then
    _Options := [csoComponentName]
  else
    _Options := [csoTypeName];
  if chk_Recursive.Checked then
    Include(_Options, csoRecursive);
  if chk_EntireScope.Checked then
    Include(_Options, csoEntireScope);
end;

procedure Tf_dzIdeExplorerSearch.SetData(const _Name: string; _Options: TComponentSearchOptionSet);
begin
  ed_Name.Text := _Name;
  if csoComponentName in _Options then
    rb_ComponentName.Checked := True
  else
    rb_TypeName.Checked := True;
  chk_Recursive.Checked := (csoRecursive in _Options);
  chk_EntireScope.Checked := (csoEntireScope in _Options);
end;

end.

