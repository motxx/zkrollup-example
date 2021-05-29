include "./circomlib/smt/smtprocessor.circom";

template Rollup(nUpdates, nLevels) {
    signal input oldRoot;
    signal output newRoot;
    signal intermediateRoot;

    signal private input siblings[nUpdates][nLevels];
    signal private input oldKey[nUpdates];
    signal private input oldValue[nUpdates];
    signal private input isOld0[nUpdates];
    signal private input newKey[nUpdates];
    signal private input newValue[nUpdates];
    signal private input fnc[nUpdates][2];

    intermediateRoot <== oldRoot;

    var i;
    var j;

    for (i = 0; i < nUpdates; i++) {
        component proc = SMTProcessor(nLevels);
        proc.oldRoot <== intermediateRoot;
        for (j = 0; j < nLevels; j++) {
            proc.siblings[j] <== siblings[i][j];
        }
        proc.oldKey <== oldKey[i];
        proc.oldValue <== oldValue[i];
        proc.isOld0 <== isOld0[i];
        proc.newKey <== newKey[i];
        proc.newValue <== newValue[i];
        for (j = 0; j < 2; j++) {
            proc.fnc[j] <== fnc[i][j];
        }
        intermediateRoot <== proc.newRoot;
//        log(proc.siblings);
        log(proc.oldKey);
        log(proc.oldValue);
        log(proc.isOld0);
        log(proc.newKey);
        log(proc.newValue);
        log(intermediateRoot);
    }

    newRoot <== intermediateRoot;
}

component main = Rollup(1, 2);
