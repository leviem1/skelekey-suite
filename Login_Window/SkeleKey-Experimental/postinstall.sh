#!/bin/bash
osver=$(sw_vers -productVersion)
if [[ $osver == "10.10"* ]]; then #if Yosemite
	#Create Launcher Script
	echo -e  '#!/bin/bash\nsudo osascript /Library/Scripts/login_window.scpt' > /Library/Scripts/com.skelekey.SkeleKey.Launcher.sh
	#Create LaunchJob
    defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist Label -string "com.skelekey.SkeleKey-LoginWindow.plist"
	defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist ProgramArguments -array -string "/bin/sh"
	defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist ProgramArguments -array-add "/Library/Scripts/com.skelekey.SkeleKey.Launcher.sh"
	defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist WatchPaths -array-add "/Volumes"
	#Allow disks to mount at login window
	sudo defaults write /Library/Preferences/SystemConfiguration/autodiskmount AutomountDisksWithoutUserLogin -bool true
	#Setup Accessibility Preferences
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/MacOS/ARDAgent',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/RemoteManagement/ARDAgent.app',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/bin/bash',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/sbin/launchd',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/loginwindow.app',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/usr/bin/osascript',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/Applications/Utilities/Script Editor.app/',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/bin/sh',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/usr/libexec/sshd-keygen-wrapper',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.apple.SystemUIServer',0,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/Applications/Utilities/Terminal.app',1,1,1,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.apple.WindowServer',0,1,1,NULL)"
    #Create Launch Daemon
    sudo launchctl load -w /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist
elif [[ $osver == "10.11"* ]]; then #if ElCapitan
	#Create Launcher Script
	echo -e  '#!/bin/bash\nsudo osascript /Library/Scripts/login_window.scpt' > /Library/Scripts/com.skelekey.SkeleKey.Launcher.sh
	#Create LaunchJob
	defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist Label "com.skelekey.SkeleKey-LoginWindow.plist" ProgramArguments "/bin/sh" "/Library/Scripts/com.skelekey.SkeleKey.Launcher.sh" WatchPaths "/Volumes"
    defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist Label -string "com.skelekey.SkeleKey-LoginWindow.plist"
    defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist ProgramArguments -array -string "/bin/sh"
    defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist ProgramArguments -array-add "/Library/Scripts/com.skelekey.SkeleKey.Launcher.sh"
    defaults write /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist WatchPaths -array-add "/Volumes"
	#Allow disks to mount at login window
	sudo defaults write /Library/Preferences/SystemConfiguration/autodiskmount AutomountDisksWithoutUserLogin -bool true
	#Setup Accessibility Preferences
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/MacOS/ARDAgent',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/RemoteManagement/ARDAgent.app',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/bin/bash',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/sbin/launchd',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/loginwindow.app',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/usr/bin/osascript',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/Applications/Utilities/Script Editor.app/',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/bin/sh',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/usr/libexec/sshd-keygen-wrapper',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.apple.SystemUIServer',0,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/Applications/Utilities/Terminal.app',1,1,1,NULL,NULL)"
	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.apple.WindowServer',0,1,1,NULL,NULL)"
    #Create Launch Daemon
    sudo launchctl load -w /Library/LaunchDaemons/com.skelekey.SkeleKey-LoginWindow.plist
else
	return 1
fi
