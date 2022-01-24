// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/ITreasury.sol";
import "../interfaces/ITradable.sol";

struct Traits {
    // handling
    uint8 brakeTier;
    uint8 suspensionTier;
    // speed
    uint8 engineTier;
    uint8 exhaustTier;
    // --- first 32 byte ends

    // acceleration
    uint8 wheelTier;
    uint8 gearboxTier;
    uint8 bodyTier;
    uint8 specialTier;
    // --- second 32 byte ends
    uint8 protectionTier;
    uint16 designSeed;
    bool initialized;
}

contract xlr8 is ERC721Enumerable, Pausable, Ownable, ITradable {
    uint256 public baseMintPrice;
    mapping(uint256 => Traits) public traits;

    ITreasury private _treasury;
    string private _baseURIStorage;
    address private _marketplace;
    address private _initializer;

    constructor() ERC721("xlr8", "XLR") {
        baseMintPrice = 0.1 ether; // 0.5 AVAX???
    }

    function completeSale(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(_marketplace == msg.sender, "Only for marketplace");

        _transfer(from, to, tokenId);
    }

    /**
     * Mints the new car. Also collects price and pushes to the fundRecipient
     */
    function mint() public payable {
        require(msg.value >= baseMintPrice, "Mint price requirement not met");

        _mint(msg.sender, totalSupply() + 1);

        _treasury.deposit{value: msg.value}();
    }

    function initialize(uint256 tokenId, Traits memory tokenTraits) public {
        require(_initializer == msg.sender, "Only for initializer");
        require(!traits[tokenId].initialized, "Token already initialized");
        require(tokenTraits.initialized, "Initialized must be set to true");

        traits[tokenId] = tokenTraits;
    }

    /***************************************
     * Internal
     ***************************************/

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIStorage;
    }

    /***************************************
     * Owner only maintanence/security calls
     ***************************************/

    function setBaseMintPrice(uint256 newBaseMintPrice) public onlyOwner {
        baseMintPrice = newBaseMintPrice;
    }

    function setTreasury(ITreasury newTreasury) public onlyOwner {
        _treasury = newTreasury;
    }

    function setMarketplace(address marketplace) public onlyOwner {
        _marketplace = marketplace;
    }

    function setInitializer(address initializer) public onlyOwner {
        _initializer = initializer;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setBaseURI(string memory baseURIStorage) public onlyOwner {
        _baseURIStorage = baseURIStorage;
    }
}