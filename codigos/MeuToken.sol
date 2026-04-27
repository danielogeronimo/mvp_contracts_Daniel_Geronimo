// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MeuToken is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("MeuToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // Função para mint adicional (apenas owner)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

