#!/bin/osascript

#VARIABLES
set validVols to {}
set drive_names to {}
set drive_uuids to {}
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
set epass to {}
set epasses to {}
set sk_names to {}
set ucreds to {}
set pcreds to {}

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

(* --working on improving
#########################
#   Attempt to Decrypt All Credenials   #
#########################
repeat with epass in epasses
	repeat with drive in drive_names
		set detect_skeles to do shell script "cd /Volumes/" & drive & ";  ls -ldA1 *-SkeleKey-Applet.app"
		set detect_skeles to paragraphs of detect_skeles
		repeat with name_ in detect_skeles
			if name_ contains "-SkeleKey-Applet.app" then
				set name_ to do shell script "echo '" & name_ & "' | awk -F- '{print $1}'"
				set sk_names to sk_names & name_
			end if
		end repeat
		repeat with skname in sk_names
			set username to (do shell script "openssl enc -aes-256-cbc -d -in /Volumes/" & drive & "/" & skname & "-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass & "\" | sed '1q;d'")
			set passwd to (do shell script "openssl enc -aes-256-cbc -d -in /Volumes/" & drive & "/" & skname & "-SkeleKey-Applet.app/Contents/Resources/.p.enc.bin -pass pass:\"" & epass & "\" | sed '2q;d'")
			set ucreds to ucreds & username
			set pcreds to pcreds & passwd
		end repeat
		set drive_ to drive
	end repeat
end repeat
*)