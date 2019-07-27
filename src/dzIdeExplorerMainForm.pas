unit dzIdeExplorerMainForm;

{$INCLUDE 'jedi.inc'}

{$IFNDEF DelphiXE3_Up}
// My Delphi XE2 installation does not have Firemonkey support
// and XE didn't support it. So this define removes any code referencing it.
{$DEFINE nodzFmxSupport}
{$ENDIF ~DelphiXE3_Up}

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
  ComCtrls,
  ExtCtrls,
  ImgList,
  StdCtrls,
  Menus,
// Imagelist is new in Delphi 10 Seattle, for older verions
// add a unit alias as ImageList=Controls
  ImageList,
  ActnList,
  ActnMan,
  dzIdeExplorerClassInformation,
  dzIdeExplorerEventHook;

type
  TExplorerForm = class(TForm)
    tv_Forms: TTreeView;
    im_Controls: TImageList;
    TheSplitter: TSplitter;
    im_Properties: TImageList;
    pc_Details: TPageControl;
    ts_Properties: TTabSheet;
    ts_Hierarchy: TTabSheet;
    lv_Properties: TListView;
    tv_Hierarchy: TTreeView;
    p_Left: TPanel;
    p_LeftTop: TPanel;
    b_Filter: TButton;
    pm_Controls: TPopupMenu;
    mi_Expandall: TMenuItem;
    mi_Collapse: TMenuItem;
    ts_Events: TTabSheet;
    lv_Events: TListView;
    N1: TMenuItem;
    mi_Click: TMenuItem;
    mi_Show: TMenuItem;
    TheStatusBar: TStatusBar;
    b_Update: TButton;
    chk_Follow: TCheckBox;
    ts_Additional: TTabSheet;
    tv_Additional: TTreeView;
    b_SelectActive: TButton;
    pm_Parents: TPopupMenu;
    mi_CopyPath: TMenuItem;
    tim_CheckHook: TTimer;
    procedure FormShow(Sender: TObject);
    procedure tv_FormsChange(Sender: TObject; Node: TTreeNode);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure b_FilterClick(Sender: TObject);
    procedure pm_ControlsPopup(Sender: TObject);
    procedure mi_ExpandallClick(Sender: TObject);
    procedure mi_CollapseClick(Sender: TObject);
    procedure mi_ClickClick(Sender: TObject);
    procedure mi_ShowClick(Sender: TObject);
    procedure b_UpdateClick(Sender: TObject);
    procedure chk_FollowClick(Sender: TObject);
    procedure b_SelectActiveClick(Sender: TObject);
    procedure mi_CopyPathClick(Sender: TObject);
    procedure lv_PropertiesInfoTip(Sender: TObject; Item: TListItem; var InfoTip: string);
    procedure tim_CheckHookTimer(Sender: TObject);
  private
    FWasHookDeactivated: Boolean;
    FSelecting: Boolean;
    FActiveControlChangedHook: TNotifyEventHook;
    FFollowFocusEnabled: Boolean;
    FActiveDelphiForm: TForm;
    FActiveDelphiControl: TWinControl;
    FLastActiveForm: TForm;
    FLastActiveControl: TWinControl;
    FVclForms: TTreeNode;
    FClassInfo: TClassInfoList;
    FValueHints: TStringList;
    procedure FillTree;
    procedure SelectFocused(_Force: Boolean);
    procedure HandleOnActiveControlChange(Sender: TObject);
    procedure WMEnable(var _Msg: TWMEnable); message WM_ENABLE;
    procedure UpdatePropertiesAndEvents(_Node: TTreeNode);
    procedure UpdateHierarchy(_Node: TTreeNode);
    procedure UpdateAdditional(_Node: TTreeNode);
    procedure UpdateMenu(_mnu: TMenu);
    procedure UpdateParents(_Ctrl: TControl);
    procedure AddSubmenuItems(_ParentNode: TTreeNode; _Item: TMenuItem);
    procedure UpdateSubmenu(_mi: TMenuItem);
    procedure UpdateActionList(_lst: TActionList);
    procedure UpdateActionManager(_mgr: TActionManager);
    procedure UpdateActiveDelphiForm;
  public
    constructor Create(_Owner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.DFM}

uses
  TypInfo,
  Variants,
  Registry,
  Actions,
{$IFDEF HAS_UNIT_RTTI}
  Rtti,
{$ENDIF HAS_UNIT_RTTI}
  StrUtils,
  Clipbrd,
  dzIdeExplorerUtils,
  dzIdeExplorerVcl,
{$IFNDEF nodzFmxSupport}
  dzIdeExplorerFMX,
{$ENDIF ~nodzFmxSupport}
  dzIdeExplorerFilterForm,
  dzIdeExplorerMenuTree;

constructor TExplorerForm.Create(_Owner: TComponent);
var
  Reg: TRegIniFile;
  Section: string;
