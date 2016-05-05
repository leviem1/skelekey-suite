--
--  AppDelegate.applescript
--  SkeleKey-Manager
--
--  Created by Mark Hedrick on 02/21/16.
--  Copyright (c) 2016 Mark Hedrick and Levi Muniz. All rights reserved.
--
--VERSION 0.3
#VARIABLES
set validVols to {}
set drive_names to {}
set drive_uuids to {}
set epass to {}
set epasses to {}
set sk_names to {}
set ucreds to {}
set pcreds to {}
set uuids to {}
set count_dec to 0
set count_atmpt_auth to 0
set matching_users to {}
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

#FUNCTIONS
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

set loggedusers to do shell script "last | grep 'logged in' | awk {'print $1'}"
if loggedusers is not "" then
		return 1
end if
#CODE
################################
#   Find USB Vols, then search for SK Applet        #
################################
try
	set discoverVol to do shell script "ls /Volumes | grep -v 'Macintosh HD'"
	set discoverVol to get paragraphs of discoverVol
on error
	return "Could not list volumes!"
end try
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
repeat with vol in validVols
	try
		set vol to replace_chars(vol, " ", "\\ ")
		set findSKA to do shell script "cd /Volumes/" & vol & "; ls -ldA1 *-SkeleKey-Applet.app"
		if findSKA is not "" then
			set drive_names to drive_names & vol
		end if
	on error
		#quit
	end try
end repeat
#####################
#   Find Matching USB UUIDs    #
#####################
repeat with vol in drive_names
	try
		set uuid to do shell script "diskutil info /Volumes/" & vol & " | grep 'Volume UUID' | awk '{print $3}' | rev"
		set drive_uuids to drive_uuids & uuid
	on error
		#quit
	end try
end repeat
###########################
#   Generate epass for each set of creds    #
###########################
repeat with uuid in drive_uuids
	set nums to returnNumbersInString(uuid)
	repeat with char in nums
		set encstring to do shell script "echo \"" & uuid & "\" | " & (item (char + 1) of algorithms)
		set epass to epass & encstring
	end repeat
	#set epass to epass as text
	set epass to do shell script "echo \"" & epass & "\" | fold -w160 | paste -sd'%' - | fold -w270 | paste -sd'@' - | fold -w51 | paste -sd'*' - | fold -w194 | paste -sd'~' - | fold -w64 | paste -sd'2' - | fold -w78 | paste -sd'^' - | fold -w38 | paste -sd')' - | fold -w28 | paste -sd'(' - | fold -w69 | paste -sd'=' -  | fold -w128 | paste -sd'$3bs' -  "
	if (length of epass) is greater than 2048 then
		set epass to (characters 1 thru 2047 of epass) as string
	end if
	set epasses to epasses & epass
end repeat
#########################
#   Attempt to Decrypt All Credenials   #
#########################
repeat (count of drive_names) times
	set drive to item (count_dec + 1) in drive_names
	set epass to item (count_dec + 1) in epasses
	set detect_skeles to do shell script "cd /Volumes/" & drive & ";  ls -ldA1 *-SkeleKey-Applet.app"
	set detect_skeles to paragraphs of detect_skeles
	repeat with name_ in detect_skeles
		if name_ contains "-SkeleKey-Applet.app" then
			set name_ to do shell script "echo '" & name_ & "' | awk -F- '{print $1}'"
			set sk_names to sk_names & name_
		end if
	end repeat
	repeat with skname in sk_names
		set _username to (do shell script "openssl enc -aes-256-cbc -d -in /Volumes/" & drive & "/" & skname & "-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass & "\" | sed '1q;d'")
		set _passwd to (do shell script "openssl enc -aes-256-cbc -d -in /Volumes/" & drive & "/" & skname & "-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass & "\" | sed '2q;d'")
		set ucreds to ucreds & _username
		set pcreds to pcreds & _passwd
	end repeat
	set drive_ to drive
end repeat
#########################
#   Attempt to authenticate local users  #
#########################
try
	set localusers to paragraphs of (do shell script "dscl . list /Users | grep -v ^_.* | grep -v 'daemon' | grep -v 'Guest' | grep -v 'nobody'") as list --Find all local user accounts
on error
	#quit
end try
repeat with users in ucreds
	if users is in localusers then
		set matching_users to matching_users & users
	end if
end repeat
try
	if matching_users is not "" then
		
		set randStr to do shell script "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1"
		do shell script "echo 'on run arg
	set uname to item 1 of arg
	set passwd to item 2 of arg
	try
		do shell script \"sudo echo elevate\" user name uname password passwd with administrator privileges
		return uname & \"
\" & passwd
	on error
		return \"auth error\"
	end try
end run' > /tmp/SK-LW-UA-" & randStr & ".applescript"
		repeat (count of matching_users) times
			set user_ to item (count_atmpt_auth + 1) in matching_users
			set pass_ to item (count_atmpt_auth + 1) in pcreds
			set auth to do shell script "osascript /tmp/SK-LW-UA-" & randStr & ".applescript '" & user_ & "'" & space & "'" & pass_ & "'"
			set auth to paragraphs of auth
			set uname to item 1 of auth
			set passwd to item 2 of auth
		end repeat
	else
		#quit
	end if
	do shell script "rm -r /tmp/SK-LW-UA-" & randStr & ".applescript"
on error
	return "Could not authenticate with any of the provided credentials!"
end try
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
			set value of text field 2 of window "Login" to uname
			set value of text field 1 of window "Login" to passwd
			keystroke tab
			keystroke return
		end tell
	end tell
	if drive_ is not "Macintosh HD" or ".DS_Store" then
		try
			do shell script "diskutil umount /Volumes/" & drive_
		on error
			do shell script "diskutil unmountDisk /Volumes/" & drive_
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
	set uid to do shell script "dscl . list /Users UniqueID | grep '" & uname & "' | awk {'print $2'}"
	try
		set hidesub500 to do shell script "/usr/libexec/PlistBuddy -c 'print :Hide500Users' /Library/Preferences/com.apple.loginwindow.plist"
	on error
		set hidesub500 to "false"
	end try
	try
		set ishidden to do shell script "dscl . list /Users IsHidden | grep '" & uname & "' | awk {'print $2'}"
	on error
		set ishidden to "0"
	end try
	if ishidden is "" then set ishidden to "0"
	if (uid is less than 500 and hidesub500 is "true") or ishidden is "1" then
		tell application "System Events"
			keystroke "Othe"
			delay 0.25
			keystroke return
			delay 0.5
			tell process "SecurityAgent"
				set value of text field 2 of window "Login" to uname
				set value of text field 1 of window "Login" to passwd
			end tell
			delay 0.25
			keystroke return
			keystroke return
			say "Welcome back " & uname
		end tell
	else --if no users hidden
		set fullname to do shell script "dscacheutil -q user -a name '" & uname & "' | grep 'gecos' | sed -e 's/.*gecos: \\(.*\\)/\\1/'"
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
				set value of text field 1 of window "Login" to passwd
			end tell
			delay 0.25
			keystroke return
			say "Welcome back " & uname
		end tell
	end if
	if drive_ is not "Macintosh HD" or ".DS_Store" then
		try
			do shell script "diskutil umount /Volumes/" & drive_
		on error
			do shell script "diskutil unmountDisk /Volumes/" & drive_
		end try
	end if
end if