// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Marketplace {

    IERC721 public immutable ticketingFactory;

    struct TicketOffer {
        address owner;
        uint256 startPrice;
        uint256 endSaleDate;
        address highestBidder;
        uint256 highestBid;
        bool active;
    }

    mapping(uint256 => mapping(address => uint256)) bidders;
    mapping(uint256 => TicketOffer) public ticketOffers;
    uint256[] public ticketIds;

    event newTicketSale(uint256 indexed _ticketId, uint256 indexed _startPrice, uint256 indexed _endSaleDate);

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
    function getAllListedTickets() public view {}

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
     * Allow user to sell a ticket on the marketplace.
     */
    function createTicketSale(uint256 _ticketId, uint256 _startPrice, uint256 _endSaleDate) external payable {
        require(ticketingFactory.ownerOf(_ticketId) == msg.sender, 'You must own the ticket to sell it.');
        require(_endSaleDate < block.timestamp + 1 weeks, 'The end sale date must be in less than 1 week');
        require(_endSaleDate > block.timestamp + 1 days, 'The end sale date must be in more than 1 day');
        require(_startPrice > 0, 'The start price must be greater than 0');
        // Define listing price

        ticketingFactory.transferFrom(msg.sender, address(this), _ticketId);
        require(ticketingFactory.ownerOf(_ticketId) == address(this), 'The new ticket owner must be the marketplace itself.');

        ticketIds.push(_ticketId);
        TicketOffer memory ticketOffer = ticketOffers[_ticketId];
        ticketOffer.owner = msg.sender;
        ticketOffer.startPrice = _startPrice;
        ticketOffer.endSaleDate = _endSaleDate;
        ticketOffer.highestBidder = address(0);
        ticketOffer.highestBid = 0;
        ticketOffer.active = true;

        emit newTicketSale(_ticketId, _startPrice, _endSaleDate);
    }

    /**
     * Allow the user to make an offer on a specific ticket.
     */
    function addOfferOnTicket() public {}
    /**
     * Allow the user to cancel his offer of his ticket.
     */
    function cancelOfferOnTicket() public {}
    /**
     * Refund money if user are not the highest bidder
     */
    function refund() public {}
    /**
     * Allow the user to claim their purchased ticket after winning the auction.
     */
    function claim() public {}

}