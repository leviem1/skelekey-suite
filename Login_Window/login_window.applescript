#!/bin/osascript
set drive_names to {}
set drive_uuids to {}
set epasses to {}
set ucreds to {}
set pcreds to {}
set matching_users to {}
set text_based to "0"
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
set encstring to ""
set epass to ""
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
set discoverVol to do shell script "ls /Volumes | grep -v 'Macintosh HD'"
set discoverVol to get paragraphs of discoverVol

repeat with vol in discoverVol --Find Volumes with SkeleKey's
	set vol to replace_chars(vol, " ", "\\ ")
	if (do shell script "if test -e /Volumes/" & vol & "/*-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin; then echo \"1\";fi") is "1" then
		set drive_names to drive_names & vol
	end if
end repeat

repeat with vol in drive_names --Find that Volume's UUID
	set uuid to do shell script "diskutil info /Volumes/" & vol & " | grep 'Volume UUID' | awk '{print $3}' | rev"
	set drive_uuids to drive_uuids & uuid
end repeat

repeat with uuid in drive_uuids --Convert UUID to the epass
	set nums to returnNumbersInString(uuid)
	repeat with char in nums
		set encstring to do shell script "echo \"" & uuid & "\" | " & (item (char + 1) of algorithms)
		set epass to epass & encstring
	end repeat
	set epass to do shell script "echo \"" & epass & "\" | fold -w160 | paste -sd'%' - | fold -w270 | paste -sd'@' - | fold -w51 | paste -sd'*' - | fold -w194 | paste -sd'~' - | fold -w64 | paste -sd'2' - | fold -w78 | paste -sd'^' - | fold -w38 | paste -sd')' - | fold -w28 | paste -sd'(' - | fold -w69 | paste -sd'=' -  | fold -w128 | paste -sd'$3bs' -  "
	if (length of epass) is greater than 2048 then
		set epass to (characters 1 thru 2047 of epass) as string
	end if
	set epasses to epasses & epass
end repeat

repeat with epass_str in epasses --Attempt to decrypt all SkeleKey's plugged in the computer
	repeat with drive in drive_names
		set username to (do shell script "openssl enc -aes-256-cbc -d -in /Volumes/" & drive & "/*-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass_str & "\" | sed '1q;d'")
		set passwd to (do shell script "openssl enc -aes-256-cbc -d -in /Volumes/" & drive & "/*-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass_str & "\" | sed '2q;d'")
		set ucreds to ucreds & username
		set pcreds to pcreds & passwd
	end repeat
end repeat

set localusers to paragraphs of (do shell script "dscl . list /Users | grep -v ^_.* | grep -v 'daemon' | grep -v 'Guest' | grep -v 'nobody'") as list --Find all local user accounts

repeat with users in ucreds --Check if SkeleKey users match local users
	if users is in localusers then
		set matching_users to matching_users & users
	end if
end repeat

try --Attempt to authenticate with those users
	set test_ to do shell script "sudo echo elevate" user name matching_users password passwd with administrator privileges
	set test_ to "YES"
on error
	set test_ to "NO"
end try

if test_ is not equal to "YES" then --If cant authenticate, error out
	say "error!"
end if
set uname to matching_users as string
set passwd to passwd as string
set secag to "SecurityAgent"

try --Figure out login screen mechanism
	set test_for_fn to do shell script "/usr/libexec/PlistBuddy -c 'print :SHOWFULLNAME' /Library/Preferences/com.apple.loginwindow.plist"
	if test_for_fn is "true" then
		set text_based to "1"
	else if test_for_fn is "false" then
		set text_based to "0"
	else
		set text_based to "0"
	end if
on error
	set text_based to "0"
end try

if text_based is "1" then --If using uname/pass fields, use this method
	try
		do shell script "killall SecurityAgent; killall SystemUIServer"
	end try
	delay 5
	tell application "System Events" to tell process secag to activate
	tell application "Bluetooth Setup Assistant" to quit
	tell application "System Events"
		tell process "SecurityAgent"
			set value of text field 2 of window "Login" to uname
			set value of text field 1 of window "Login" to passwd
		end tell
	end tell
	if drive is not "Macintosh HD" or ".DS_Store" then
		try
			do shell script "diskutil umount /Volumes/" & drive
		on error
			do shell script "diskutil unmountDisk /Volumes/" & drive
		end try
	end if
else if text_based is "0" then --If using user image, use this method
	try
		do shell script "killall SecurityAgent; killall SystemUIServer"
	end try
	tell application "System Events" to tell process secag to activate
	tell application "Bluetooth Setup Assistant" to quit
	tell application "System Events"
		tell process "SecurityAgent"
			set value of text field 1 of window "Login" to passwd
		end tell
	end tell
	if drive is not "Macintosh HD" or ".DS_Store" then
		try
			do shell script "diskutil umount /Volumes/" & drive
		on error
			do shell script "diskutil unmountDisk /Volumes/" & drive
		end try
	end if
end if