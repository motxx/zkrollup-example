include "../circomlib/circuits/smt/smtprocessor.circom";

template Rollup() {
    signal private input a;
    signal private input b;
    signal output out;

    component smtprocessor = SMTProcessor(4);

    out <== a*b;
}

component main = Rollup();
