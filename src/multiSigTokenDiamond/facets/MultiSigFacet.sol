// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.30;

// import "../libraries/LibDiamond.sol";

// /**
//  * @title MultiSigFacet
//  * @notice Multi-signature wallet functionality for the Diamond
//  * @dev Allows multiple owners to approve and execute transactions
//  */
// contract MultiSigFacet {

//     event OwnerAdded(address indexed owner);
//     event OwnerRemoved(address indexed owner);
//     event RequirementChanged(uint256 required);
//     event TransactionSubmitted(uint256 indexed txId, address indexed submitter, address to, uint256 value, bytes data);
//     event TransactionConfirmed(uint256 indexed txId, address indexed owner);
//     event TransactionRevoked(uint256 indexed txId, address indexed owner);
//     event TransactionExecuted(uint256 indexed txId, address indexed executor);
//     event TransactionFailed(uint256 indexed txId);
    
//     bytes32 constant MULTISIG_STORAGE_POSITION = keccak256("multisig.token.diamond.storage");

//     struct Transaction {
//         address to;
//         uint256 value;
//         bytes data;
//         bool executed;
//         uint256 confirmations;
//     }

//     struct MultiSigStorage {
//         address[] owners;
//         mapping(address => bool) isOwner;
//         uint256 required;
//         Transaction[] transactions;
//         mapping(uint256 => mapping(address => bool)) confirmations;
//     }

//     function multiSigStorage() internal pure returns (MultiSigStorage storage ms) {
//         bytes32 position = MULTISIG_STORAGE_POSITION;
//         assembly {
//             ms.slot := position
//         }
//     }

//     modifier onlyMultiSigOwner() {
//         require(multiSigStorage().isOwner[msg.sender], "Not a multisig owner");
//         _;
//     }

//     modifier txExists(uint256 _txId) {
//         require(_txId < multiSigStorage().transactions.length, "Transaction does not exist");
//         _;
//     }

//     modifier notExecuted(uint256 _txId) {
//         require(!multiSigStorage().transactions[_txId].executed, "Transaction already executed");
//         _;
//     }

//     modifier notConfirmed(uint256 _txId) {
//         require(!multiSigStorage().confirmations[_txId][msg.sender], "Transaction already confirmed");
//         _;
//     }
 
//     function initializeMultiSig(address[] memory _owners, uint256 _required) external {
//         LibDiamond.enforceIsContractOwner();
//         MultiSigStorage storage ms = multiSigStorage();
        
//         require(ms.owners.length == 0, "MultiSig: Already initialized");
//         require(_owners.length > 0, "MultiSig: Owners required");
//         require(_required > 0 && _required <= _owners.length, "MultiSig: Invalid requirement");
//         for (uint256 i = 0; i < _owners.length; i++) {
//             address owner = _owners[i];
//             require(owner != address(0), "MultiSig: Invalid owner");
//             require(!ms.isOwner[owner], "MultiSig: Duplicate owner");
//             ms.isOwner[owner] = true;
//             ms.owners.push(owner);
//             emit OwnerAdded(owner);
//         }
//         ms.required = _required;
//         emit RequirementChanged(_required);
//     }

//     function submitTransaction(address _to,uint256 _value,bytes memory _data) public onlyMultiSigOwner returns (uint256 txId) {
//         MultiSigStorage storage ms = multiSigStorage(); 
//         txId = ms.transactions.length;
//         ms.transactions.push(Transaction({
//             to: _to,
//             value: _value,
//             data: _data,
//             executed: false,
//             confirmations: 0
//         }));
//         emit TransactionSubmitted(txId, msg.sender, _to, _value, _data);
//         confirmTransaction(txId);
//     }

//     function confirmTransaction(uint256 _txId)public onlyMultiSigOwner txExists(_txId) notExecuted(_txId) notConfirmed(_txId){
//         MultiSigStorage storage ms = multiSigStorage();
//         ms.confirmations[_txId][msg.sender] = true;
//         ms.transactions[_txId].confirmations += 1;
//         emit TransactionConfirmed(_txId, msg.sender);
//     }

