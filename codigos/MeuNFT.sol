// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MeuNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    address public stakingContract;

    modifier onlyStakingOrOwner() {
        require(msg.sender == stakingContract || msg.sender == owner(), "Apenas staking ou owner");
        _;
    }

    constructor() ERC721("MeuNFT", "MNFT") Ownable(msg.sender) {}

    function setStakingContract(address _staking) external onlyOwner {
        stakingContract = _staking;
    }

    function safeMint(address to) external onlyStakingOrOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    // Bloqueia transferências (soulbound)
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        require(from == address(0) || to == address(0), "NFT nao transferivel");
        return super._update(to, tokenId, auth);
    }
}