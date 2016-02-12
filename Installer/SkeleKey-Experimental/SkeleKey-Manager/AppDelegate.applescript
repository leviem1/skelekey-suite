--
--  AppDelegate.applescript
--  SkeleKey-Manager
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
    property acknowledgements : missing value
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
    property fromStart : true
    property theDate : missing value
    property theTime : missing value
    property displayDate : missing value
    property dateEnabled : missing value
    
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
    
    on dateChecked_(sender)
        log dateEnabled's state()
        if (dateEnabled's state()) is 0 then
            theDate's setEnabled:false
            theDate's setHidden:false
            else if (dateEnabled's state()) is 1 then
            theDate's setEnabled:true
            theDate's setHidden:true
        end if
    end dateChecked_
    
    on displayData_(sender)
        global lastOpenedDate_str
        set lastOpenedDate to theDate's dateValue()
        set myFormatter to current application's class "NSDateFormatter"'s alloc()'s init()
        displayDate's setStringValue_(lastOpenedDate)
        #set lastOpenedDate_str to myFormatter's stringFromDate_(lastOpenedDate)
        log lastOpenedDate
        set lastOpenedDate_str to do shell script "echo '" & lastOpenedDate_str & "' | sed \"s/.....$//g\""
        log lastOpenedDate_str
    end displayData_
    
    on windowMath(window1, window2) --Thanks to Holly Lakin for helping us with the math of this function
        set origin to origin of window1's frame()
        set windowSize to |size| of window1's frame()
        set x to x of origin
        set y to y of origin
        set yAdd to height of windowSize
        set y to y + yAdd
        window2's setFrameTopLeftPoint:{x, y}
    end windowMath
    
    on radioOption:sender --get mode
        set modeString to sender's title as text
    end radioOption:
    
    on controlTextDidChange:aNotification --check if both passwords are equal
        set password1String to (stringValue() of password1) as string
        set password2String to (stringValue() of password2) as string
        if password1String is equal to password2String then
            checkIcon's setImage:(NSImage's imageNamed:"NSStatusAvailable")
            installButton's setEnabled:true
            else if password1String is not equal to password2String then
            checkIcon's setImage:(NSImage's imageNamed:"NSStatusUnavailable")
            installButton's setEnabled:false
        end if
    end controlTextDidChange:
    
    on buttonClicked:sender -- "Start!" button
        if modeString is "Install a SkeleKey" then
            mainWindow's orderOut:sender
            installWindow's makeKeyAndOrderFront:me
            installWindow's makeFirstResponder:username
            windowMath(mainWindow, installWindow)
            else if modeString is "Remove a SkeleKey" then
            mainWindow's orderOut:sender
            removeWindow's makeKeyAndOrderFront:me
            windowMath(mainWindow, removeWindow)
        end if
    end buttonClicked:
    
    on acknowledgements:sender
        acknowledgements's makeKeyAndOrderFront:me
    end acknowledgements:
    
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
            set fileName2 to choose from list validVols with title "SkeleKey-Manager" with prompt "Please choose a destination:"
            set fileName2 to "/Volumes/" & (fileName2 as text) & "/"
            set fileName3 to replace_chars(fileName2, "\\ ", " ")
            on error
            display alert "No valid destination found! Please (re)insert the USB and try again!"
            return
        end try
        if fileName2 is not "/Volumes/False/" then
            startButton's setEnabled:true
            fileName's setStringValue:fileName2
            fileName's setToolTip:fileName2
            else
            startButton's setEnabled:false
            fileName's setStringValue:""
            fileName's setToolTip:""
        end if
    end destvolume:
    
    on installButton:sender --install button action
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
        
        if usernameValue is "" then
            display dialog "Please enter a username!" with icon 0 buttons "Okay" with title "SkeleKey-Manager" default button 1
            return
        end if
        
        if password1Value is not equal to password2Value then
            display alert "Passwords do not match!"
            password1's setStringValue:""
            password2's setStringValue:""
            return
        end if
        try
            do shell script "cp -R " & UnixPath & "/Contents/Resources/SkeleKey-Applet.app " & fileName2
            set uuid to do shell script "diskutil info " & fileName2 & " | grep 'Volume UUID' | awk '{print $3}' | rev"
            set nums to returnNumbersInString(uuid)
            repeat with char in nums
                set encstring to do shell script "echo \"" & uuid & "\" | " & (item (char + 1) of algorithms)
                set epass to epass & encstring
            end repeat
            
            set epass to do shell script "echo \"" & epass & "\" | fold -w160 | paste -sd'%' - | fold -w270 | paste -sd'@' - | fold -w51 | paste -sd'*' - | fold -w194 | paste -sd'~' - | fold -w64 | paste -sd'2' - | fold -w78 | paste -sd'^' - | fold -w38 | paste -sd')' - | fold -w28 | paste -sd'(' - | fold -w69 | paste -sd'=' -  | fold -w128 | paste -sd'$3bs' -  "
            if (length of epass) is greater than 2048 then
                set epass to (characters 1 thru 2047 of epass) as string
            end if
            do shell script "echo \"" & usernameValue & "\n" & password2Value & "\" | openssl enc -aes-256-cbc -e -out " & fileName2 & "SkeleKey-Applet.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass & "\""
            try
                set theNumber to 1
                do shell script "test -e " & fileName2 & usernameValue & "-SkeleKey-Applet.app"
                repeat
                    try
                        set theNumber to theNumber + 1
                        do shell script "test -e " & fileName2 & usernameValue & "\\ " & theNumber & "-SkeleKey-Applet.app"
                        on error
                        do shell script "mv -f " & fileName2 & "SkeleKey-Applet.app " & fileName2 & usernameValue & "\\ " & theNumber & "-SkeleKey-Applet.app"
                        exit repeat
                    end try
                end repeat
                on error
                do shell script "mv -f " & fileName2 & "SkeleKey-Applet.app " & fileName2 & usernameValue & "-SkeleKey-Applet.app"
            end try
            
            display dialog "Sucessfully created SkeleKey at location:
            " & fileName2 buttons "Continue" with title "SkeleKey-Manager" default button 1
            on error
            display dialog "Could not create SkeleKey at location: " & fileName2 with icon 0 buttons "Okay" with title "SkeleKey-Manager" default button 1
        end try
        housekeeping_(sender)
        houseKeepingInstall_(sender)
        installWindow's orderOut:sender
        mainWindow's makeKeyAndOrderFront:me
        windowMath(installWindow, mainWindow)
    end installButton:
    
    on destApp:sender --choose app to remove
        global delApp
        global fileName3
        try
            set delApp to choose file of type "com.apple.application-bundle" default location fileName3
            set delApp to POSIX path of delApp
            set delApp to replace_chars(delApp, " ", "\\ ")
            delFileName's setStringValue:delApp
            delFileName's setToolTip:delApp
            delButton's setEnabled:true
            on error
            delFileName's setStringValue:""
            delFileName's setToolTip:""
            delButton's setEnabled:false
        end try
    end destApp:
    
    on delButton:sender --remove button action
        global delApp
        removeWindow's orderOut:sender
        loadingWindow's makeKeyAndOrderFront:me
        windowMath(removeWindow, loadingWindow)
        quitItem's setEnabled:false
        set isBusy to true
        try
            delay 0.1
            do shell script "srm -rf " & delApp
            display dialog "Sucessfully securely removed app at location:
            " & delApp buttons "Continue" with title "SkeleKey-Manager" default button 1
            on error
            display dialog "Could not securely remove app at location: " & delApp with icon 0 buttons "Okay" with title "SkeleKey-Manager" default button 1
        end try
        set isBusy to false
        quitItem's setEnabled:true
        housekeeping_(sender)
        finishedDel_(sender)
    end delButton:
    
    on gotit:sender --tutorialScreen button action
        if (dontShow's state()) is 1 then
            try
                do shell script "defaults write ~/Library/Preferences/org.district70.sebs.SkeleKey-Manager.plist dontShow -bool true"
            end try
            else if (dontShow's state()) is 0 then
            try
                do shell script "defaults write ~/Library/Preferences/org.district70.sebs.SkeleKey-Manager.plist dontShow -bool false"
            end try
        end if
        tutorialWindow's orderOut:sender
    end gotit:
    
    on welcomeNext:sender
        welcomeWindow's orderOut:sender
        if fromStart is true then
            tutorialWindow's makeKeyAndOrderFront:me
            windowMath(welcomeWindow, tutorialWindow)
        end if
    end welcomeNext:
    
    on housekeeping:sender --remove main window's info
        global fileName2
        fileName's setStringValue:""
        fileName's setToolTip:""
        startButton's setEnabled:false
        set fileName2 to ""
    end housekeeping:
    
    on houseKeepingInstall:sender --remove install window's info
        username's setStringValue:""
        password1's setStringValue:""
        password2's setStringValue:""
        set usernameValue to ""
        set password1Value to ""
        set password2Value to ""
        installWindow's orderOut:sender
        mainWindow's makeKeyAndOrderFront:me
        windowMath(installWindow, mainWindow)
    end houseKeepingInstall:
    
    on cancelDel:sender --when removal is canceled
        houseKeepingDel_()
        removeWindow's orderOut:sender
        mainWindow's makeKeyAndOrderFront:me
        windowMath(removeWindow, mainWindow)
    end cancelDel:
    
    on finishedDel:sender --when removal has finished
        houseKeepingDel_()
        loadingWindow's orderOut:sender
        mainWindow's makeKeyAndOrderFront:me
        windowMath(loadingWindow, mainWindow)
    end finishedDel:
    
    on houseKeepingDel_() --remove del window's info
        global delApp
        delFileName's setStringValue:""
        delFileName's setToolTip:""
        delButton's setEnabled:false
        set delApp to ""
    end houseKeepingDel_
    
    on doOpenTutorial:sender
        tutorialWindow's makeKeyAndOrderFront:me
    end doOpenTutorial:
    
    on doOpenWelcome:sender
        welcomeWindow's makeKeyAndOrderFront:me
        set fromStart to false
    end doOpenWelcome:
    
    on applicationWillFinishLaunching:aNotification --dependency and admin checking
        set currDate to current date
        log currDate
        theDate's setDateValue_(currDate)
        theDate's setMinDate_(currDate)
        set dependencies to {"echo", "openssl", "ls", "diskutil", "grep", "awk", "base64", "sudo", "cp", "bash", "mv", "rm", "base64", "md5", "srm", "defaults", "test", "fold", "paste"}
        set notInstalledString to ""
        
        try
            do shell script "sudo echo elevate" with administrator privileges
            on error
            display dialog "SkeleKey needs administrator privileges to run!" buttons "Quit" default button 1 with title "SkeleKey-Manager" with icon 0
            quit
        end try
        
        repeat with i in dependencies
            set status to do shell script i & "; echo $?"
            if status is "127" then
                set notInstalledString to notInstalledString & i & "
                "
            end if
        end repeat
        
        if notInstalledString is not "" then
            display alert "The following required resources are not installed:
            
            " & notInstalledString buttons "Quit"
            quit
        end if
        
        try
            set dontShowValue to do shell script "defaults read ~/Library/Preferences/org.district70.sebs.SkeleKey-Manager.plist dontShow"
            on error
            set dontShowValue to "0"
        end try
        
        try
            set hasWelcomed to do shell script "defaults read ~/Library/Preferences/org.district70.sebs.SkeleKey-Manager.plist hasWelcomed"
            on error
            do shell script "defaults write ~/Library/Preferences/org.district70.sebs.SkeleKey-Manager.plist hasWelcomed -bool true"
            set hasWelcomed to "0"
        end try
        
        if hasWelcomed is "0" then
            welcomeWindow's makeKeyAndOrderFront:me
            else
            if dontShowValue is "0" then
                tutorialWindow's makeKeyAndOrderFront:me
            end if
        end if
    end applicationWillFinishLaunching:
    
    on applicationShouldTerminate:sender
        if isBusy is true then
            return NSTerminateCancel
        end if
        
        return current application's NSTerminateNow
    end applicationShouldTerminate:
    
    on applicationShouldTerminateAfterLastWindowClosed:sender
        return true
    end applicationShouldTerminateAfterLastWindowClosed:
end script