import { ethers, network } from "hardhat";
import { verify } from "./utils/verify";

async function main() {
  const endSaleDate = Math.round((new Date().getTime() + (604000 * 1000)) / 1000);
  const TicketingFactory = await ethers.getContractFactory("TicketingFactory");
  console.log("Deploying TicketingFactory...");
  const ticketingFactory = await upgrades.deployProxy(
    TicketingFactory,
    ["POGO", "POGO", "ipfs/XXX/", 2222, endSaleDate],
    { initializer: "initializer" }
  );
  console.log(`TicketingFactory contract deployed to ${ticketingFactory.address}`);

  const Marketplace = await ethers.getContractFactory("Marketplace");
  console.log("Deploying Marketplace...");
  const marketplace = await upgrades.deployProxy(
      Marketplace,
      [ticketingFactory.address],
      { initializer: "initializer" }
  );
  console.log(`Marketplace contract deployed to ${marketplace.address}`);

  if(network.name === "DEPLOY_NETWORK") {
    console.log("Verifiying the smart contract...");
    // Wait 6 blocks
    await ticketingFactory.deployTransaction.wait(6);
    await verify(ticketingFactory.address, []);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
