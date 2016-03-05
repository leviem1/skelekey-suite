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
	set e_mn to do shell script "echo '" & myname & "' | rev | md5 | base64 | fold -w4 | paste -sd'1' - "
	set e_mn to characters 7 thru 11 of e_mn
	set e_me to do shell script "echo '" & myemail & "' | base64 | rev | md5| fold -w3 | paste -sd'4' - "
	set e_me to characters ((length of e_me) - 4) thru (length of e_me) of e_me
	set e_mo to do shell script "echo '" & myorg & "' | base64 | md5 | rev | fold -w3 | paste -sd'K' - "
	set e_mo to characters 4 thru 8 of e_mo
	
	set e_me2 to do shell script "echo '" & myemail & "' | md5 | md5 | base64| fold -w4 | paste -sd'A' - "
	set e_me2 to characters ((length of e_me2) - 4) thru (length of e_me2) of e_me2
	
	if orgexists is equal to "1" then
		set lickey to "SK-" & e_me & "-" & e_mn & "-" & e_mo as string
		set lickey to do shell script "echo '" & lickey & "' | tr '[a-z]' '[A-Z]'"
	else
		set lickey to "SK-" & e_me & "-" & e_mn & "-" & e_me2 as string
		set lickey to do shell script "echo '" & lickey & "' | tr '[a-z]' '[A-Z]'"
	end if
	return lickey
end licensekeygen

set lickeynum to licensekeygen(myname, myemail, myorg, orgexists)
display dialog "License Key: " & lickeynum