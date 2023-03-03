#!/bin/sh
src=$1
shift
cat startup.s $src trap.s | tepasm/tepasm -f -  $* -l timer.asm
