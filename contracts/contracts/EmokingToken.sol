// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EMOKING is ERC20, Ownable, ReentrancyGuard {
    uint256 private constant TOTAL_SUPPLY = 1_000_000_000 * 10**18;

    address public liquidityWallet;
    address public marketingWallet;
    address public devWallet;
    address public partnershipWallet;
    address public deployerWallet;
    address public lpPairAddress;

    uint256 public launchTime;
    mapping(address => bool) public isBlacklisted;

    constructor(
        address _liquidityWallet,
        address _marketingWallet,
        address _devWallet,
        address _partnershipWallet,
        address _deployerWallet,
        address _lpPairAddress
    ) ERC20("EMOKING", "EMOKING") Ownable(msg.sender) {
        require(_liquidityWallet != address(0), "Liquidity wallet cannot be zero address");
        require(_marketingWallet != address(0), "Marketing wallet cannot be zero address");
        require(_devWallet != address(0), "Dev wallet cannot be zero address");
        require(_partnershipWallet != address(0), "Partnership wallet cannot be zero address");
        require(_deployerWallet != address(0), "Deployer wallet cannot be zero address");
        require(_lpPairAddress != address(0), "LP pair cannot be zero address");

        liquidityWallet = _liquidityWallet;
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
        partnershipWallet = _partnershipWallet;
        deployerWallet = _deployerWallet;
        lpPairAddress = _lpPairAddress;

        launchTime = block.timestamp;

        _mint(liquidityWallet, (TOTAL_SUPPLY * 70) / 100);
        _mint(marketingWallet, (TOTAL_SUPPLY * 10) / 100);
        _mint(devWallet, (TOTAL_SUPPLY * 10) / 100);
        _mint(partnershipWallet, (TOTAL_SUPPLY * 5) / 100);
        _mint(deployerWallet, (TOTAL_SUPPLY * 5) / 100);
    }

    function blacklist(address user, bool value) external onlyOwner {
        require(
            user != liquidityWallet &&
            user != marketingWallet &&
            user != devWallet &&
            user != partnershipWallet &&
            user != deployerWallet &&
            user != lpPairAddress,
            "Cannot blacklist core wallets"
        );
        isBlacklisted[user] = value;
    }

    function transfer(address to, uint256 amount) public override nonReentrant returns (bool) {
        require(!isBlacklisted[msg.sender], "Sender is blacklisted");
        require(!isBlacklisted[to], "Recipient is blacklisted");

        if (block.timestamp < launchTime + 10 minutes && msg.sender == lpPairAddress) {
            isBlacklisted[to] = true;
        }

        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override nonReentrant returns (bool) {
        require(!isBlacklisted[from], "Sender is blacklisted");
        require(!isBlacklisted[to], "Recipient is blacklisted");

        if (block.timestamp < launchTime + 10 minutes && from == lpPairAddress) {
            isBlacklisted[to] = true;
        }

        return super.transferFrom(from, to, amount);
    }
}
