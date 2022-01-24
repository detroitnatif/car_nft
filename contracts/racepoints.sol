// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MotoExperiencePoints is ERC20, Ownable {
    bool private _transferEnabledForMint = false;

    constructor() ERC20("MotoExperiencePoints", "MExp") {}

    // we want to authorize controller contracts to mint tokens in order to reward players
    mapping(address => bool) private _mintAuthorized;

    function mint(address account, uint256 amount) public {
        bool isOwner = owner() == msg.sender;
        bool isAuthorized = _mintAuthorized[msg.sender];
        require(isOwner || isAuthorized, "Not authorized to mint");

        _transferEnabledForMint = true;
        _mint(account, amount);
        _transferEnabledForMint = false;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function _beforeTokenTransfer(
        address,
        address,
        uint256
    ) internal view override {
        require(_transferEnabledForMint, "Experience is not transferable");
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
}