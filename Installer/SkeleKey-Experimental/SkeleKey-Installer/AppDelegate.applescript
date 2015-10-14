--
--  AppDelegate.applescript
--  SkeleKey-Installer
--
--  Created by Mark Hedrick on 9/29/15.
--  Copyright (c) 2015 Mark Hedrick and Levi Muniz. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	-- IBOutlets
	property theWindow : missing value
    property username : missing value
    property password1 : missing value
    property password2 : missing value
    property fileName : missing value
    property fileName2 : missing value
    property modeNumber : missing value
    property startButton : missing value
    property checkpass : "0"

    on replace_chars(this_text, search_string, replacement_string)
        set AppleScript's text item delimiters to the search_string
        set the item_list to every text item of this_text
        set AppleScript's text item delimiters to the replacement_string
        set this_text to the item_list as string
        set AppleScript's text item delimiters to ""
        return this_text
    end replace_chars

    on destvolume:choosevolume
        try
            set discoverVol to do shell script "ls /Volumes | grep -v 'Macintosh HD'"
        on error
            display alert "No valid destination found! Please (re)insert the USB and try again!"
            return
        end try
            set discoverVol to get paragraphs of discoverVol
            set fileName2 to choose from list discoverVol with title "SkeleKey-Installer" with prompt "Please choose a destination:"
            set fileName2 to "/Volumes/" & (fileName2 as text) & "/"
        if fileName2 is not "/Volumes/False/" then
            username's setEditable_(true)
            password1's setEditable_(true)
            password2's setEditable_(true)
            fileName's setStringValue_(fileName2)
            fileName's setToolTip_(fileName2)
            startButton's setEnabled_(true)
        end if
    end destvolume:
    
    on housekeeping_()
        username's setEditable_(false)
        username's setStringValue_("")
        password1's setEditable_(false)
        password1's setStringValue_("")
        password2's setEditable_(false)
        password2's setStringValue_("")
        fileName's setStringValue_("")
        fileName's setToolTip_("")
        startButton's setEnabled_(false)
        set fileName2 to ""
        set discoverVol to ""
        set usernameValue to ""
        set password1Value to ""
        set password2Value to ""
    end housekeeping_

    on buttonClicked_(sender)
        set UnixPath to POSIX path of (path to current application as text)
        set usernameValue to "" & (stringValue() of username)
        set password1Value to "" & (stringValue() of password1)
        set password2Value to "" & (stringValue() of password2)
        set usernameValue to replace_chars(usernameValue, "`", "\\`")
        set usernameValue to replace_chars(usernameValue, "\"", "\\\"")
        set password1Value to replace_chars(password1Value, "`", "\\`")
        set password1Value to replace_chars(password1Value, "\"", "\\\"")
        set password2Value to replace_chars(password2Value, "`", "\\`")
        set password2Value to replace_chars(password2Value, "\"", "\\\"")
        
        if usernameValue is "" then
            display dialog "Please enter username!" with icon 0 buttons "Okay" with title "SkeleKey-Installer" default button 1
            return
        end if
        
        if password1Value does not equal password2Value then
            display alert "Passwords do not match!"
            password1's setStringValue_("")
            password2's setStringValue_("")
            return
        end if
        
        do shell script "cp -R " & UnixPath & "/Contents/Resources/Files/SkeleKey-Client.app " & FileName2
        set uuid to do shell script "diskutil info \"" & fileName2 & "\" | grep 'Volume UUID' | awk '{print $3}'"
        set epass to uuid & (do shell script "echo " & uuid & " | base64") & (do shell script "uname | md5")
        
        try
            do shell script "echo \"" & usernameValue & "\n" & password2Value & "\" | openssl enc -aes-256-cbc -e -out " & fileName2 & "SkeleKey-Client.app/Contents/Resources/Files/.p.enc.bin -pass pass:" & epass
            display dialog "Sucessfully created SkeleKey at location: \n" & fileName2 buttons "Continue" with title "SkeleKey-Installer" default button 1
        on error
            display dialog "Could not create SkeleKey at location: " & fileName2 with icon 0 buttons "Okay" with title "SkeleKey-Installer" default button 1
        end try
        housekeeping_()
    end buttonClicked_
    
    --Quit cocoa application when activated
    on quitbutton:quit_
        quit
    end quitbutton:
    
    on applicationWillFinishLaunching_(aNotification)
        set dependencies to {"echo", "openssl", "ls", "diskutil", "grep", "awk", "base64", "sudo", "cp", "bash"}
        set notInstalledString to ""
        try
            do shell script "sudo echo elevate" with administrator privileges
        on error
            display dialog "SkeleKey needs administrator privileges to run!" buttons "Quit" default button 1 with title "SkeleKey-Installer" with icon 0
            quit
        end try
        
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
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
	--latest
end script