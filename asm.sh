#!/bin/sh
src=$1
shift
cat startup.s $src |tepasm/tepasm -f -  $*
