// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IYakStrategy {
    /**
     * @notice Deposit and deploy deposits tokens to the strategy using AVAX
     * @dev Must mint receipt tokens to `msg.sender`
     */
    function deposit() external payable;

    /**
     * @notice Deposit on behalf of another account using AVAX
     * @dev Must mint receipt tokens to `account`
     * @param account address to receive receipt tokens
     */
    function depositFor(address account) external payable;

    /**
     * @notice Redeem receipt tokens for deposit tokens
     * @param amount receipt tokens
     */
    function withdraw(uint256 amount) external;

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Calculate receipt tokens for a given amount of deposit tokens
     * @dev If contract is empty, use 1:1 ratio
     * @dev Could return zero shares for very low amounts of deposit tokens
     * @param amount deposit tokens
     * @return receipt tokens
     */
    function getSharesForDepositTokens(uint256 amount)
        external
        view
        returns (uint256);

    /**
     * @notice Calculate deposit tokens for a given amount of receipt tokens
     * @param amount receipt tokens
     * @return deposit tokens
     */
    function getDepositTokensForShares(uint256 amount)
        external
        view
        returns (uint256);
}
