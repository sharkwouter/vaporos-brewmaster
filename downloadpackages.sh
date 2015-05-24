#!/bin/bash

# set variables
sources="sources.list"
repopkglist="packages.txt"
downloaddir="packages"

# This function will print instructions for how to use this program
usage ( ) {
        echo "Usage: $0 update"
        echo "       $0 upgrade"
        echo "       $0 download pkg1 [pkg2 ...]"
	echo ""
	echo "$0 is a script designed for downloading and upgrading packages used in your Stephenson's Rocket mod. It uses the ${sources} file to when updating the list of packages found in${repopkglist} and downloads packages to ${downloaddir}."
	echo ""
	echo "Commands:"
	echo "  update - Create ${repopkglist} with all packages found in the repos in ${sources}"
	echo "  upgrade - Download the latest version of all packages found in packages to ${downloaddir}"
	echo "  download - Download new packages" 
	exit 1
}

update ( ) {
	# create an empty file which we will later use to list all packages
	> ${repopkglist}

	echo "Updating list of packages found in the repositories listed in the ${sources} file"
	while read repo; do
	 	# ignore line which don't start with deb
		if [[ "$(echo ${repo}|cut -d" " -f1)" = "deb" ]]; then 
			# get required info from repo string
			repourl=$(echo $repo|cut -d" " -f2)
			reponame=$(echo $repo|cut -d" " -f3)
			repoareas=$(echo $repo|cut -d" " -f4-)
			for area in ${repoareas}; do
				for arch in i386 amd64 all; do
					url="${repourl}/dists/${reponame}/${area}/binary-${arch}/Packages.gz"
					curl -sSL ${url} | gunzip -cq | grep '^Filename:'|cut -d " " -f 2- | sed "s#^#${repourl}/#g" >> ${repopkglist}
                        	done
               		done
        	fi
	done < ${sources}
	echo "$(grep -c 'pool' ${repopkglist}) packages found"
}

upgrade ( ) {
	echo "Upgrading packages"
	mkdir -p ${downloaddir}
	existingpkgs=$(ls packages|grep '.deb$')
	for package in ${existingpkgs}; do
		
		# determine architecture of package
		arch=$(echo ${package}|cut -d "_" -f3|cut -d "." -f1)
		packagesn="/$(echo ${package}|cut -d ":" -f1)_"
		latestpkg=$(grep ${packagesn} ${repopkglist}|grep "_${arch}\.\|_all\."|sort -t "/" -k9 -V -r|head -1)
		if [ ! -z "$latestpkg" ]; then
			cd ${downloaddir}
			wget -nc $(grep ${packagesn} ${repopkglist}|grep "_${arch}\.\|_all\."|sort -t "/" -k9 -V -r|head -1)
			cd - > /dev/null
		fi
	done
}

download ( ) {
	echo "downloading ${clioptions}"
	mkdir -p ${downloaddir}
	for package in ${clioptions}; do
		echo -e "\n${package}"
		
		# determine architecture of package
		arch=$(echo ${package}|cut -d ":" -f2)
		if [ "$arch" != "amd64" ] && [ "$arch" != "i386" ]; then
			arch="amd64";
		fi
		packagesn="/$(echo ${package}|cut -d ":" -f1)_"
		matches=$(grep ${packagesn} ${repopkglist}|grep "_${arch}\.\|_all\."|sort -t "/" -k9 -V -r)
		if [[ "$?" > 0 ]];then
			echo "${package} not found in any of the repositories in ${sources}"
			break;
		fi
		echo ${matches}|tr "\ " "\n"|nl
		echo -e "\nWhich version do you want?:"
		while true; do
			read choice
			if [[ "${choice}" > 0 ]] && [[ "$choice" < "$(expr $(echo ${matches}|wc -w) + 1 )" ]]; then
				break;
			else
				echo "${choice} is not a valid option"
			fi
		done	
		cd ${downloaddir}
		wget -nc $(echo ${matches}|tr "\ " "\n"|sed -n "${choice}p")
		cd - > /dev/null
	done
}



# read command line option
whattodo="$1"
shift
clioptions="$@"

# execute function based on command line option
case "${whattodo}" in
	"update")
		update
	;;
	"upgrade")
		upgrade
	;;
	"download")
		shift
		download
	;;
	"")
		echo "No option specified"
		usage
	;;
	*)
		echo "Unknown option $1"
		usage
	;;
esac
