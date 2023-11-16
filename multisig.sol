pragma solidity ^0.8.0;

contract MultiSignatureWallet {
    // State variables
    address public owner;
    uint256 public quorum;
    address[] public authorizedSigners;

    // Event emitted when a transaction is successfully executed
    event TransactionExecuted(uint256 indexed transactionId, address indexed destination, uint256 value, address indexed executor);

    // Transaction structure to represent proposed transactions
    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvals;
        mapping(address => bool) isApproved;
    }

    // Array to store proposed transactions
    Transaction[] public transactions;

    // Constructor to initialize the wallet with authorized signers and quorum
    constructor(address[] memory _initialSigners, uint256 _quorum) {
        owner = msg.sender;
        quorum = _quorum;
        authorizedSigners = _initialSigners;
    }

    // Modifier to restrict function access to authorized signers only
    modifier onlyAuthorizedSigner() {
        require(isAuthorizedSigner(msg.sender), "Not authorized signer");
        _;
    }

    // Function to propose a new transaction
    function proposeTransaction(address _destination, uint256 _value, bytes memory _data) external onlyAuthorizedSigner {
        transactions.push(Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false,
            approvals: 0
        }));
    }

    // Function to approve a proposed transaction
    function approveTransaction(uint256 _transactionId) external onlyAuthorizedSigner {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        require(!transactions[_transactionId].isApproved[msg.sender], "Transaction already approved");

        transactions[_transactionId].isApproved[msg.sender] = true;
        transactions[_transactionId].approvals++;

        if (transactions[_transactionId].approvals >= quorum) {
            executeTransaction(_transactionId);
        }
    }

    // Function to execute a transaction
    function executeTransaction(uint256 _transactionId) public onlyAuthorizedSigner {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        require(!transactions[_transactionId].executed, "Transaction already executed");

        transactions[_transactionId].executed = true;
        (bool success, ) = transactions[_transactionId].destination.call{value: transactions[_transactionId].value}(transactions[_transactionId].data);

        require(success, "Transaction execution failed");

        emit TransactionExecuted(_transactionId, transactions[_transactionId].destination, transactions[_transactionId].value, msg.sender);
    }

    // Function to check if an address is an authorized signer
    function isAuthorizedSigner(address _signer) public view returns (bool) {
        for (uint256 i = 0; i < authorizedSigners.length; i++) {
            if (authorizedSigners[i] == _signer) {
                return true;
            }
        }
        return false;
    }
}
