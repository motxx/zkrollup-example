include "./circomlib/smt/smtprocessor.circom";

template Rollup(nTxs) {

    signal input oldRoot;
    signal output newRoot;

    // TODO: nLevels - JSのoperationごとに変わる値. どうしよう.
    signal private input siblings[nLevels][nTxs];
    signal private input oldKey[nTxs];
    signal private input oldValue[nTxs];
    signal private input isOld0[nTxs];
    signal private input newKey[nTxs];
    signal private input newValue[nTxs];
    signal private input fnc[2][nTxs];

    component smtprocessor = SMTProcessor(4);

    newRoot <== oldRoot;
}

component main = Rollup(10);
