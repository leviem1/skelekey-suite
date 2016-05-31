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
	property NSDate : class "NSDate"
	property NSDateFormatter : class "NSDateFormatter"
	-- IBOutlets
	property mainWindow : missing value
	property installWindow : missing value
	property removeWindow : missing value
	property loadingWindow : missing value
	property welcomeWindow : missing value
	property registrationWindow : missing value
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
	property backButton : missing value
	property registrationButton : missing value
	property delButton : missing value
	property theDate : missing value
	property theDateID : missing value
	property dateEnabled : missing value
	property loginEnabled : missing value
	property limitEnabled : missing value
	property regFirstName : missing value
	property stateInformerDate : missing value
	property stateInformerLogin : missing value
	property stateInformerLimit : missing value
	property regEmail : missing value
	property regOrg : missing value
	property regSerial : missing value
	property stepperTF : missing value
	property stepper : missing value
	property loginComponentInstaller : missing value
	property loginComponentInfo2 : missing value
	property execlimitDesc : missing value
	property webPushBtn : missing value
	property webStatus : missing value
	property isBusy : false
	property fromStart : true
	property loginFile : false
	property webFile : false
	property modeString : "Create a SkeleKey"
	property exp_date_e : ""
	property webState : ""
	property execlimit : ""
	property oldExec : 1
	
	property beta_mode : true
	
	################
	#  ESSENTIALS  #
	################
	
	#Window Math Function (Thanks to Aaron Duran and Holly Lakin for helping us with the math in this function)
	on windowMath(window1, window2)
		set origin to origin of window1's frame()
		set windowSize to |size| of window1's frame()
		set windowSize2 to |size| of window2's frame()
		set x to x of origin
		set y to y of origin
		set y to y + (height of windowSize) / 2
		set y to y + (height of windowSize2) / 2
		set x to x + (width of windowSize) / 2
		set x to x - (width of windowSize2) / 2
		window2's setFrameTopLeftPoint:{x, y}
	end windowMath
	
	#Number Ninja Function
	on returnNumbersInString(inputString)
		set inputString to quoted form of inputString
		do shell script "sed s/[a-zA-Z\\']//g <<< " & inputString
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
	
	#Mode Selector Function
	on radioOption:sender
		set modeString to sender's title as text
	end radioOption:
	
	#Take to Purchase Page Function
	on purchaseBtn:sender
		do shell script "open 'http://www.skelekey.com/#purchase'"
	end purchaseBtn:
	
	#Registration Window Quit Function
	on regQuit:sender
		quit
	end regQuit:
	
	#############
	#  ADD-Ons  #
	#############
	#Date Checked Sender
	on dateChecked:sender
		global currDate
		if (dateEnabled's state()) is 0 then
			housekeeping("Date Unchecked")
		else if (dateEnabled's state()) is 1 then
			housekeeping("Date Checked")
		end if
	end dateChecked:
	
	#Display Expiration Date Function
	on displayData:sender
		set exp_date to theDate's dateValue()
		set exp_date to theDate's dateValue()'s |description| as Unicode text
		set exp_date_e to do shell script "date -u -j -f \"%Y-%m-%d %T\" \"" & exp_date & "\" +\"%s\""
	end displayData:
	
	#Login Checked Sender
	on loginChecked:sender
		global loginFile
		if (loginEnabled's state()) is 0 then
			housekeeping("Login Unchecked")
			webPushBtn's setEnabled:1
			webStatus's setImage:(NSImage's imageNamed:"NSStatusUnavailable")
			webStatus's setEnabled:1
			
		else if (loginEnabled's state()) is 1 then
			housekeeping("Login Checked")
			webPushBtn's setEnabled:0
			webStatus's setImage:(NSImage's imageNamed:"NSStatusPartiallyAvailable")
			webStatus's setEnabled:0
			set webState to "none"
			set webFile to false
		end if
	end loginChecked:
	
	#Move Login Window PKG to User's Desktop
	on loginComponentMover:sender
		global UnixPath
		try
			do shell script "mkdir -p ~/Desktop/SkeleKey-LoginWindow"
			do shell script "cp '" & UnixPath & "/Contents/Resources/SkeleKey_LoginWindow.pkg' ~/Desktop/SkeleKey-LoginWindow; open -R ~/Desktop/SkeleKey-LoginWindow/SkeleKey_LoginWindow.pkg"
		on error
			display dialog "Could not copy installation package to your Desktop! Please make sure your Desktop doesn't have a folder titled 'SkeleKey-LoginWindow' containing a file titled 'SkeleKey_LoginWindow.pkg and try again.'" with icon 0 buttons "Okay" with title "SkeleKey Manager" default button 1
		end try
	end loginComponentMover:
	
	#Open Installer Function
	on loginComponentInstaller:sender
		global UnixPath
		try
			do shell script "open -a Installer.app '" & UnixPath & "/Contents/Resources/SkeleKey_LoginWindow.pkg'"
		on error
			display dialog "Could not open installation package! Please re-download SkeleKey Manager." with icon 0 buttons "Okay" with title "SkeleKey Manager" default button 1
		end try
		
	end loginComponentInstaller:
	
	#Execution Checked Sender
	on limitChecked:sender
		global execlimit
		if (limitEnabled's state()) is 0 then
			housekeeping("Exec Unchecked")
		else if (limitEnabled's state()) is 1 then
			housekeeping("Exec Checked")
		end if
	end limitChecked:
	
	#Execution Limit External Fileout Logic
	on execlimit_ext(user, limit, drive)
		set execlimitEL to do shell script "printf '" & limit & "' | rev | base64 | rev"
		try
			do shell script "printf '" & execlimitEL & "' > '" & drive & ".SK_EL_" & user & ".enc.bin'"
		on error
			display dialog "Could not create SkeleKey with execution limit!" with icon 0 buttons "Okay" with title "SkeleKey Manager" default button 1
		end try
	end execlimit_ext
	
	#Hack-around for sender difficuly
	on stepperAction:sender
		fixField()
	end stepperAction:
	
	#Execution Limit Text Field Checker
	on fixField()
		global execlimit
		try
			set oldExec to ((stringValue() of stepperTF) as string) as number
			if oldExec is greater than 999999 then
				stepper's setDoubleValue:999999
				stepperTF's setStringValue:"999999"
				set oldExec to 999999
			else if oldExec is less than 1 then
				stepper's setDoubleValue:1
				stepperTF's setStringValue:"1"
				set oldExec to 1
			end if
			stepper's setDoubleValue:oldExec
			set execlimit to oldExec
		on error
			if ((stringValue() of stepperTF) as string) is not "" then
				stepperTF's setStringValue:(oldExec as string)
				stepper's setDoubleValue:oldExec
			else
				set oldExec to 1
				stepper's setDoubleValue:1
			end if
		end try
	end fixField
	
	#Web Support Enable
	on webPushBtnEnable:sender
		global webState
		global webFile
		if (webPushBtn's state()) is 0 then
			webStatus's setImage:(NSImage's imageNamed:"NSStatusUnavailable")
			set webState to "none"
			set webFile to false
			loginEnabled's setEnabled:1
		else if (webPushBtn's state()) is 1 then
			webStatus's setImage:(NSImage's imageNamed:"NSStatusAvailable")
			set webState to "WEBYES"
			set webFile to true
			loginEnabled's setEnabled:0
			housekeeping("Login Unchecked")
		end if
	end webPushBtnEnable:
	
	##########
	#  BASE  #
	##########
	#Password Value Check Function
	on checkPasswords()
		global isLicensed
		set password1String to (stringValue() of password1) as string
		set password2String to (stringValue() of password2) as string
		if password1String is equal to password2String and password1String is not "" then
			checkIcon's setImage:(NSImage's imageNamed:"NSStatusAvailable")
			if isLicensed is true then
				installButton's setEnabled:true
			end if
		else if password1String is not equal to password2String then
			checkIcon's setImage:(NSImage's imageNamed:"NSStatusUnavailable")
			installButton's setEnabled:false
		else
			checkIcon's setImage:(NSImage's imageNamed:"NSStatusPartiallyAvailable")
			installButton's setEnabled:false
		end if
	end checkPasswords
	
	#License Generator Function
	on licensekeygen(myname, myemail, myorg)
		set e_mn to do shell script "printf \"" & myname & "\" | rev"
		set e_mn to do shell script "printf \"" & e_mn & "\" | md5"
		set e_mn to do shell script "printf \"" & e_mn & "\" | base64"
		set e_mn to do shell script "printf \"" & e_mn & "\" | fold -w4 | paste -sd'1' - "
		set e_mn to characters 7 thru 11 of e_mn as text
		
		set e_me to do shell script "printf \"" & myemail & "\" | base64"
		set e_me to do shell script "printf \"" & e_me & "\" | rev"
		set e_me to do shell script "printf \"" & e_me & "\" | md5"
		set e_me to do shell script "printf \"" & e_me & "\" | fold -w3 | paste -sd'4' - "
		set e_me to characters 3 thru 7 of e_me as text
		
		set e_mo to do shell script "printf \"" & myorg & "\" | base64"
		set e_mo to do shell script "printf \"" & e_mo & "\" | md5"
		set e_mo to do shell script "printf \"" & e_mo & "\" | rev"
		set e_mo to do shell script "printf \"" & e_mo & "\" | fold -w3 | paste -sd'K' - "
		set e_mo to characters 16 thru 20 of e_mo as text
		
		set e_me2 to do shell script "printf \"" & myemail & "\" | md5"
		set e_me2 to do shell script "printf \"" & e_me2 & "\" | md5"
		set e_me2 to do shell script "printf \"" & e_me2 & "\" | base64"
		set e_me2 to do shell script "printf \"" & e_me2 & "\" | fold -w4 | paste -sd'A' - "
		set e_me2 to characters 4 thru 8 of e_me2 as text
		if myorg is not "" then
			set lickey to "SK-" & e_me & "-" & e_mn & "-" & e_mo as string
			set lickey to do shell script "printf '" & lickey & "' | tr '[a-z]' '[A-Z]'"
		else
			set lickey to "SK-" & e_me & "-" & e_mn & "-" & e_me2 as string
			set lickey to do shell script "printf '" & lickey & "' | tr '[a-z]' '[A-Z]'"
		end if
		return lickey
	end licensekeygen
	
	#Check Registration Function
	on checkRegistration()
		global regFirstNameString
		global regEmailString
		global regOrgString
		global regSerialString
		set regFirstNameString to (stringValue() of regFirstName) as string
		set regEmailString to (stringValue() of regEmail) as string
		set regOrgString to (stringValue() of regOrg) as string
		set regSerialString to (stringValue() of regSerial) as string
		if regFirstNameString is not "" and regEmailString is not "" and regSerialString is not "" then
			registrationButton's setEnabled:true
		else
			registrationButton's setEnabled:false
		end if
	end checkRegistration
	
	#Check License Key Function
	on checkLicenseKey:sender
		global regFirstNameString
		global regEmailString
		global regOrgString
		global regSerialString
		global isLicensed
		set lickey to licensekeygen(regFirstNameString, regEmailString, regOrgString)
		try
			set check_regSerialString_allowed to do shell script "printf $(curl \"http://www.skelekey.com/wp-content/uploads/lr_updates/lr_db_search.php?sn=" & regSerialString & "\" -A \"SkeleKey-Manager-LRLDBS\" -s)"
		on error
			set check_regSerialString_allowed to "0"
		end try
		
		if regSerialString is not equal to lickey then
			regFirstName's setStringValue:""
			regOrg's setStringValue:""
			regEmail's setStringValue:""
			regSerial's setStringValue:""
			registrationButton's setEnabled:false
			display dialog "Error! The license key you have entered is incorrect!" with title "SkeleKey Manager" buttons {"OK"}
		else if check_regSerialString_allowed is "1" then
			regFirstName's setStringValue:""
			regOrg's setStringValue:""
			regEmail's setStringValue:""
			regSerial's setStringValue:""
			registrationButton's setEnabled:false
			display dialog "The license key you have entered has been disabled!
            Please contact us at admin@skelekey.com if you have questions." with icon 0 with title "SkeleKey Manager" buttons {"OK"}
			
		else
			set isLicensed to true
			set plist_license_name_comp to do shell script "printf '" & regFirstNameString & "' | rev |  shasum -a 512 | awk '{print $1}'"
			set plist_license_email_comp to do shell script "printf '" & regEmailString & "' | md5 |  shasum -a 512 | awk '{print $1}'"
			set plist_license_org_comp to do shell script "printf '" & regOrgString & "' | rev |  shasum -a 512 | awk '{print $1}'"
			set plist_license_serial_comp to do shell script "printf '" & regSerialString & "' | base64 |  shasum -a 512 | awk '{print $1}'"
			set plist_license_key_comp to plist_license_serial_comp & plist_license_name_comp & plist_license_org_comp & plist_license_email_comp
			do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist license -dict 'full_name' '" & regFirstNameString & "'"
			do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist license -dict-add 'email_address' '" & regEmailString & "'"
			do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist license -dict-add 'organization' '" & regOrgString & "'"
			do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist license -dict-add 'serial_number' '" & regSerialString & "'"
			do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist license -dict-add 'verikey' '" & plist_license_key_comp & "'"
			display dialog "Success! SkeleKey Manager is now licensed to: " & regFirstNameString & ". Return to the main window and use the app normally!" with title "SkeleKey Manager" buttons {"OK"}
			registrationWindow's orderOut:sender
		end if
	end checkLicenseKey:
	
	#Text Field Checker
	on controlTextDidChange:aNotification
		set theObj to (tag of object of aNotification as string)
		if theObj is equal to "5" then
			checkPasswords()
		else if theObj is equal to "4" then
			checkRegistration()
		else if theObj is equal to "3" then
			fixField()
		end if
	end controlTextDidChange:
	
	#Main Window Start Button Function
	on buttonClicked:sender
		global currDate
		if modeString is "Create a SkeleKey" then
			mainWindow's orderOut:sender
			set currDateNS to NSDate's |date|
			set myFormatter to current application's class "NSDateFormatter"'s alloc()'s init()
			myFormatter's setDateFormat:"yyyy-MM-dd hh:mm:ss"
			set currDate to myFormatter's stringFromDate:currDateNS
			theDate's setDateValue:currDateNS
			theDate's setMinDate:currDateNS
			installWindow's makeKeyAndOrderFront:me
			installWindow's makeFirstResponder:username
			windowMath(mainWindow, installWindow)
		else if modeString is "Remove a SkeleKey" then
			mainWindow's orderOut:sender
			removeWindow's makeKeyAndOrderFront:me
			windowMath(mainWindow, removeWindow)
		end if
	end buttonClicked:
	
	#Destination Volume Chooser Function
	on destvolume:choosevolume
		global fileName2
		set validVols to {}
		try
			set discoverVol to do shell script "ls /Volumes | grep -v 'Macintosh HD'"
			set discoverVol to get paragraphs of discoverVol
			repeat with vol in discoverVol
				try
					set isValid to do shell script "diskutil info '/Volumes/" & vol & "' | grep \"Protocol\" | awk '{print $2}'"
				on error
					set isValid to "False"
				end try
				#if isValid is "USB" then
				set validVols to validVols & {vol}
				#end if
			end repeat
			set fileName2 to choose from list validVols with title "SkeleKey Manager" with prompt "Please choose a destination:"
			set fileName2 to "/Volumes/" & (fileName2 as text) & "/"
		on error
			display dialog "No valid destination found! Please (re)insert the USB and try again!" with icon 2 buttons "Okay" with title "SkeleKey Manager" default button 1
			
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
	
	on housekeeping(flavor)
		if flavor is "Main Window" then
			global fileName2
			fileName's setStringValue:""
			fileName's setToolTip:""
			startButton's setEnabled:false
			set fileName2 to ""
		else if flavor is "Install Window" then
			global usernameValue
			global password1Value
			global password2Value
			username's setStringValue:""
			password1's setStringValue:""
			password2's setStringValue:""
			set usernameValue to ""
			set password1Value to ""
			set password2Value to ""
			theDate's setEnabled:false
			theDate's setHidden:true
			theDateID's setHidden:true
			installButton's setEnabled:false
			installButton's setHidden:false
			dateEnabled's setState:0
			stateInformerDate's setHidden:false
			stateInformerLimit's setHidden:false
			stateInformerLogin's setHidden:false
			set exp_date_e to ""
			loginEnabled's setState:0
			loginComponentInfo2's setHidden:true
			loginComponentInstaller's setHidden:true
			limitEnabled's setState:0
			stepperTF's setHidden:true
			execlimitDesc's setHidden:true
			stepper's setHidden:true
			stepperTF's setStringValue:"0"
			stepper's setStringValue:"0"
			set execlimit to ""
			set webState to "none"
			checkIcon's setImage:(NSImage's imageNamed:"NSStatusPartiallyAvailable")
			loginEnabled's setEnabled:1
            webPushBtn's setEnabled:1
            webStatus's setEnabled:1
		else if flavor is "Removal Window" then
			global delApp
			delFileName's setStringValue:""
			delFileName's setToolTip:""
			delButton's setEnabled:false
			set delApp to ""
		else if flavor is "Date Unchecked" then
			theDate's setEnabled:false
			theDate's setHidden:true
			theDateID's setHidden:true
			stateInformerDate's setHidden:false
			installButton's setHidden:false
			set exp_date_e to ""
		else if flavor is "Date Checked" then
			global currDate
			theDate's setEnabled:true
			theDate's setHidden:false
			theDateID's setHidden:false
			stateInformerDate's setHidden:true
			set newDate to (year of currDate) & "-" & ((month of currDate) as integer) & "-" & (day of currDate) & space & (time string of currDate) as text
			set exp_date_e to do shell script "date -u -j -f \"%Y-%m-%d %T\" \"" & (newDate as Unicode text) & "\" +\"%s\""
		else if flavor is "Login Unchecked" then
			global loginFile
			stateInformerLogin's setHidden:false
			loginComponentInfo2's setHidden:true
			loginComponentInstaller's setHidden:true
			set loginFile to false
		else if flavor is "Login Checked" then
			global loginFile
			stateInformerLogin's setHidden:true
			loginComponentInfo2's setHidden:false
			loginComponentInstaller's setHidden:false
			set loginFile to true
		else if flavor is "Exec Unchecked" then
			stateInformerLimit's setHidden:false
			stepperTF's setHidden:true
			execlimitDesc's setHidden:true
			stepper's setHidden:true
			stepperTF's setStringValue:"0"
			stepper's setStringValue:"0"
			set execlimit to ""
		else if flavor is "Exec Checked" then
			stateInformerLimit's setHidden:true
			stepperTF's setStringValue:"1"
			stepperTF's setHidden:false
			stepper's setHidden:false
			stepper's setDoubleValue:1
			execlimitDesc's setHidden:false
		else if flavor is "Web Unchecked" then
			webStatus's setImage:(NSImage's imageNamed:"NSStatusUnavailable")
			set webState to "none"
			webPushBtn's setState:0
		end if
	end housekeeping
	
	#Install Button Function
	on installButton:sender
		global fileName2
		global usernameValue
		global password1Value
		global password2Value
		global UnixPath
		global webState
		global execlimit
		global loginFile
		global webFile
		
		set usernameValue to "" & (stringValue() of username)
		set password1Value to "" & (stringValue() of password1)
		set password2Value to "" & (stringValue() of password2)
		
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
			display dialog "Please enter a username!" with icon 2 buttons "Okay" with title "SkeleKey Manager" default button 1
			return
		end if
		if password1Value is not equal to password2Value then
			display dialog "Passwords do not match!" with icon 2 buttons "Okay" with title "SkeleKey Manager" default button 1
			password1's setStringValue:""
			password2's setStringValue:""
			return
		end if
		
        if loginFile is true and webFile is false then
            set findSKA to do shell script "cd '" & fileName2 & "'; ls -ldA1 *-SkeleKey-Applet.app/Contents/Resources/.loginenabled | awk '{print $1}' FS=/"
            if findSKA is not "" then
                display dialog "This USB Drive already has a SkeleKey with the Login Window add-on enabled! This SkeleKey already has the Login Window add-on enabled:\n" & (findSKA as string) with icon 2 buttons "Okay" with title "SkeleKey Manager" default button 1
                housekeeping("Main Window")
                housekeeping("Install Window")
                housekeeping("Login Unchecked")
                housekeeping("Web Unchecked")
                housekeeping("Exec Unchecked")
                housekeeping("Date Unchecked")
                installWindow's orderOut:sender
                mainWindow's makeKeyAndOrderFront:me
                windowMath(installWindow, mainWindow)
                return
            end if
        end if
        
		try
			do shell script "cp -R '" & UnixPath & "/Contents/Resources/SkeleKey-Applet.app' '" & fileName2 & "'"
			set uuid to do shell script "diskutil info '" & fileName2 & "' | grep 'Volume UUID' | awk '{print $3}' | rev"
			set nums to returnNumbersInString(uuid)
			repeat with char in nums
				set encstring to do shell script "printf \"" & uuid & "\" | " & (item (char + 1) of algorithms)
				set epass to epass & encstring
			end repeat
			set epass to do shell script "printf \"" & epass & "\" | fold -w160 | paste -sd'%' - | fold -w270 | paste -sd'@' - | fold -w51 | paste -sd'*' - | fold -w194 | paste -sd'~' - | fold -w64 | paste -sd'2' - | fold -w78 | paste -sd'^' - | fold -w38 | paste -sd')' - | fold -w28 | paste -sd'(' - | fold -w69 | paste -sd'=' -  | fold -w128 | paste -sd'$3bs' -  "
			if (length of epass) is greater than 2048 then
				set epass to (characters 1 thru 2047 of epass) as string
			end if
			if exp_date_e is "" then set exp_date_e to "none"
			if execlimit is "" then set execlimit to "none"
			if webState is "" then set webState to "none"
			do shell script "printf '" & usernameValue & "\n" & password2Value & "\n" & exp_date_e & "\n" & execlimit & "\n" & webState & "' | openssl enc -aes-256-cbc -e -out '" & fileName2 & "SkeleKey-Applet.app/Contents/Resources/.p.enc.bin' -pass pass:\"" & epass & "\""
			execlimit_ext(usernameValue, execlimit, fileName2)
			if webFile is true then
				do shell script "touch '" & fileName2 & "SkeleKey-Applet.app/Contents/Resources/.webenabled'"
			end if
			
			if loginFile is true and webFile is false then
				do shell script "touch '" & fileName2 & "SkeleKey-Applet.app/Contents/Resources/.loginenabled'"
			end if
			
			
			try
				set theNumber to 1
				
				do shell script "test -e '" & fileName2 & usernameValue & "-SkeleKey-Applet.app'"
				repeat
					try
						set theNumber to theNumber + 1
						do shell script "test -e '" & fileName2 & usernameValue & " " & theNumber & "-SkeleKey-Applet.app'"
					on error
						do shell script "mv -f '" & fileName2 & "SkeleKey-Applet.app' '" & fileName2 & usernameValue & " " & theNumber & "-SkeleKey-Applet.app'"
						exit repeat
					end try
				end repeat
			on error
				do shell script "mv -f '" & fileName2 & "SkeleKey-Applet.app' '" & fileName2 & usernameValue & "-SkeleKey-Applet.app'"
			end try
			display notification "Sucessfully created SkeleKey for for username: " & usernameValue with title "SkeleKey Manager"
			display dialog "Sucessfully created SkeleKey at location:
            " & fileName2 buttons "Continue" with title "SkeleKey Manager" default button 1
		on error
			display notification "Could not create SkeleKey" with title "SkeleKey Manager" subtitle "ERROR"
			display dialog "Could not create SkeleKey at location: " & fileName2 with icon 0 buttons "Okay" with title "SkeleKey Manager" default button 1
		end try
		housekeeping("Main Window")
		housekeeping("Install Window")
		housekeeping("Login Unchecked")
		housekeeping("Web Unchecked")
		housekeeping("Exec Unchecked")
		housekeeping("Date Unchecked")
		installWindow's orderOut:sender
		mainWindow's makeKeyAndOrderFront:me
		windowMath(installWindow, mainWindow)
	end installButton:
	
	#Removal Target Function
	on destApp:sender
		global delApp
		global fileName2
		global isLicensed
		try
			set delApp to choose file of type "com.apple.application-bundle" default location fileName2 with prompt "Please choose a SkeleKey Applet to remove:" without invisibles
			set delApp to POSIX path of delApp
			delFileName's setStringValue:delApp
			delFileName's setToolTip:delApp
			if isLicensed is true then
				delButton's setEnabled:true
			end if
		on error
			delFileName's setStringValue:""
			delFileName's setToolTip:""
			delButton's setEnabled:false
		end try
	end destApp:
	
	#Removal Button Function
	on delButton:sender
		global delApp
		removeWindow's orderOut:sender
		loadingWindow's makeKeyAndOrderFront:me
		windowMath(removeWindow, loadingWindow)
		quitItem's setEnabled:false
		set isBusy to true
		delay 0.25
		try
			do shell script "srm -rf '" & delApp & "'"
			display dialog "Sucessfully securely removed app at location:
            " & delApp buttons "Continue" with title "SkeleKey Manager" default button 1
		on error
			display dialog "Could not securely remove app at location: " & delApp with icon 0 buttons "Okay" with title "SkeleKey Manager" default button 1
		end try
		set isBusy to false
		quitItem's setEnabled:true
		housekeeping("Main Window")
		finishedDel_(sender)
	end delButton:
	
	#Tutorial Screen Button Function
	on gotit:sender
		global isLicensed
		if isLicensed is false then
			registrationWindow's makeKeyAndOrderFront:me
		end if
		if (dontShow's state()) is 1 then
			try
				do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist dontShow -bool true"
			end try
		else if (dontShow's state()) is 0 then
			try
				do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist dontShow -bool false"
			end try
		end if
		tutorialWindow's orderOut:sender
	end gotit:
	
	#Tutorial Window Button Function
	on welcomeNext:sender
		welcomeWindow's orderOut:sender
		if fromStart is true then
			tutorialWindow's makeKeyAndOrderFront:me
			windowMath(welcomeWindow, tutorialWindow)
		end if
	end welcomeNext:
	
	#Install Window Back Button
	on backButtonInstaller:sender
		housekeeping("Install Window")
		housekeeping("Login Unchecked")
		housekeeping("Web Unchecked")
		housekeeping("Exec Unchecked")
		housekeeping("Date Unchecked")
		
		installWindow's orderOut:sender
		mainWindow's makeKeyAndOrderFront:me
		windowMath(installWindow, mainWindow)
	end backButtonInstaller:
	
	#Removal Window Cancelled Function
	on cancelDel:sender
		housekeeping("Removal Window")
		removeWindow's orderOut:sender
		mainWindow's makeKeyAndOrderFront:me
		windowMath(removeWindow, mainWindow)
	end cancelDel:
	
	#Remove Window Complete Function
	on finishedDel:sender
		housekeeping("Removal Window")
		loadingWindow's orderOut:sender
		mainWindow's makeKeyAndOrderFront:me
		windowMath(loadingWindow, mainWindow)
	end finishedDel:
	
	#Tutorial Window Execution Function
	on doOpenTutorial:sender
		tutorialWindow's makeKeyAndOrderFront:me
	end doOpenTutorial:
	
	#Welcome Window Execution Function
	on doOpenWelcome:sender
		welcomeWindow's makeKeyAndOrderFront:me
		set fromStart to false
	end doOpenWelcome:
	
	#On-startup Function
	on applicationWillFinishLaunching:aNotification
		global isLicensed
		global UnixPath
		set UnixPath to POSIX path of (path to current application as text)
		set dependencies to {"printf", "openssl", "ls", "diskutil", "grep", "awk", "base64", "sudo", "cp", "bash", "mv", "rm", "base64", "md5", "srm", "defaults", "test", "fold", "paste", "dscl", "/usr/libexec/PlistBuddy", "curl"}
		set notInstalledString to ""
		if beta_mode is false then
			try
				do shell script "sudo printf elevate" with administrator privileges
			on error
				display dialog "SkeleKey needs administrator privileges to run!" buttons "Quit" default button 1 with title "SkeleKey-Manager" with icon 0
				quit
			end try
		end if
		set cmd_existance to do shell script "command; printf $?"
		if cmd_existance is not "" then
			repeat with i in dependencies
				try
					set status to do shell script "command -v " & i
				on error
					set notInstalledString to notInstalledString & i & "
                    "
				end try
			end repeat
			if notInstalledString is not "" then
				display dialog "The following required resources are not installed:
                
                " & notInstalledString buttons "Quit" default button 1 with title "SkeleKey Manager" with icon 0
				
				quit
			end if
		else
			display dialog "The system file 'command' is misssing!"
		end if
		try
			set licensedValue_fullname_real to do shell script "/usr/libexec/PlistBuddy -c \"print :license:full_name\" ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist"
			set licensedValue_emailaddress_real to do shell script "/usr/libexec/PlistBuddy -c \"print :license:email_address\" ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist"
			set licensedValue_organization_real to do shell script "/usr/libexec/PlistBuddy -c \"print :license:organization\" ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist"
			set licensedValue_serialnumber_real to do shell script "/usr/libexec/PlistBuddy -c \"print :license:serial_number\" ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist"
			set licensedValue_verikey_real to do shell script "/usr/libexec/PlistBuddy -c \"print :license:verikey\" ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist"
			try
				set check_licensedValue_serialnumber to do shell script "printf $(curl \"http://www.skelekey.com/wp-content/uploads/lr_updates/lr_db_search.php?sn=" & licensedValue_serialnumber_real & "\" -A \"SkeleKey-Manager-LRLDBS\" -s)"
			on error
				set check_licensedValue_serialnumber to "0"
			end try
			if check_licensedValue_serialnumber is "0" then
				set licensedValue_fullname_gen to do shell script "printf '" & licensedValue_fullname_real & "' | rev |  shasum -a 512 | awk '{print $1}'"
				set licensedValue_emailaddress_gen to do shell script "printf '" & licensedValue_emailaddress_real & "' | md5 |  shasum -a 512 | awk '{print $1}'"
				set licensedValue_organization_gen to do shell script "printf '" & licensedValue_organization_real & "' | rev |  shasum -a 512 | awk '{print $1}'"
				set licensedValue_serialnumber_gen to do shell script "printf '" & licensedValue_serialnumber_real & "' | base64 |  shasum -a 512 | awk '{print $1}'"
				set licensedValue_verikey_gen to licensedValue_serialnumber_gen & licensedValue_fullname_gen & licensedValue_organization_gen & licensedValue_emailaddress_gen
				if licensedValue_verikey_gen is equal to licensedValue_verikey_real then
					set isLicensed to true
				else
					set isLicensed to false
					try
						do shell script "defaults delete ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist \"license\""
					end try
				end if
			else
				set isLicensed to false
				try
					do shell script "defaults delete ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist \"license\""
				end try
			end if
		on error
			set isLicensed to false
		end try
		
		try
			set dontShowValue to do shell script "defaults read ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist dontShow"
		on error
			set dontShowValue to "0"
		end try
		try
			set hasWelcomed to do shell script "defaults read ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist hasWelcomed"
		on error
			do shell script "defaults write ~/Library/Preferences/com.skelekey.SkeleKey-Manager.plist hasWelcomed -bool true"
			set hasWelcomed to "0"
		end try
		if hasWelcomed is "0" then
			welcomeWindow's makeKeyAndOrderFront:me
			registrationWindow's makeKeyAndOrderFront:me
		else
			if dontShowValue is "0" then
				tutorialWindow's makeKeyAndOrderFront:me
			end if
		end if
	end applicationWillFinishLaunching:
	
	#On Termination Function
	on applicationShouldTerminate:sender
		if isBusy is true then
			return NSTerminateCancel
		end if
		return current application's NSTerminateNow
	end applicationShouldTerminate:
	
	#Application Specific Values
	on applicationShouldTerminateAfterLastWindowClosed:sender
		return true
	end applicationShouldTerminateAfterLastWindowClosed:
end script