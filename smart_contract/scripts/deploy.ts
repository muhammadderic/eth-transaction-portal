import { network } from "hardhat";

/** 
 * broadcast a deployment transaction for the Transactions contract 
 * to the target blockchain environment, 
 * wait for block confirmation, and 
 * log the deployed contract address.
*/
const main = async () => {
  // Create an explicit connection with the target network (local network)
  const { ethers } = await network.create();

  // Deploying contracts
  const transactionsContract = await ethers.deployContract("Transactions");
  await transactionsContract.waitForDeployment();

  console.log("Transactions address:", await transactionsContract.getAddress());
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();