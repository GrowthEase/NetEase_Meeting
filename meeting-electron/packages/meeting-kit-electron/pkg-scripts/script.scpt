try
    set autoLoginEnabled to do shell script "sudo defaults read /Library/Preferences/com.apple.loginwindow 'autoLoginUser'"
    if autoLoginEnabled is not "" then
        
    else
        
    end if
on error errMsg
   set dialogText to "网易会议 Rooms希望针对系统重启功能启用自动登录，请在系统偏好设置中启用自动登录。"
    set buttonResponse to button returned of (display dialog dialogText buttons {"拒绝", "打开系统偏好设置"} default button 2 with title "启用自动登录")

    if buttonResponse is equal to "打开系统偏好设置" then
        tell application "System Preferences"
            reveal anchor "autoLogin" of pane id "com.apple.preference.users"
            activate
        end tell

        set continueText to "在系统偏好设置中完成自动登录配置。"
        display dialog continueText buttons {"继续"} default button 1 with title "启用自动登录"
    else if buttonResponse is equal to "拒绝" then
        set dialogText2 to "网易会议 Rooms建议使用每周重启功能以获得最佳系统性能，如果未启用自动登录，则网易会议 Rooms将无法重启系统，是否确定要拒绝？"
        set buttonResponse2 to button returned of (display dialog dialogText2 buttons {"打开系统偏好设置", "拒绝"} default button 1 with title "启用自动登录")

        if buttonResponse2 is equal to "打开系统偏好设置" then
            tell application "System Preferences"
                reveal anchor "autoLogin" of pane id "com.apple.preference.users"
                activate
            end tell

            set continueText to "在系统偏好设置中完成自动登录配置。"
            display dialog continueText buttons {"继续"} default button 1 with title "启用自动登录"
        end if
    end if
end try