--
--  AppDelegate.applescript
--  SkeleKey-Applet
--
--  Created by Mark Hedrick on 10/11/15.
--  Copyright (c) 2015 Mark Hedrick and Levi Muniz. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	on returnNumbersInString(inputString)
		set inputString to quoted form of inputString
		do shell script "sed s/[a-zA-Z\\']//g <<< " & inputString --take out the alpha characters
		set nums to the result
		set numlist to {}
		repeat with i from 1 to length of nums
			set certain_char to character i of nums
			try
				set certain_char to certain_char as number
				set the end of numlist to certain_char
			end try
		end repeat
		return numlist
	end returnNumbersInString
	
	on decryptinfo(volumepath, authinfobin)
		set md5 to " md5 | "
		set md5_e to " md5"
		set base64 to " base64 | "
		set base64_e to " base64"
		set rev to "rev | "
		set rev_e to "rev"
		set sha224 to "shasum -a 224 | awk '{print $1}' | "
		set sha224_e to "shasum -a 224 | awk '{print $1}'"
		set sha256 to "shasum -a 256 | awk '{print $1}' | "
		set sha256_e to "shasum -a 256 | awk '{print $1}'"
		set sha384 to "shasum -a 384 | awk '{print $1}' | "
		set sha384_e to "shasum -a 384 | awk '{print $1}'"
		set sha512 to "shasum -a 512 | awk '{print $1}' | "
		set sha512_e to "shasum -a 512 | awk '{print $1}'"
		set sha512224 to "shasum -a 512224 | awk '{print $1}' | "
		set sha512224_e to "shasum -a 512224 | awk '{print $1}'"
		set sha512256 to "shasum -a 512256 | awk '{print $1}' | "
		set sha512256_e to "shasum -a 512256 | awk '{print $1}'"
		set zero to md5 & base64_e
		set one to sha256 & sha512256_e
		set two to sha224 & sha384_e
		set three to base64 & rev & sha256_e
		set four to sha512 & rev_e
		set five to sha512224 & md5_e
		set six to sha384 & rev_e
		set seven to sha384 & base64_e
		set eight to base64 & md5_e
		set nine to sha512256 & md5 & rev_e
		set algorithms to {zero, one, two, three, four, five, six, seven, eight, nine}
		set encstring to ""
		set epass to ""
		set uuid to do shell script "diskutil info '" & volumepath & "' | grep 'Volume UUID' | awk '{print $3}' | rev"
		set nums to returnNumbersInString(uuid)
		set algorithms to {zero, one, two, three, four, five, six, seven, eight, nine}
		repeat with char in nums
			set encstring to do shell script "printf \"" & uuid & "\" | " & (item (char + 1) of algorithms)
			set epass to epass & encstring
		end repeat
		set epass to do shell script "printf \"" & epass & "\" | fold -w160 | paste -sd'%' - | fold -w270 | paste -sd'@' - | fold -w51 | paste -sd'*' - | fold -w194 | paste -sd'~' - | fold -w64 | paste -sd'2' - | fold -w78 | paste -sd'^' - | fold -w38 | paste -sd')' - | fold -w28 | paste -sd'(' - | fold -w69 | paste -sd'=' -  | fold -w128 | paste -sd'$3bs' -  "
		if (length of epass) is greater than 2048 then
			set epass to (characters 1 thru 2047 of epass) as string
		end if
		set encContents to (do shell script "openssl enc -aes-256-cbc -d -in '" & authinfobin & "' -pass pass:\"" & epass & "\"")
		
		set username to paragraph 1 of encContents
		set passwd to paragraph 2 of encContents
		set exp_date_e to paragraph 3 of encContents
		set execlimit to paragraph 4 of encContents
		set webState to paragraph 5 of encContents
		return {username, passwd, exp_date_e, execlimit, webState}
	end decryptinfo
	
	on assistiveaccess(username, passwd)
		do shell script "sw_vers -productVersion"
		try
			if result contains "10.11" then
				do shell script "sudo sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.skelekey.SkeleKey-Applet',0,1,1,NULL,NULL)\"" user name username password passwd with administrator privileges
			else
				do shell script "sudo sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.skelekey.SkeleKey-Applet',0,1,1,NULL)\"" user name username password passwd with administrator privileges
			end if
		on error
			error number 102
		end try
	end assistiveaccess
	
	on expCheck(expireDate, drive, usernameValue)
		global UnixPath
		set current_date_e to do shell script "date -u '+%s'"
		if current_date_e is greater than or equal to expireDate and expireDate is not "none" then
			display dialog "This SkeleKey has expired!" with icon 0 buttons "Quit" with title "SkeleKey-Applet" default button 1
			do shell script "chflags hidden '" & UnixPath & "'"
			do shell script "nohup sh -c \"killall SkeleKey-Applet; srm -rf '" & UnixPath & "'; srm -rf '" & drive & ".SK_EL_" & usernameValue & ".enc.bin'\" > /dev/null &"
		end if
	end expCheck
	
	on checkadmin(username, passwd)
		try
			do shell script "sudo printf elevate" user name username password passwd with administrator privileges
		on error
			error number 101
		end try
	end checkadmin
	
	on execlimit_ext(usernameValue, drive, execlimit_bin)
		global UnixPath
		
		set execlimit_ext to do shell script "cat '" & drive & ".SK_EL_" & usernameValue & ".enc.bin' | rev | base64 -D | rev"
		
		if execlimit_ext is not equal to execlimit_bin then
			if execlimit_ext is less than execlimit_bin then
				set numEL to execlimit_ext
			else if execlimit_ext is greater than execlimit_bin then
				set numEL to execlimit_bin
			end if
		else
			set numEL to execlimit_bin
		end if
		
		if numEL is not "none" then
			if numEL is less than or equal to 0 then
				display dialog "This SkeleKey has reached it's execution limit!" with icon 0 buttons "Quit" with title "SkeleKey-Applet" default button 1
				do shell script "chflags hidden '" & UnixPath & "'"
				do shell script "nohup sh -c \"killall SkeleKey-Applet; srm -rf '" & UnixPath & "'; srm -rf '" & drive & ".SK_EL_" & usernameValue & ".enc.bin'\" > /dev/null &"
				quit
			else if numEL is greater than 0 then
				set newNumEL to do shell script "printf '" & (numEL - 1) & "' | rev | base64 | rev"
				do shell script "printf '" & newNumEL & "' > '" & drive & ".SK_EL_" & usernameValue & ".enc.bin'"
			end if
		end if
	end execlimit_ext
	
	on guiauth(usern, pass)
		try
			tell application "System Events" to tell process "SecurityAgent"
				set value of text field 1 of window 1 to usern
				set value of text field 2 of window 1 to pass
				click button 2 of window 1
			end tell
		on error
			error number 103
		end try
	end guiauth
	
	on auth(username, passwd)
		set fullnames to {}
		
		set localusers to paragraphs of (do shell script "dscl . list /Users | egrep -v '(daemon|Guest|nobody|^_.*)'") as list
		repeat with acct in localusers
			set fn to do shell script "dscacheutil -q user -a name '" & acct & "' | grep 'gecos' | sed -e 's/.*gecos: \\(.*\\)/\\1/'"
			set fullnames to fullnames & fn
		end repeat
		if (fullnames contains username) or (localusers contains username) then
			guiauth(username, passwd)
		else
			error number 105
		end if
	end auth
	
	on PageElements(theUrl)
		global UnixPath
		set ufields to {"*accountname", "*sername", "*mail", "*ser", "*appleId"}
		set pfields to {"*assword", "*asswd", "*pw", "*pass", "*ass", "*pwd"}
		tell application "Safari"
			set myDoc to document of front window
			set mySrc to source of myDoc
		end tell
		set wwwFields to do shell script "echo " & (quoted form of mySrc) & " | perl " & UnixPath & "/Contents/Resources/formfind.pl | grep Input | egrep -ov '(HIDDEN|RADIO)' | awk '{ print $2 }' | tr -d '\"' | sed \"s/^id=//\" | egrep -v '(sesskey|cookies|testcookies|search)'"
		set wwwFields to paragraphs of wwwFields
		repeat with elementid in wwwFields
			repeat with field in ufields
				try
					set ufid to do shell script "echo " & elementid & " | grep -o '\\<." & field & "\\>'"
					exit repeat
				end try
			end repeat
			repeat with field in pfields
				try
					set pfid to do shell script "echo " & elementid & " | grep -o '\\<." & field & "\\>'"
					exit repeat
				end try
			end repeat
		end repeat
		return {ufid, pfid}
	end PageElements
	
	on inputByID(theId, theValue)
		tell application "Safari"
			do JavaScript "  document.getElementById('" & theId & "').value ='" & theValue & "';" in document 1
		end tell
	end inputByID
	on clickID(theId)
		tell application "Safari"
			do JavaScript "document.getElementById('" & theId & "').click();" in document 1
		end tell
	end clickID
	
	on web(username, passwd)
		tell application "System Events" to (name of processes) contains "Safari"
		set safariRunning to result
		if safariRunning is false then display dialog "Safari is not running! Please open Safari to use the SkeleKey Web Add-on!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
		tell application "Safari"
			set website to get URL of front document
		end tell
		
		if website contains "accounts.google.com" then
			try
				inputByID("Email", username)
				clickID("next")
				delay 0.25
				inputByID("Passwd", passwd)
				clickID("signIn")
			end try
		else
			set PageIDs to PageElements(website)
			try
				inputByID((item 1 of PageIDs), username)
				clickID("next")
				inputByID((item 2 of PageIDs), passwd)
				clickID("submit")
			end try
		end if
	end web
	
	on main()
		global UnixPath
		try
			set UnixPath to POSIX path of (path to current application as text)
			set volumepath to UnixPath
			set volumepath to POSIX path of ((path to current application as text) & "::")
			if volumepath does not contain "/Volumes/" then
				display dialog "SkeleKey Applet is not located on a USB Device!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
				quit
			end if
			set authinfobin to UnixPath & "Contents/Resources/.p.enc.bin"
			set webFile to UnixPath & "Contents/Resources/.webenabled"
			set volumepath to (do shell script "printf '" & volumepath & "' | awk -F '/' '{print $3}'")
			set volumepath to "/Volumes/" & volumepath
			set volumepath2 to volumepath & "/"
			set authcred to decryptinfo(volumepath, authinfobin)
			#Regular Run
			if (item 5 of authcred) is "none" then
				expCheck(item 3 of authcred, volumepath2, item 1 of authcred)
				execlimit_ext(item 1 of authcred, volumepath2, item 4 of authcred)
				checkadmin(item 1 of authcred, item 2 of authcred)
				assistiveaccess(item 1 of authcred, item 2 of authcred)
				auth(item 1 of authcred, item 2 of authcred)
				#Web Only Run
			else if (item 5 of authcred) is "WEBYES" then
				set osver to do shell script "sw_vers -productVersion"
				if osver contains "10.11" then
					expCheck(item 3 of authcred)
					execlimit_ext(item 1 of authcred, volumepath2, item 4 of authcred)
					try
						do shell script "test -e " & webFile
					on error
						error number 106
					end try
					web(item 1 of authcred, item 2 of authcred)
				else
					error number 107
				end if
			end if
		on error number errorNumber
			if errorNumber is 101 then
				display dialog "SkeleKey only authenticates users with admin privileges. Maybe the wrong password was entered?" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
				return
			else if errorNumber is 102 then
				display dialog "Failed to set accessibility permissions" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
				return
			else if errorNumber is 103 then
				display dialog "Error! No authentication window found! Is the prompt on the screen? Quitting..." with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
				return
			else if errorNumber is 104 then
				display dialog "Error! This SkeleKey is no longer valid and has reached the execution limit! Quitting..." with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
				return
			else if errorNumber is 105 then
				display dialog "User account is not on this computer!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
			else if errorNumber is 106 then
				display dialog "This SkeleKey Applet does not have Website Support Enabled!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
			else if errorNumber is 107 then
				display dialog "The SkeleKey Web add-on is only available on systems running at least 10.11!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
				return
			end if
		end try
	end main
	
	on applicationWillFinishLaunching:aNotification
		set dependencies to {"printf", "openssl", "ls", "diskutil", "awk", "base64", "sudo", "cp", "sed", "sqlite3", "md5", "rev", "fold", "paste", "sw_vers", "grep", "dscl", "nohup test", "sh", "srm", "egrep", "chflags", "killall", "date", "dscacheutil", "test"}
		set notInstalledString to ""
		repeat with i in dependencies
			set status to do shell script i & "; printf $?"
			if status is "127" then
				set notInstalledString to notInstalledString & i & "
                "
			end if
		end repeat
		if notInstalledString is not "" then
			display alert "The following required items are not installed:
            
            " & notInstalledString buttons "Quit"
			quit
		end if
		main()
		quit
	end applicationWillFinishLaunching:
	
	on applicationShouldTerminate:sender
		return current application's NSTerminateNow
	end applicationShouldTerminate:
	
end script