# stephensons-rocket-mod
This is a template for Stephenson's Rocket mods.

To create a mod for Stephenson's rocket, you first clone the stephenson's rocket repo:

    git clone --depth=1 https://github.com/steamos-community/stephensons-rocket.git

After you've done that move into the newly created repo and clone this repo like this:

    cd stephensons-rocket
    git clone https://github.com/steamos-community/stephensons-rocket-mod.git

Now you can start working on your mod. It can be found in stephensons-rocket/stephensons-rocket-mod/ by default, but feel free to rename the directory to better reflect it's function. New packages are placed in the directory packages and are installed when placed behind install= in the config file. Packages behind remove= in the config file will be removed from the pool before installing your mod.

Using your own post_install.sh script is also possible, just put your version in your mod directory.

Make sure all the repos you used to download packages can be found in the sources.list file of your mod.

If you want to generate an iso with your mod, just run:

    ./gen.sh yourmod

That's it, good luck!
