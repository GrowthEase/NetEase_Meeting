@echo off

set param1=%1
set param2=%2

echo param1 "%param1%"
echo param2 "%param2%"

:: Init enviroment
echo VS142COMNTOOLS_EX: %VS142COMNTOOLS_EX%

cd meeting-ipc
if "%param2%" == "x64" (
    call "%VS142COMNTOOLS_EX%vcvars64.bat"
) else (
    call "%VS142COMNTOOLS_EX%vcvars32.bat"
)

cd %~dp0
if "release" == "%param1%" (
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Release /property:Platform=%param2%
)^
else if "debug" == "%param1%" (
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Debug /property:Platform=%param2%
)^
else (
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Release /property:Platform=%param2%
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Debug /property:Platform=%param2%
)

if "release" == "%param1%" (
xcopy .\output\nem_hosting_module\Release\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module\Release\*.pdb ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Release\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Release\*.pdb ..\bin\ /s /e /y
)^
else if "debug" == "%param1%" (
xcopy .\output\nem_hosting_module\Debug\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module\Debug\*.pdb ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Debug\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Debug\*.pdb ..\bin\ /s /e /y
)^
else (
xcopy .\output\nem_hosting_module\Release\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module\Release\*.pdb ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Release\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Release\*.pdb ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module\Debug\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module\Debug\*.pdb ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Debug\*.dll ..\bin\ /s /e /y
xcopy .\output\nem_hosting_module_client\Debug\*.pdb ..\bin\ /s /e /y
)