begin
  inherited;
{$IFNDEF DELPHIX_RIO_UP}
  tim_CheckHook.Enabled := False;
{$ENDIF}
  TForm_SetMinConstraints(Self);

  p_Left.BevelOuter := bvNone;
  p_LeftTop.BevelOuter := bvNone;
  pc_Details.ActivePage := ts_Properties;

  FClassInfo := TClassInfoList.Create;
  FValueHints := TStringList.Create;

  Reg := TRegIniFile.Create(TApplication_GetRegistryPath);
  try
    Section := Name;

    Top := Reg.ReadInteger(Section, 'Top', 200);
    Left := Reg.ReadInteger(Section, 'Left', 200);
    Width := Reg.ReadInteger(Section, 'Width', 450);
    Height := Reg.ReadInteger(Section, 'Height', 300);

    pc_Details.Width := Reg.ReadInteger(Section, 'Divide', 310);

    lv_Properties.Columns[0].Width := Reg.ReadInteger(Section, 'Col1', 75);
    lv_Properties.Columns[1].Width := Reg.ReadInteger(Section, 'Col2', 75);
    lv_Properties.Columns[2].Width := Reg.ReadInteger(Section, 'Col3', 75);
    lv_Properties.Columns[3].Width := Reg.ReadInteger(Section, 'Col4', 75);

    lv_Events.Columns[0].Width := Reg.ReadInteger(Section, 'Events1', 75);
    lv_Events.Columns[1].Width := Reg.ReadInteger(Section, 'Events2', 75);
    lv_Events.Columns[2].Width := Reg.ReadInteger(Section, 'Events3', 75);
    lv_Events.Columns[3].Width := Reg.ReadInteger(Section, 'Events4', 75);
  finally
    Reg.Free;
  end;

end;

destructor TExplorerForm.Destroy;
begin
  if Assigned(FActiveControlChangedHook) then
    UnhookScreenActiveControlChange(FActiveControlChangedHook);
  FreeAndNil(FValueHints);
  FreeAndNil(FClassInfo);
  inherited;
end;

procedure TExplorerForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Reg: TRegIniFile;
  Section: string;
begin
  Reg := TRegIniFile.Create(TApplication_GetRegistryPath);
  try
    Section := Name;

    Reg.WriteBool(Section, 'Visible', Visible);
    Reg.WriteInteger(Section, 'Top', Top);
    Reg.WriteInteger(Section, 'Left', Left);
    Reg.WriteInteger(Section, 'Width', Width);
    Reg.WriteInteger(Section, 'Height', Height);

    Reg.WriteInteger(Section, 'Divide', pc_Details.Width);

    Reg.WriteInteger(Section, 'Col1', lv_Properties.Columns[0].Width);
    Reg.WriteInteger(Section, 'Col2', lv_Properties.Columns[1].Width);
    Reg.WriteInteger(Section, 'Col3', lv_Properties.Columns[2].Width);
    Reg.WriteInteger(Section, 'Col4', lv_Properties.Columns[3].Width);

    Reg.WriteInteger(Section, 'Events1', lv_Events.Columns[0].Width);
    Reg.WriteInteger(Section, 'Events2', lv_Events.Columns[1].Width);
    Reg.WriteInteger(Section, 'Events3', lv_Events.Columns[2].Width);
    Reg.WriteInteger(Section, 'Events4', lv_Events.Columns[3].Width);
  finally
    Reg.Free;
  end;
end;

procedure TExplorerForm.FormShow(Sender: TObject);
begin
  if Assigned(FActiveControlChangedHook) then
    UnhookScreenActiveControlChange(FActiveControlChangedHook);
  FillTree;
  FActiveControlChangedHook := HookScreenActiveControlChange(HandleOnActiveControlChange);
end;

procedure TExplorerForm.b_SelectActiveClick(Sender: TObject);
begin
  SelectFocused(True);
end;

procedure TExplorerForm.b_UpdateClick(Sender: TObject);
begin
  FillTree;
end;

procedure TExplorerForm.chk_FollowClick(Sender: TObject);
begin
  FFollowFocusEnabled := chk_Follow.Checked;
  if FFollowFocusEnabled then begin
    SelectFocused(True);
  end;
end;

function CheckModalLevel: Boolean;
begin
{$IFDEF DELPHI2005_UP}
  Result := (Application.ModalLevel > 0);
{$ELSE}
  // Delphi <2005 does not have Applicaton.ModalLevel, so we always return true
  Result := True;
{$ENDIF}
end;

procedure TExplorerForm.WMEnable(var _Msg: TWMEnable);
begin
  inherited;
  if not _Msg.Enabled and CheckModalLevel then
    EnableWindow(Self.Handle, True);
end;

type
  TMyFormClasses = array[0..2] of TClass;
