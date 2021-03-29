#!/bin/bash

nc -w 0 -v ldap1.0816146.nasa 389 &> /dev/null
nc -w 0 -v agent.0816146.nasa 5566

exit $?
