<?php
$zone0_name = "0816146.nasa";
$zone1_name = "view.0816146.nasa";

$zone0 = "/etc/bind/dbs/db.nasa";
$zone1 = "/etc/bind/dbs/db.view1";
$zone2 = "/etc/bind/dbs/db.view22";
$zone3 = "/etc/bind/dbs/db.view87";

$KSK0 = "/etc/bind/keys/K0816146.nasa.KSK.key";
$ZSK0 = "/etc/bind/keys/K0816146.nasa.ZSK.key";
$KSK1 = "/etc/bind/keys/Kview.0816146.nasa.KSK.key";
$ZSK1 = "/etc/bind/keys/Kview.0816146.nasa.ZSK.key";

$serial = system("grep -i serial $zone0 |awk '{print $1}'");
if (empty($serial))
	exit("Zone file SOA serial not found.\n");

echo "=====> " . date("YmdHis") . "\n";

$today = date("Ymd");
$serial_day = substr($serial, 0, 8);
if ($today == $serial_day)
	$new_serial = $serial + 1;
else if ($serial_day < $today)
	$new_serial = $today . "00";

system("sed -i -e 's/$serial/$new_serial/g' $zone0");
system("sed -i -e 's/$serial/$new_serial/g' $zone1");
system("sed -i -e 's/$serial/$new_serial/g' $zone2");
system("sed -i -e 's/$serial/$new_serial/g' $zone3");

echo "serial\t" . gettype($new_serial) . "\t$new_serial\n";

system("dnssec-signzone -t -3 87 -H 87 -o $zone0_name -k $KSK0 $zone0 $ZSK0");
system("dnssec-signzone -t -3 87 -H 87 -o $zone1_name -k $KSK1 $zone1 $ZSK1");
system("dnssec-signzone -t -3 87 -H 87 -o $zone1_name -k $KSK1 $zone2 $ZSK1");
system("dnssec-signzone -t -3 87 -H 87 -o $zone1_name -k $KSK1 $zone3 $ZSK1");
system("service bind9 restart");
