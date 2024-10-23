// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";

contract MintableERC721 is ERC721URIStorage {
    address public owner;
    uint256 public nextTokenId;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
        nextTokenId = 1;
    }

    function mintToken(string memory tokenURI) public {
        _safeMint(msg.sender, nextTokenId);
        _setTokenURI(nextTokenId, tokenURI);
        nextTokenId++;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Not owner');
        _;
    }
}

contract Rewards {
    address public owner;
    MintableERC721 public nftContract;

    mapping(uint256 => uint256) public rewards;
    uint256 public nextRewardId;

    event RewardRedeemed(address indexed user, uint256 rewardId);
    event NewRewardAdded(uint256 rewardId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(MintableERC721 _nftContract) {
        owner = msg.sender;
        nftContract = _nftContract;
        nextRewardId = 1;
    }

    function setOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner address cannot be zero");
        owner = _newOwner;
    }

    function addReward(uint256 price) public onlyOwner {
        rewards[nextRewardId] = price;
        emit NewRewardAdded(nextRewardId);
        nextRewardId++;
    }

    function redeemReward(uint256 rewardId, string memory tokenURI) public {
        require(rewards[rewardId] > 0, "Reward does not exist");
        
        nftContract.mintToken(tokenURI);
        rewards[rewardId] = 0;

        emit RewardRedeemed(msg.sender, rewardId);
    }
}

contract Factory {
    address[] public nfts;
    uint256 public nftCount;

    address[] public rewardsContracts;
    uint256 public rewardsCount;

    event NFTDeployed(address nftAddress);

    function deployNFT(string calldata _name, string calldata _symbol) public returns (address) {
        MintableERC721 nft = new MintableERC721(_name, _symbol);
        nfts.push(address(nft));
        nftCount += 1;

        Rewards rewardsContract = new Rewards(nft);
        rewardsContracts.push(address(rewardsContract));
        rewardsCount += 1;

        emit NFTDeployed(address(nft));
        return address(nft);
    }
}