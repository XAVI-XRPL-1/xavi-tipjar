const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying TipJar to XRPL EVM...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "XRP");

  const TipJar = await ethers.getContractFactory("TipJar");
  const tipJar = await TipJar.deploy();

  await tipJar.waitForDeployment();

  const address = await tipJar.getAddress();
  console.log("\n✅ TipJar deployed to:", address);
  console.log("Explorer:", `https://explorer.xrplevm.org/address/${address}`);
  
  console.log("\nWaiting for block confirmations...");
  await new Promise(resolve => setTimeout(resolve, 5000));

  console.log("\nDeployment complete!");
  console.log("Contract Address:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
