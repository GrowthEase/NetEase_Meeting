!macro customInstall
   SetOutPath $TEMP
   DeleteRegKey HKCR "nemeeting"
   ReadRegStr $0 HKLM "SOFTWARE\NetEase\NIM_MEETING" "install_dir"
   RMDir /r "$0"
   ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64" "Installed"
   StrCmp $0 "1" EndInstall
   ExecWait '"$INSTDIR\resources\VC_redist.X64.exe" /S /norestart' $0
   EndInstall:
!macroend


