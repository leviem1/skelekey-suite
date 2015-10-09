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
    
    on destvolume:choosevolume
        try
            set discoverVol to do shell script "ls /Volumes | grep -v 'Macintosh HD'"   #Implementation of old volume system
        on error
        display alert "No valid volume found! Please (re)insert the USB and try again!"
        return
        end try
            get paragraphs of discoverVol
            set fileName2 to choose from list discoverVol with title "Choose disk..."
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
        set fileName2 to missing value
        set discoverVol to missing value
        set username to missing value
        set password1 to missing value
        set password2 to missing value
    end housekeeping_
(*
    on radioSelect_(sender)
        set modeString to sender's |title| as text
    end radioSelect:
*)
    on buttonClicked_(sender)
        set usernameValue to "" & (stringValue() of username)
        set password1Value to "" & (stringValue() of password1)
        set password2Value to "" & (stringValue() of password2)
        if password1Value does not equal password2Value then
            display alert "Passwords do not match!"
            return
        end if
        set uuid to do shell script "diskutil info \"" & fileName2 & "\" | grep 'Volume UUID' | awk '{print $3}' | base64"
        try
        do shell script "echo \"" & usernameValue & "\n" & password2Value & "\" | openssl enc -aes-256-cbc -e -out " & fileName2 & ".p.bin -pass pass:" & uuid
        display dialog "Sucessfully created SkeleKey at location: " & fileName2 buttons "Continue"
        on error
        display dialog "Could not create SkeleKey at location: " & fileName2 with icon 0 buttons "Quit"
        end try
        housekeeping_()
    end buttonClicked_
    
    --Quit cocoa application when activated
    on quitbutton:quit_
        quit
    end quitbutton:
    
    on applicationWillFinishLaunching_(aNotification)
        try
            do shell script "sudo echo elevate" with administrator privileges   #attempt to gain admin before screen
        on error
            display alert "SkeleKey needs administrator privileges to run!" buttons "Quit"
            quit
        end try
    end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script