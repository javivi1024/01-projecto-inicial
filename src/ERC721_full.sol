// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";

contract MintableERC721 is ERC721URIStorage {
    // Variables
    address public owner;
    uint256 public nextTokenId;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
        nextTokenId = 1;
    }

    function mintToken(string memory tokenURI) public returns (uint256) {
        uint256 tokenId = nextTokenId;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        nextTokenId++;
        return tokenId;
    }

    //Mintability not restricted for the proof of concept
    function canMint() public pure returns (bool) {
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Not owner');
        _;
    }
}

contract Rewards {

    address public owner;

    // Declaring the ERC721 token contract variable
    MintableERC721 public tokenContract;

    // Mapping to store balance for each user
    mapping(address => uint256) private balance;

    // Mapping to store available rewards
    mapping(uint256 => uint256) public rewards;

    // ID for the next reward to be added
    uint256 public nextRewardId;

    event rewardsRedeemed(address indexed user, uint256 rewardId, uint256 price);
    event newRewardAdded(uint256 rewardId, uint256 price);

    // Modifier for functions that only the owner can call
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    /**
     * @dev Constructor to initialize the contract.
     * Sets the contract's owner to the deployer.
     */
    constructor(MintableERC721 _tokenContract) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        nextRewardId = 1;
    }

    /**
     * @dev Allows the owner to change the contract's owner.
     * @param _newOwner The address of the new owner.
     */
    function setOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner address cannot be zero");
        owner = _newOwner;
    }

    /**
     * @dev Allows the owner to add a new reward to the program.
     * @param price The price of the reward.
     */
    function addReward(uint256 price) public onlyOwner {
        rewards[nextRewardId] = price;
        emit newRewardAdded(nextRewardId, price);
        nextRewardId++;
    }

    /**
     * @dev Allows a user to add balance to his account in the contract
     * @param amount The amount to add
     */
    function addBalance(uint256 amount) public {
        // In ERC721, "balance" typically refers to the number of NFTs owned,
        // not a fungible balance. You might redefine this logic based on your use case.
        // For simplicity, we'll treat `amount` as a simple counter of actions.
        balance[msg.sender] += amount;
    }

    /**
     * @dev Query a user's balance.
     * @param user The address of the user.
     * @return The amount of tokens the user has.
     */
    function getBalance(address user) public view returns (uint256) {
        return balance[user];
    }

    /**
     * @dev Query a reward's price, here the contract could create an NFT and send it to the user, as the real reward.
     * @param rewardId The ID of the reward.
     * @return The price of the reward.
     */
    function getReward(uint256 rewardId) public returns (uint256) {
        require(balance[msg.sender] >= rewards[rewardId], "Not enough balance!!");
        balance[msg.sender] -= rewards[rewardId];

        console.log("Reward redeemed!! ", rewardId);
        console.log("Current balance ", balance[msg.sender]);

        return rewards[rewardId];
    }
}

contract Factory {
    address[] public tokens;
    uint256 public tokenCount;

    address[] public rewards;
    uint256 public rewardsCount;

    event TokenDeployed(address tokenAddress);

    function deployToken(string calldata _name, string calldata _ticker) public returns (address) {
        MintableERC721 token = new MintableERC721(_name, _ticker);
        tokens.push(address(token));
        tokenCount += 1;

        Rewards rewardsContract = new Rewards(token);
        rewards.push(address(rewardsContract));
        rewardsCount += 1;

        emit TokenDeployed(address(token));
        return address(token);
    }
}