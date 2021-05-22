const SMT = require('circomlib/src/smt');
const Transaction = require('./models/transaction');
const LeafDB = require('./mem-db');

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
  }

  async upsertBalance(pubkey, balance) {
    const resFind = await this.balanceTree.find(pubkey);
    if (!resFind.found) {
      const newBalance = balance;
      this.leafDB.insert(pubkey, newBalance);
      const newBalanceHash = hash(newBalance);
      const resInsert = await this.balanceTree.insert(pubkey, newBalanceHash);
      console.log("resInsert: ", resInsert);
    }
    else {
      const oldBalance = this.leafDB.get(pubkey);
      const newBalance = oldBalance + balance;
      if (newBalance < 0) {
        throw "Negative balance";
      }
      const newBalanceHash = hash(newBalance);
      const resUpdate = await this.balanceTree.update(pubkey, newBalanceHash);
      console.log("resUpdate: ", resUpdate);
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
}

(async () => {
  const balanceTree = await SMT.newMemEmptyTrie();
  const leafDB = new LeafDB();
  const rollup = new Rollup(balanceTree, leafDB);

  const mintTx = new Transaction(ZeroPubkey, AlicePubkey, 100);
  await rollup.processTx(mintTx, balanceTree);
  const transferTx = new Transaction(AlicePubkey, BobPubkey, 25);
  await rollup.processTx(transferTx);
  const burnTx = new Transaction(AlicePubkey, ZeroPubkey, 10);
  await rollup.processTx(burnTx);

  console.log(balanceTree);
})();