const
  MY_FORM_CLASSES: TMyFormClasses = (
    TExplorerForm,
    Tf_IdeExplorerFilterForm,
    Tf_IdeExplorerMenuTree);

procedure TExplorerForm.UpdateActiveDelphiForm;
var
  frm: TForm;
  i: Integer;
  ActiveControlChanged: Boolean;
  ActControl: TWinControl;
begin
  ActiveControlChanged := False;
  frm := Screen.ActiveForm;
  if frm <> Self then begin
    for i := Low(MY_FORM_CLASSES) to High(MY_FORM_CLASSES) do
      if frm is MY_FORM_CLASSES[i] then
        Exit; //==>
    FActiveDelphiForm := frm;
    ActControl := Screen.ActiveControl;
    ActiveControlChanged := (ActControl <> FActiveDelphiControl);
    if ActiveControlChanged then
      FActiveDelphiControl := ActControl;
  end;
  if FFollowFocusEnabled and ActiveControlChanged then
    SelectFocused(False);
end;

procedure TExplorerForm.HandleOnActiveControlChange(Sender: TObject);
begin
  UpdateActiveDelphiForm;
end;

procedure TExplorerForm.lv_PropertiesInfoTip(Sender: TObject; Item: TListItem; var InfoTip: string);
var
  Idx: Integer;
begin
  InfoTip := '';
  if not Assigned(Item) or (Item.SubItems.Count = 0) then
    Exit; //==>
  Idx := Integer(Item.SubItems.Objects[0]) - 1;
  if (Idx < 0) or (Idx >= FValueHints.Count) then
    Exit;
  InfoTip := FValueHints[Idx];
end;

procedure TExplorerForm.mi_ClickClick(Sender: TObject);
var
  Node: TTreeNode;
  cmp: TComponent;
begin
  Node := tv_Forms.Selected;
  if not Assigned(Node) or not Assigned(Node.Data) then
    Exit;
  cmp := TComponent(Node.Data);
  TVclUtils.Click(cmp);
{$IFNDEF nodzFmxSupport}
  TFmxUtils.Click(cmp);
{$ENDIF ~nodzFmxSupport}
end;

procedure TExplorerForm.mi_CollapseClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := tv_Forms.Selected;
  if not Assigned(Node) then
    Exit;
  Node.Collapse(True);
end;

procedure TExplorerForm.mi_CopyPathClick(Sender: TObject);
var
  IndentStr: string;

  function Recurse(_tn: TTreeNode): string;
  begin
    if _tn = nil then
      Result := ''
    else begin
      Result := Recurse(_tn.Parent) + #13#10 + IndentStr + '> ' + _tn.Text;
      IndentStr := IndentStr + '  ';
    end;
  end;

var
  s: string;
begin
  IndentStr := '';
  s := Recurse(tv_Additional.Selected);
  Clipboard.AsText := s;
end;

procedure TExplorerForm.mi_ExpandallClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := tv_Forms.Selected;
  if not Assigned(Node) then
    Exit;
  Node.Expand(True);
end;

procedure TExplorerForm.mi_ShowClick(Sender: TObject);
var
  Node: TTreeNode;
  cmp: TComponent;
begin
  Node := tv_Forms.Selected;
  if not Assigned(Node) or not Assigned(Node.Data) then
    Exit;
  cmp := TComponent(Node.Data);
  TVclUtils.Show(cmp);
{$IFNDEF nodzFmxSupport}
  TFmxUtils.Show(cmp);
{$ENDIF ~nodzFmxSupport}
end;

procedure TExplorerForm.pm_ControlsPopup(Sender: TObject);
var
  Node: TTreeNode;
  cmp: TComponent;
begin
  Node := tv_Forms.Selected;
  if Assigned(Node) and Assigned(Node.Data) then begin
    cmp := TComponent(Node.Data);
    mi_Click.Enabled := TVclUtils.CanClick(cmp)
{$IFNDEF nodzFmxSupport}
    or TFmxUtils.CanClick(cmp)
{$ENDIF ~nodzFmxSupport}
    ;
    mi_Show.Enabled := TVclUtils.CanShow(cmp)
{$IFNDEF nodzFmxSupport}
    or TFmxUtils.CanShow(cmp)
{$ENDIF ~nodzFmxSupport}
    ;
  end else begin
    mi_Click.Enabled := False;
    mi_Show.Enabled := False;
  end;
end;

procedure TExplorerForm.b_FilterClick(Sender: TObject);
begin
  Tf_IdeExplorerFilterForm.Execute(Self, FClassInfo);
  FillTree;
end;

