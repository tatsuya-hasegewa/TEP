#!/bin/sh
set -x
src=$1
shift
cat startup.s $src trap.s | tepasm/tepasm -f -  $* -l out.asm
