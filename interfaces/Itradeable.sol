// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITradable is IERC721 {
    function completeSale(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
