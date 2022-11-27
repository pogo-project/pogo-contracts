// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TicketingFactory is 
    ERC721URIStorageUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable ,
    PausableUpgradeable
{
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _ticketIds;

    string private baseURI;
    uint256 public maxTicketsSupply;
    uint256 public endDateSale;

    event MintedTicket(address indexed _owner, uint256 indexed _id);

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        uint256 _maxTicketsSupply,
        uint256 _endDateSale
    ) initializer public {
        require(_endDateSale > block.timestamp + 1 days, 'Ticketing: the _endDateSale must be in more than 1 day');

        __ERC721_init(_name, _symbol);
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();
        maxTicketsSupply = _maxTicketsSupply;
        endDateSale = _endDateSale;
        setBaseURI(_baseTokenURI);
    }

    function mintTickets() public {
        _ticketIds.increment();
        uint256 newTicketId = _ticketIds.current();
        _safeMint(msg.sender, newTicketId);
        tokenURI(newTicketId);
        emit MintedTicket(msg.sender, newTicketId);
    }

    function _baseURI() internal view  virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _baseTokenURI) internal onlyOwner {
        baseURI = _baseTokenURI;
    }

    function tokenURI(uint256 _ticketId) public view virtual override returns (string memory) {
        require(_exists(_ticketId), "Metadata: URI query for nonexistent ticket");
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _ticketId.toString(),".json"))
            : "";
    }
}
