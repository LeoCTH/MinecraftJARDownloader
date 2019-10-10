#!/bin/bash

#
# Minecraft JAR Downloader
# by LeoCTH,
# ver 1.0 finished @ 2019/10/10
#
# Description:
# As its name indicates, this single shell file downloads Minecraft client a/o server JARs.
# This shell uses a service called BMCLAPI, a popular image site within China.
# (which you can learn more here -> bmclapi.bangbang93.com (in Chinese))
# (supporting downloading native sources i.e. launcher.mojang.com
#  will be added in a future release.)
#
# Licensing:
# All source files published on GitHub by me (LeoCTH), UNLESS SPECIFIED, are licensed
# under the MIT License. Do NOT redistribute to platforms other than GitHub unless
# you are granted by me, the author, to do so.
#
# And PLEASE don't be a jerk who steals other people's work and added their own name on it, okay?
#
# And a final ProTip: this code is foldable :) (tested on Notepad++, which I edited this file on)
#

# darn this is a long intro. let's get to the code quickly
{

#Download functions
{
regex='v\d/objects/[0-9a-f]{40}/(client|server).jar' # ahh yes errorprone
# TODO im definitely combining these two together
function downloadServer() {
	if [ x$1 == x ]
	then
		#test args
		echo "Not enough arguments! Expected a version argument"
		return 255
	fi
	
	echo "Downloading $1 Server"
	echo "-----"
	echo "Retrieving file link from BMCLAPI2 (by bangbang93)..."
	curl -# "https://bmclapi2.bangbang93.com/version/$1/server" -o link.tmp --retry-max-time 60
	echo ""
	echo "Link retrieved."
	
	suburl=$(cat link.tmp | grep -oiP -e $regex) # REGEX
	echo "SubUrl: $suburl"
	fullurl=https://launcher.mojang.com/$suburl
	echo "FullUrl: $fullurl"
	echo ""
	
	localDir="./jars/$1/minecraft_server.$1.jar"
	
	if [[ -f $localDir && $f -eq 0 ]]
	then
		# I don't want to waste your time so lol.
		echo "Local file already exists; use -f flag to force download."
	else
		echo "Saving into $localDir"
		curl $fullurl -# -o ./jars/$1/minecraft_server.$1.jar --retry-max-time 60
	fi
	rm link.tmp #clean up
}

function downloadClient() {
	if [ x$1 == x ]
	then
		#test args
		echo "Not enough arguments! Expected a version argument"
		return 255
	fi
	
	echo "Downloading $1 Client"
	echo "-----"
	echo "Retrieving file link from BMCLAPI2 (by bangbang93)..."
	curl -# "https://bmclapi2.bangbang93.com/version/$1/client" -o link.tmp --retry-max-time 60
	echo "Link retrieved."
	
	suburl=$(cat link.tmp | grep -oiP -e $regex) # REGEX
	echo "SubUrl: $suburl"
	fullurl=https://launcher.mojang.com/$suburl
	echo "FullUrl: $fullurl"
	
	localDir="./jars/$1/minecraft_client.$1.jar"
	
	if [[ -f $localDir && $f -eq 0 ]]
	then
		# I don't want to waste your time so lol.
		echo "Local file already exists; use -f flag to force downloading".
	else
		echo "Saving into $localDir"
		curl $fullurl -# -o ./jars/$1/minecraft_client.$1.jar --retry-max-time 60
	fi
	
	rm link.tmp #clean up
}
}

#Print help :)
function get_help_dude() {
	# pretty
	echo ""
	echo "$(basename $0): $(basename $0) [-hf] [-t type] [versions to install...]"
	echo "    Downloads a Minecraft server/client JAR."
	echo ""
	echo "    Options:"
	echo "      -t  Type of Minecraft JAR to download."
	echo "          Valid values: [s]erver, [c]lient, or [b]oth."
	echo "      -h  Display this help page."
	echo "      -f  Force overriding existing files."
}

# Retrieving arguments
{
f=0
args=0 #pffff

# yeah boi this is where mah magic comes in
while getopts ":ht:f" opt
do
	case $opt in
		h)
		get_help_dude; exit;;
		
		t)
		typ=$OPTARG;
		args=`expr $args + 1`
		if [ x$typ != x ]; then args=`expr $args + 1`; fi;;
		
		f)
		f=1; args=`expr $args + 1`;;
		
		?)
		echo "Unrecognized argument(s)!"
		get_help_dude; exit;;
		
	esac
done

shift $args # remove options

if [[ x$@ == x || y$typ == y ]]
then
	echo "Invalid syntax/Not enough arguments!"
	get_help_dude; exit
fi

}

# Download
{
echo "============================"
echo "| Minecraft JAR Downloader |"
echo "| version 1.0 - by LeoCTH  |"
echo "============================"

for version in $@
do
{
	echo ""
	echo "Creating target folder for version $version"
	if [ ! -d "./jars/$version" ]
	then
		mkdir ./jars/$version
	fi

	if [ $f -ne 0 ]
	then
		echo "Force override (-f) flag enabled."
	fi

	echo ""
	echo "Downloading $version"
	echo ""
	
	if [ $typ == s ]
	then
		downloadServer $version
	elif [ $typ == c ]
	then
		downloadClient $version
	elif [ $typ == b ]
	then
		downloadServer $version
		downloadClient $version
	else
		echo "Invalid argument for jar type!"
		get_help_dude; exit
	fi
}
done

echo ""
echo "All downloading complete."
echo ""
read -p "Press any key to quit..."
exit
}

}