// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GDATWallet is Ownable {
    IERC20 public gdatToken;

    constructor(address _gdatToken) {
        gdatToken = IERC20(_gdatToken);
    }

    function deposit(uint256 amount) external {
        require(gdatToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(gdatToken.transfer(msg.sender, amount), "Transfer failed");
    }

    function balance() external view returns (uint256) {
        return gdatToken.balanceOf(address(this));
    }
}
