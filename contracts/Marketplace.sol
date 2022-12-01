// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Marketplace {

    IERC721 public immutable ticketingFactory;

    struct TicketOffer {
        address payable owner;
        uint256 startPrice;
        uint256 endSaleDate;
        address payable highestBidder;
        uint256 highestBid;
        bool active;
    }

    mapping(uint256 => mapping(address => uint256)) private bidders;
    mapping(uint256 => TicketOffer) private ticketOffers;
    uint256[] public ticketIds;
    // The fee charged by the marketplace to be allowed to list Ticket
    // uint256 listingPrice = 0.01 ether;

    event NewTicketSale(uint256 indexed _ticketId, uint256 indexed _startPrice, uint256 indexed _endSaleDate);
    event OfferAdded(uint256 indexed _ticketId, address indexed _bidder, uint256 indexed _amount);
    event BidderRefunded(uint256 indexed _ticketId, address indexed _bidder, uint256 indexed _amount);

    constructor(IERC721 _ticketingFactory) {
        ticketingFactory = _ticketingFactory;
    }

    /**
     * Get all ticket offers on the marketplace.
     */
    function getAllTicketOffers() public view {}
    /**
     * Get all listed tickets on the marketplace.
     */
    function getAllListedTickets() public view returns (TicketOffer[] memory) {
        
    }

    /**
     * Get ticket offer of a specific ticket.
     */
    function getTicketOffer(uint256 _ticketId) public view returns (TicketOffer memory) {
        return ticketOffers[_ticketId];
    }
    /**
     * Get all ticket offer of a specific user.
     */
    function getTicketOffersOf() public view {}
    /**
     * Get all purchased tickets of a specific user.
     */
    function getPurchasedTicketsOf() public view {}
    /**
     * Get all listed tickets on the marketplace of a specific user.
     */
    function getListedTicketsOf() public view {}

    /**
     * Get the bidder's amount of a specific user.
     */
    function getBidderBid(uint256 _ticketId, address _bidder) public view returns (uint256) {
        return bidders[_ticketId][_bidder];
    }

    /**
     * Set the bidder's amount of a specific user to 0.
     */
    function resetBidderBid(uint256 _ticketId, address _bidder) private {
        bidders[_ticketId][_bidder] = 0;
    }

    /**
     * Allow user to sell a ticket on the marketplace.
     */
    function createTicketSale(uint256 _ticketId, uint256 _startPrice, uint256 _endSaleDate) external payable {
        require(ticketingFactory.ownerOf(_ticketId) == msg.sender, 'You must own the ticket to sell it.');
        require(_endSaleDate < block.timestamp + 1 weeks, 'The end sale date must be in less than 1 week');
        require(_endSaleDate > block.timestamp + 1 days, 'The end sale date must be in more than 1 day');
        require(_startPrice > 0, 'The start price must be greater than 0');
        // Define listing price
        // require(msg.value == listingPrice, "Price must be equal to the listing price");

        // Check if correctly approve before transferFrom
        ticketingFactory.transferFrom(msg.sender, address(this), _ticketId);
        require(ticketingFactory.ownerOf(_ticketId) == address(this), 'The new ticket owner must be the marketplace itself.');

        ticketIds.push(_ticketId);
        TicketOffer memory ticketOffer = ticketOffers[_ticketId];
        ticketOffer.owner = payable(msg.sender);
        ticketOffer.startPrice = _startPrice;
        ticketOffer.endSaleDate = _endSaleDate;
        ticketOffer.highestBidder = payable(address(0));
        ticketOffer.highestBid = 0;
        ticketOffer.active = true;

        emit NewTicketSale(_ticketId, _startPrice, _endSaleDate);
    }

    function updateTicketSale() external {}

    /**
     * Allow the user to make an offer on a specific ticket.
     */
    function addOfferOnTicket(uint256 _ticketId, uint256 _amount) external payable {
        TicketOffer memory ticketOffer = getTicketOffer(_ticketId);
        require(ticketOffer.active == true, 'There is no sale for this ticket.');
        require(ticketOffer.startPrice > _amount, 'Amount of the offer must be higher than the start price.');
        require(ticketOffer.highestBid > _amount, 'Amount must be higher than the highest bid.');

        // If bidder has already made an offer, readjust the amount to send
        uint256 amount = _amount;
        uint256 bidderBid = getBidderBid(_ticketId, msg.sender);
        if(bidderBid != 0) {
            amount -= bidderBid;
        }

        if(ticketOffer.highestBidder != msg.sender && ticketOffer.highestBidder != address(0)) {
            refund(_ticketId, payable(msg.sender), amount);
        }

        uint256 newContractBalance = address(this).balance + amount;
        // transferFrom(msg.sender, address(this), amount)
        require(newContractBalance == address(this).balance, 'Balance not updated correctly, transfer probably failed');

        ticketOffer.highestBidder = payable(msg.sender);
        ticketOffer.highestBid = _amount;
        bidders[_ticketId][msg.sender] = _amount;
        
        emit OfferAdded(_ticketId, msg.sender, _amount);
    }
    /**
     * Allow the user to cancel their offer
     */
    function cancelOfferOnTicket(uint256 _ticketId) external {
        TicketOffer memory ticketOffer = getTicketOffer(_ticketId);
        require(ticketOffer.highestBidder == address(0), 'Can not cancel the offer if someone already bidded on it.');
        require(ticketOffer.owner == address(msg.sender), 'Only the owner can cancel the auction.');
        ticketingFactory.transferFrom(address(this), msg.sender, _ticketId);
        ticketOffer.active = false;
    }
    /**
     * Allow the user to claim their purchased ticket after winning the auction.
     */
    function claim() public {}

    /**
     * Refund money if user are not the highest bidder
     */
    function refund(uint256 _ticketId, address payable _bidder, uint256 _amount) private {
        (bool success,) = _bidder.call{value: _amount}('');
        require(success, 'Failed to refund');
        resetBidderBid(_ticketId, _bidder);

        emit BidderRefunded(_ticketId, _bidder, _amount);
    }

}