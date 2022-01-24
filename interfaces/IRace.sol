// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

struct Reward {
    uint256 parts;
    uint256 exp;
}

interface IRace {
    function getCurrentSignupRound() external view returns (uint256);

    function getSignupEndForRound(uint256 round)
        external
        view
        returns (uint256);

    function getClaimTimestampForRound(uint256 round)
        external
        view
        returns (uint256);

    function calculateReward(uint256 motoNFT, uint256 round)
        external
        view
        returns (Reward memory);
}