procedure TExplorerForm.FillTree;

  function AddRootChild(_Parent: TTreeNode; const _Caption: string): TTreeNode;
  begin
    Result := tv_Forms.Items.AddChild(_Parent, _Caption);
    Result.ImageIndex := 4;
    Result.SelectedIndex := 4;
  end;

  function AddComponents(_Parent: TTreeNode; _Component: TComponent): Integer;
  var
    i: Integer;
    Node: TTreeNode;
    cmp: TComponent;
    HasChildren: Boolean;
    IsClassVisible: Boolean;
    ci: TClassInformation;
  begin
    Result := 0;
    for i := 0 to _Component.ComponentCount - 1 do begin
      cmp := _Component.Components[i];
      HasChildren := (cmp.ComponentCount > 0);
      if FClassInfo.Find(cmp.ClassName, ci) then
        IsClassVisible := ci.IsVisible
      else begin
        ci := TClassInformation.Create(cmp.ClassName, cmp.ClassType, True);
        FClassInfo.Add(ci);
        IsClassVisible := True;
      end;
      if IsClassVisible or HasChildren then begin
        Inc(Result);
        Node := tv_Forms.Items.AddChild(_Parent,
          cmp.Name + ': ' + cmp.ClassName + ' (' + IntToStr(cmp.ComponentCount) + ')');
        Node.Data := Pointer(cmp);
        Node.ImageIndex := 3;
        Node.SelectedIndex := 3;
        if (AddComponents(Node, cmp) = 0) and not IsClassVisible then begin
          tv_Forms.Items.Delete(Node);
          Dec(Result);
        end;
      end;
    end;
  end;

  procedure AddChild(_Parent: TTreeNode; _Cmp: TComponent);
  var
    Node: TTreeNode;
  begin
    Node := tv_Forms.Items.AddChild(_Parent, _Cmp.Name + ': ' + _Cmp.ClassName);
    Node.Data := Pointer(_Cmp);
    Node.ImageIndex := 2;
    Node.SelectedIndex := 2;
    if AddComponents(Node, _Cmp) = 0 then
      tv_Forms.Items.Delete(Node);
  end;

var
  DelphiRoot: TTreeNode;
  i: Integer;
  Node: TTreeNode;
begin
  tv_Forms.Items.BeginUpdate;
  try
    FVclForms := nil;
    tv_Forms.Items.Clear;

    DelphiRoot := tv_Forms.Items.AddChild(nil, 'Delphi IDE');
    DelphiRoot.ImageIndex := 0;
    DelphiRoot.SelectedIndex := 0;

    Node := AddRootChild(DelphiRoot, 'Custom Forms (VCL)');
    for i := 0 to TVclUtils.Screen.CustomFormCount - 1 do
      AddChild(Node, TVclUtils.Screen.CustomForms[i]);

    Node := AddRootChild(DelphiRoot, 'Data Modules (VCL)');
    for i := 0 to TVclUtils.Screen.DataModuleCount - 1 do
      AddChild(Node, TVclUtils.Screen.DataModules[i]);

    Node := AddRootChild(DelphiRoot, 'Forms (VCL)');
    FVclForms := Node;
    for i := 0 to TVclUtils.Screen.FormCount - 1 do
      AddChild(Node, TVclUtils.Screen.Forms[i]);

{$IFNDEF nodzFmxSupport}
    Node := AddRootChild(DelphiRoot, 'Forms (FMX)');
    for i := 0 to TFmxUtils.Screen.FormCount - 1 do
      AddChild(Node, TFmxUtils.Screen.Forms[i]);

    Node := AddRootChild(DelphiRoot, 'Data Modules (FMX)');
    for i := 0 to TFmxUtils.Screen.DataModuleCount - 1 do
      AddChild(Node, TFmxUtils.Screen.DataModules[i]);

{$IFDEF DELPHIXE5_UP}
    Node := AddRootChild(DelphiRoot, 'Popup Forms (FMX)');
    for i := 0 to TFmxUtils.Screen.PopupFormCount - 1 do
      AddChild(Node, TFmxUtils.Screen.PopupForms[i]);
{$ENDIF DELPHIXE5_UP}
{$ENDIF ~nodzFmxSupport}

    DelphiRoot.Expand(False);

  finally
    tv_Forms.Items.EndUpdate;
  end;
end;

function GetMethodDescription(_Method: TMethod): string;
var
  Obj: TObject;
{$IFDEF HAS_UNIT_RTTI}
  RttyContext: TRttiContext;
  RttiType: TRttiType;
  RttiMethod: TRttiMethod;
{$ENDIF HAS_UNIT_RTTI}
  ObjName: string;
  MethodName: string;
begin
  Obj := TObject(_Method.Data);
  if not Assigned(Obj) then begin
    Result := 'Nil';
    Exit;
  end;

  ObjName := Obj.ClassName + '($' + IntToHex(Integer(_Method.Data), 8) + ')';
  MethodName := '$' + IntToHex(Integer(_Method.Code), 8);
  if Obj is TComponent then
    ObjName := TComponent(Obj).Name;

