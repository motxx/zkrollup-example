#!/bin/sh

set -eu

if [ $# != 1 ]; then
  echo 'specify num'
  exit 1
fi

num=$1
fname="pot${num}_0000.ptau"
fname_aft="pot${num}_0001.ptau"

snarkjs powersoftau new bn128 $num $fname
snarkjs powersoftau contribute $fname $fname_aft --name="First contribution"
