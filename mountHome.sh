\\seroisfile.sero.gic.ericsson.se\home\ezhoyux
\\vhub.rnd.ki.sw.ericsson.se\home\ezhoyux

# mount gic home to ubuntu
sudo mkdir /mnt/$USER_gichome
sudo mount -t cifs -o rw,vers=3.0,user=$USER //seroisfile.sero.gic.ericsson.se/home/$USER /mnt/$USER_gichome
