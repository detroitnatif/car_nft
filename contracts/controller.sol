// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interfaces/IRace.sol";
import "./MotoNFT.sol";
import "./MotoExperiencePoints.sol";
import "./MotoParts.sol";

struct SignUpRecord {
    IRace race;
    uint256 round;
}

contract Controller is Ownable, Pausable {
    using SafeMath for uint256;

    event CarSignedUp(uint256 carID, address race, uint256 round);

    mapping(uint256 => SignUpRecord) public signUpRecords;

    MotoNFT private _motoNFT;
    MotoExperiencePoints private _motoExperiencePoints;
    MotoParts private _motoParts;

    mapping(IRace => bool) private _registeredRaces;
    mapping(IRace => bool) private _stoppedRaces;

    constructor(
        MotoNFT motoNFT,
        MotoParts motoParts,
        MotoExperiencePoints motoExperiencePoints
    ) {
        _motoNFT = motoNFT;
        _motoParts = motoParts;
        _motoExperiencePoints = motoExperiencePoints;
    }

    function isRegisteredRace(IRace race) public view returns (bool) {
        return _registeredRaces[race];
    }

    function signUpForRace(uint256 carID, IRace race)
        public
        onlyCarOwner(carID)
    {
        require(_registeredRaces[race], "Race is not registered");
        require(!_stoppedRaces[race], "Race is no longer active");
        require(
            address(signUpRecords[carID].race) == address(0x0),
            "Bike is already signed up for a race"
        );
        signUpRecords[CarId] = SignUpRecord(race, race.getCurrentSignupRound());
        emit CarSignedUp(
            carID,
            address(signUpRecords[carID].race),
            signUpRecords[carID].round
        );
    }

    function cancelSignUp(uint256 carID) public onlyBikeOwner(carID) {
        delete signUpRecords[carID];
        emit CarSignedUp(
            carID,
            address(signUpRecords[carID].race),
            signUpRecords[carID].round
        );
    }

    function claimReward(uint256 carID, bool keepSignedUp)
        public
        onlyCarOwner(carID)
    {
        SignUpRecord memory signUpRecord = signUpRecords[carID];
        require(
            address(signUpRecord.race) != address(0),
            "Car is not signed up for any race"
        );
        uint256 claimTime = signUpRecord.race.getClaimTimestampForRound(
            signUpRecord.round
        );
        require(block.timestamp > claimTime, "Not time to claim yet");

        Reward memory reward = signUpRecord.race.calculateReward(
            carID,
            signUpRecord.round
        );
        _motoParts.mint(msg.sender, reward.parts);
        _motoExperiencePoints.mint(msg.sender, reward.exp);

        cancelSignUp(bikeId);
        if (keepSignedUp) {
            signUpForRace(bikeId, signUpRecord.race);
        }
    }

    /**
     * @dev Throws if called by any account other than the NFT Bike owner.
     */
    modifier onlyCarOwner(uint256 carID) {
        address carOwner = _motoNFT.ownerOf(carNFT);
        require(carOwner == msg.sender, "Car is not owned by sender");
        _;
    }

    /***************************************
     * Owner only maintanence/security calls
     ***************************************/
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function changeRaceRegistration(IRace race, bool value) public onlyOwner {
        _registeredRaces[race] = value;
    }

    function changeRaceStoppedStatus(IRace race, bool value) public onlyOwner {
        _stoppedRaces[race] = value;
    }
}
