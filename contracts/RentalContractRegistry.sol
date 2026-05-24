// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RentalContractRegistry {

    // =============== ENUMS ===============

    enum ContractStatus {
        Draft,
        Active,
        Terminated,
        Expired
    }

    enum PaymentType {
        Deposit,
        Rent,
        FinalSettlement,
        Refund
    }

    enum PaymentProvider {
        VNPay,
        MoMo,
        InternalWallet
    }

    // =============== STRUCTS ===============

    struct ContractData {
        string contractId;
        string propertyId;
        bytes32 contractHash;

        string landlordId;
        string tenantId;

        uint256 version;
        uint256 signedAt;
        uint256 updatedAt;

        ContractStatus status;
        bool exists;
    }

    struct PaymentRecord {
        string paymentId;
        string contractId;

        string userId;

        uint256 amount;
        bytes32 paymentHash;

        PaymentType paymentType;
        PaymentProvider provider;

        string externalTxId;

        uint256 paidAt;

        bool verified;
        bool exists;
    }

    struct EscrowData {
        string contractId;
        uint256 totalDeposited;
        uint256 totalPaidRent;
        uint256 totalRefunded;
    }

    // =============== STORAGE ===============

    address public backend;

    mapping(string => ContractData) public contracts;
    mapping(string => PaymentRecord) public payments;
    mapping(string => bool) public usedExternalTx;
    mapping(string => EscrowData) public escrows;

    // =============== MODIFIER ===============

    modifier onlyBackend() {
        require(msg.sender == backend, "Not authorized");
        _;
    }

    // =============== EVENTS ===============

    event ContractRegistered(
        string contractId,
        string propertyId,
        bytes32 contractHash,
        string landlordId,
        string tenantId,
        uint256 version,
        uint256 signedAt
    );

    event ContractUpdated(
        string contractId,
        bytes32 newHash,
        uint256 version,
        uint256 updatedAt
    );

    event ContractTerminated(
        string contractId,
        uint256 terminatedAt
    );

    event PaymentRecorded(
        string paymentId,
        string contractId,
        string userId,
        uint256 amount,
        PaymentType paymentType,
        PaymentProvider provider,
        string externalTxId,
        uint256 paidAt
    );

    event EscrowUpdated(
        string contractId,
        uint256 totalDeposited,
        uint256 totalPaidRent,
        uint256 totalRefunded
    );

    // =============== CONSTRUCTOR ===============

    constructor(address _backend) {
        backend = _backend;
    }

    // =============== CONTRACT MANAGEMENT ===============

    function registerContract(
        string memory contractId,
        string memory propertyId,
        bytes32 contractHash,
        string memory landlordId,
        string memory tenantId
    ) public {

        require(!contracts[contractId].exists, "Already exists");

        contracts[contractId] = ContractData({
            contractId: contractId,
            propertyId: propertyId,
            contractHash: contractHash,
            landlordId: landlordId,
            tenantId: tenantId,
            version: 1,
            signedAt: block.timestamp,
            updatedAt: block.timestamp,
            status: ContractStatus.Active,
            exists: true
        });

        escrows[contractId] = EscrowData({
            contractId: contractId,
            totalDeposited: 0,
            totalPaidRent: 0,
            totalRefunded: 0
        });

        emit ContractRegistered(
            contractId,
            propertyId,
            contractHash,
            landlordId,
            tenantId,
            1,
            block.timestamp
        );
    }

    function updateContractHash(
        string memory contractId,
        bytes32 newHash
    ) public {

        require(contracts[contractId].exists, "Not found");

        contracts[contractId].contractHash = newHash;
        contracts[contractId].updatedAt = block.timestamp;
        contracts[contractId].version += 1;

        emit ContractUpdated(
            contractId,
            newHash,
            contracts[contractId].version,
            block.timestamp
        );
    }

    function terminateContract(
        string memory contractId
    ) public {

        require(contracts[contractId].exists, "Not found");

        contracts[contractId].status = ContractStatus.Terminated;

        emit ContractTerminated(
            contractId,
            block.timestamp
        );
    }

    // =============== PAYMENT (OFF-CHAIN VERIFIED ONLY) ===============

    function recordPayment(
        string memory paymentId,
        string memory contractId,
        string memory userId,
        uint256 amount,
        bytes32 paymentHash,
        PaymentType paymentType,
        PaymentProvider provider,
        string memory externalTxId
    ) public onlyBackend {

        require(contracts[contractId].exists, "Contract not found");
        require(!payments[paymentId].exists, "Payment exists");
        require(!usedExternalTx[externalTxId], "Duplicate transaction");

        usedExternalTx[externalTxId] = true;

        payments[paymentId] = PaymentRecord({
            paymentId: paymentId,
            contractId: contractId,
            userId: userId,
            amount: amount,
            paymentHash: paymentHash,
            paymentType: paymentType,
            provider: provider,
            externalTxId: externalTxId,
            paidAt: block.timestamp,
            verified: true,
            exists: true
        });

        _updateEscrow(contractId, amount, paymentType);

        emit PaymentRecorded(
            paymentId,
            contractId,
            userId,
            amount,
            paymentType,
            provider,
            externalTxId,
            block.timestamp
        );
    }

    // =============== ESCROW LOGIC ===============

    function _updateEscrow(
        string memory contractId,
        uint256 amount,
        PaymentType paymentType
    ) internal {

        if (paymentType == PaymentType.Deposit) {
            escrows[contractId].totalDeposited += amount;
        } 
        else if (paymentType == PaymentType.Rent) {
            escrows[contractId].totalPaidRent += amount;
        } 
        else if (paymentType == PaymentType.Refund) {
            escrows[contractId].totalRefunded += amount;
        }

        emit EscrowUpdated(
            contractId,
            escrows[contractId].totalDeposited,
            escrows[contractId].totalPaidRent,
            escrows[contractId].totalRefunded
        );
    }

    // =============== VERIFY FUNCTIONS ===============

    function verifyContract(
        string memory contractId,
        bytes32 hashToCheck
    ) public view returns (bool) {
        return contracts[contractId].contractHash == hashToCheck;
    }

    function verifyPayment(
        string memory paymentId,
        bytes32 hashToCheck
    ) public view returns (bool) {
        return payments[paymentId].paymentHash == hashToCheck;
    }
}