// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EMOKING is ERC20, Ownable {

    uint256 private constant TOTAL_SUPPLY = 1_000_000_000 * 10**18;

    address public liquidityWallet;
    address public marketingWallet;
    address public devWallet;
    address public partnershipWallet;
    address public deployerWallet;

    mapping(address => bool) public isBlacklisted;

    constructor(
        address _liquidityWallet,
        address _marketingWallet,
        address _devWallet,
        address _partnershipWallet,
        address _deployerWallet
    ) ERC20("EMOKING", "EMOKING") Ownable(msg.sender) {
        require(_liquidityWallet != address(0), "Liquidity wallet cannot be zero address");
        require(_marketingWallet != address(0), "Marketing wallet cannot be zero address");
        require(_devWallet != address(0), "Dev wallet cannot be zero address");
        require(_partnershipWallet != address(0), "Partnership wallet cannot be zero address");
        require(_deployerWallet != address(0), "Deployer wallet cannot be zero address");

        liquidityWallet = _liquidityWallet;
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
        partnershipWallet = _partnershipWallet;
        deployerWallet = _deployerWallet;

        _mint(liquidityWallet, (TOTAL_SUPPLY * 70) / 100);       // 70%
        _mint(marketingWallet, (TOTAL_SUPPLY * 10) / 100);       // 10%
        _mint(devWallet, (TOTAL_SUPPLY * 10) / 100);             // 10%
        _mint(partnershipWallet, (TOTAL_SUPPLY * 5) / 100);      // 5%
        _mint(deployerWallet, (TOTAL_SUPPLY * 5) / 100);         // 5%
    }

    function blacklist(address user, bool value) external onlyOwner {
        isBlacklisted[user] = value;
    }

    // Optional: block transfers from/to blacklisted addresses
    function transfer(address to, uint256 amount) public override returns (bool) {
        require(!isBlacklisted[msg.sender], "Sender is blacklisted");
        require(!isBlacklisted[to], "Recipient is blacklisted");
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(!isBlacklisted[from], "Sender is blacklisted");
        require(!isBlacklisted[to], "Recipient is blacklisted");
        return super.transferFrom(from, to, amount);
    }
}
