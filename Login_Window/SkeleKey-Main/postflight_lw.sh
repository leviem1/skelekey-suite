#!/bin/bash
#--
#--  postflight_lw.sh
#--  SkeleKey-Manager
#--
#--  Created by Mark Hedrick on 02/25/16.
#--  Copyright (c) 2016 Mark Hedrick and Levi Muniz. All rights reserved.
#--
#--VERSION 1.0.0
osver=$(sw_vers -productVersion)
if [[ $osver == "10.10"* ]]; then #if Yosemite
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
