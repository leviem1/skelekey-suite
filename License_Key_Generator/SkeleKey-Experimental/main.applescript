--
--  main.applescript
--  SkeleKey-LicenseKeyGenerator
--
--  Created by Mark Hedrick on 02/23/16.
--  Copyright (c) 2016 Mark Hedrick. All rights reserved.
--
set lickey to ""
set orgexists to "0"
display dialog "This software should only be used by the SkeleKey Team"
set myname to display dialog "Please enter the customer's name:" default answer "" buttons {"OK"} default button 1 with title "SkeleKey License Manager"
set myemail to display dialog "Please enter the customer's email address:" default answer "" buttons {"OK"} default button 1 with title "SkeleKey License Manager"
set myorg to display dialog "Please enter the customer's organization (optional):" default answer "" buttons {"OK"} default button 1 with title "SkeleKey License Manager"
set myname to text returned of myname
set myemail to text returned of myemail
set myorg to text returned of myorg

on licensekeygen(myname, myemail, myorg, orgexists)
	if myorg is not equal to "" then
		set orgexists to "1"
	end if
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
	
	if orgexists is equal to "1" then
		set lickey to "SK-" & e_me & "-" & e_mn & "-" & e_mo as string
		set lickey to do shell script "printf '" & lickey & "' | tr '[a-z]' '[A-Z]'"
	else
		set lickey to "SK-" & e_me & "-" & e_mn & "-" & e_me2 as string
		set lickey to do shell script "printf '" & lickey & "' | tr '[a-z]' '[A-Z]'"
	end if
	return lickey
end licensekeygen

set lickeynum to licensekeygen(myname, myemail, myorg, orgexists)
display dialog "License Key: " & lickeynum