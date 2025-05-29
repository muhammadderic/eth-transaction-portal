import { network } from "hardhat";

/** 
 * broadcast a deployment transaction for the Transactions contract 
 * to the target blockchain environment (Sepolia via Alchemy), 
 * wait for block confirmation, and 
 * log the deployed contract address.
*/
const main = async (): Promise<void> => {
  // Create an explicit connection with the target network (local network)
  const { ethers } = await network.create();

  console.log("Deploying Transactions contract to Sepolia...");

  // Deploying contracts
  const transactionsContract = await ethers.deployContract("Transactions");
  await transactionsContract.waitForDeployment();

  const deployedAddress = await transactionsContract.getAddress();
  console.log("Transactions contract deployed successfully!");
  console.log("Contract Address:", deployedAddress);
};

const runMain = async (): Promise<void> => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error("Deployment failed:", error);
    process.exit(1);
  }
};

runMain();