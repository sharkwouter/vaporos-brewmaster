#!/bin/bash


# remove old pool
if [ -d pool ]; then
	rm -rf pool
fi

# redownload all packages
for i in steamos debian backports steamos-tools; do
	./downloadpackages.sh update autobuild-config/$i.repo
	./downloadpackages.sh download `cat autobuild-config/$i.packages|tr "\n" "\ "`
done

# sync vaporos packages
rsync -av vaporos-packages/ pool

# done
