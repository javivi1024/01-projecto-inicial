// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC1155Rewards.sol";

contract Factory {
    address[] public tokens;
    uint256 public tokenCount;

    event TokenDeployed(address tokenAddress);

    function deployToken(address initialOwner, string calldata uri, string calldata name, string calldata symbol) public returns (address) {
        ERC1155Rewards token = new ERC1155Rewards(initialOwner, uri, name, symbol);
        tokens.push(address(token));
        tokenCount += 1;

        emit TokenDeployed(address(token));
        return address(token);
    }

}