{$IFDEF HAS_UNIT_RTTI}
  RttyContext := TRttiContext.Create;
  try
    RttiType := RttyContext.GetType(Obj.ClassType);
    for RttiMethod in RttiType.GetMethods do
      if RttiMethod.CodeAddress = _Method.Code then begin
        MethodName := RttiMethod.Name;
      end;
  finally
    RttyContext.Free;
  end;
{$ENDIF HAS_UNIT_RTTI}

  Result := ObjName + '.' + MethodName;
end;

function MakePrintableString(const _s: string): string;
var
  i: Integer;
  c: Char;
  LastWasEscaped: Boolean;
begin
  Result := '';
  LastWasEscaped := False;
  for i := 1 to Length(_s) do begin
    c := _s[i];
    if c < #32 then begin
      if not LastWasEscaped then begin
        Result := Result + '''';
      end;
      Result := Result + '#' + IntToStr(Ord(c));
      LastWasEscaped := True;
    end else begin
      if LastWasEscaped or (Result = '') then
        Result := Result + '''';
      Result := Result + c;
      LastWasEscaped := False;
    end;
  end;
  if not LastWasEscaped then
    Result := Result + '''';
end;

function StripTrailingCrLf(const _s: string): string;
var
  Len: Integer;
begin
  Result := _s;
  Len := Length(Result);
  if Len < 2 then
    Exit; //==>
  if Copy(Result, Len - 1, 2) = #13#10 then
    Result := Copy(Result, 1, Len - 2);
end;

function GetObjectDescription(_Obj: TObject; out _Hint: string): string;
begin
  _Hint := '';
  if not Assigned(_Obj) then
    Result := 'Nil'
  else if _Obj is TComponent then
    Result := TComponent(_Obj).Name
  else if _Obj is TStrings then begin
    _Hint := StripTrailingCrLf((_Obj as TStrings).Text);
    Result := MakePrintableString(_Hint);
    Result := _Obj.ClassName + ': ' + Result;
  end else
    Result := _Obj.ClassName + '($' + IntToHex(Integer(_Obj), 8) + ')'
end;

function GetIntegerDescription(_Value: Integer; const _PropTypeName: string): string;
begin
  Result := '';
  if _PropTypeName = 'TColor' then
    Result := ColorToString(_Value)
  else if _PropTypeName = 'TCursor' then
    Result := CursorToString(_Value);
  Result := Result + ' ' + IntToStr(_Value);
  if _PropTypeName = 'Byte' then
    Result := Result + ' ($' + IntToHex(_Value, 2) + ')'
  else
    Result := Result + ' ($' + IntToHex(_Value, 8) + ')';
  Result := Trim(Result);
end;

type
  TIntegerSet = set of 0..SizeOf(Integer) * 8 - 1;

function GetSetDescription(_TypeInfo: PTypeInfo; _Set: TIntegerSet): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to SizeOf(Integer) * 8 - 1 do
    if i in _Set then begin
      if Result <> '' then
        Result := Result + ', ';
      Result := Result + GetEnumName(_TypeInfo, i);
    end;
  Result := '[' + Result + ']';
end;

function GetFullNodeName(_Node: TTreeNode): string;
var
  s: string;
  p: Integer;
begin
  Result := '';
  if Assigned(_Node) then begin
    if Assigned(_Node.Data) then begin
      s := _Node.Text;
      p := Pos(':', s);
      if p > 0 then
        Result := Trim(LeftStr(s, p - 1));
      if Result = '' then begin
        p := Pos(' ', s);
        if p > 0 then
          Result := Trim(LeftStr(s, p - 1));
      end;
    end else
      Result := _Node.Text;
    if Assigned(_Node.Parent) then
      Result := GetFullNodeName(_Node.Parent) + '\' + Result;
  end;
end;

procedure TExplorerForm.SelectFocused(_Force: Boolean);

  procedure SelectFocusedControl(_ActCtrl: TWinControl; _Parent: TTreeNode; var _Found: Boolean);
  var
    CtrlItem: TTreeNode;
  begin
    CtrlItem := _Parent.getFirstChild;
    while Assigned(CtrlItem) do begin
      if CtrlItem.Data = _ActCtrl then begin
        CtrlItem.Selected := True;
        CtrlItem.MakeVisible;
        FLastActiveControl := CtrlItem.Data;
        _Found := True;
        Exit;
      end else if TObject(CtrlItem.Data) is TWinControl then begin
        SelectFocusedControl(_ActCtrl, CtrlItem, _Found);
        if _Found then
          Exit;
      end;
      CtrlItem := CtrlItem.getNextSibling;
    end;
  end;

  function doGetParentForm(_Ctrl: TControl): TCustomForm;
  begin
{$IFDEF DELPHI2005_UP}
    Result := GetParentForm(_Ctrl, False)
{$ELSE}
    // GetParentForm did not yet have the boolean parameter
    Result := GetParentForm(_Ctrl);
{$ENDIF}
  end;

var
  i: Integer;
  ActForm: TForm;
  ActFrmClsName: string;
  ActFrmName: string;
  ActFrmCaption: string;
  ActCtrl: TWinControl;
  FrmItem: TTreeNode;
  HasFrmChanged: Boolean;
  found: Boolean;
  ParentForm: TCustomForm;
begin
  if FSelecting then
    Exit;

  FSelecting := True;
  tv_Forms.Items.BeginUpdate;
  try
    ActForm := FActiveDelphiForm;
    ActCtrl := FActiveDelphiControl;
    if not Assigned(ActForm) or (ActForm = Self) then
      Exit;
    HasFrmChanged := (FLastActiveForm <> ActForm);
    if not _Force and not HasFrmChanged and (FLastActiveControl = ActCtrl) then
      Exit;

    FLastActiveForm := ActForm;
    FLastActiveControl := ActCtrl;

    ActFrmClsName := ActForm.ClassName;
    ActFrmCaption := ActForm.Caption;
    ActFrmName := ActForm.Name;

    if HasFrmChanged then
      FillTree;
    if not Assigned(FVclForms) then
      Exit;

    if Assigned(ActCtrl) then
      ParentForm := doGetParentForm(ActCtrl)
    else
      ParentForm := ActForm;
    for i := 0 to FVclForms.Count - 1 do begin
      FrmItem := FVclForms.Item[i];
      if FrmItem.Data = ParentForm then begin
        FrmItem.Selected := True;
        FrmItem.Expand(False);
        FLastActiveForm := FrmItem.Data;
        if Assigned(ActCtrl) then begin
          if ActCtrl <> FrmItem.Data then begin
            found := False;
            SelectFocusedControl(ActCtrl, FrmItem, found);
          end;
        end;
        Break;
      end;
    end;
  finally
    tv_Forms.Items.EndUpdate;
    FSelecting := False;
  end;
end;

procedure TExplorerForm.tim_CheckHookTimer(Sender: TObject);
begin
{$IFDEF DELPHIX_RIO_UP}
  tim_CheckHook.Enabled := False;
  try
    if IsHookScreenActiveControlChangeActive(FActiveControlChangedHook) then begin
      tim_CheckHook.Interval := 500;
      if FWasHookDeactivated then begin
        FWasHookDeactivated := False;
        FActiveDelphiForm := nil;
        FActiveDelphiControl := nil;
        UpdateActiveDelphiForm;
      end;
    end else begin
      FWasHookDeactivated := True;
      tim_CheckHook.Interval := 100;
      UpdateActiveDelphiForm;
    end;
  finally
    tim_CheckHook.Enabled := True;
  end;
{$ENDIF}
end;

procedure TExplorerForm.tv_FormsChange(Sender: TObject; Node: TTreeNode);
begin
  TheStatusBar.SimpleText := GetFullNodeName(Node);
  UpdatePropertiesAndEvents(Node);
  UpdateHierarchy(Node);
  UpdateAdditional(Node);
end;

procedure TExplorerForm.UpdatePropertiesAndEvents(_Node: TTreeNode);
{$IFNDEF DelphiXE6_Up}
type
  TSymbolName = ShortString;
{$ENDIF}
var
  lvItem: TListItem;
  i: Integer;
  PropList: PPropList;
  iNumOfProps: Integer;
  Method: TMethod;
  strTemp: string;
  iTemp: Integer;
  s: TIntegerSet;
  ti: PTypeInfo;
  ValueStr: string;
  PropTypeName: TSymbolName;
  objTemp: TObject;
  i64Temp: Int64;
  ValueHint: string;
begin
  TheStatusBar.SimpleText := GetFullNodeName(_Node);
  lv_Properties.Items.BeginUpdate;
  lv_Events.Items.BeginUpdate;
  try
    lv_Properties.Items.Clear;
    lv_Events.Items.Clear;
    FValueHints.Clear;
    if (_Node = nil) or (_Node.Data = nil) then
      Exit; //==>

    Getmem(PropList, SizeOf(TPropList));
    try
      iNumOfProps := GetPropList(TComponent(_Node.Data).ClassInfo, tkAny, PropList);
      for i := 0 to iNumOfProps - 1 do begin
        if PropList[i].PropType^.Kind = tkMethod then
          lvItem := lv_Events.Items.Add
        else
          lvItem := lv_Properties.Items.Add;
        if lvItem <> nil then begin
          lvItem.Caption := string(PropList[i].Name);
          PropTypeName := PropList[i].PropType^.Name;
          lvItem.SubItems.Add(string(PropTypeName));
          lvItem.ImageIndex := Integer(PropList[i].PropType^.Kind);
          strTemp := GetEnumName(TypeInfo(TTypeKind), Integer(PropList[i].PropType^.Kind));
          lvItem.SubItems.Add(Copy(strTemp, 3, MaxInt));
          ValueStr := '<Unknown>';
          try
            ValueHint := '';
            case PropList[i].PropType^.Kind of
              tkInteger: begin
                  iTemp := GetOrdProp(TObject(_Node.Data), PropList[i]);
                  ValueStr := GetIntegerDescription(iTemp, string(PropTypeName));
                end;
              tkChar: begin
                  iTemp := GetOrdProp(TObject(_Node.Data), PropList[i]);
                  ValueStr := IntToHex(iTemp, 1) + ' ' + IntToStr(iTemp) + ' ' + Chr(iTemp);
                end;
              tkEnumeration: begin
                  iTemp := GetOrdProp(TObject(_Node.Data), PropList[i]);
                  ValueStr := GetEnumName(PropList[i].PropType^, iTemp);
                end;
              tkFloat:
                ValueStr := FloatToStr(GetFloatProp(TObject(_Node.Data), PropList[i]));
              tkSet: begin
                  ti := GetTypeData(PropList[i].PropType^)^.CompType^;
                  Integer(s) := GetOrdProp(TObject(_Node.Data), PropList[i]);
                  ValueStr := GetSetDescription(ti, s);
                end;
              tkClass: begin
                  objTemp := GetObjectProp(TObject(_Node.Data), PropList[i]);
                  ValueStr := GetObjectDescription(objTemp, ValueHint);
                end;
              tkMethod: begin
                  Method := GetMethodProp(TObject(_Node.Data), PropList[i]);
                  ValueStr := GetMethodDescription(Method);
                end;
              tkWChar: begin
//                    iTemp := GetOrdProp(Node.Data, PropList[i]);
                  ValueStr := '[== Unhandled ==]';
                end;
              tkLString, tkString:
                ValueStr := GetStrProp(TObject(_Node.Data), PropList[i]);
              tkWString:
                ValueStr := GetWideStrProp(TObject(_Node.Data), PropList[i]);
              tkVariant:
                ValueStr := VarToStrDef(GetVariantProp(TObject(_Node.Data), PropList[i]), 'Null');
              tkArray:
                ValueStr := '<Array>';
              tkRecord:
                ValueStr := '<Record>';
              tkInterface:
//                  GetInterfaceProp(Node.Data, PropList[i])
                ValueStr := '<Interface>';
              tkInt64: begin
                  i64Temp := GetInt64Prop(TObject(_Node.Data), PropList[i]);
                  ValueStr := IntToStr(i64Temp) + '($' + IntToHex(i64Temp, 16) + ')';
                end;
              tkDynArray:
                ValueStr := '<DynArray>';
{$IFDEF Delphi2009_Up}
              tkUString: begin
                  ValueStr := GetUnicodeStrProp(_Node.Data, PropList[i]);
                end;
{$ENDIF Delphi2009_Up}
{$IFDEF Delphi2010_Up}
              tkClassRef:
                ValueStr := '<ClassRef>';
              tkPointer:
                ValueStr := '<Pointer>';
              tkProcedure:
                ValueStr := '<Procedure>';
{$ENDIF Delphi2010_Up}
            end;
          except
            ValueStr := '#Exception#';
          end;
          lvItem.SubItems.Add(ValueStr);
          if ValueHint <> '' then begin
            lvItem.SubItems.Objects[0] := Pointer(FValueHints.Add(ValueHint) + 1);
          end;
        end;
      end;
    finally
      FreeMem(PropList, SizeOf(TPropList));
    end;
  finally
    lv_Events.Items.EndUpdate;
    lv_Properties.Items.EndUpdate;
  end;
end;

procedure TExplorerForm.UpdateHierarchy(_Node: TTreeNode);
var
  ClassRef: TClass;
  i: Integer;
  PNode: TTreeNode;
  strList: TStringList;
begin
  tv_Hierarchy.Items.BeginUpdate;
  try
    tv_Hierarchy.Items.Clear;
    if (_Node = nil) or (_Node.Data = nil) then
      Exit; //==>

    PNode := nil;
    ClassRef := TComponent(_Node.Data).ClassType;
    strList := TStringList.Create;
    try
      while ClassRef <> nil do begin
        strList.Insert(0, ClassRef.ClassName);
        ClassRef := ClassRef.ClassParent;
      end;
      for i := 0 to strList.Count - 1 do begin
        PNode := tv_Hierarchy.Items.AddChild(PNode, strList[i]);
        PNode.ImageIndex := 3;
        PNode.SelectedIndex := 3;
      end;
      if tv_Hierarchy.Items[0] <> nil then
        tv_Hierarchy.Items[0].Expand(True);
    finally
      strList.Free;
    end;
  finally
    tv_Hierarchy.Items.EndUpdate;
  end;
end;

procedure TExplorerForm.UpdateAdditional(_Node: TTreeNode);
var
  cmp: TComponent;
begin
  tv_Additional.Items.BeginUpdate;
  try
    tv_Additional.Items.Clear;
    if (_Node = nil) or (_Node.Data = nil) then
      Exit; //==>
    cmp := _Node.Data;
    if cmp is TControl then
      UpdateParents(_Node.Data)
    else if cmp is TMenu then
      UpdateMenu(_Node.Data)
    else if cmp is TMenuItem then
      UpdateSubmenu(_Node.Data)
    else if cmp is TActionList then
      UpdateActionList(_Node.Data)
    else if cmp is TActionManager then
      UpdateActionManager(_Node.Data)
  finally
    tv_Additional.Items.EndUpdate;
  end;
end;

procedure TExplorerForm.UpdateParents(_Ctrl: TControl);
var
  PNode: TTreeNode;
  strList: TStringList;
  CtrlIdxStr: string;
  i: Integer;
begin
  ts_Additional.Caption := 'Parents';
  PNode := nil;
  strList := TStringList.Create;
  try
    while _Ctrl <> nil do begin
      CtrlIdxStr := '';
      if Assigned(_Ctrl.Parent) then begin
        for i := 0 to _Ctrl.Parent.ControlCount - 1 do begin
          if _Ctrl.Parent.Controls[i] = _Ctrl then
            CtrlIdxStr := '[' + IntToStr(i) + '] ';
        end;
      end;
      strList.Insert(0, CtrlIdxStr + _Ctrl.Name + ': ' + _Ctrl.ClassName);
      _Ctrl := _Ctrl.Parent;
    end;
    for i := 0 to strList.Count - 1 do begin
      PNode := tv_Additional.Items.AddChild(PNode, strList[i]);
      PNode.ImageIndex := 3;
      PNode.SelectedIndex := 3;
    end;
    if tv_Additional.Items[0] <> nil then
      tv_Additional.Items[0].Expand(True);
  finally
    strList.Free;
  end;
end;

procedure TExplorerForm.AddSubmenuItems(_ParentNode: TTreeNode; _Item: TMenuItem);
var
  PNode: TTreeNode;
  i: Integer;
  Item: TMenuItem;
begin
  for i := 0 to _Item.Count - 1 do begin
    Item := _Item.Items[i];
    PNode := tv_Additional.Items.AddChild(_ParentNode, Item.Name + ': ' + Item.ClassName + ' - "' + Item.Caption + '"');
    AddSubmenuItems(PNode, Item);
  end;
end;

procedure TExplorerForm.UpdateMenu(_mnu: TMenu);
var
  PNode: TTreeNode;
begin
  ts_Additional.Caption := 'Menu';
  PNode := tv_Additional.Items.AddChild(nil, _mnu.Name + ': ' + _mnu.ClassName);
  AddSubmenuItems(PNode, _mnu.Items);
  PNode.Expand(False);
end;

procedure TExplorerForm.UpdateSubmenu(_mi: TMenuItem);
var
  PNode: TTreeNode;
begin
  ts_Additional.Caption := 'Submenu';
  PNode := tv_Additional.Items.AddChild(nil, _mi.Name + ': ' + _mi.ClassName);
  AddSubmenuItems(PNode, _mi);
  PNode.Expand(False);
end;

function GetActionCaption(_act: TContainedAction): string;
begin
  if _act is TCustomAction then
    Result := TCustomAction(_act).Caption
  else
    Result := '';
end;

procedure TExplorerForm.UpdateActionList(_lst: TActionList);
var
  PNode: TTreeNode;
  i: Integer;
  act: TContainedAction;
  Items: TTreeNodes;
begin
  ts_Additional.Caption := 'Actions';
  Items := tv_Additional.Items;
  PNode := Items.AddChild(nil, _lst.Name + ': ' + _lst.ClassName);
  for i := 0 to _lst.ActionCount - 1 do begin
    act := _lst.Actions[i];
    Items.AddChild(PNode, act.Name + ': ' + act.ClassName + ' - "' + GetActionCaption(act) + '"')
  end;
  PNode.Expand(False);
end;

procedure TExplorerForm.UpdateActionManager(_mgr: TActionManager);
var
  PNode: TTreeNode;
  i: Integer;
  act: TContainedAction;
  Items: TTreeNodes;
begin
  ts_Additional.Caption := 'Actions';
  Items := tv_Additional.Items;
  PNode := Items.AddChild(nil, _mgr.Name + ': ' + _mgr.ClassName);
  for i := 0 to _mgr.ActionCount - 1 do begin
    act := _mgr.Actions[i];
    Items.AddChild(PNode, act.Name + ': ' + act.ClassName + ' - "' + GetActionCaption(act) + '"')
  end;
  PNode.Expand(False);
end;

end.

