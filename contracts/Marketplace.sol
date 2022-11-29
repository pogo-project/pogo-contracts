// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Marketplace {

    IERC721 public immutable ticketingFactory;

    struct TicketOffer {
        address owner;
        uint256 startPrice;
        uint256 endSellingDate;
        address highestBidder;
        address highestBid;
        bool active;
    }

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
    function createTicketSale() public {}
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