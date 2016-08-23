--
--  main.scpt
--  SkeleKey-Packages
--
--  Created by Mark Hedrick on 03/03/16.
--  Copyright (c) 2016 Mark Hedrick and Levi Muniz. All rights reserved.
--

set vkey to "ff685d05f6f43397451657157e19764e"
set exp_date to "MTQ1ODA1NDQ5Mgo=" --March 15th @ midnight MST!

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

on comparator(listA, listB)
	set intersectors to {}
	repeat with item_ in listA
		if listB contains item_ then
			set intersectors to intersectors & item_
		end if
	end repeat
	return intersectors
end comparator

set UnixPath to POSIX path of (path to current application as text)
set UnixPath to replace_chars(UnixPath, "\\", "\\\\")
set UnixPath to replace_chars(UnixPath, "'", "\\'")
set UnixPath2 to UnixPath & "Contents/Resources/Pkgs/"
set UnixPath3 to UnixPath & "Contents/Resources/Scripts/"
set UnixPath4 to UnixPath & "Contents/"
set UnixPath5 to UnixPath & "Contents/Resources/.p.enc.bin"

#Do not run if this program is executed after specified date
set exp_date to do shell script "openssl enc -base64 -d -a <<< '" & exp_date & "'"
set current_date to do shell script "date -u +%s"
if current_date is greater than or equal to exp_date then
	display dialog "This installation package has expired! Now quitting..." with title "SkeleKey-Packages" buttons "OK" default button 1
	quit
end if

#Decryption Passwords
try
	set dec to do shell script "openssl enc -aes-256-cbc -d -in $'" & UnixPath5 & "' -pass pass:" & vkey
	set pws to paragraphs of dec
on error
	display dialog "ERROR! Could not decrypt!" with title "SkeleKey-Packages" buttons "OK" default button 1
	quit
end try

#Attempt to authenticate with all passwords located in the secure password array
repeat with pw in pws
	try
		do shell script "sudo echo elevate" user name "stuadmin" password pw with administrator privileges
		set pw_now to pw
		exit repeat
	end try
end repeat

try
	set pw to pw_now
on error
	display dialog "ERROR! Could not authenticate!" with title "SkeleKey-Packages" buttons "OK" default button 1
	quit
end try

#Attempt to install all packages located in the pkgs folder assuming they are allowed below
set allowed_pkgs to {"Capstone.pkg"}
try
	set pkg_names to do shell script "cd $'" & UnixPath2 & "'; ls *.pkg"
	set pkg_names to paragraphs of pkg_names
on error
	display dialog "ERROR! Could not find payload!" with title "SkeleKey-Packages" buttons "OK" default button 1
	quit
end try

set trusted_pkgs to comparator(allowed_pkgs, pkg_names)

repeat with pkg in trusted_pkgs
	try
		do shell script "cd $'" & UnixPath2 & "'; sudo installer -allowUntrusted -pkg \"" & pkg & "\" -target /" user name "stuadmin" password pw with administrator privileges
		display notification "Successfully Installed:" & space & pkg with title "SkeleKey-Packages"
	on error
		display dialog "ERROR! Could not install " & pkg & "!" with title "SkeleKey-Packages" buttons "OK" default button 1
	end try
end repeat