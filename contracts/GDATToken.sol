// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GDATToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 5000000 * 10**18;
    uint256 public constant STO_START = 1711929600; // 2025-04-01 00:00:00 UTC
    uint256 public constant STO_END = 1714617599; // 2025-06-30 23:59:59 UTC

    uint256 public constant APRIL_PRICE_USD = 0.5 * 10**18; // 0.5 USD
    uint256 public constant MAY_PRICE_USD = 0.75 * 10**18; // 0.75 USD
    uint256 public constant JUNE_PRICE_USD = 1 * 10**18; // 1 USD
    
    uint256 public ethUsdRate; // ETH/USD rate in wei

    mapping(address => bool) public whitelist;
    address public fundReceiver;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event FundsWithdrawn(address indexed receiver, uint256 amount);

    constructor(address _fundReceiver, uint256 _ethUsdRate) ERC20("GDAT Token", "GDAT") {
        _mint(msg.sender, MAX_SUPPLY);
        fundReceiver = _fundReceiver;
        ethUsdRate = _ethUsdRate;
    }

    function addToWhitelist(address _address) external onlyOwner {
        whitelist[_address] = true;
    }

    function removeFromWhitelist(address _address) external onlyOwner {
        whitelist[_address] = false;
    }

    function updateEthUsdRate(uint256 _ethUsdRate) external onlyOwner {
        ethUsdRate = _ethUsdRate;
    }

    function getCurrentPrice() public view returns (uint256) {
        if (block.timestamp >= STO_START && block.timestamp < STO_START + 30 days) {
            return (APRIL_PRICE_USD * 10**18) / ethUsdRate; // Convert USD to wei
        } else if (block.timestamp >= STO_START + 30 days && block.timestamp < STO_START + 60 days) {
            return (MAY_PRICE_USD * 10**18) / ethUsdRate; // Convert USD to wei
        } else if (block.timestamp >= STO_START + 60 days && block.timestamp <= STO_END) {
            return (JUNE_PRICE_USD * 10**18) / ethUsdRate; // Convert USD to wei
        } else {
            revert("STO is not active");
        }
    }

    function buyTokens() external payable {
        require(block.timestamp >= STO_START && block.timestamp <= STO_END, "STO is not active");
        require(whitelist[msg.sender], "You are not whitelisted");
        require(msg.value > 0, "Send ETH to buy tokens");

        uint256 currentPrice = getCurrentPrice();
        uint256 tokensToBuy = msg.value * ethUsdRate / currentPrice;
        require(balanceOf(owner()) >= tokensToBuy, "Not enough tokens available");
        require(totalSupply() + tokensToBuy <= MAX_SUPPLY, "Exceeds max supply");

        _transfer(owner(), msg.sender, tokensToBuy);
        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(fundReceiver).transfer(balance);
        emit FundsWithdrawn(fundReceiver, balance);
    }
}