//     function revokeConfirmation(uint256 _txId)public onlyMultiSigOwner txExists(_txId) notExecuted(_txId){
//         MultiSigStorage storage ms = multiSigStorage();
//         require(ms.confirmations[_txId][msg.sender], "Transaction not confirmed");
//         ms.confirmations[_txId][msg.sender] = false;
//         ms.transactions[_txId].confirmations -= 1;
//         emit TransactionRevoked(_txId, msg.sender);
//     }

//     function executeTransaction(uint256 _txId)public onlyMultiSigOwner txExists(_txId) notExecuted(_txId){
//         MultiSigStorage storage ms = multiSigStorage();
//         Transaction storage txn = ms.transactions[_txId];
//         require(txn.confirmations >= ms.required, "Not enough confirmations");
//         txn.executed = true;
//         (bool success, ) = txn.to.call{value: txn.value}(txn.data);
//         if (success) {
//             emit TransactionExecuted(_txId, msg.sender);
//         } else {
//             txn.executed = false;
//             emit TransactionFailed(_txId);
//             revert("Transaction execution failed");
//         }
//     }

//     function addOwner(address _owner) external onlyMultiSigOwner {
//         MultiSigStorage storage ms = multiSigStorage();
//         require(_owner != address(0), "Invalid owner");
//         require(!ms.isOwner[_owner], "Owner already exists");

//         ms.isOwner[_owner] = true;
//         ms.owners.push(_owner);

//         emit OwnerAdded(_owner);
//     }

//     function removeOwner(address _owner) external onlyMultiSigOwner {
//         MultiSigStorage storage ms = multiSigStorage();
//         require(ms.isOwner[_owner], "Not an owner");
//         require(ms.owners.length - 1 >= ms.required, "Would break requirement");
//         ms.isOwner[_owner] = false;
//         for (uint256 i = 0; i < ms.owners.length; i++) {
//             if (ms.owners[i] == _owner) {
//                 ms.owners[i] = ms.owners[ms.owners.length - 1];
//                 ms.owners.pop();
//                 break;
//             }
//         }
//         emit OwnerRemoved(_owner);
//     }

//     function changeRequirement(uint256 _required) external onlyMultiSigOwner {
//         MultiSigStorage storage ms = multiSigStorage();
//         require(_required > 0 && _required <= ms.owners.length, "Invalid requirement");

//         ms.required = _required;
//         emit RequirementChanged(_required);
//     }

//     function getOwners() external view returns (address[] memory) {
//         return multiSigStorage().owners;
//     }

//     function getTransactionCount() external view returns (uint256) {
//         return multiSigStorage().transactions.length;
//     }

//     function getTransaction(uint256 _txId)external view txExists(_txId)
//         returns (address to,uint256 value,bytes memory data,bool executed,uint256 confirmations){
//         Transaction storage txn = multiSigStorage().transactions[_txId];
//         return (txn.to, txn.value, txn.data, txn.executed, txn.confirmations);
//     }

//     function isOwner(address _owner) external view returns (bool) {
//         return multiSigStorage().isOwner[_owner];
//     }

//     function isConfirmed(uint256 _txId, address _owner) external view returns (bool) {
//         return multiSigStorage().confirmations[_txId][_owner];
//     }

//     function getConfirmations(uint256 _txId) external view txExists(_txId)returns (uint256 count, address[] memory owners) {
//         MultiSigStorage storage ms = multiSigStorage();
//         address[] memory _owners = ms.owners;
        
//         count = ms.transactions[_txId].confirmations;
//         owners = new address[](count);
        
//         uint256 index = 0;
//         for (uint256 i = 0; i < _owners.length; i++) {
//             if (ms.confirmations[_txId][_owners[i]]) {
//                 owners[index] = _owners[i];
//                 index++;
//             }
//         }
//     }
// }