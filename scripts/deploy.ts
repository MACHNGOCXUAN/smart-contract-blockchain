import { network } from "hardhat";

async function main() {
  const { ethers } = await network.connect();

  const Contract = await ethers.getContractFactory("RentalContractRegistry");

  const backend = "0x790190E9accD6749370ad36725347ffB968C9a39";

  const contract = await Contract.deploy(backend);

  await contract.waitForDeployment();

  console.log("Deployed at:", await contract.getAddress());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});