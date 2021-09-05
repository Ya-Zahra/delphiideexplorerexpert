unit dzIdeExplorerMenuTree;

// this is some debugging code, not really part of the wizard

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Menus,
  ComCtrls;

type
  Tf_dzIdeExplorerMenuTree = class(TForm)
    tv_Menu: TTreeView;
  protected
    procedure ActionExecute(_Sender: TObject);
  public
    constructor Create(_Owner: TComponent); override;
    procedure AddMenuItem(_Parent: TTreeNode; _Item: TMenuItem);
  end;

implementation

{$R *.dfm}

uses
  ActnList;

{ Tf_dzIdeExplorerMenuTree }

constructor Tf_dzIdeExplorerMenuTree.Create(_Owner: TComponent);
var
  i: Integer;
  j: Integer;
//  k: integer;
  frm: TForm;
  cmp: TComponent;
  EditWindow_0: TForm;
//  EditorFormDesigner: TComponent;
//  ViewSelector: TComponent;
//  m: Integer;
begin
  inherited;
  for i := 0 to Screen.FormCount - 1 do begin
    frm := Screen.Forms[i];
    if frm.Name = 'EditWindow_0' then begin
      EditWindow_0 := frm;
      for j := 0 to EditWindow_0.ComponentCount - 1 do begin
        cmp := EditWindow_0.Components[j];

        if cmp is TCustomComboBoxEx then
          asm nop end;

//        if cmp.Name = 'EditorFormDesigner' then begin
//          EditorFormDesigner := cmp;
//          for k := 0 to EditorFormDesigner.ComponentCount - 1 do begin
//            cmp := EditorFormDesigner.Components[k];
//            if cmp.Name = 'ViewSelector' then begin
//              ViewSelector := cmp;
//              TControl(ViewSelector).Visible := true;
//              for m := 0 to ViewSelector.ComponentCount - 1 do begin
//                cmp := ViewSelector.Components[m];
//              end;
//            end;
//          end;
//        end;
      end;
    end;
  end;
end;

procedure Tf_dzIdeExplorerMenuTree.ActionExecute(_Sender: TObject);
begin
  ShowMessage(TAction(_Sender).Name + ' was executed');
end;

procedure Tf_dzIdeExplorerMenuTree.AddMenuItem(_Parent: TTreeNode; _Item: TMenuItem);
var
  Node: TTreeNode;
  i: Integer;
begin
  Node := tv_Menu.Items.AddChild(_Parent, _Item.Name);
  for i := 0 to _Item.Count - 1 do
    AddMenuItem(Node, _Item.Items[i]);
end;

end.

