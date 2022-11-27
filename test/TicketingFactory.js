const { ethers } = require("hardhat");
const { expect } = require("chai");
const { BigNumber } = require("ethers");

describe("TicketingFactory contract", function () {
    let owner, addr1, addr2, addrs;
    let ticketingFactory;

    before(async function () {
        [owner, addr1, addr2, ...addrs] = await hre.ethers.getSigners();

        const TicketingFactory = await hre.ethers.getContractFactory("TicketingFactory");
        ticketingFactory = await TicketingFactory.deploy();
        await ticketingFactory.deployed();
    });

    it("Should return the ticketing details", async function () {
        //(now + ~~1 week in ms) then converted to solidity timestamp with / 1000
        const endDateSale = Math.round((new Date().getTime() + (604000 * 1000)) / 1000);
        await ticketingFactory.initialize(
            "POGO",
            "POGO",
            "ipfs/XXX/",
            8500,
            endDateSale,
        );
        const maxTicketsSupply = await ticketingFactory.maxTicketsSupply();
        expect(maxTicketsSupply).to.equal(BigNumber.from("8500"));
        const ticketingName = await ticketingFactory.name();
        expect(ticketingName).to.equal("POGO");
        const ticketingSymbol = await ticketingFactory.symbol();
        expect(ticketingSymbol).to.equal("POGO");
    });

    it("Should return the IPFS hash for a specific ticket id", async function () {
        const mintTicketsTx = await ticketingFactory.mintTickets();
        const rc = await mintTicketsTx.wait();
        const event = rc.events.find(event => event.event === 'MintedTicket');
        const [_owner, _id] = event.args; 

        expect(_owner).to.equal(owner.address);
        expect(_id).to.equal(BigNumber.from("1"));

        const ipfsHash = await ticketingFactory.tokenURI(_id);
        expect(ipfsHash).to.equal("ipfs/XXX/1.json");

    });

});