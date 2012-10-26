#!/bin/bash

# get_cfx.sh script
# by bananagranola @ http://forum.xda-developers.com/member.php?u=4733042 
# DESCRIPTION
# gets the relevant pages at synergye.codefi.re
# extracts the filenames and finds the newest ones
# compares the current newest files to the previous newest files from a text file
# saves the current newest files to a text file

# CUSTOMIZE HERE
# register at https://www.notifymyandroid.com/register.jsp 
# go to "my account" and get an api key
# put the api key in a text file named nma_api.txt 
# place nma_api.txt in the folder containing this script
apikey="$(cat nma_api.txt)"
#apikey="XXXXX"

# CUSTOMIZE HERE TOO
# add a field to the array for each folder you want to check on synergye.codefi.re
# note: assumes that you use the same folders between executions.
# if you change folders or their order, you might get a false positive the first time.
folders[0]="codefireX-Ace"
folders[1]="KangBang-Ace-Kernels"
folders[2]="Ace-TestBuilds"

# AND FINALLY CUSTOMIZE HERE (OPTIONAL)
# name of file used to save previous newest zip
text="get_cfx.txt"

# YOU CAN LEAVE EVERYTHING BELOW THIS UNCHANGED

# creates 2 arrays of the same length of folders
# used to store current and previous newest zips
size=${#folders[@]}
currs[$size]=""
prevs[$size]=""

# some hardcoded string variables
nma="https://www.notifymyandroid.com/publicapi/notify"
page="synergye.codefi.re"

# parses folder page
# outputs name of newest zip on synergye.codefi.re
# used in parseCurrs()
# $1: foldername on synergye.codefi.re; ie: codefireX-Ace
parseCurr () {
	# retrieve folder page
	page="$(wget -q -O - $page/$1)"
	latest=""

	# loop through lines in page
	for line in $page; do
		# find lines with downloadable zips
		if [[ $line == *download=* ]]; then
			# extract zip name
			regex=".*$1.\(.*zip\).*"
			filename=$(expr match "$line" $regex)
			# save newest zip
			if [[ "$filename" > "$latest" ]]; then
				latest=$filename
			fi
		fi
	done

	# output filename: newest zip
	echo "$1: $latest"
}

# parses filenames using parseCurr()
# populates currs[]
# no arguments
parseCurrs() {
	i=0
	while [ $i -lt $size ]; do
		currs[$i]=$(parseCurr ${folders[$i]})
		i=$(($i+1))
	done
}

# parses file containing previous newest zips
# populates prevs[]
# no arguments
parsePrevs() {
	# loops through lines in $text file
	i=0
	while read -r line; do
		# saves them in prevs[]
		prevs[i]="$line"
		i=$(($i+1))
	done < $text

	# update $size
	if [ $size -lt $i ]; then
		size=$i
	fi
}

# loops through and compares current newest zips with previous newest zips
# notifies using notifymyandroid api
# no arguments
compareAndNotify() {
	# loops through and compares current newest zips with previous newest zips
	i=0
	while [ $i -lt $size ]; do
		if [[ "${currs[$i]}" != "${prevs[$i]}" ]]; then
			# notifies using notifymyandroid api
    		#./nma.sh ${folders[$i]} ${currs[$i]} $page/${folders[$i]} 0
    		echo "nma.sh ${folders[$i]} ${currs[$i]} $page/${folders[$i]} 0"
		fi
		i=$(($i+1))
	done
}

# saves current newest zips into saved text file
# no arguments
save() {
	# empties $text file
    if [ -f $text ]; then
    	cat /dev/null > $text
    else
        touch $text
    fi
	
	# prints current newest zips into saved text file
	i=0
	while [ $i -le ${#currs[$i]} ]; do
		echo -e "${folders[$i]}: ${currs[$i]}" >> $text
		i=$(($i+1))
	done
}

# main
parseCurrs
parsePrevs
compareAndNotify
save

