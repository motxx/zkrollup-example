#!/bin/sh

set -eu

if [ $# -ne 2 ]; then
  echo 'specify circom name and input json filename'
  exit 1
fi

circom_name=$1
input_name=$2

snarkjs wtns calculate ${circom_name}.wasm input.json witness.wtns

snarkjs groth16 prove ${circom_name}_final.zkey witness.wtns proof.json public.json
