!macro customInstall
   SetOutPath $TEMP
   DeleteRegKey HKCR "nemeeting"
   ReadRegStr $0 HKLM "SOFTWARE\NetEase\NIM_MEETING" "install_dir"
   RMDir /r "$0"
!macroend