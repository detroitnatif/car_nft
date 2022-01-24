// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IYakStrategy.sol";
import "../interfaces/ITreasury.sol";
import "../contracts/MotoParts.sol";

contract Treasury is Ownable, Pausable, ITreasury {
    using SafeMath for uint256;

    uint256 public principal;
    uint256 public minTradeValue;

    IYakStrategy public farm;
    MotoParts public mParts;

    event PaymentRecieved(uint256 amount);
    event DepositRecieved(uint256 amount);

    constructor(IYakStrategy _farm, MotoParts _mParts) {
        minTradeValue = 0.05 ether; // 0.05 AVAX
        farm = _farm;
        mParts = _mParts;
    }

    fallback() external payable {
        emit PaymentRecieved(msg.value);
    }

    receive() external payable {
        emit PaymentRecieved(msg.value);
    }

    function deposit() public payable {
        require(!paused(), "Pausable: treasury is paused");

        emit DepositRecieved(msg.value);

        principal = principal.add(msg.value);
        farm.deposit{value: msg.value}();
    }

    function getInvestmentBalance() public view returns (uint256) {
        uint256 shares = farm.balanceOf(address(this));
        uint256 depositTokens = farm.getDepositTokensForShares(shares);
        return depositTokens;
    }

    function getInterest() public view returns (uint256) {
        uint256 investmentBalance = this.getInvestmentBalance();
        return investmentBalance.sub(principal);
    }

    function getMPartsValue(uint256 mPartsAmount)
        public
        view
        returns (uint256)
    {
        uint256 mPartsSupply = mParts.totalSupply();
        uint256 interest = this.getInterest();

        if (interest == 0 || mPartsSupply == 0) {
            return 0;
        }
        return interest.mul(mPartsAmount).div(mPartsSupply);
    }

    function tradeInMParts(uint256 mPartsAmount) public {
        require(!paused(), "Pausable: treasury is paused");

        uint256 senderBalance = mParts.balanceOf(msg.sender);
        require(senderBalance >= mPartsAmount, "Not enough MParts to burn");

        uint256 value = getMPartsValue(mPartsAmount);
        require(value >= minTradeValue, "Too small value to trade");

        uint256 depositTokens = farm.getSharesForDepositTokens(value);
        farm.withdraw(depositTokens);

        mParts.burn(msg.sender, mPartsAmount);

        payable(msg.sender).transfer(value);
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

    function rescueFunds() public onlyOwner {
        farm.withdraw(farm.balanceOf(address(this)));

        principal = 0;

        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function setMinTradeValue(uint256 newMinTradeValue) public onlyOwner {
        minTradeValue = newMinTradeValue;
    }
}
