--
--  AppDelegate.applescript
--  SkeleKey-Client
--
--  Created by Mark Hedrick on 10/11/15.
--  Copyright (c) 2015 Mark Hedrick and Levi Muniz. All rights reserved.
--

script AppDelegate
    property parent : class "NSObject"
    property username : ""
    property passwd : ""
    
    -- IBOutlets
    property theWindow : missing value
    on replace_chars(this_text, search_string, replacement_string)
        set AppleScript's text item delimiters to the search_string
        set the item_list to every text item of this_text
        set AppleScript's text item delimiters to the replacement_string
        set this_text to the item_list as string
        set AppleScript's text item delimiters to ""
        return this_text
    end replace_chars
    
    on decryptinfo(volumepath, authinfobin)
        set epass to (do shell script "diskutil info \"" & volumepath & "\" | grep 'Volume UUID' | awk '{print $3}' | base64")
        set username to (do shell script "openssl enc -aes-256-cbc -d -in " & authinfobin & " -pass pass:" & epass & " | sed '1q;d'")
        set passwd to (do shell script "openssl enc -aes-256-cbc -d -in " & authinfobin & " -pass pass:" & epass & " | sed '2q;d'")
        set username to username
        set passwd to passwd
    end decryptinfo
    
    on assistiveaccess(username, passwd)
        do shell script "sw_vers -productVersion"
        if result is "10.11" then --check for OS version because TCC.db is different on elcap
            try
                do shell script "sudo sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','org.district70.sebs.SkeleKey-Client',0,1,1,NULL,NULL)\"" user name username password passwd with administrator privileges
                on error
                display alert "Failed to set accessibility permissions!"
                quit
            end try
            else --preform regular assistive services modification, hasent changed since prob. lion
            try
                do shell script "sudo sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','org.district70.sebs.SkeleKey-Client',0,1,1,NULL)\"" user name username password passwd with administrator privileges
                on error
                display alert "Failed to set accessibility permissions!"
                quit
            end try
        end if
    end assistiveaccess
    
    on checkadmin(username, passwd)
        try
            do shell script "sudo echo elevate" user name username password passwd with administrator privileges
            on error
            display alert "SkeleKey only authenticates users with admin privileges" buttons "Quit"
            quit
        end try
    end checkadmin
    
    on auth(username, passwd)
        try
            display dialog username & space & passwd
            tell application "System Events" to tell process "SecurityAgent"
            set value of text field 1 of window 1 to username
            set value of text field 2 of window 1 to passwd
            keystroke return
        end tell
        on error
            display alert "Error! Please try again! Now quitting...." buttons {"Ok", "Quit"}
            quit
        end try
    end auth
    
    on main()
        set UnixPath to POSIX path of (path to current application as text)
        set volumepath to UnixPath
        set UnixPath to replace_chars(UnixPath, "//", "/")
        set UnixPath to replace_chars(UnixPath, " ", "\\ ")
        set volumepath to POSIX path of ((path to current application as text) & "::")
        set authinfobin to UnixPath & "Contents/Resources/Files/.p.enc.bin"
        set volumepath to (do shell script "echo \"" & volumepath & "\" | awk -F '/' '{print $3}'")
        set volumepath to "/Volumes/" & volumepath
        decryptinfo(volumepath, authinfobin)
        checkadmin(username, passwd)
        assistiveaccess(username, passwd)
        auth(username, passwd)
        quit
    end main
    on applicationWillFinishLaunching:aNotification
        set dependencies to {"echo", "openssl", "ls", "diskutil", "grep", "awk", "base64", "sudo", "cp", "bash", "sed", "python"}
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