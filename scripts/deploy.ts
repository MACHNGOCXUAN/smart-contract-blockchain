import { network } from "hardhat";

async function main() {
  const { ethers } = await network.connect();
  const Contract = await ethers.getContractFactory("RentalContractRegistry");
  const contract = await Contract.deploy();

  await contract.waitForDeployment();

  console.log("Deployed at:", await contract.getAddress());
}

main();