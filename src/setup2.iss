[Setup]
AppName=EveConnector
AppVersion=1
DefaultDirName={pf}\EveConnector
ShowLanguageDialog=no
PrivilegesRequired=admin
AppCopyright=Libre Informatique
AppPublisher=Libre Informatique
AppPublisherURL=http://libre-informatique.fr
OutputBaseFilename=EveConnector-Setup-v2
DisableWelcomePage=False
UsePreviousSetupType=False
UsePreviousTasks=False
FlatComponentsList=False
AlwaysShowComponentsList=True
ShowComponentSizes=False
OutputDir=C:\Users\libre-info\Desktop\EveConnector-Setup\src\Output
DisableStartupPrompt=True
; When set to none, Setup will use the first language specified in the [Languages] section as the default language.
LanguageDetectionMethod=none 
DisableDirPage=yes
UsePreviousGroup=False
DisableReadyMemo=True
DisableProgramGroupPage=yes
AlwaysShowGroupOnReadyPage=no
DefaultGroupName=EveConnector
SetupLogging=yes

[Languages]
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[Dirs]
Name: "{app}\eve-connector-win\node_modules"; Components: eveconnector

[Files]
; Node.js installer
Source: "node-v4.4.5-x64.msi"; DestDir: "{app}"; Flags: ignoreversion; Components: node; AfterInstall: InstallNode
; EveConnector
Source: "eve-connector-win\config.js"; DestDir: "{app}\eve-connector-win\"; Flags: ignoreversion; Components: eveconnector
Source: "eve-connector-win\main.js"; DestDir: "{app}\eve-connector-win\"; Flags: ignoreversion; Components: eveconnector
Source: "eve-connector-win\server.js"; DestDir: "{app}\eve-connector-win\"; Flags: ignoreversion; Components: eveconnector; AfterInstall: InstallEveConnector
; Boca printer
Source: "Drivers\HP46_Thermal_Printer\InstallDriver.exe"; DestDir: "{app}\Drivers\HP46_Thermal_Printer\"; Flags: ignoreversion; Components: winusb/printers/boca; AfterInstall: InstallDriver('HP46_Thermal_Printer')
; Star printer
Source: "Drivers\TSP743II_STR_T-001\InstallDriver.exe"; DestDir: "{app}\Drivers\TSP743II_STR_T-001\"; Flags: ignoreversion; Components: winusb/printers/tsp700; AfterInstall: InstallDriver('TSP743II_STR_T-001')
; Star display
Source: "Drivers\SCD122U\InstallDriver.exe"; DestDir: "{app}\Drivers\SCD122U\"; Flags: ignoreversion; Components: winusb/displays/star; AfterInstall: InstallDriver('SCD122U')

[Icons]
Name: "{group}\Page de test"; Filename: "{pf}\Mozilla Firefox\firefox.exe"; Parameters: "https://localhost:8164/test"
Name: "{group}\{cm:UninstallProgram, EveConnector}"; Filename: "{uninstallexe}"

[Components]
Name: "eveconnector"; Description: "EveConnector"; Types: compact custom full
Name: "node"; Description: "Node.js et npm"; Types: full custom
Name: "winusb"; Description: "Pilotes WinUSB pour les périphériques"; Types: full custom
Name: "winusb/printers"; Description: "Imprimantes"; Types: full custom
Name: "winusb/printers/tsp700"; Description: "Star TSP700"; Types: full custom
Name: "winusb/printers/boca"; Description: "Imprimante Boca"; Types: full custom
Name: "winusb/displays"; Description: "Afficheurs"; Types: full custom
Name: "winusb/displays/star"; Description: "Afficheur Star SCD122U"; Types: full custom
;Name: "test"; Description: "Test"

[UninstallDelete]
Type: filesandordirs; Name: "{app}/eve-connector-win"; Components: eveconnector

[ThirdParty]
UseRelativePaths=True

[Code]

var
  errorMessage: String;
  aborted: Boolean;

