#!/bin/sh
# PS1="\\u@\\h:\\w$"

# If id command returns zero, you have root access.
if [ $(id -u) -eq 0 ];
then # you are root, set red colour prompt
  PS1="\e[0;31m[\\u@\\h:\\w]\e[m $"

else # normal
  PS1="\e[0;32m[\\u@\\h:\\w]\e[m $"
fi









