const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');

// Replace with your own values
const mnemonic = 'your twelve word mnemonic here';
const infuraApiKey = 'your_infura_api_key_here';
const contractAddress = 'your_contract_address_here';

const web3 = new Web3(new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/${infuraApiKey}`));

// ABI (Application Binary Interface) of your Solidity contract
const abi = /* ... ABI here ... */;

// To create a contract instance
const multiSigWallet = new web3.eth.Contract(abi, contractAddress);

// Replace with your own values
const proposedTransaction = {
    destination: '0x1234567890123456789012345678901234567890',
    value: web3.utils.toWei('1', 'ether'),
    data: '0x', // Replace with your transaction data
};

// Propose a new transaction
async function proposeTransaction() {
    const accounts = await web3.eth.getAccounts();
    const result = await multiSigWallet.methods.proposeTransaction(
        proposedTransaction.destination,
        proposedTransaction.value,
        proposedTransaction.data
    ).send({ from: accounts[0] });

    console.log('Transaction proposed. Transaction ID:', result.events.TransactionProposed.returnValues.transactionId);
}

// Approve a transaction
async function approveTransaction(transactionId) {
    const accounts = await web3.eth.getAccounts();
    await multiSigWallet.methods.approveTransaction(transactionId).send({ from: accounts[0] });

    console.log('Transaction approved:', transactionId);
}

// Execute a transaction
async function executeTransaction(transactionId) {
    const accounts = await web3.eth.getAccounts();
    await multiSigWallet.methods.executeTransaction(transactionId).send({ from: accounts[0] });

    console.log('Transaction executed:', transactionId);
}

// Listen for TransactionExecuted events
multiSigWallet.events.TransactionExecuted({ fromBlock: 'latest' }, (error, event) => {
    if (!error) {
        console.log('Transaction executed event:', event.returnValues);
    } else {
        console.error('Error:', error);
    }
});

// Example usage
async function main() {
    await proposeTransaction();
    // Assuming transactionId is the ID of the proposed transaction
    const transactionId = 0;
    await approveTransaction(transactionId);
    await executeTransaction(transactionId);
}

main();
