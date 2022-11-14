// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import 'erc721a-upgradeable/contracts/ERC721AUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TicketingFactory is 
    ERC721AUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable ,
    PausableUpgradeable
{
    using Counters for Counters.Counter;
    Counters.Counter private _ticketIds;
    Counters.Counter private _ticketingDetailsIds;
    using Strings for uint256;

    string private baseURI;
    uint256 maxTicketsSupply;

    struct TicketingDetails {
        string name;
        string symbol;
        string description;
        uint256 createdAt;
        uint256 stopSellingTickets;
    }

    mapping(uint256 => TicketingDetails) public ticketingDetails;

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _baseTokenURI,
        uint256 _maxTicketsSupply,
        uint256 _stopSellingTickets
    ) initializer public {
        __ERC721A_init(_name, _symbol);
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();
        uint256 ticketingDetailsId = _ticketingDetailsIds.current();
        maxTicketsSupply = _maxTicketsSupply;
        ticketingDetails[ticketingDetailsId] = TicketingDetails({
            name: _name,
            symbol: _symbol,
            description: _description,
            createdAt: block.timestamp,
            stopSellingTickets: _stopSellingTickets
        });
        setBaseURI(_baseTokenURI);
        _ticketingDetailsIds.increment();        
    }

    function mintTickets() external payable returns (uint256) {
        _ticketIds.increment();
        uint256 newTicketId = _ticketIds.current();
        _safeMint(msg.sender, newTicketId);
        return newTicketId;
    }

    function _baseURI() internal view  virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _baseTokenURI) internal onlyOwner {
        baseURI = _baseTokenURI;
    }

    function tokenURI(uint256 _ticketId) public view virtual override returns (string memory) {
        require(_exists(_ticketId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _ticketId.toString(),".json"))
            : "";
    }

}
