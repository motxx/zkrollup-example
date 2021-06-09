const JSONbig = require('json-bigint')({"storeAsString": true});
const SMT = require('circomlib/src/smt');
const Transaction = require('./models/transaction');
const LeafDB = require('./mem-db');
const { stringifyBigInts } = require('./stringifybigint');

const ZeroPubkey = "0000000000000000";
const AlicePubkey = "1234567890111111";
const BobPubkey = "1234567890222222";

const hash = (value) => {
  return value;
};

class Rollup {
  constructor(balanceTree, leafDB) {
    this.balanceTree = balanceTree;
    this.leafDB = leafDB;
    this.circuitInput = {};
  }

  _addResOperation(resOperation, optype) {
    const h = this.circuitInput;
    if (!h["oldRoot"]) {
      h["oldRoot"] = [];
      h["newRoot"] = [];
      h["siblings"] = [];
      h["oldKey"] = [];
      h["oldValue"] = [];
      h["newKey"] = [];
      h["newValue"] = [];
      h["isOld0"] = [];
      h["fnc"] = [];
    }
    h["oldRoot"].push(resOperation.oldRoot);
    h["newRoot"].push(resOperation.newRoot);
    h["siblings"].push(resOperation.siblings);
    h["oldKey"].push(resOperation.oldKey);
    h["oldValue"].push(resOperation.oldValue);
    h["newKey"].push(resOperation.newKey ?? '0');
    h["newValue"].push(resOperation.newValue ?? '0');
    h["isOld0"].push((resOperation.isOld0 & 1).toString());
    h["fnc"].push(
        optype === "insert" ? ['1', '0']
      : optype === "update" ? ['0', '1']
      :                       ['0', '0']);
    console.log(resOperation);
  }

  async upsertBalance(pubkey, balance) {
    const resFind = await this.balanceTree.find(pubkey);
    if (!resFind.found) {
      const newBalance = balance;
      this.leafDB.insert(pubkey, newBalance);
      const newBalanceHash = hash(newBalance);
      const resInsert = await this.balanceTree.insert(pubkey, newBalanceHash);
      this._addResOperation(resInsert, "insert");
    }
    else {
      const oldBalance = this.leafDB.get(pubkey);
      const newBalance = oldBalance + balance;
      if (newBalance < 0) {
        throw "Negative balance";
      }
      const newBalanceHash = hash(newBalance);
      const resUpdate = await this.balanceTree.update(pubkey, newBalanceHash);
      this._addResOperation(resUpdate, "update");
    }
  }

  async processTx(tx) {
    if (tx.srcPubkey === ZeroPubkey) {
      await this.upsertBalance(tx.destPubkey, tx.balance);
    }
    else if (tx.destPubkey === ZeroPubkey) {
      await this.upsertBalance(tx.srcPubkey, -tx.balance);
    }
    else {
      // 更新順序を固定するためにPromise.allを使わない
      await this.upsertBalance(tx.srcPubkey, -tx.balance);
      await this.upsertBalance(tx.destPubkey, tx.balance);
    }
  }

  circuitInputJSON() {
    return JSON.stringify(stringifyBigInts(this.circuitInput));
  }
}

(async () => {
  const balanceTree = await SMT.newMemEmptyTrie();
  const leafDB = new LeafDB();
  const rollup = new Rollup(balanceTree, leafDB);

  const mintTx = new Transaction(ZeroPubkey, AlicePubkey, 100);
  await rollup.processTx(mintTx, balanceTree);
  const transferTx = new Transaction(AlicePubkey, BobPubkey, 25);
  await rollup.processTx(transferTx);
//  const burnTx = new Transaction(AlicePubkey, ZeroPubkey, 10);
//  await rollup.processTx(burnTx);

  console.log(balanceTree);
  console.log(rollup.circuitInputJSON())
})();
