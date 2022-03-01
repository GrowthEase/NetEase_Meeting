@echo off

set param1=%1
echo param1 "%param1%"

:: Init enviroment
echo VS142COMNTOOLS: %VS142COMNTOOLS%
call "%VS142COMNTOOLS%VsDevCmd.bat"

cd %~dp0
if "release" == "%param1%" (
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Release /property:Platform=Win32
)^
else if "debug" == "%param1%" (
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Debug /property:Platform=Win32
)^
else (
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Release /property:Platform=Win32
MSBuild .\output\nem_ipc_module.sln /t:Rebuild /m /p:Configuration=Debug /property:Platform=Win32
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
