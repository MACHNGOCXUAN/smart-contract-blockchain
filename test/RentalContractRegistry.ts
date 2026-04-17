import { expect } from "chai";
import { network } from "hardhat";

describe("RentalContractRegistry", function () {
	it("registers a contract and stores its hash", async function () {
		const { ethers } = await network.connect();

		const factory = await ethers.getContractFactory("RentalContractRegistry");
		const registry = await factory.deploy();
		await registry.waitForDeployment();

		const contractId = "RENTAL-001";
		const contractHash = ethers.id("sample-contract-content");

		await registry.registerContract(contractId, contractHash);

		const stored = await registry.contracts(contractId);
		expect(stored.exists).to.equal(true);
		expect(stored.contractHash).to.equal(contractHash);
	});

	it("reverts when registering an existing contractId", async function () {
		const { ethers } = await network.connect();

		const factory = await ethers.getContractFactory("RentalContractRegistry");
		const registry = await factory.deploy();
		await registry.waitForDeployment();

		const contractId = "RENTAL-001";
		const firstHash = ethers.id("first-version");
		const secondHash = ethers.id("second-version");

		await registry.registerContract(contractId, firstHash);

		await expect(
			registry.registerContract(contractId, secondHash),
		).to.be.revertedWith("Already exists");
	});
});
