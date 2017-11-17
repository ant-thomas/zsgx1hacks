#!/bin/sh

# If id command returns zero, you have root access.
if [ $(id -u) -eq 0 ]; then 
	# You are root, set red colour prompt
	PS1="\e[0;31m[\\u@\\h:\\w]\e[m $"
else 
	# Normal user so green prompt
	PS1="\e[0;32m[\\u@\\h:\\w]\e[m $"
fi
