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
  TSearchType = (stComponentName, stTypeName);

type
  Tf_dzIdeExplorerSearch = class(TForm)
    ed_Name: TEdit;
    SearchForLabel: TLabel;
    rb_ComponentName: TRadioButton;
    rb_TypeName: TRadioButton;
    b_Ok: TButton;
    b_Cancel: TButton;
    chk_: TCheckBox;
  private
    procedure SetData(const _Name: string; _Type: TSearchType);
    procedure GetData(out _Name: string; out _Type: TSearchType);
  public
    class function Execute(_Owner: TWinControl; var _Name: string; var _Type: TSearchType): boolean;
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

class function Tf_dzIdeExplorerSearch.Execute(_Owner: TWinControl; var _Name: string;
  var _Type: TSearchType): boolean;
var
  frm: Tf_dzIdeExplorerSearch;
begin
  frm := Tf_dzIdeExplorerSearch.Create(_Owner);
  try
    frm.SetData(_Name, _Type);
    Result := (mrOK = frm.ShowModal);
    if Result then
      frm.GetData(_Name, _Type);
  finally
    FreeAndNil(frm);
  end;
end;

procedure Tf_dzIdeExplorerSearch.GetData(out _Name: string; out _Type: TSearchType);
begin
  _Name := ed_Name.Text;
  if rb_ComponentName.Checked then
    _Type := stComponentName
  else
    _Type := stTypeName;
end;

procedure Tf_dzIdeExplorerSearch.SetData(const _Name: string; _Type: TSearchType);
begin
  ed_Name.Text := _Name;
  if _Type = stComponentName then
    rb_ComponentName.Checked := True
  else
    rb_TypeName.Checked := True;
end;

end.
