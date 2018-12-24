// This contract is generated programmatically

pragma solidity ^0.4.24;

// storage variable to later use in delegates chain.
// Also defines all structures
contract PlasmaStorage {

    // For tree depth 24
    bytes32 constant EMPTY_TREE_ROOT = 0x1d3843a9bbf376e57b3eca393198d7211882f6f2a76a53730243e2a1a519d92a;

    // Plasma itself

    uint32 constant DEADLINE = 3600; // seconds, to define

    event BlockCommitted(uint32 indexed blockNumber);
    event BlockVerified(uint32 indexed blockNumber);

    enum Circuit {
        DEPOSIT,
        TRANSFER,
        EXIT
    }

    enum AccountState {
        NOT_REGISTERED,
        REGISTERED,
        PENDING_EXIT
        // there is no EXITED state, cause we remove an account all together
    }

    struct Block {
        uint8 circuit;
        uint64  deadline;
        uint128 totalFees;
        bytes32 newRoot;
        bytes32 publicDataCommitment;
        address prover;
    }

    // Key is block number
    mapping (uint32 => Block) public blocks;
    // Only some addresses can send proofs
    mapping (address => bool) public operators;
    // Fee collection accounting
    mapping (address => uint256) public balances;

    struct Account {
        uint8 state;
        uint32 exitBatchNumber;
        address owner;
        uint256 publicKey;
    }

    // one Ethereum address should have one account
    mapping (address => uint24) public ethereumAddressToAccountID;

    // Plasma account => general information
    mapping (uint24 => Account) public accounts;

    // Public information for users
    bool public stopped;
    uint32 public lastCommittedBlockNumber;
    uint32 public lastVerifiedBlockNumber;
    bytes32 public lastVerifiedRoot;
    uint64 public constant MAX_DELAY = 1 days;
    uint256 public constant DENOMINATOR = 1000000000000;

    // deposits

    uint256 public constant DEPOSIT_BATCH_SIZE = 1;
    uint256 public totalDepositRequests; // enumerates total number of deposit, starting from 0
    uint256 public lastCommittedDepositBatch;
    uint256 public lastVerifiedDepositBatch;
    uint128 public currentDepositBatchFee; // deposit request fee scaled units

    uint24 public constant SPECIAL_ACCOUNT_DEPOSITS = 1;

    uint24 public nextAccountToRegister;

    // some ideas for optimization of the deposit request information storage:
    // store in a mapping: 20k gas to add, 5k to update a record + 5k to update the global counter per batch
    // store in an array: 20k + 5k gas to add, 5k to update + up to DEPOSIT_BATCH_SIZE * SLOAD

    // batch number => (plasma address => deposit information)
    mapping (uint256 => mapping (uint24 => DepositRequest)) public depositRequests;
    mapping (uint256 => DepositBatch) public depositBatches;

    struct DepositRequest {
        uint128 amount;
    }

    enum DepositBatchState {
        CREATED,
        COMMITTED,
        VERIFIED
    }

    struct DepositBatch {
        uint8 state;
        uint24 numRequests;
        uint32 blockNumber;
        uint64 timestamp;
        uint128 batchFee;
    }

    event LogDepositRequest(uint256 indexed batchNumber, uint24 indexed accountID, uint256 indexed publicKey, uint128 amount);
    event LogCancelDepositRequest(uint256 indexed batchNumber, uint24 indexed accountID);

    // Transfers

    uint256 constant TRANSFER_BLOCK_SIZE = 128;

    mapping (uint32 => mapping (uint24 => uint128)) public partialExits;


    // Exits 

    uint256 constant EXIT_BATCH_SIZE = 1;
    uint256 totalExitRequests; 
    uint256 lastCommittedExitBatch;
    uint256 lastVerifiedExitBatch;
    uint128 currentExitBatchFee; 

    uint24 public constant SPECIAL_ACCOUNT_EXITS = 0;

    // batches for complete exits
    mapping (uint256 => ExitBatch) public exitBatches;

    enum ExitBatchState {
        CREATED,
        COMMITTED,
        VERIFIED
    }

    struct ExitBatch {
        uint8 state;
        uint32 blockNumber;
        uint64 timestamp;
        uint128 batchFee;
    }

    event LogExitRequest(uint256 indexed batchNumber, uint24 indexed accountID);
    event LogCancelExitRequest(uint256 indexed batchNumber, uint24 indexed accountID);

    // Delegates chain
    address public transactor;
    address public exitor;
}