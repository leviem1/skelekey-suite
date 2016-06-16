--
--  AppDelegate.applescript
--  SkeleKey-Manager
--
--  Created by Mark Hedrick on 02/21/16.
--  Copyright (c) 2016 Mark Hedrick and Levi Muniz. All rights reserved.
--
--VERSION 0.4.1
#VARIABLES
set findSKA to {}
set epass to {}
set validVols to {}
set fullnames to {}
set secag to "SecurityAgent"

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
set execlimit_ext to ""
set exp_date_e to ""

#FUNCTIONS
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

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

try
	set loggedusers to do shell script "last | grep -v '\\<_.*\\>' | grep 'logged in' | awk {'print $1'}"
	set lwuid to do shell script "ps -ef | grep loginwindow | grep -v grep | awk '{print $1}'"
	try
		set discoverVol to do shell script "ls /Volumes | grep -v 'Macintosh HD' | grep -v '.DS_Store'"
		set discoverVol to get paragraphs of discoverVol
	on error
		return 1
	end try
	
	if (loggedusers is not "" and lwuid is not "0") or ((length of discoverVol) is 0) or ((length of discoverVol) is 1 and discoverVol contains "Recovery HD") then
		return 2
	end if
	
	#CODE
	################################
	#   Find USB Vols, then search for SK Applet        #
	################################
	
	repeat with vol in discoverVol --Figure the validity of a mounted drive
		set vol to replace_chars(vol, "\\", "\\\\")
		set vol to replace_chars(vol, "'", "\\'")
		try
			set isValid to do shell script "diskutil info $'/Volumes/" & vol & "' | grep \"Protocol\" | awk '{print $2}'"
		on error
			set isValid to "False"
		end try
		if isValid is "USB" then
			set validVols to validVols & {vol}
		end if
	end repeat
	
	repeat with vol in validVols
		try
			set findSKAvol to do shell script "cd $'/Volumes/" & vol & "'; ls -ldA1 *-SkeleKey-Applet.app/Contents/Resources/.loginenabled"
			set findSKA to findSKA & (paragraphs of findSKAvol)
			if (length of findSKA) is greater than or equal to 2 then
				do shell script "say -v Samantha Multiple login window skeley keys detected!"
				return 1
			else if findSKA is not "" then
				set drive_name to vol
			else
				return 1
			end if
		on error
			return 3
		end try
	end repeat
	
	set skname to item 1 of findSKA
	set skname to replace_chars(skname, "\\", "\\\\")
	set skname to replace_chars(skname, "'", "\\'")
	set skname to do shell script "printf $'" & skname & "' | awk -F- '{print $1}'"
	set skname to replace_chars(skname, "\\", "\\\\")
	set skname to replace_chars(skname, "'", "\\'")
	
	do shell script "say -v Samantha Starting Skeley Key Login Window"
	#####################
	#   Find Matching USB UUIDs    #
	#####################
	try
		set uuid to do shell script "diskutil info $'/Volumes/" & drive_name & "' | grep 'Volume UUID' | awk '{print $3}' | rev"
	on error
		return 4
	end try
	
	###########################
	#   Generate epass for each set of creds    #
	###########################
	set nums to returnNumbersInString(uuid)
	repeat with char in nums
		set encstring to do shell script "printf \"" & uuid & "\" | " & (item (char + 1) of algorithms)
		set epass to epass & encstring
	end repeat
	set epass to epass as text
	set epass to do shell script "printf \"" & epass & "\" | fold -w160 | paste -sd'%' - | fold -w270 | paste -sd'@' - | fold -w51 | paste -sd'*' - | fold -w194 | paste -sd'~' - | fold -w64 | paste -sd'2' - | fold -w78 | paste -sd'^' - | fold -w38 | paste -sd')' - | fold -w28 | paste -sd'(' - | fold -w69 | paste -sd'=' -  | fold -w128 | paste -sd'$3bs' -  "
	if (length of epass) is greater than 2048 then
		set epass to (characters 1 thru 2047 of epass) as string
	end if
	
	#########################
	#   Attempt to Decrypt All Credenials   #
	#########################
	set encContents to (do shell script "openssl enc -aes-256-cbc -d -in $'/Volumes/" & drive_name & "/" & skname & "-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin' -pass pass:\"" & epass & "\"")
	set ucreds to paragraph 1 of encContents
	set ucreds to replace_chars(ucreds, "\\", "\\\\")
	set ucreds to replace_chars(ucreds, "'", "\\'")
	set pcreds to paragraph 2 of encContents
	set pcreds to replace_chars(pcreds, "\\", "\\\\")
	set pcreds to replace_chars(pcreds, "'", "\\'")
	set exp_date_e to paragraph 3 of encContents
	set execlimit_bin to paragraph 4 of encContents
	
	##############
	#   Expiration Date   #
	##############
	set current_date_e to do shell script "date -u '+%s'"
	if current_date_e is greater than or equal to exp_date_e and exp_date_e is not "none" then
		do shell script "say -v Samantha This Skeley Key has reached its expiration date!"
		return 5
	end if
	
	##############
	#   Execution Limit  #
	#############
	set randName to do shell script "cat $'/Volumes/" & drive_name & "/" & skname & "-SkeleKey-Applet.app/Contents/Resources/.SK_EL_STR' | rev | base64 -D | rev"
	set execlimit_ext to do shell script "cat $'/Volumes/" & drive_name & "/.SK_EL_" & randName & ".enc.bin' | rev | base64 -D | rev"
	
	if execlimit_ext is not equal to execlimit_bin then
		if execlimit_ext is less than execlimit_bin then
			set numEL to execlimit_ext
		else if execlimit_ext is greater than execlimit_bin then
			set numEL to execlimit_bin
		end if
	else
		set numEL to execlimit_bin
	end if
	
	if numEL is not "none" then
		if numEL is less than or equal to 0 then
			do shell script "say -v Samantha This Skeley Key has reached its execution limit!"
			return 6
		else if numEL is greater than 0 then
			set newNumEL to do shell script "printf '" & (numEL - 1) & "' | rev | base64 | rev"
			do shell script "printf '" & newNumEL & "' > $'/Volumes/" & drive_name & "/.SK_EL_" & randName & ".enc.bin'"
		end if
	end if
	
	#########################
	#   Attempt to authenticate local users  #
	#########################
	
	try
		set localusers to paragraphs of (do shell script "dscl . list /Users | grep -v ^_.* | grep -v 'daemon' | grep -v 'Guest' | grep -v 'nobody'") as list --Find all local user accounts
	on error
		return 7
	end try
	
	repeat with user in localusers
		set fullname to do shell script "dscacheutil -q user -a name '" & user & "' | grep 'gecos' | sed -e 's/.*gecos: \\(.*\\)/\\1/'"
		set fullnames to fullnames & fullname
	end repeat
	
	if ucreds is not in localusers and users is not in fullnames then
		do shell script "say -v Samantha User account was not found on this computer."
		return 8
	end if
	
	set fullname to do shell script "dscacheutil -q user -a name $'" & ucreds & "' | grep 'gecos' | sed -e 's/.*gecos: \\(.*\\)/\\1/'"
	
	set ucredsv to do shell script "printf $'" & ucreds & "'"
	set pcreds to do shell script "printf $'" & pcreds & "'"
	
	########################
	#   Figure out login window format   #
	########################
	try
		set OS to do shell script "sw_vers -productVersion"
	on error
		return "Could not determine OS X version!"
	end try
	
	if OS is not greater than "10.10" then --fix 10.10 login screen issue, simulate a fake logout
		do shell script "/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend"
	end if
	
	try
		set test_for_txtlgn to do shell script "/usr/libexec/PlistBuddy -c 'print :SHOWFULLNAME' /Library/Preferences/com.apple.loginwindow.plist"
		
		if test_for_txtlgn is not "true" then
			set test_for_txtlgn to "false"
		end if
	on error
		set test_for_txtlgn to "false"
	end try
	
	####################
	#   Finally, the login window!   #
	####################
	if test_for_txtlgn is "true" then --text only login window
		try
			tell application "System Events" to tell process secag to activate
		end try
		try
			tell application "Bluetooth Setup Assistant" to quit
		end try
		tell application "System Events"
			delay 0.5
			tell process "SecurityAgent"
				set value of text field 2 of window "Login" to ucredsv
				set value of text field 1 of window "Login" to pcreds
				keystroke tab
				keystroke return
			end tell
		end tell
		if drive_name is not "Macintosh\\ HD" or ".DS_Store" then
			try
				do shell script "diskutil umount $'/Volumes/" & drive_name & "'"
			on error
				do shell script "diskutil unmountDisk$ '/Volumes/" & drive_name & "'"
			end try
		end if
	else --graphical item login window
		try
			do shell script "killall \"System Events\""
		end try
		try
			tell application "System Events" to activate
		end try
		try
			tell application "System Events" to tell process secag to activate
		end try
		try
			tell application "Bluetooth Setup Assistant" to quit
		end try
		set uid to do shell script "dscl . list /Users UniqueID | grep $'" & ucreds & "' | awk {'print $2'}"
		try
			set hidesub500 to do shell script "/usr/libexec/PlistBuddy -c 'print :Hide500Users' /Library/Preferences/com.apple.loginwindow.plist"
		on error
			set hidesub500 to "false"
		end try
		try
			set ishidden to do shell script "dscl . list /Users IsHidden | grep $'" & ucreds & "' | awk {'print $2'}"
		on error
			set ishidden to "0"
		end try
		if ishidden is "" then set ishidden to "0"
		if (uid is less than 500 and hidesub500 is "true") or ishidden is "1" then
			delay 0.5
			tell application "System Events"
				keystroke "Othe"
				delay 0.25
				keystroke return
				delay 0.5
				tell process "SecurityAgent"
					set value of text field 2 of window "Login" to ucredsv
					set value of text field 1 of window "Login" to pcreds
				end tell
				delay 0.25
				keystroke return
				keystroke return
				do shell script "say -v Samantha $'Welcome back " & fullname & "'"
			end tell
		else --if no users hidden...
			delay 0.25
			tell application "System Events"
				key code 53
				delay 0.5
				keystroke fullname
				delay 0.5
				keystroke tab
				keystroke return
				delay 0.5
				tell process "SecurityAgent"
					set value of text field 1 of window "Login" to pcreds
				end tell
				delay 0.25
				keystroke return
				do shell script "say -v Samantha 'Welcome back " & fullname & "'"
			end tell
		end if
		if drive_name is not "Macintosh\\ HD" or ".DS_Store" then
			try
				do shell script "diskutil umount $'/Volumes/" & drive_name & "'"
			on error
				try
					do shell script "diskutil unmountDisk $'/Volumes/" & drive_name & "'"
				end try
			end try
		end if
	end if
on error
	do shell script "say -v Samantha Cannot log in"
	try
		if drive_name is not "Macintosh\\ HD" or ".DS_Store" then
			try
				do shell script "diskutil umount $'/Volumes/" & drive_name & "'"
			on error
				try
					do shell script "diskutil unmountDisk $'/Volumes/" & drive_name & "'"
				end try
			end try
		end if
	end try
end try