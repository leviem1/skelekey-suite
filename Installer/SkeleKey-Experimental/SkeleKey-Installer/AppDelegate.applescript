--
--  AppDelegate.applescript
--  SkeleKey-Installer
--
--  Created by Mark Hedrick on 9/29/15.
--  Copyright (c) 2015 Mark Hedrick and Levi Muniz. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
    property NSImage : class "NSImage"
	-- IBOutlets
    property mainWindow : missing value
	property installWindow : missing value
    property removeWindow : missing value
    property loadingWindow : missing value
    property welcomeWindow : missing value
    property tutorialWindow : missing value
    property checkIcon : missing value
    property dontShow : missing value
    property quitItem : missing value
    property username : missing value
    property password1 : missing value
    property password2 : missing value
    property fileName : missing value
    property delFileName : missing value
    property startButton : missing value
    property installButton : missing value
    property delButton : missing value
    property modeString : "Install a SkeleKey"
    property isBusy : false
    
    on replace_chars(this_text, search_string, replacement_string)
        set AppleScript's text item delimiters to the search_string
        set the item_list to every text item of this_text
        set AppleScript's text item delimiters to the replacement_string
        set this_text to the item_list as string
        set AppleScript's text item delimiters to ""
        return this_text
    end replace_chars
    
    on windowMath(window1, window2) --Thanks to Holly Lakin for helping us with the math of this function
        set origin to origin of window1's frame()
        set windowSize to |size| of window1's frame()
        set x to x of origin
        set y to y of origin
        set yAdd to height of windowSize
        set y to y + yAdd
        window2's setFrameTopLeftPoint_({x,y})
    end windowMath
    
    on radioOption_(sender) --get mode
        set modeString to sender's title as text
    end radioOption_
    
    on controlTextDidChange_(aNotification) --check if both passwords are equal
        set password1String to (stringValue() of password1) as string
        set password2String to (stringValue() of password2) as string
        if password1String equals password2String then
            checkIcon's setImage_(NSImage's imageNamed_("NSStatusAvailable"))
            installButton's setEnabled_(true)
        else if password1String does not equal password2String then
            checkIcon's setImage_(NSImage's imageNamed_("NSStatusUnavailable"))
            installButton's setEnabled_(false)
        end if
    end controlTextDidChange_
    
    on buttonClicked_(sender) -- "Start!" button
        if modeString is "Install a SkeleKey" then
            mainWindow's orderOut_(sender)
            installWindow's makeKeyAndOrderFront_(me)
            installWindow's makeFirstResponder_(username)
            windowMath(mainWindow, installWindow)
        else if modeString is "Remove a SkeleKey" then
            mainWindow's orderOut_(sender)
            removeWindow's makeKeyAndOrderFront_(me)
            windowMath(mainWindow, removeWindow)
        end if
    end buttonClicked_

    on destvolume:choosevolume --choose volume to install
        global fileName2
        global fileName3
        set validVols to {}
        try
            set discoverVol to do shell script "ls /Volumes | grep -v 'Macintosh HD'"
            set discoverVol to get paragraphs of discoverVol
            repeat with vol in discoverVol
                set vol to replace_chars(vol, " ", "\\ ")
                try
                    set isValid to do shell script "diskutil info /Volumes/" & vol & " | grep \"Protocol\" | awk '{print $2}'"
                on error
                    set isValid to "False"
                end try
                if isValid is "USB" then
                    set validVols to validVols & {vol}
                end if
            end repeat
            set fileName2 to choose from list validVols with title "SkeleKey-Installer" with prompt "Please choose a destination:"
            set fileName2 to "/Volumes/" & (fileName2 as text) & "/"
            set fileName3 to replace_chars(fileName2, "\\ ", " ")
        on error
            display alert "No valid destination found! Please (re)insert the USB and try again!"
            return
        end try
        if fileName2 is not "/Volumes/False/" then
            startButton's setEnabled_(true)
            fileName's setStringValue_(fileName2)
            fileName's setToolTip_(fileName2)
        else
            startButton's setEnabled_(false)
            fileName's setStringValue_("")
            fileName's setToolTip_("")
        end if
    end destvolume:
    
    on installButton_(sender) --install button action
        global fileName2
        global password1Value
        global password2Value
        set UnixPath to POSIX path of (path to current application as text)
        set UnixPath to replace_chars(UnixPath, " ", "\\ ")
        set usernameValue to "" & (stringValue() of username)
        set password1Value to "" & (stringValue() of password1)
        set password2Value to "" & (stringValue() of password2)
        set usernameValue to replace_chars(usernameValue, "`", "\\`")
        set usernameValue to replace_chars(usernameValue, "\"", "\\\"")
        set password1Value to replace_chars(password1Value, "`", "\\`")
        set password1Value to replace_chars(password1Value, "\"", "\\\"")
        set password1Value to replace_chars(password2Value, "$", "\\$")
        set password2Value to replace_chars(password2Value, "`", "\\`")
        set password2Value to replace_chars(password2Value, "\"", "\\\"")
        set password2Value to replace_chars(password2Value, "$", "\\$")
        
        if usernameValue is "" then
            display dialog "Please enter a username!" with icon 0 buttons "Okay" with title "SkeleKey-Installer" default button 1
            return
        end if
        
        if password1Value does not equal password2Value then
            display alert "Passwords do not match!"
            password1's setStringValue_("")
            password2's setStringValue_("")
            return
        end if
        try
            do shell script "cp -R " & UnixPath & "/Contents/Resources/SkeleKey-Client.app " & fileName2
            set uuid to do shell script "diskutil info " & fileName2 & " | grep 'Volume UUID' | awk '{print $3}' | rev"
            set epass to uuid & (do shell script "echo " & uuid & " | base64") & (do shell script "echo 'S3bs!*?' | md5 | md5")
            do shell script "echo \"" & usernameValue & "\n" & password2Value & "\" | openssl enc -aes-256-cbc -e -out " & fileName2 & "SkeleKey-Client.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass & "\""
            do shell script "mv -f " & fileName2 & "SkeleKey-Client.app " & fileName2 & usernameValue & "-SkeleKey-Client.app"
            display dialog "Sucessfully created SkeleKey at location: \n" & fileName2 buttons "Continue" with title "SkeleKey-Installer" default button 1
        on error
            display dialog "Could not create SkeleKey at location: " & fileName2 with icon 0 buttons "Okay" with title "SkeleKey-Installer" default button 1
        end try
        housekeeping_(sender)
        houseKeepingInstall_(sender)
        installWindow's orderOut_(sender)
        mainWindow's makeKeyAndOrderFront_(me)
        windowMath(installWindow, mainWindow)
    end installButton_
    
    on destApp_(sender) --choose app to remove
        global delApp
        global fileName3
        try
            set delApp to choose file of type "com.apple.application-bundle" default location fileName3
            set delApp to POSIX path of delApp
            set delApp to replace_chars(delApp, " ", "\\ ")
            delFileName's setStringValue_(delApp)
            delFileName's setToolTip_(delApp)
            delButton's setEnabled_(true)
        on error
            delFileName's setStringValue_("")
            delFileName's setToolTip_("")
            delButton's setEnabled_(false)
        end try
    end destApp_
    
    on delButton_(sender) --remove button action
        global delApp
        removeWindow's orderOut_(sender)
        loadingWindow's makeKeyAndOrderFront_(me)
        windowMath(removeWindow, loadingWindow)
        quitItem's setEnabled_(false)
        set isBusy to true
        try
            delay .1
            do shell script "srm -rf " & delApp
            display dialog "Sucessfully securely removed app at location: \n" & delApp buttons "Continue" with title "SkeleKey-Installer" default button 1
        on error
            display dialog "Could not securely remove app at location: " & delApp with icon 0 buttons "Okay" with title "SkeleKey-Installer" default button 1
        end try
        set isBusy to false
        quitItem's setEnabled_(true)
        housekeeping_(sender)
        finishedDel_(sender)
    end delButton_
    
    on gotit_(sender) --welcomescreen button action
        if (dontShow's state()) is 1 then
            try
                do shell script "defaults write ~/Library/Preferences/org.district70.sebs.SkeleKey-Installer.plist dontShow -bool true"
            end try
        else if (dontShow's state()) is 0 then
            try
                do shell script "defaults write ~/Library/Preferences/org.district70.sebs.SkeleKey-Installer.plist dontShow -bool false"
            end try
        end if
        welcomeWindow's orderOut_(sender)
    end gotit_
    
    on tutorialnext_(sender)
        windowMath(tutorialWindow, welcomeWindow)
    end tutorialnext_
            
    on housekeeping_(sender) --remove main window's info
        global fileName2
        fileName's setStringValue_("")
        fileName's setToolTip_("")
        startButton's setEnabled_(false)
        set fileName2 to ""
    end housekeeping_
    
    on houseKeepingInstall_(sender) --remove install window's info
        username's setStringValue_("")
        password1's setStringValue_("")
        password2's setStringValue_("")
        set usernameValue to ""
        set password1Value to ""
        set password2Value to ""
        installWindow's orderOut_(sender)
        mainWindow's makeKeyAndOrderFront_(me)
        windowMath(installWindow, mainWindow)
    end houseKeepingInstall_
    
    on cancelDel_(sender) --when removal is canceled
        houseKeepingDel_()
        removeWindow's orderOut_(sender)
        mainWindow's makeKeyAndOrderFront_(me)
        windowMath(removeWindow, mainWindow)
    end cancelDel_
    
    on finishedDel_(sender) --when removal has finished
        houseKeepingDel_()
        loadingWindow's orderOut_(sender)
        mainWindow's makeKeyAndOrderFront_(me)
        windowMath(loadingWindow, mainWindow)
    end finishedDel_
    
    on houseKeepingDel_() --remove del window's info
        global delApp
        delFileName's setStringValue_("")
        delFileName's setToolTip_("")
        delButton's setEnabled_(false)
        set delApp to ""
    end houseKeepingDel_
    
    on doOpenWelcome_(sender)
        welcomeWindow's makeKeyAndOrderFront_(me)
    end doOpenWelcome_
    
    on applicationWillFinishLaunching_(aNotification) --dependency and admin checking
        set dependencies to {"echo", "openssl", "ls", "diskutil", "grep", "awk", "base64", "sudo", "cp", "bash", "mv", "rm", "base64", "md5", "srm", "defaults"}
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
            display alert "The following required resources are not installed:\n\n" & notInstalledString buttons "Quit"
            quit
        end if
        
        try
            set dontShowValue to do shell script "defaults read ~/Library/Preferences/org.district70.sebs.SkeleKey-Installer.plist dontShow"
        on error
            set dontShowValue to "0"
        end try
        if hasWelcomed is "0"
            welcomeWindow's makeKeyAndOrderFront_(me)
            if dontShowValue is "0" then
                welcomeWindow's makeKeyAndOrderFront_(me)
            end if
        end if
    end applicationWillFinishLaunching_
    
    on applicationDidFinishLaunching_(aNotification)
        try
            set hasWelcomed to do shell script "defaults read ~/Library/Preferences/org.district70.sebs.SkeleKey-Installer.plist hasWelcomed"
        on error
            do shell script "defaults write ~/Library/Preferences/org.district70.sebs.SkeleKey-Installer.plist hasWelcomed -bool true"
            set hasWelcomed to "0"
        end try
    end applicationDidFinishLaunching_
	
	on applicationShouldTerminate_(sender)
        
        if isBusy is true then
            return NSTerminateCancel
        end if
        
        return current application's NSTerminateNow
	end applicationShouldTerminate_
    
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
end script