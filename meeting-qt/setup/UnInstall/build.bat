echo build begin

path %path%;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE
devenv setup_yixin.sln /build Release /project "setup" /projectconfig Release

echo build end
pause 