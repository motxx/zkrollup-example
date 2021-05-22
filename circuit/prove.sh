#!/bin/sh

set -eu

snarkjs wtns calculate circuit.wasm input.json witness.wtns

snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json
