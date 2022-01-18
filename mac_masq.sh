#!/bin/bash
interfaces=( $(netstat -in | egrep 'utun\d .*\d+\.\d+\.\d+\.\d+' | cut -d ' ' -f 1) )
rulefile="rules.tmp"
echo "" > $rulefile
sudo pfctl -a com.apple/tun -F nat
for i in "${interfaces[@]}"
do
  RULE="nat on ${i} proto {tcp, udp, icmp} from 192.168.64.0/24 to any -> ${i}"
  echo "RULE:"$RULE
  echo $RULE >> $rulefile
done
echo "pass in log on bridge0 inet all flags S/SA keep state tag cisco_anyconnect_vpn_pass"  >> $rulefile
echo "pass in log on bridge100 inet all flags S/SA keep state tag cisco_anyconnect_vpn_pass"  >> $rulefile
sudo pfctl -a com.apple/tun -f $rulefile

# references:
## https://gist.github.com/mowings/633a16372fb30ee652336c8417091222
## https://unix.stackexchange.com/questions/106304/route-add-no-longer-works-when-i-connected-to-vpn-via-cisco-anyconnect-client/501094#501094
