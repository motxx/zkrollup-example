#!/bin/sh

set -eu

# rm -f *.r1cs *.sym *.wasm *.ptau

circom circuit.circom --r1cs --wasm --sym

# phase 1
# snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau

snarkjs zkey new circuit.r1cs pot12_final.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey circuit_final.zkey --name="1st Contributor Name"

snarkjs zkey export verificationkey circuit_final.zkey verification_key.json

snarkjs powersoftau verify pot12_final.ptau
snarkjs zkey verify circuit.r1cs pot12_final.ptau circuit_final.zkey
