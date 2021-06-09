#!/bin/sh

set -eu

if [ $# -lt 2 ]; then
  echo 'specify num and circom name'
  exit 1
fi

num=$1
circom_name=$2
tau_fname="pot${num}_0000.ptau"
tau_fname_aft="pot${num}_0001.ptau"
tau_fname_final="pot${num}_final.ptau"

# rm -f *.r1cs *.sym *.wasm *.ptau

# phase 1
if [ $3 -eq 1 ]; then
  snarkjs powersoftau new bn128 $num $tau_fname -v
  snarkjs powersoftau contribute $tau_fname $tau_fname_aft --name="First contribution" -v
  # prepare phase 2
  snarkjs powersoftau prepare phase2 $tau_fname_aft $tau_fname_final
fi

# compile
if [ $4 -eq 1 ]; then
  circom ${circom_name}.circom --r1cs --wasm --sym
fi

# phase 2
snarkjs zkey new ${circom_name}.r1cs $tau_fname_final ${circom_name}_0000.zkey
snarkjs zkey contribute ${circom_name}_0000.zkey ${circom_name}_final.zkey --name="1st Contributor Name"

snarkjs zkey export verificationkey ${circom_name}_final.zkey verification_key.json

snarkjs powersoftau verify $tau_fname_final
snarkjs zkey verify ${circom_name}.r1cs $tau_fname_final ${circom_name}_final.zkey
