class Transaction {
  constructor(srcPubkey, destPubkey, balance) {
    this.srcPubkey = srcPubkey;
    this.destPubkey = destPubkey;
    this.balance = balance;
  }
}

module.exports = Transaction;
