#!/bin/bash
#zoom crackly audio fix for JAMF
#v0.1
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
i="6"
#stop and start the core audio daemon
launchctl stop com.apple.audio.coreaudiod && launchctl start com.apple.audio.coreaudiod
#as current user, ask zoom to quit, then suppress the error that Zoom always give
sudo -u "$currentUser" osascript -e 'tell app "zoom.us" to quit' || echo "it's fine"
#check every ten seconds if zoom is open for
echo "check 1"
while [[ $( ps aux | grep -v "grep" | grep -c "zoom.us.app" ) != 0 && $i != 0 ]] ; do
    sleep 10
    ((--i))
    echo "$i tries left"
done
#if zoom is still running, fail
ps aux | grep -v "grep" | grep -c "zoom.us.app"
echo "check 2"
if [[ $( ps aux | grep -v "grep" | grep -c "zoom.us.app" ) != 0 ]] ; then
	echo "Zoom's still open"
    say "please close your zoom meeting and try again"
    exit 1
#if zoom isn't running, open it as current user
elif [[ $( ps aux | grep -v "grep" | grep -c "zoom.us.app" ) = 0 ]] ; then
	sudo -u "$currentUser" open /Applications/zoom.us.app
    exit 0
fi