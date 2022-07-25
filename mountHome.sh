\\seroisfile.sero.gic.ericsson.se\home\ezhoyux
\\vhub.rnd.ki.sw.ericsson.se\home\ezhoyux

# mount gic home to ubuntu
GICHOME_FOLDER="$HOME"/"$USER"_gichome
sudo mkdir -p $GICHOME_FOLDER
sudo mount -t cifs -o rw,vers=3.0,user=$USER //seroisfile.sero.gic.ericsson.se/home/$USER $GICHOME_FOLDER



## {add below lines to .profile file

# if gichome folder is created, mount gic home
GICHOME_FOLDER="$HOME"/"$USER"_gichome
if [ -d "$GICHOME_FOLDER" ] ; then
    if grep -qs $GICHOME_FOLDER /proc/mounts ; then
        echo "GIC home is mounted on $GICHOME_FOLDER"
    else
        echo "Mounting GIC home, ctrl-c to cancel!!!"
        sudo mount -t cifs -o rw,vers=3.0,user=$USER //seroisfile.sero.gic.ericsson.se/home/$USER $GICHOME_FOLDER
    fi
fi

## }add below lines to .profile file


# mount gic home on macos
GICHOME_FOLDER="$HOME"/gichome
sudo mkdir -p $GICHOME_FOLDER
mount_smbfs //$USER@seroisfile.sero.gic.ericsson.se/home/$USER $GICHOME_FOLDER
