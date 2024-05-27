# How to get tls certificate on Android TV Box



## Android TVBox

 android 4.4

 sshdroid with root

  static-web-server

  socat or ssh



### The idea is using port forwarding to forward TVBox http port 80 to another environment (so called off-target) that could run acme.sh and apache. 

Could not find proper way to acme.sh on Android TVBox, old software, dependency missing and etc.

The off-target environment could be any machine either in private network or public network, as long as it could be reached by TVBox.

### On TVBox shell

```bash
#find DNS that telia gives
PUBIP=$(curl -k --silent https://api.ipify.org)
nslookup $PUBIP
Server:    0.0.0.0
Address 1: 0.0.0.0

Name:      xx.xx.xx.xx
Address 1: xx.xx.xx.xx xx-xx-xx-xx-noyyyy.tbcn.telia.com

#offtarget env could be reached at 192.168.1.120:3128
OFFTARGET=192.168.1.120
socat TCP-LISTEN:80,fork TCP:$OFFTARGET:3128
```



### Create a free account on zeroSSL

Navigate to Developer option on left panel, "Generate" EAB Credentials for ACME Clients.

Save generated EAB credentials: eab-kid and eab-hmac-key.

![image-20240527203314726](static/images/TlsCertsonTVBox/image-20240527203314726.png)



```bash
docker run -d --name apache2-container -v /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt -e TZ=UTC -p 3128:80 ubuntu/apache2:2.4-22.04_beta

#get into bash
docker exec -it apache2-container bash
```



```bash
apt install openssl

curl https://get.acme.sh | sh -s email=user@example.com --force --install

#register zerossl eab account in acme.sh
sh acme.sh --register-account -m user@example.com --eab-kid L2L51-XXXXXXXXXXX --eab-hmac-key ONoznjJ2oDDGDSGDSGDSFSDFDSFtYOcM9ewXWBGPZiBO6vyM-_YYYYYYYYYYY_qXXXXXXXXXXX

sh ./acme.sh --issue -d xx-xx-xx-xx-noyyyy.tbcn.telia.com -w /var/www/html --insecure --force --debug 3 -k ec-256 -ak 2048


...

[Mon May 27 15:00:07 UTC 2024] Your cert is in: /root/.acme.sh/xx-xx-xx-xx-noyyyy.tbcn.telia.com_ecc/7xx-xx-xx-xx-noyyyy.tbcn.telia.com.cer
[Mon May 27 15:00:07 UTC 2024] Your cert key is in: /root/.acme.sh/xx-xx-xx-xx-noyyyy.tbcn.telia.com__ecc/xx-xx-xx-xx-noyyyy.tbcn.telia.com_.key
[Mon May 27 15:00:07 UTC 2024] APP
[Mon May 27 15:00:07 UTC 2024] 13:USER_PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
[Mon May 27 15:00:07 UTC 2024] The intermediate CA cert is in: /root/.acme.sh/xx-xx-xx-xx-noyyyy.tbcn.telia.com__ecc/ca.cer
[Mon May 27 15:00:07 UTC 2024] And the full chain certs is there: /root/.acme.sh/xx-xx-xx-xx-noyyyy.tbcn.telia.com__ecc/fullchain.cer

```

Then copy our .cer and .key from docker shell , or download from zerossl dashbaord to TVBox and use them. 



Next time , when needs to renew certs, probably run 

```bash
sh ./acme.sh --renew -d xx-xx-xx-xx-noyyyy.tbcn.telia.com_ -w /var/www/html --insecure --force --debug 3 -k ec-256 -ak 2048
```

