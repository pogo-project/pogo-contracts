import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, BigNumber, Contract } from "ethers";

const listingPrice = "0.005";

describe("POGO contracts", () => {
    let marketplace: Contract,
        ticketingFactory: Contract;
    let owner: Signer, 
      addr1: Signer, 
      addr2: Signer, 
      addrs: Signer[];

    before(async () => {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        const TicketingFactory = await ethers.getContractFactory("TicketingFactory"); 
        ticketingFactory = await TicketingFactory.deploy();
        await ticketingFactory.deployed();

        const Marketplace = await ethers.getContractFactory("Marketplace");
        marketplace = await Marketplace.deploy();
        await marketplace.deployed();
    });

    describe("TicketingFactory contract", () => {
        it("Should initialize smart contract", async () => {
            let name = "POGO";
            let symbol = "POGO";
            let baseTokenURI = "ipfs://XXX/";
            let maxTicketsSupply = 2222;
            let endSaleDate = Math.round((new Date().getTime() + (604000 * 1000)) / 1000);
            
            await ticketingFactory.initialize(name,symbol,baseTokenURI,maxTicketsSupply,endSaleDate);
            expect(await ticketingFactory.maxTicketsSupply()).to.equal(maxTicketsSupply);
            expect(await ticketingFactory.owner()).to.equal(await owner.getAddress());
        });

        it("Should mint tickets", async () => {
            const ticketId: number = 1;
            await ticketingFactory.mintTickets();
            expect(await ticketingFactory.balanceOf(await owner.getAddress())).to.equal(1);
            expect(await ticketingFactory.tokenURI(ticketId)).to.equal(`ipfs://XXX/${ ticketId }.json`);
        });

        it("Should mint tickets", async () => {
            const ticketId: number = 2;
            await ticketingFactory.connect(addr2).mintTickets();
            expect(await ticketingFactory.balanceOf(await addr2.getAddress())).to.equal(1);
            expect(await ticketingFactory.tokenURI(ticketId)).to.equal(`ipfs://XXX/${ ticketId }.json`);
        });

    });

    describe("Marketplace contract", () => {
        it("Should initialize smart contract", async () => {
            await marketplace.initialize(ticketingFactory.address)
            expect(await marketplace.ticketingFactory()).to.equal(ticketingFactory.address);
        });

        it("Should initialize smart contract a second time", async () => {
            await expect(marketplace.initialize(ticketingFactory.address))
            .to.be.rejectedWith("Contract instance has already been initialized");
        });

        it("Should create a ticket sale", async () => {
            let ticketId: number = 1;
            let startPrice = ethers.utils.parseEther("0.06");
            //(now + ~~1 week in ms) then converted to solidity timestamp with / 1000
            let endSaleDate = Math.round((new Date().getTime() + (604000 * 1000)) / 1000);

            await ticketingFactory.approve(marketplace.address, ticketId);
            await marketplace.createTicketSale(ticketId, startPrice, endSaleDate, { value: ethers.utils.parseEther(listingPrice) });
            let ticketOffer = await marketplace.ticketOffers(ticketId);
            expect(ticketOffer.owner).to.equal(await owner.getAddress());
            expect(ticketOffer.startPrice).to.equal(startPrice);
            expect(ticketOffer.highestBidder).to.equal(ethers.constants.AddressZero);
            expect(ticketOffer.highestBid).to.equal(0);
            expect(ticketOffer.active).to.equal(true);
            expect(await ethers.provider.getBalance(marketplace.address)).to.equal(ethers.utils.parseEther(listingPrice));
        });

        it("Should add offer on ticket", async () => {
            let ticketId: number = 1;
            let bidAmount = ethers.utils.parseEther("0.08");
            await marketplace.connect(addr1).addOfferOnTicket(ticketId, { value: bidAmount });

            let ticketOffer = await marketplace.ticketOffers(ticketId);
            expect(ticketOffer.highestBidder).to.equal(await addr1.getAddress());
            expect(ticketOffer.highestBid).to.equal(bidAmount);
        });



        it("Should add offer on ticket", async () => {
            let ticketId: number = 1;
            let bidAmount = ethers.utils.parseEther("0.1");
            await marketplace.connect(addr2).addOfferOnTicket(ticketId, { value: bidAmount });

            let ticketOffer = await marketplace.ticketOffers(ticketId);
            expect(ticketOffer.highestBidder).to.equal(await addr2.getAddress());
            expect(ticketOffer.highestBid).to.equal(bidAmount);
        });

        it("Should try to cancel offer on ticket", async () => {
            let ticketId: number = 1;
            await expect(marketplace.cancelOfferOnTicket(ticketId))
            .to.be.rejectedWith("Can not cancel the offer if someone already bidded on it.");
        });

    });
});