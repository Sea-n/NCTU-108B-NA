#!/bin/bash
cd "`dirname $0`"

mv db.sshfp{,.bak}

for host in router ns1 ns2 agent; do
	ssh-keyscan -T 1 $host 2> /dev/null |cut -d ' ' -f 2- > $host.pub

	grep ecdsa $host.pub > $host-ecdsa.pub
	grep ed25519 $host.pub > $host-ed25519.pub

	ssh-keygen -r $host -f $host-ecdsa.pub   |grep ' IN SSHFP 3 2 ' |tr ' ' '\t' |tee -a db.sshfp
	ssh-keygen -r $host -f $host-ed25519.pub |grep ' IN SSHFP 4 2 ' |tr ' ' '\t' |tee -a db.sshfp
done
