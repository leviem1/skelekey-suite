--
--  AppDelegate.applescript
--  SkeleKey-Client
--
--  Created by Mark Hedrick on 10/11/15.
--  Copyright (c) 2015 Mark Hedrick and Levi Muniz. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
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
    set UnixPath to POSIX path of (path to me as text)
    set UnixPath to replace_chars(UnixPath, "//", "/")
    set UnixPath to replace_chars(UnixPath, " ", "\\ ")
    set volumepath to POSIX path of ((path to me as text) & "::")
    set authinfobin to UnixPath & "Contents/Resources/Files/.p.bin"
    set tccutil to UnixPath & "Contents/Resources/Files/tccutil.py"

    on decryptinfo:decbin
        set epass to (do shell script "diskutil info \"" & volumepath & "\" | grep 'Volume UUID' | awk '{print $3}' | base64")
        set decusername to (do shell script "openssl enc -aes-256-cbc -d -in " & authinfobin & " -pass pass:" & epass & " | sed '1q;d'")
        set decpasswd to (do shell script "openssl enc -aes-256-cbc -d -in " & authinfobin & " -pass pass:" & epass & " | sed '2q;d'")
    end decryptinfo:
    
    on assistiveaccess:tccutil
        try
            set assacc to do shell script "chmod +x " & tccutil & " ; sudo " & tccutil & " -i org.district70.sebs.SkeleKey-Client" user name decusername password decpasswd with administrator privileges
            on error
            display alert "Failed to set assistive access permissions!" with title "SkeleKey"
            quit
        end try
    end assistiveaccess:
        
    
    on auth:main
        try
            tell application "System Events" to tell process "SecurityAgent"
            set value of text field 1 of window 1 to decusername
            set value of text field 2 of window 1 to decpasswd
            keystroke return
        end tell
        on error
            display alert "Error! Please try again! Now quitting...." buttons {"Ok", "Quit"} with title "SkeleKey"
            quit
        end try
    end auth:
    
	on applicationWillFinishLaunching_(aNotification)
        set dependencies to {"echo", "openssl", "ls", "diskutil", "grep", "awk", "base64", "sudo", "cp", "bash", "sed", "python"}
        set notInstalledString to ""
        repeat with i in dependencies
            set status to do shell script i & "; echo $?"
            if status is "127" then
                set notInstalledString to notInstalledString & i & "\n"
            end if
        end repeat
        if notInstalledString is not "" then
            display alert "The following required items are not installed:\n\n" & notInstalledString buttons "Quit"
            quit
        end if
    end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script