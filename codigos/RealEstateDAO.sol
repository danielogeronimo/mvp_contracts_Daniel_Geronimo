// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

interface IPropertyNFT {
    function safeMint(address to) external;
}

contract RealEstateDAO is AccessControl, ReentrancyGuard {
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");
    
    AggregatorV3Interface internal priceFeed;
    IERC20 public brickToken;
    IPropertyNFT public propertyNFT;

    mapping(address => uint256) public stakedAmount;
    mapping(uint256 => bool) public proposals;

    constructor(address _brickToken, address _nftAddress, address _oracle) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(VOTER_ROLE, DEFAULT_ADMIN_ROLE);
        
        brickToken = IERC20(_brickToken);
        propertyNFT = IPropertyNFT(_nftAddress);
        priceFeed = AggregatorV3Interface(_oracle);
    }

    // ETAPA 4: Oráculo
    function getMarketPrice() public view returns (uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        return uint256(price / 1e8);
    }

    // ETAPA 2: Staking
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Valor insuficiente");
        brickToken.transferFrom(msg.sender, address(this), amount);
        stakedAmount[msg.sender] += amount;
    }

    // Lógica de Mint via Protocolo
    function requestNFT() external {
        require(stakedAmount[msg.sender] >= 500 * 10**18, "Stake insuficiente");
        require(getMarketPrice() > 1500, "Preco de mercado baixo");
        propertyNFT.safeMint(msg.sender);
    }

    // ETAPA 2: Governança
    function createProposal(uint256 proposalId) external onlyRole(VOTER_ROLE) {
        proposals[proposalId] = true;
    }
}
