#!/bin/bash

# set variables
sources="sources.list"
repopkglist="packages.txt"
packagedir="pool"

# This function will print instructions for how to use this program
usage ( ) {
        echo "Usage: $0 update [repolist file]"
        echo "       $0 upgrade [location of old packages]"
        echo "       $0 download pkg1 [pkg2 ...]"
	echo ""
	echo "$0 is a script designed for downloading and upgrading packages used in your Stephenson's Rocket mod. It uses the ${sources} file to when updating the list of packages found in${repopkglist} and downloads packages to ${packagedir}."
	echo ""
	echo "Commands:"
	echo "  update - Create ${repopkglist} with all packages found in the repos in ${sources}. Run this first to ensure the latest versions of packages are downloaded."
	echo "  upgrade - Download the latest version of all packages found in packages to ${packagedir}. Might still have some bugs, so carefully read what it is doing. Does not delete the old versions."
	echo "  download - Download new packages" 
	exit 1
}

# This function creates a list with all available packages in the repos listed in the $sources file or the user specified file
update ( ) {
	# create an empty file which we will later use to list all packages
	> ${repopkglist}

	# allow users to change sources.list file
	if [ ${clioptions} ]; then
		sources="${clioptions}"
	fi

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
					wget ${url} 
					gunzip -cq Packages.gz| grep '^Filename:'|cut -d " " -f 2- | sed "s#^#${repourl}/#g" >> ${repopkglist}
					rm Packages.gz
                        	done
               		done
        	fi
	done < ${sources}
	echo "$(grep -c 'pool' ${repopkglist}) packages found"
}

# This function tries to download the latest version of packages found in $packagedir or the user specified directory
upgrade ( ) {
	# check if the package list exists first
	if [ ! -e ${repopkglist} ]; then
		echo -e "Error: ${repopkglist} doesn't exist, run \"${0} update\" first\n"
		usage;
	fi

	# set directory with debs to check for updates
	if [ ${clioptions} ]; then
		upgradedir="${clioptions}"
	else
		upgradedir="${packagedir}"
	fi

	echo "Upgrading packages"
	mkdir -p ${packagedir}
	existingpkgs=$(find ${upgradedir} -name *.deb|rev|cut -f1 -d"/"|rev)
	for package in ${existingpkgs}; do
		pkgname=$(echo ${package}|cut -f1 -d"_")
		pkgarch=$(echo ${package}|cut -f3 -d"_")
		pkgversion=$(echo ${package}|cut -f2 -d"_")

		versions=$(grep "/${pkgname}_" ${repopkglist}|grep "_${pkgarch}"|cut -f2 -d "_")
		newest=$(echo "${pkgversion} ${versions}"|tr "\ " "\n"|sort -rV|head -1)
		if [ "${newest}" != "${pkgversion}" ]; then
			pkgdownloadurl=$(grep "/${pkgname}_" ${repopkglist}|grep "_${pkgarch}"|grep "${newest}"|head -1)
			downloaddir=$(echo ${pkgdownloadurl}|rev|cut -d"/" -f2-4|rev)
			mkdir -p ${packagedir}/${downloaddir}
			cd ${packagedir}/${downloaddir}
			echo -e "\nDownloading:\n${pkgname}_${newest}_${pkgarch}\nWill replace:\n${package}"
			echo "url: ${pkgdownloadurl}"
			wget -nc -q ${pkgdownloadurl}
			cd - > /dev/null
		fi
	done
}

# Downloads the packages the user specified, if available
download ( ) {
	# check if the package list exists first
	if [ ! -e ${repopkglist} ]; then
		echo -e "Error: ${repopkglist} doesn't exist, run \"${0} update\" first\n"
		usage;
	fi

	echo "downloading ${clioptions}"
	mkdir -p ${packagedir}
	for package in ${clioptions}; do
		echo -e "\n${package} $(echo ${clioptions}|tr "\ " "\n"|nl|grep ${package}|cut -f 1)/$(echo ${clioptions}|wc -w)"
		
		# determine architecture of package
		arch=$(echo ${package}|cut -d ":" -f2)
		if [ "$arch" != "amd64" ] && [ "$arch" != "i386" ]; then
			arch="amd64";
		fi
		packagesn="/$(echo ${package}|cut -d ":" -f1)_"
		matches=$(grep ${packagesn} ${repopkglist}|grep "_${arch}\.\|_all\."|sort|uniq)
		if [[ "$(echo ${matches}|wc -w)" == "0" ]];then
			echo -e "\n${package} not found in any of the repositories in ${sources}"
			break;
		fi
		if [ "$(echo ${matches}|wc -w)" == "1" ]; then
			choice="1"
		else
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
		fi
		downloadurl=$(echo ${matches}|tr "\ " "\n"|sed -n "${choice}p")
		downloaddir=$(echo ${downloadurl}|rev|cut -d"/" -f2-4|rev)
		mkdir -p ${packagedir}/${downloaddir}
		cd ${packagedir}/${downloaddir}
		wget -nc ${downloadurl}
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
