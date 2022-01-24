// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/ITreasury.sol";
import "../interfaces/ITradable.sol";

struct SaleRecord {
    address seller;
    uint256 price;
}

contract Marketplace is Ownable {
    using SafeMath for uint256;

    ITreasury private _treasury;

    // Commision percentage base point - 200 => 2%
    uint256 public comisionPercentageBase = 200;

    mapping(ITradable => mapping(uint256 => SaleRecord)) public askingPrices;

    constructor(ITreasury treasury) {
        _treasury = treasury;
    }

    function sell(
        ITradable collection,
        uint256 tokenId,
        uint256 price
    ) public {
        require(
            collection.ownerOf(tokenId) == msg.sender,
            "Token is not owned by sender"
        );

        askingPrices[collection][tokenId] = SaleRecord(msg.sender, price);
    }

    function cancelSell(ITradable collection, uint256 tokenId) public {
        require(
            collection.ownerOf(tokenId) == msg.sender,
            "Token is not owned by sender"
        );

        delete askingPrices[collection][tokenId];
    }

    function buy(ITradable collection, uint256 tokenId) public payable {
        address seller = askingPrices[collection][tokenId].seller;
        require(
            seller == collection.ownerOf(tokenId),
            "Token is not owned by seller"
        );
        require(
            msg.value >= askingPrices[collection][tokenId].price,
            "Not enough value sent"
        );

        uint256 comision = (msg.value.mul(comisionPercentageBase)).div(10000);
        uint256 sellerReward = msg.value.sub(comision);

        payable(seller).transfer(sellerReward);

        _treasury.deposit{value: comision}();

        collection.completeSale(seller, msg.sender, tokenId);

        delete askingPrices[collection][tokenId];
    }

    /***************************************
     * Owner only maintanence/security calls
     ***************************************/
    function setComisionPercentageBase(uint256 newComisionPercentageBase)
        public
        onlyOwner
    {
        comisionPercentageBase = newComisionPercentageBase;
    }
}
