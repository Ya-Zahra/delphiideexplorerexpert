unit dzIdeExplorerFilterForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Forms,
  Dialogs,
  Controls,
  StdCtrls,
  Buttons,
  dzIdeExplorerClassInformation;

type
  Tf_dzIdeExplorerFilter = class(TForm)
    b_Ok: TButton;
    b_Cancel: TButton;
    lb_Visible: TListBox;
    lb_Hidden: TListBox;
    l_Visible: TLabel;
    l_Hidden: TLabel;
    b_Hide: TSpeedButton;
    b_HideAll: TSpeedButton;
    b_Show: TSpeedButton;
    b_ShowAll: TSpeedButton;
    l_Note: TLabel;
    procedure b_HideClick(Sender: TObject);
    procedure b_ShowClick(Sender: TObject);
    procedure b_HideAllClick(Sender: TObject);
    procedure b_ShowAllClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lb_VisibleDblClick(Sender: TObject);
    procedure lb_HiddenDblClick(Sender: TObject);
  private
    procedure EnableButtons;
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetData(_Items: TClassInfoList);
    procedure GetData(_Items: TClassInfoList);
  public
    class function Execute(_Owner: TWinControl; _Items: TClassInfoList): boolean;
    constructor Create(_Owner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  dzIdeExplorerUtils;

class function Tf_dzIdeExplorerFilter.Execute(_Owner: TWinControl; _Items: TClassInfoList): boolean;
var
  frm: Tf_dzIdeExplorerFilter;
begin
  frm := Tf_dzIdeExplorerFilter.Create(_Owner);
  try
    TForm_CenterOn(frm, _Owner);
    frm.SetData(_Items);
    Result := (frm.ShowModal = mrOk);
    if Result then
      frm.GetData(_Items);
  finally
    FreeAndNil(frm);
  end;
end;

constructor Tf_dzIdeExplorerFilter.Create(_Owner: TComponent);
begin
  inherited;
  TForm_SetMinConstraints(Self);
end;

procedure Tf_dzIdeExplorerFilter.FormResize(Sender: TObject);
var
  Space: integer;
  ListboxWidth: integer;
  w: integer;
begin
  Space := lb_Visible.Left;
  ListboxWidth := (ClientWidth - 4 * Space - b_Hide.Width) div 2;
  lb_Visible.Width := ListboxWidth;
  lb_Hidden.Width := ListboxWidth;

  w := ListboxWidth + 2 * Space;
  b_Hide.Left := w;
  b_HideAll.Left := w;
  b_Show.Left := w;
  b_ShowAll.Left := w;

  w := ClientWidth - ListboxWidth - Space;
  l_Hidden.Left := w;
  lb_Hidden.Left := w;
end;

procedure Tf_dzIdeExplorerFilter.GetData(_Items: TClassInfoList);
var
  i: Integer;
  s: string;
  Item: TClassInformation;
begin
  for i := 0 to lb_Visible.Items.Count - 1 do begin
    s := lb_Visible.Items[i];
    if _Items.Find(s, Item) then
      Item.IsVisible := True;
  end;
  for i := 0 to lb_Hidden.Items.Count - 1 do begin
    s := lb_Hidden.Items[i];
    if _Items.Find(s, Item) then
      Item.IsVisible := False;
  end;
end;

procedure Tf_dzIdeExplorerFilter.SetData(_Items: TClassInfoList);
var
  i: Integer;
  Item: TClassInformation;
begin
  for i := 0 to _Items.Count - 1 do begin
    Item := _Items[i];
    if Item.IsVisible then
      lb_Visible.Items.Add(Item.Name)
    else
      lb_Hidden.Items.Add(Item.Name);
  end;
  EnableButtons;
end;

procedure Tf_dzIdeExplorerFilter.b_HideClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(lb_Visible);
  MoveSelected(lb_Visible, lb_Hidden.Items);
  SetItem(lb_Visible, Index);
end;

procedure Tf_dzIdeExplorerFilter.b_ShowClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(lb_Hidden);
  MoveSelected(lb_Hidden, lb_Visible.Items);
  SetItem(lb_Hidden, Index);
end;

procedure Tf_dzIdeExplorerFilter.b_HideAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lb_Visible.Items.Count - 1 do
    lb_Hidden.Items.AddObject(lb_Visible.Items[I],
      lb_Visible.Items.Objects[I]);
  lb_Visible.Items.Clear;
  SetItem(lb_Visible, 0);
end;

procedure Tf_dzIdeExplorerFilter.b_ShowAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lb_Hidden.Items.Count - 1 do
    lb_Visible.Items.AddObject(lb_Hidden.Items[I], lb_Hidden.Items.Objects[I]);
  lb_Hidden.Items.Clear;
  SetItem(lb_Hidden, 0);
end;

procedure Tf_dzIdeExplorerFilter.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

procedure Tf_dzIdeExplorerFilter.EnableButtons;
var
  VisibleEmpty, HiddenEmpty: Boolean;
begin
  VisibleEmpty := lb_Visible.Items.Count = 0;
  HiddenEmpty := lb_Hidden.Items.Count = 0;
  b_Hide.Enabled := not VisibleEmpty;
  b_HideAll.Enabled := not VisibleEmpty;
  b_Show.Enabled := not HiddenEmpty;
  b_ShowAll.Enabled := not HiddenEmpty;
end;

function Tf_dzIdeExplorerFilter.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then
      Exit;
  Result := LB_ERR;
end;

procedure Tf_dzIdeExplorerFilter.lb_HiddenDblClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(lb_Hidden);
  MoveSelected(lb_Hidden, lb_Visible.Items);
  SetItem(lb_Hidden, Index);
end;

procedure Tf_dzIdeExplorerFilter.lb_VisibleDblClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(lb_Visible);
  MoveSelected(lb_Visible, lb_Hidden.Items);
  SetItem(lb_Visible, Index);
end;

procedure Tf_dzIdeExplorerFilter.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then
      Index := 0
    else if Index > MaxIndex then
      Index := MaxIndex;
    Selected[Index] := True;
  end;
  EnableButtons;
end;

end.

