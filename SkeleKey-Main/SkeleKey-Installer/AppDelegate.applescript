--
--  AppDelegate.applescript
--  SkeleKey-Installer
--
--  Created by Mark Hedrick on 9/29/15.
--  Copyright (c) 2015 Mark Hedrick. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	-- IBOutlets
	property theWindow : missing value
    property username : missing value
    property password1 : missing value
    property password2 : missing value
    property fileName : "Select volume..."
    
    on destvolume:cmd
        set fileName to choose folder default location "/Volumes"
        set fileName to POSIX path of fileName
        return fileName
    end destvolume:
    
    on buttonClicked_(sender)
        set username to "" & (stringValue() of username)
        set password1 to "" & (stringValue() of password1)
        set password2 to "" & (stringValue() of password2)
        
    end buttonClicked_
    
    on checkinfo:a
        display dialog "Username: " & username & "\nPassword1: " & password1 & "\nPassword2: " & password2 & "\nFile: " & fileName
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