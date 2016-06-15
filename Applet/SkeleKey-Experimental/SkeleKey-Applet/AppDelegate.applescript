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
        do shell script "/usr/bin/sed s/[a-zA-Z\\']//g <<< " & inputString --take out the alpha characters
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
    
    on replace_chars(this_text, search_string, replacement_string)
        set AppleScript's text item delimiters to the search_string
        set the item_list to every text item of this_text
        set AppleScript's text item delimiters to the replacement_string
        set this_text to the item_list as string
        set AppleScript's text item delimiters to ""
        return this_text
    end replace_chars
    
    on decryptinfo(volumepath, authinfobin)
        set md5 to " /sbin/md5 | "
        set md5_e to " /sbin/md5"
        set base64 to " /usr/bin/base64 | "
        set base64_e to " /usr/bin/base64"
        set rev to "/usr/bin/rev | "
        set rev_e to "/usr/bin/rev"
        set sha224 to "/usr/bin/shasum -a 224 | /usr/bin/awk '{print $1}' | "
        set sha224_e to "/usr/bin/shasum -a 224 | /usr/bin/awk '{print $1}'"
        set sha256 to "/usr/bin/shasum -a 256 | /usr/bin/awk '{print $1}' | "
        set sha256_e to "/usr/bin/shasum -a 256 | /usr/bin/awk '{print $1}'"
        set sha384 to "/usr/bin/shasum -a 384 | /usr/bin/awk '{print $1}' | "
        set sha384_e to "/usr/bin/shasum -a 384 | /usr/bin/awk '{print $1}'"
        set sha512 to "/usr/bin/shasum -a 512 | /usr/bin/awk '{print $1}' | "
        set sha512_e to "/usr/bin/shasum -a 512 | /usr/bin/awk '{print $1}'"
        set sha512224 to "/usr/bin/shasum -a 512224 | /usr/bin/awk '{print $1}' | "
        set sha512224_e to "/usr/bin/shasum -a 512224 | /usr/bin/awk '{print $1}'"
        set sha512256 to "/usr/bin/shasum -a 512256 | /usr/bin/awk '{print $1}' | "
        set sha512256_e to "/usr/bin/shasum -a 512256 | /usr/bin/awk '{print $1}'"
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
        set epass to ""
        set uuid to do shell script "/usr/sbin/diskutil info $'" & volumepath & "' | /usr/bin/grep 'Volume UUID' | /usr/bin/awk '{print $3}' | /usr/bin/rev"
        set nums to returnNumbersInString(uuid)
        repeat with char in nums
            set encstring to do shell script "printf \"" & uuid & "\" | " & (item (char + 1) of algorithms)
            set epass to epass & encstring
        end repeat
        set epass to do shell script "printf \"" & epass & "\" | /usr/bin/fold -w160 | /usr/bin/paste -sd'%' - | /usr/bin/fold -w270 | /usr/bin/paste -sd'@' - | /usr/bin/fold -w51 | /usr/bin/paste -sd'*' - | /usr/bin/fold -w194 | /usr/bin/paste -sd'~' - | /usr/bin/fold -w64 | /usr/bin/paste -sd'2' - | /usr/bin/fold -w78 | /usr/bin/paste -sd'^' - | /usr/bin/fold -w38 | /usr/bin/paste -sd')' - | /usr/bin/fold -w28 | /usr/bin/paste -sd'(' - | /usr/bin/fold -w69 | /usr/bin/paste -sd'=' -  | /usr/bin/fold -w128 | /usr/bin/paste -sd'$3bs' -  "
        if (length of epass) is greater than 2048 then
            set epass to (characters 1 thru 2047 of epass) as string
        end if
        set encContents to (do shell script "/usr/bin/openssl enc -aes-256-cbc -d -in $'" & authinfobin & "' -pass pass:\"" & epass & "\"")
        
        set username to paragraph 1 of encContents
        set username to replace_chars(username, "\\", "\\\\")
        set username to replace_chars(username, "'", "\\'")
        return {{paragraph 1 of encContents, username}, paragraph 2 of encContents, paragraph 3 of encContents, paragraph 4 of encContents, paragraph 5 of encContents}
    end decryptinfo
    
    on assistiveaccess(username, passwd, osver)
        try
            if osver contains "10.11" then
                do shell script "/usr/bin/sudo /usr/bin/sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.skelekey.SkeleKey-Applet',0,1,1,NULL,NULL)\"" user name username password passwd with administrator privileges
            else
                do shell script "/usr/bin/sudo /usr/bin/sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.skelekey.SkeleKey-Applet',0,1,1,NULL)\"" user name username password passwd with administrator privileges
            end if
        on error
            error number 102
        end try
    end assistiveaccess
    
    on expCheck(expireDate, drive, usernameValue)
        global UnixPath
        global randName
        set randName to do shell script "/bin/cat $'" & drive & usernameValue & "-SkeleKey-Applet.app/Contents/Resources/.SK_EL_STR' | /usr/bin/rev | /usr/bin/base64 -D | /usr/bin/rev"
        set current_date_e to do shell script "/bin/date -u '+%s'"
        if current_date_e is greater than or equal to expireDate and expireDate is not "none" then
            display dialog "This SkeleKey has expired!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            do shell script "/usr/bin/chflags hidden $'" & UnixPath & "'"
            do shell script "/usr/bin/nohup /bin/sh -c \"/usr/bin/killall SkeleKey-Applet; /usr/bin/srm -rf $'" & UnixPath & "'; /usr/bin/srm -rf $'" & drive & ".SK_EL_" & randName & ".enc.bin'\" > /dev/null &"
        end if
    end expCheck
    
    on checkadmin(username, passwd)
        try
            do shell script "/usr/bin/sudo printf elevate" user name username password passwd with administrator privileges
        on error
            error number 101
        end try
    end checkadmin
    
    on execlimit_ext(user, drive, execlimit_bin)
        global UnixPath
        global randName
        try
            set existence_EL to do shell script "/bin/test -e $'" & drive & ".SK_EL_" & randName & ".enc.bin'"
        on error
            set existence_EL to "error"
        end try
        
        if execlimit_bin is not "none" and existence_EL is "error" then
            display dialog "This SkeleKey has reached it's execution limit!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            do shell script "/usr/bin/chflags hidden $'" & UnixPath & "'"
            do shell script "/usr/bin/nohup /bin/sh -c \"/usr/bin/killall SkeleKey-Applet; /usr/bin/srm -rf $'" & UnixPath & "'; /usr/bin/srm -rf $'" & drive & ".SK_EL_" & randName & ".enc.bin'\" > /dev/null &"
        end if
        
        set execlimit_ext to do shell script "/bin/cat $'" & drive & ".SK_EL_" & randName & ".enc.bin' | /usr/bin/rev | /usr/bin/base64 -D | /usr/bin/rev"
        
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
                display dialog "This SkeleKey has reached it's execution limit!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
                do shell script "/usr/bin/chflags hidden $'" & UnixPath & "'"
                do shell script "/usr/bin/nohup sh -c \"/usr/bin/killall SkeleKey-Applet; /usr/bin/srm -rf $'" & UnixPath & "'; /usr/bin/srm -rf $'" & drive & ".SK_EL_" & randName & ".enc.bin'\" > /dev/null &"
                quit
            else if numEL is greater than 0 then
                set newNumEL to do shell script "printf '" & (numEL - 1) & "' | /usr/bin/rev | /usr/bin/base64 | /usr/bin/rev"
                do shell script "printf '" & newNumEL & "' > $'" & drive & ".SK_EL_" & randName & ".enc.bin'"
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
        
        set localusers to paragraphs of (do shell script "/usr/bin/dscl . list /Users | /usr/bin/egrep -v '(daemon|Guest|nobody|^_.*)'") as list
        repeat with acct in localusers
            set fn to do shell script "/usr/bin/dscacheutil -q user -a name '" & acct & "' | /usr/bin/grep 'gecos' | /usr/bin/sed -e 's/.*gecos: \\(.*\\)/\\1/'"
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
        set ufields to {"*accountname", "*sername", "*mail", "*ser", "*appleId", "*_login"}
        set pfields to {"*assword", "*asswd", "*pw", "*pass", "*ass", "*pwd"}
        tell application "Safari"
            set mySrc to document of front window
            set mySrc to source of mySrc
        end tell
        set wwwFields to do shell script "/bin/echo " & (quoted form of mySrc) & " | perl $'" & UnixPath & "/Contents/Resources/formfind.pl' | /usr/bin/grep Input | /usr/bin/egrep -ov '(HIDDEN|RADIO)' | /usr/bin/awk '{ print $2 }' | tr -d '\"' | /usr/bin/sed \"s/^id=//\" | /usr/bin/egrep -v '(sesskey|cookies|testcookies|search)'"
        set wwwFields to paragraphs of wwwFields
        repeat with elementid in wwwFields
            repeat with field in ufields
                try
                    set ufid to do shell script "/bin/echo " & elementid & " | /usr/bin/grep -o '\\<." & field & "\\>'"
                    exit repeat
                end try
            end repeat
            repeat with field in pfields
                try
                    set pfid to do shell script "/bin/echo " & elementid & " | /usr/bin/grep -o '\\<." & field & "\\>'"
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
        
        if safariRunning is false then error number 108
        
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
            set UnixPath to replace_chars(UnixPath, "\\", "\\\\")
            set UnixPath to replace_chars(UnixPath, "'", "\\'")
            set volumepath to POSIX path of ((path to current application as text) & "::")
            set volumepath to replace_chars(volumepath, "\\", "\\\\")
            set volumepath to replace_chars(volumepath, "'", "\\'")
            if volumepath does not contain "/Volumes/" then
                display dialog "SkeleKey Applet is not located on a USB Device!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
                quit
            end if
            set authinfobin to UnixPath & "Contents/Resources/.p.enc.bin"
            set webFile to UnixPath & "Contents/Resources/.webenabled"
            set authcred to decryptinfo(volumepath, authinfobin)
            set volumepath to volumepath & "/"
            expCheck(item 3 of authcred, volumepath, item 2 of (item 1 of authcred))
            execlimit_ext(item 2 of (item 1 of authcred), volumepath, item 4 of authcred)
            set osver to do shell script "/usr/bin/sw_vers -productVersion"
            #Regular Run
            if (item 5 of authcred) is "none" then
                checkadmin(item 1 of (item 1 of authcred), item 2 of authcred)
                assistiveaccess(item 1 of (item 1 of authcred), item 2 of authcred, osver)
                auth(item 1 of (item 1 of authcred), item 2 of authcred)
            #Web Only Run
            else if ((item 5 of authcred) is "WEBYES") and (osver contains "10.11") then
                try
                    do shell script "/bin/test -e $'" & webFile & "'"
                on error
                    error number 106
                end try
                web(item 1 of (item 1 of authcred), item 2 of authcred)
            else
                error number 107
            end if
        on error number errorNumber
            if errorNumber is 101 then
                display dialog "SkeleKey only authenticates users with admin privileges. Maybe the wrong password was entered?" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            else if errorNumber is 102 then
                display dialog "Failed to set accessibility permissions" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            else if errorNumber is 103 then
                display dialog "Error! No authentication window found! Is the prompt on the screen? Quitting..." with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            else if errorNumber is 104 then
                display dialog "Safari is not running! Please open Safari to use the SkeleKey Web Add-on!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            else if errorNumber is 105 then
                display dialog "User account is not on this computer!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            else if errorNumber is 106 then
                display dialog "This SkeleKey Applet does not have Website Support Enabled!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            else if errorNumber is 107 then
                display dialog "The SkeleKey Web add-on is only available on systems running at least 10.11!" with icon 0 buttons "Quit" with title "SkeleKey Applet" default button 1
            end if
            return
        end try
    end main
    
    on applicationWillFinishLaunching:aNotification
        set dependencies to {"/usr/bin/openssl", "/bin/ls", "/usr/sbin/diskutil", "/usr/bin/grep", "/usr/bin/awk", "/usr/bin/base64", "/usr/bin/sudo", "/bin/cp", "/bin/bash", "/bin/mv", "/sbin/md5", "/usr/bin/srm", "/usr/bin/defaults", "/bin/test", "/usr/bin/fold", "/usr/bin/paste", "/usr/bin/rev", "/usr/libexec/PlistBuddy", "/usr/bin/curl", "/usr/bin/shasum", "/usr/bin/tr", "/bin/date", "/bin/mkdir", "/usr/bin/open", "/usr/bin/touch", "/usr/bin/osascript"}
        set notInstalledString to ""
        set cmd_existance to do shell script "/usr/bin/command; printf $?"
        if cmd_existance is not "" then
            repeat with i in dependencies
                try
                    set status to do shell script "/usr/bin/command -v " & i
                on error
                    set notInstalledString to notInstalledString & i & "
"
                end try
            end repeat
            if notInstalledString is not "" then
                display dialog "The following required resources are not installed:
                
" & notInstalledString buttons "Quit" default button 1 with title "SkeleKey Manager" with icon 0
                quit
            end if
        else
            display dialog "The system file 'command' is misssing!"
            quit
        end if
        main()
        quit
    end applicationWillFinishLaunching:
    
    on applicationShouldTerminate:sender
        return current application's NSTerminateNow
    end applicationShouldTerminate:
    
end script