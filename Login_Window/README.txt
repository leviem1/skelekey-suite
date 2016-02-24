###########Login Window README########
Files:

autodiskmount.plist -- makes all volumes mount without user authentication

login_window.applescript -- actual script that runs at login window (make sure to read-only compile before distributing)

org.district70.SkeleKey-LoginWindow.plist -- watches to see change at login window

org.district70.SkeleKey.Launcher.sh -- calls the login_window.applescript file from the watcher plist

tcc_setup.txt -- my way of organizing what is needed for this script to run (and the commands to set them up). Still need to put those in a script somewhere.
