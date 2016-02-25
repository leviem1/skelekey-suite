--
--  AppDelegate.applescript
--  SkeleKey-Applet
--
--  Created by Mark Hedrick on 10/11/15.
--  Copyright (c) 2015 Mark Hedrick and Levi Muniz. All rights reserved.
--

script AppDelegate
    property parent : class "NSObject"
    
    on replace_chars(this_text, search_string, replacement_string)
        set AppleScript's text item delimiters to the search_string
        set the item_list to every text item of this_text
        set AppleScript's text item delimiters to the replacement_string
        set this_text to the item_list as string
        set AppleScript's text item delimiters to ""
        return this_text
    end replace_chars
    
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
        set uuid to do shell script "diskutil info " & volumepath & " | grep 'Volume UUID' | awk '{print $3}' | rev"
        set nums to returnNumbersInString(uuid)
        set algorithms to {zero, one, two, three, four, five, six, seven, eight, nine}
        repeat with char in nums
            set encstring to do shell script "echo \"" & uuid & "\" | " & (item (char + 1) of algorithms)
            set epass to epass & encstring
        end repeat
        set epass to do shell script "echo \"" & epass & "\" | fold -w160 | paste -sd'%' - | fold -w270 | paste -sd'@' - | fold -w51 | paste -sd'*' - | fold -w194 | paste -sd'~' - | fold -w64 | paste -sd'2' - | fold -w78 | paste -sd'^' - | fold -w38 | paste -sd')' - | fold -w28 | paste -sd'(' - | fold -w69 | paste -sd'=' -  | fold -w128 | paste -sd'$3bs' -  "
        if (length of epass) is greater than 2048 then
            set epass to (characters 1 thru 2047 of epass) as string
        end if
        set username to (do shell script "openssl enc -aes-256-cbc -d -in " & authinfobin & " -pass pass:\"" & epass & "\" | sed '1q;d'")
        set passwd to (do shell script "openssl enc -aes-256-cbc -d -in " & authinfobin & " -pass pass:\"" & epass & "\" | sed '2q;d'")
        try
            set exp_date_e to (do shell script "openssl enc -aes-256-cbc -d -in " & authinfobin & " -pass pass:\"" & epass & "\" | sed '3q;d'")
        end try
        return {username, passwd, exp_date_e}
    end decryptinfo
    
    on assistiveaccess(username, passwd)
        do shell script "sw_vers -productVersion"
        try
            if result contains "10.11" then
                do shell script "sudo sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','org.district70.sebs.SkeleKey-Applet',0,1,1,NULL,NULL)\"" user name username password passwd with administrator privileges
                else
                do shell script "sudo sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','org.district70.sebs.SkeleKey-Applet',0,1,1,NULL)\"" user name username password passwd with administrator privileges
            end if
            on error
            display dialog "Failed to set accessibility permissions" with icon 0 buttons "Quit" with title "SkeleKey-Applet" default button 1
            quit
        end try
    end assistiveaccess
    
    on checkadmin(username, passwd, exp_date_e)
        set current_date_e to do shell script "date -u '+%s'"
        if current_date_e is greater than or equal to exp_date_e then
            display dialog "This SkeleKey has expired!" with icon 0 buttons "Quit" with title "SkeleKey-Applet" default button 1
            quit
        end if
        try
            do shell script "sudo echo elevate" user name username password passwd with administrator privileges
            
            on error
            display dialog "SkeleKey only authenticates users with admin privileges. Maybe the wrong password was entered?" with icon 0 buttons "Quit" with title "SkeleKey-Applet" default button 1
            quit
        end try
    end checkadmin
    
    on auth(username, passwd)
        set localusers to paragraphs of (do shell script "dscl . list /Users | grep -v ^_.* | grep -v 'daemon' | grep -v 'Guest' | grep -v 'nobody'") as list
        if username is not in localusers then
            display dialog "User account is not on this computer!" with icon 0 buttons "Quit" with title "SkeleKey-Applet" default button 1
            else
            try
                tell application "System Events" to tell process "SecurityAgent"
                set value of text field 1 of window 1 to username
                set value of text field 2 of window 1 to passwd
                click button 2 of window 1
            end tell
            on error
            display dialog "Error! No authentication window found! Is the prompt on the screen? Quitting...." with icon 0 buttons "Quit" with title "SkeleKey-Applet" default button 1
            quit
        end try
    end if
end auth

on main()
    set UnixPath to POSIX path of (path to current application as text)
    set volumepath to UnixPath
    set UnixPath to replace_chars(UnixPath, "//", "/")
    set UnixPath to replace_chars(UnixPath, " ", "\\ ")
    set volumepath to POSIX path of ((path to current application as text) & "::")
    set authinfobin to UnixPath & "Contents/Resources/.p.enc.bin"
    set volumepath to (do shell script "echo \"" & volumepath & "\" | awk -F '/' '{print $3}'")
    set volumepath to "/Volumes/" & volumepath
    set volumepath to replace_chars(volumepath, " ", "\\ ")
    set authcred to decryptinfo(volumepath, authinfobin)
    checkadmin(item 1 of authcred, item 2 of authcred, item 3 of authcred)
    assistiveaccess(item 1 of authcred, item 2 of authcred)
    auth(item 1 of authcred, item 2 of authcred)
    quit
end main

on applicationWillFinishLaunching:aNotification
    set dependencies to {"echo", "openssl", "ls", "diskutil", "grep", "awk", "base64", "sudo", "cp", "bash", "sed", "python", "sqlite3", "md5", "rev", "fold", "paste", "sw_vers", "grep", "dscl"}
    set notInstalledString to ""
    repeat with i in dependencies
        set status to do shell script i & "; echo $?"
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
    -- Insert code here to do any housekeeping before your application quits
    return current application's NSTerminateNow
end applicationShouldTerminate:

end script