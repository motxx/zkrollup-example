include "./circomlib/smt/smtprocessor.circom";

template Rollup(nUpdates, nLevels) {
    signal input oldRoot;
    signal output newRoot;
    signal intermediateRoot;

    signal private input siblings[nLevels][nUpdates];
    signal private input oldKey[nUpdates];
    signal private input oldValue[nUpdates];
    signal private input isOld0[nUpdates];
    signal private input newKey[nUpdates];
    signal private input newValue[nUpdates];
    signal private input fnc[2][nUpdates];

    intermediateRoot <== oldRoot;

    var i;
    var j;

    for (i = 0; i < nUpdates; i++) {
        component proc = SMTProcessor(nLevels);
        proc.oldRoot <== intermediateRoot;
        for (j = 0; j < nLevels; j++) {
            proc.siblings[j] <== siblings[j][i];
        }
        proc.oldKey <== oldKey[i];
        proc.oldValue <== oldValue[i];
        proc.isOld0 <== isOld0[i];
        proc.newKey <== newKey[i];
        proc.newValue <== newValue[i];
        for (j = 0; j < 2; j++) {
            proc.fnc[j] <== fnc[j][i];
        }
        intermediateRoot <== proc.newRoot;
    }

    newRoot <== intermediateRoot;
}

component main = Rollup(4, 4);
