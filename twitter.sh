#!/bin/sh

# Behaves like a browser. 
COOKIE_LINE="--cookie /tmp/cookiesShtw.txt --cookie-jar /tmp/cookiesShtw.txt --user-agent Mozilla/4.0"

# ./twitter login <user> <passwd>
# Ret = Logged in
f_login() {
	shift	
	# Submit login through form post. 
	Resp=`curl -s $COOKIE_LINE --data "username=$1" --data "password=$2" --data 'commit=Sign In' https://mobile.twitter.com/session > /dev/null`
	echo "Logged in"
}

# ./twitter logout
# Ret = Logged out
f_logout() {
	shift	
	# Submit login through form post. 
	Resp=`curl -s $COOKIE_LINE https://mobile.twitter.com/session/destroy > /dev/null`
	rm /tmp/cookiesShtw.txt
	echo "Logged out"
}


# ./twitter say <what is happening>
# Ret = Done
f_say () {
	shift

	# Encode text
	R=`echo "$@" | perl -n -e 's/ /\%20/g && print'`

	# Get authentication code. 
	auth=`curl -s $COOKIE_LINE http://mobile.twitter.com`
	auth=`echo $auth | perl -n -e '(/<form action="http:\/\/mobile.twitter.com\/"(.*)<input type="submit" value="Tweet" class="tweet-btns"\/>/ && print "$1") '`
	auth=`echo $auth | perl -n -e '(/<input name="authenticity_token" type="hidden" value="(.*)" \/>(.*)/ && print "$1")'`

	# Submit tweet through form post. 
	Resp=`curl -s $COOKIE_LINE --data "tweet[text]=$R" --data "authenticity_token=$auth" --data 'submit=Tweet' http://mobile.twitter.com`
	echo "\nDone"
}

# ./twitter see
# Ret = Formatted timeline.
f_see () {
	# Get the timeline
	R=`curl -s $COOKIE_LINE http://mobile.twitter.com`

	R=`echo "$R" | perl -n -e '
   (/<strong><a href="http:\/\/mobile.twitter.com\/(.*)">(.*)<\/a><\/strong>/ && print "\n$2 says:") 
|| (/<span class="status">(.*)(<a rel="nofollow" href="(.*)" target="_blank" class="twitter_external_link">(.*)<\/a>(.*))+<\/span>/ && print " $1($3)\n") 
|| (/<span class="status">(.*)<\/span>/ && print " $1\n") 
|| (/class="status_link">(.*)<\/a>/ && print "-- $1\n")
|| (/timeline-user/ && exit(0))'`
	echo "$R"
}

# Check option and take action
case $1 in
"login" ) f_login "$@" ;;
"logout" ) f_logout "$@" ;;
"say") f_say "$@" ;;
"see") f_see ;;
*) echo "Usage: $0 [login <user> <passwd> | say <text> | see ]"
esac


