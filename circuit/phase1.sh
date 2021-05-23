#!/bin/sh

set -eu

snarkjs powersoftau new bn128 14 pot12_0000.ptau
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution"
