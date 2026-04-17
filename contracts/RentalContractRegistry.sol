// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RentalContractRegistry {

    struct ContractData {
        bytes32 contractHash;
        bool exists;
    }

    mapping(string => ContractData) public contracts;

    function registerContract(string memory contractId, bytes32 contractHash) public {
        require(!contracts[contractId].exists, "Already exists");

        contracts[contractId] = ContractData({
            contractHash: contractHash,
            exists: true
        });
    }
}