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
    property checkpass : "0"
    
    on destvolume:choosevolume
        set fileName2 to choose folder default location "/Volumes"
        set fileName2 to POSIX path of fileName2
        if fileName2 is not "" then
            username's setEditable_(true)
            password1's setEditable_(true)
            password2's setEditable_(true)
            fileName's setStringValue_(fileName2)
            fileName's setToolTip_(fileName2)
        end if
    end destvolume:
    
    on radioSelect_(sender)
        set modeString to sender's |title| as text
    end radioSelect:
    
    on buttonClicked_(sender)
        set username to "" & (stringValue() of username)
        set password1 to "" & (stringValue() of password1)
        set password2 to "" & (stringValue() of password2)
        if password1 does not equal password2 then
            display alert "Passwords do not match!"
        end if
        set uuid to do shell script "diskutil info \"" & fileName2 & "\" | grep 'Volume UUID' | awk '{print $3}' | base64"
        try
        do shell script "echo \"" & password2 & "\" | openssl enc -aes-256-cbc -e -out " & fileName2 & ".p.bin -pass pass:" & uuid
        display dialog "Sucessfully created SkeleKey at location: " & fileName2
        on error
        display dialog "Could not create SkeleKey at location: " & fileName2 with icon 0
        end try
    end buttonClicked_
    
    --Quit cocoa application when activated
    on quitbutton:quit_
        quit
    end quitbutton:
    
    on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script