procedure Test();
begin
  MsgBox('Test:' #13#13 'Bye bye!', mbInformation, MB_OK);
end;


// ***********************************************
// util method, equivalent to C# string.StartsWith
function StartsWith(SubStr, S: String):Boolean;
begin
   Result:= Pos(SubStr, S) = 1;
end;

// ********************************************
// util method, equivalent to C# string.Replace
function StringReplace(S, oldSubString, newSubString: String) : String;
var
  stringCopy : String;
begin
  stringCopy := S; //Prevent modification to the original string
  StringChange(stringCopy, oldSubString, newSubString);
  Result := stringCopy;
end;

// *****************************
// Gets a command line parameter
function GetCommandlineParam (inParamName: String):String;
var
   paramNameAndValue: String;
   i: Integer;
begin
   Result := '';

   for i:= 0 to ParamCount do
   begin
     paramNameAndValue := ParamStr(i);
     if (StartsWith(inParamName, paramNameAndValue)) then
     begin
       Result := StringReplace(paramNameAndValue, inParamName + '=', '');
       break;
     end;
   end;
end;



// *******************************
// Gets the Node.js installer mode 
// (passive = only progress bar / quiet = no windows at all)
function NodeInstallMode(Param: String): String;
begin
   Result := '/passive';
   if WizardSilent then
      Result := '/quiet';
end;

function NodeDir(): String;
begin
    Result :=  ExpandConstant('{app}\nodejs');
end;

function NodeExe(): String;
begin
    Result := NodeDir() + '\node.exe';
end;

function NpmExe(): String;
begin
    Result := NodeDir() + '\npm';
end;



// ******************************
// Stops the EveConnector service
function StopService(): Boolean;
var
  errorCode: Integer;
begin
  Log('StopService() called');
  Result := ShellExec('runas', NodeExe(), 'main.js stop', ExpandConstant('{app}\eve-connector-win'), 
    SW_HIDE, ewWaitUntilTerminated, errorCode);
end;



// ******************************
// Uninstall the EveConnector service
function UninstallService(): Boolean;
var
  errorCode: Integer;
begin
  Log('UninstallService() called');
  Result := ShellExec('runas', NodeExe(), 'main.js uninstall', ExpandConstant('{app}\eve-connector-win'), 
    SW_HIDE, ewWaitUntilTerminated, errorCode);
end;




// ************************
// Installs Node.js and npm
procedure InstallNode();
var
  installer, installMode: String;
  errorCode, showWindow: Integer;
  res: Boolean;
begin
  Log('InstallNode() called');
  if aborted then exit;

  installer := ExpandConstant('"{app}\node-v4.4.5-x64.msi"');
  installMode := '/passive';
  showWindow := SW_SHOW;
  if WizardSilent then
  begin
    installMode := '/quiet';
    showWindow := SW_HIDE;
  end;
  res := ShellExec('runas', 'msiexec.exe',
    '/i ' + installer + ' INSTALLDIR="' + NodeDir() + '" ' + installMode, 
    '', showWindow, ewWaitUntilTerminated, errorCode);
  if not res then begin
    errorMessage := 'L''installation de Node.js a échoué: ' + IntToStr(errorCode);
    Log(errorMessage);
    aborted := True;
    exit;
  end;
end;



// **************************
// Uninstalls Node.js and npm
procedure UninstallNode();
var
  installer, installMode: String;
  errorCode, showWindow: Integer;
  res: Boolean;
begin
  Log('UninstallNode() called');

  installer := ExpandConstant('"{app}\node-v4.4.5-x64.msi"');
  installMode := '/passive';
  showWindow := SW_SHOW;
  res := ShellExec('runas', 'msiexec.exe',
    '/x ' + installer + ' INSTALLDIR="' + NodeDir() + '" ' + installMode, 
    '', showWindow, ewWaitUntilTerminated, errorCode);
  if not res then begin
    errorMessage := 'La désinstallation de Node.js a échoué: ' + IntToStr(errorCode);
    Log(errorMessage);
  end;
end;



// ***********************************************
// Installs eve-connector and node-windows modules
// then install and start the service
procedure InstallEveConnector();
var
  proxy: String;
  errorCode: Integer;
  res: Boolean;
begin
  Log('InstallEveConnector() called');
  if aborted then exit;

  
  proxy := GetCommandlineParam('/PROXY');
  if proxy <> '' then      
    // Set proxy settings for npm
    begin
      Log('Configuring proxy for npm ("' + proxy + '")...');
      proxy := 'http://' + proxy;
                
      res := ShellExec('runas', NpmExe(), 'config set proxy ' + proxy, ExpandConstant('{app}\eve-connector-win'), 
        SW_HIDE, ewWaitUntilTerminated, errorCode);
      if not res then
        begin
          errorMessage := 'Configuring http proxy for npm FAILED (ShellExec returned false)';
          aborted := True;
        end
      else if errorCode <> 0 then
        begin
          errorMessage := Format('Configuring http proxy for npm FAILED: errorCode %d', [errorCode]);
          aborted := True;  
        end
      else
        Log(Format('Configuring http proxy for npm DONE OK (%s)', [proxy]))
      
      res := ShellExec('runas', NpmExe(), 'config set https-proxy ' + proxy, ExpandConstant('{app}\eve-connector-win'), 
        SW_HIDE, ewWaitUntilTerminated, errorCode);
      if not res then
        begin
          errorMessage := 'Configuring https proxy for npm FAILED (ShellExec returned false)';
          aborted := True;
        end
      else if errorCode <> 0 then
        begin
          errorMessage := Format('Configuring https proxy for npm FAILED: errorCode %d', [errorCode]);
          aborted := True;  
        end
      else
        Log(Format('Configuring https proxy for npm DONE OK (%s)', [proxy]))
      
      if aborted then
      begin
        Log(errorMessage);
        errorMessage := 'Le paramétrage du proxy pour NPM a échoué';
        exit;
      end;
    end

  else
    // Set proxy settings for npm
    begin
      Log('Clearing proxy settings for npm...');

      res := ShellExec('runas', NpmExe(), 'config rm proxy', ExpandConstant('{app}\eve-connector-win'), 
        SW_HIDE, ewWaitUntilTerminated, errorCode);
      if not res then
        begin
          errorMessage := 'Clearing http proxy settings for npm FAILED (ShellExec returned false)';
          aborted := True;
        end
      else if errorCode <> 0 then
        begin
          errorMessage := Format('Clearing http proxy settings for npm FAILED: errorCode %d', [errorCode]);
          aborted := True;  
        end
      else
        Log('Clearing http proxy settings for npm DONE OK');

      res := ShellExec('runas', NpmExe(), 'config rm https-proxy', ExpandConstant('{app}\eve-connector-win'), 
        SW_HIDE, ewWaitUntilTerminated, errorCode);
      if not res then
        begin
          errorMessage := 'Clearing https proxy settings for npm FAILED (ShellExec returned false)';
          aborted := True;
        end
      else if errorCode <> 0 then
        begin
          errorMessage := Format('Clearing https proxy settings for npm FAILED: errorCode %d', [errorCode]);
          aborted := True;  
        end
      else
        Log('Clearing http proxy settings for npm DONE OK');

      if aborted then
      begin
        errorMessage := 'Le nettoyage des paramètres de proxy pour NPM a échoué';
        Log(errorMessage);
        exit;
      end;
    end;

  // Install eve-connector module (npm)
  Log('Installing eve-connector module (npm)...');
  res := ShellExec('runas', NpmExe(), 'install eve-connector', ExpandConstant('{app}\eve-connector-win'), 
    SW_HIDE, ewWaitUntilTerminated, errorCode);
  if not res then 
    begin
      errorMessage := 'npm install eve-connector FAILED (ShellExec returned false)';
      Log(errorMessage);
      aborted := True;
      exit;
    end
  else if errorCode <> 0 then
    begin
      errorMessage := Format('npm install eve-connector FAILED: errorCode %d', [errorCode]);
      Log(errorMessage);
      aborted := True;
      exit;
    end
  else
    Log('npm install eve-connector DONE OK');

  // Install node-windows module (npm)
  Log('Installing node-windows module (npm)...');
  res := ShellExec('runas', NpmExe(), 'install node-windows', ExpandConstant('{app}\eve-connector-win'), 
    SW_HIDE, ewWaitUntilTerminated, errorCode);
  if not res then 
    begin
      errorMessage := 'npm install node-windows FAILED (ShellExec returned false)';
      Log(errorMessage);
      aborted := True;
      exit;
    end
  else if errorCode <> 0 then
    begin
      errorMessage := Format('npm install node-windows FAILED: errorCode %d', [errorCode]);
      Log(errorMessage);
      aborted := True;
      exit;
    end
  else
    Log('npm install node-windows DONE OK');

  // Install and start the EveConnector service
  Log('Installing and starting EveConnector service...');
  res := ShellExec('runas', NodeExe(), 'main.js', ExpandConstant('{app}\eve-connector-win'), 
    SW_HIDE, ewWaitUntilTerminated, errorCode);
  if not res then 
    begin
      errorMessage := 'EveConnector service installation FAILED  (ShellExec returned false)';
      Log(errorMessage);
      aborted := True;
      exit;
    end
  else if errorCode <> 0 then
    begin
      errorMessage := Format('EveConnector service installation FAILED: errorCode %d', [errorCode]);
      Log(errorMessage);
      aborted := True;
      exit;
    end
  else
    Log('EveConnector service installed OK');
 end;



// Install WinUSB drivers
procedure InstallDriver(dir: String);
  var 
    path: String;
    res: Boolean;
    errorCode: Integer;
begin
  Log(Format('Installing driver (%s)...', [dir]));
  path := ExpandConstant(Format('{app}\Drivers\%s', [dir]));
  res := ShellExec('runas', path + '\InstallDriver.exe', '', path, 
    SW_HIDE, ewWaitUntilTerminated, errorCode);
  if not res then
    Log(Format('ERR: Could not install driver %s', [dir]));
end;



function InitializeSetup(): Boolean;
begin
   aborted := False;
   errorMessage := '';
   Result := True;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if IsComponentSelected('node') or IsComponentSelected('eveconnector') then
  begin
    StopService();
  end;
  Result := ''; // Return a non empty string (message) to abort 
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  Log('CurStepChanged(' + IntToStr(Ord(CurStep)) + ') called');
  if aborted then 
  begin
    if not WizardSilent then 
      MsgBox(errorMessage + ' / Abandon de l''installation de EveConnector.', mbCriticalError, MB_OK);
    Log('Aborting install');
    Abort();
  end;

  if CurStep = ssPostInstall then
  begin
    
  end;
end;


function InitializeUninstall(): Boolean;
begin
  Log('InitializeUninstall() called');
  UninstallService();
  UninstallNode();
  Result := True;
end;