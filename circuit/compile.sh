#!/bin/sh

set -eu

if [ $# != 1 ]; then
  echo 'specify num'
  exit 1
fi

num=$1
taufname="pot${num}_0000.ptau"
taufname_aft="pot${num}_0001.ptau"
taufname_final="pot${num}_final.ptau"

# rm -f *.r1cs *.sym *.wasm *.ptau

circom circuit.circom --r1cs --wasm --sym

# phase 1
snarkjs powersoftau new bn128 $num $taufname -v
snarkjs powersoftau contribute $taufname $taufname_aft --name="First contribution" -v

# phase 2
snarkjs powersoftau prepare phase2 $taufname_aft $taufname_final

snarkjs zkey new circuit.r1cs $taufname_final circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey circuit_final.zkey --name="1st Contributor Name"

snarkjs zkey export verificationkey circuit_final.zkey verification_key.json

snarkjs powersoftau verify $taufname_final
snarkjs zkey verify circuit.r1cs $taufname_final circuit_final.zkey
