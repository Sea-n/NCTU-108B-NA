#!/bin/bash

credit=$1

echo "dn: cn=TA,ou=People,dc=0816146,dc=nasa
changetype: modify
replace: ludoucredit
ludoucredit: $credit" \
|ldapmodify -H ldap://ldap1.0816146.nasa -D cn=admin,dc=0816146,dc=nasa -x -w 22366457
