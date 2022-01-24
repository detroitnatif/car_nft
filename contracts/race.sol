// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IRace.sol";

contract FixedRewardRace is IRace {
    using SafeMath for uint256;

    uint256 public creationTimestamp;

    uint256 private _signupPeriod;
    uint256 private _racingPeriod;
    uint256 private _rewardParts;

    constructor(
        uint256 signupPeriod,
        uint256 racingPeriod,
        uint256 rewardParts
    ) {
        creationTimestamp = block.timestamp;
        _signupPeriod = signupPeriod;
        _racingPeriod = racingPeriod;
        _rewardParts = rewardParts;
    }

    function getCurrentSignupRound() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp.sub(creationTimestamp);
        uint256 raceInterval = _signupPeriod.add(_racingPeriod);
        uint256 elapsedRounds = timeElapsed.div(raceInterval);

        uint256 signupEndTime = this.getSignupEndForRound(elapsedRounds + 1);

        if (block.timestamp < signupEndTime) {
            return elapsedRounds.add(1);
        }
        return elapsedRounds.add(2);
    }

    function getSignupEndForRound(uint256 round) public view returns (uint256) {
        uint256 raceInterval = _signupPeriod.add(_racingPeriod);

        uint256 signupEndTime = ((round.sub(1)).mul(raceInterval))
            .add(creationTimestamp)
            .add(_signupPeriod);

        return signupEndTime;
    }

    function getClaimTimestampForRound(uint256 round)
        public
        view
        returns (uint256)
    {
        uint256 raceInterval = _signupPeriod.add(_racingPeriod);

        uint256 claimTime = (round.mul(raceInterval)).add(creationTimestamp);

        return claimTime;
    }

    function calculateReward(uint256, uint256)
        public
        view
        returns (Reward memory)
    {
        uint256 expReward = _racingPeriod / 60;
        return Reward(_rewardParts, expReward);}}