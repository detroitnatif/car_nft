// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MotoParts is ERC20Pausable, Ownable {
    constructor() ERC20("MotoParts", "MParts") {}

    // we want to authorize controller contracts to mint tokens in order to reward players
    mapping(address => bool) private _mintAuthorized;
    // we want to authorize treasury contract to mint tokens in order to exchange them for AVAX
    mapping(address => bool) private _burnAuthorized;

    function mint(address account, uint256 amount) public {
        bool isOwner = owner() == msg.sender;
        bool isAuthorized = _mintAuthorized[msg.sender];
        require(isOwner || isAuthorized, "Not authorized to mint");

        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        bool isOwner = owner() == msg.sender;
        bool isAuthorized = _burnAuthorized[msg.sender];
        require(isOwner || isAuthorized, "Not authorized to burn");

        _burn(account, amount);
    }

    /***************************************
     * Owner only maintanence/security calls
     ***************************************/

    function changeMintAuthorization(address account, bool authorized)
        public
        onlyOwner
    {
        _mintAuthorized[account] = authorized;
    }

    function changeBurnAuthorization(address account, bool authorized)
        public
        onlyOwner
    {
        _burnAuthorized[account] = authorized;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
