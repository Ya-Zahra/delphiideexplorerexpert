unit dzIdeExplorerReg;

interface

uses
  ToolsApi,
  dzIdeExplorerExpert;

procedure Register;

implementation

procedure Register;
begin
  RegisterPackageWizard(TDGHIDEExplorer.Create);
end;

end.

