#!/bin/sh

# Behaves like a browser. 
COOKIE_LINE="--cookie /tmp/cookiesShtw.txt --cookie-jar /tmp/cookiesShtw.txt --user-agent Mozilla/4.0"

# ./twitter login <user> <passwd>
# Ret = Logged in
f_login() {
	shift	
	# Submit login through form post. 
	curl -s $COOKIE_LINE --data "username=$1" --data "password=$2" --data 'commit=Sign In' https://mobile.twitter.com/session
	echo "\nLogged in"
}

# ./twitter say <what is happening>
# Ret = Done
f_say () {
	shift

	# Encode text
	R=`echo "$@" | sed -e 's/ /\%20/g'`

	# Get authentication code. 
	auth=`curl -s $COOKIE_LINE http://mobile.twitter.com`
	auth=`echo $auth | sed -n -e "s/.*<form action=\"http:\/\/mobile.twitter.com\/\"\(.*\)<input type=\"submit\" value=\"Tweet\" class=\"tweet-btns\"\/>.*/\1/p"`
	auth=`echo $auth | sed -n -e "s/.*<input name=\"authenticity_token\" type=\"hidden\" value=\"\(.*\)\" \/>.*/\1/p"`

	# Submit tweet through form post. 
	curl -s $COOKIE_LINE --data "tweet[text]=$R" --data "authenticity_token=$auth" --data 'submit=Tweet' https://mobile.twitter.com
	echo "\nDone"
}

# ./twitter see
# Ret = Formatted timeline.
f_see () {
	# Get the timeline
	R=`curl -s $COOKIE_LINE http://mobile.twitter.com`
 
	# Format timeline: time \n person \n message \n\n. 
	R=`echo "$R" | sed -n -e "s/.*<strong><a href=\"http:\/\/mobile.twitter.com\/\(.*\)\">\(.*\)<\/a><\/strong>.*/\1/p" \
		              -e "s/.*class=\"status_link\">\(.*\)<\/a>.*/\1/p" 	\
		              -e "s/.*<span class=\"status\">\(.*\)<\/span>.*/\1\n------------\n/p"`

	echo "$R"
}

# Check option and take action
case $1 in
"login" ) f_login "$@" ;;
"say") f_say "$@" ;;
"see") f_see ;;
*) echo "Usage: $0 [login <user> <passwd> | say <text> | see ]"
esac


