const SMT = require('circomlib/src/smt');
const Transaction = require('./models/transaction');

const ZeroPubkey = "0000000000000000";
const AlicePubkey = "1234567890111111";
const BobPubkey = "1234567890222222";

const upsertBalance = async (pubkey, balance, balanceTree) => {
  const resFind = await balanceTree.find(pubkey);
  if (!resFind.found) {
    const resInsert = await balanceTree.insert(pubkey, balance);
    console.log("resInsert: ", resInsert);
  }
  else {
    // FIXME: Value must be hash. Database having account tree leaves should be implemented.
    const newBalance = resFind.foundValue + balance;
    const resUpdate = await balanceTree.update(pubkey, balance);
    console.log("resUpdate: ", resUpdate);
  }
};

const processTx = async (tx, balanceTree) => {
  if (tx.srcPubkey === ZeroPubkey) {
    await upsertBalance(tx.destPubkey, tx.balance, balanceTree);
  }
  else {
    throw "Not implemented transfer";
  }
};

(async () => {
  const balanceTree = await SMT.newMemEmptyTrie();

  const firstTx = new Transaction(ZeroPubkey, AlicePubkey, 100);
  await processTx(firstTx, balanceTree);
  const second = new Transaction(ZeroPubkey, AlicePubkey, 123);
  await processTx(second, balanceTree);
  //const secondTx = new Transaction(AlicePubkey, BobPubkey, 25);
  //processTx(secondTx);

  console.log(balanceTree);
})();
