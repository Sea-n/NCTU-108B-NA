#!/bin/bash

name=$1
host=ldap1.0816146.nasa
base="ou=People,dc=0816146,dc=nasa"

ludou=`ldapsearch -x -h $host -b $base -s sub "(cn=$name)" \
|grep -oP 'ludoucredit: \K.*'`
if [ $ludou -le 0 ]; then
	exit
fi

ldapsearch -x -h $host -b $base -s sub "(cn=$name)" \
|sed -n '/^ /{H;d};/sshPublicKey:/x;$g;s/\n *//g;s/sshPublicKey: //gp'
