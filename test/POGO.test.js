import { ethers } from "hardhat";
const { expect } = require("chai");

describe("POGO contracts", () => {
    let marketplace;
    let owner, 
      addr1, 
      addr2, 
      addrs;

    before(async () => {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        const Marketplace = await ethers.getContractFactory("Marketplace");
        marketplace = await Marketplace.deploy();
        await marketplace.deployed();
    });

    describe("Marketplace contract", () => {
        it("Should create a ticket sale", async () => {
            let tokenId = 1;
            let startPrice = 0.06;
            //(now + ~~1 week in ms) then converted to solidity timestamp with / 1000
            let endSaleDate = Math.round((new Date().getTime() + (604000 * 1000)) / 1000);

            marketplace.createTicketSale(tokenId, startPrice, endSaleDate);


        });
    });

});