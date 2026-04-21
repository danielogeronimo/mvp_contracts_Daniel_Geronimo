// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PropertyNFT is ERC721, Ownable {
    uint256 public nextNFTId;

    constructor() ERC721("PropertyNFT", "PROP") Ownable(msg.sender) {}

    function safeMint(address to) external onlyOwner {
        _safeMint(to, nextNFTId);
        nextNFTId++;
    }
}
