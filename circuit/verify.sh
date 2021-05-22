#!/bin/sh

set -eu

snarkjs groth16 verify verification_key.json public.json proof.json
