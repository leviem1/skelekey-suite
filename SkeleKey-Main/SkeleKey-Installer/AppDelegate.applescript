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
    property checkpass : "0"
    
    on destvolume:cmd
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
    
    on buttonClicked_(sender)
        set username to "" & (stringValue() of username)
        set password1 to "" & (stringValue() of password1)
        set password2 to "" & (stringValue() of password2)
        if password1 does not equal password2 then
            display alert "Passwords do not match!"
        end if
    end buttonClicked_
    
    on checkinfo:a
        display dialog "Username: " & username & "\nPassword1: " & password1 & "\nPassword2: " & password2 & "\nFile: " & fileName & "\nEditable: " & editable
    end checkinfo:
    
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