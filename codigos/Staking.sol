// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MeuNFT.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Staking is Ownable, ReentrancyGuard {
    IERC20 public tokenStake;
    MeuNFT public nftContract;
    AggregatorV3Interface internal priceFeed; // ETH/USD

    struct StakeInfo {
        uint256 amount;
        uint256 since;
        uint256 points;
    }
    mapping(address => StakeInfo) public stakes;

    uint256 public constant BASE_RATE = 100;          // pontos por token por dia (base)
    uint256 public constant NFT_THRESHOLD = 1000;     // pontos necessários para mintar NFT
    uint256 public multiplier = 1e18;                 // multiplicador baseado no preço (fator 18 decimais)

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);
    event NFTAwarded(address indexed user, uint256 tokenId);

    constructor(address _token, address _nft, address _priceFeed) Ownable(msg.sender) {
        tokenStake = IERC20(_token);
        nftContract = MeuNFT(_nft);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Atualiza multiplicador com base no preço ETH/USD
    function updateMultiplier() public {
        (, int price, , , ) = priceFeed.latestRoundData();
        uint256 ethUsd = uint256(price) * 1e10; // Chainlink retorna 8 decimais
        // Exemplo: se ETH > 2000 USD, multiplicador = 2x; senão 1x
        if (ethUsd > 2000 * 1e8) {
            multiplier = 2e18;
        } else {
            multiplier = 1e18;
        }
    }

    // Calcula pontos desde o último stake/resgate
    function _calculatePendingPoints(address user) internal view returns (uint256 pending) {
        StakeInfo storage s = stakes[user];
        if (s.amount == 0) return 0;
        uint256 secondsStaked = block.timestamp - s.since;
        // BASE_RATE * amount * tempo (em dias fracionados) * multiplicador
        uint256 daysStaked = (secondsStaked * 1e18) / 86400; // 1 dia = 86400 seg
        pending = (s.amount * BASE_RATE * daysStaked * multiplier) / 1e36;
        return pending;
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Quantidade invalida");
        updateMultiplier();

        // Atualiza pontos acumulados antes de alterar o depósito
        uint256 pending = _calculatePendingPoints(msg.sender);
        stakes[msg.sender].points += pending;
        stakes[msg.sender].amount += amount;
        stakes[msg.sender].since = block.timestamp;

        tokenStake.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        StakeInfo storage s = stakes[msg.sender];
        require(s.amount >= amount, "Saldo insuficiente");
        updateMultiplier();

        uint256 pending = _calculatePendingPoints(msg.sender);
        s.points += pending;
        s.amount -= amount;
        s.since = block.timestamp;

        // Recompensa em tokens: 1 ponto = 0.001 token (apenas exemplo)
        uint256 reward = s.points / 1000;
        if (reward > 0) {
            s.points = 0; // reseta pontos
            // Mint da recompensa (o owner do token deve permitir mint)
            // Aqui vamos usar o próprio token; se o contrato não tiver mint, precisamos de fundos.
            // Para simplicidade, exigimos que o contrato tenha saldo.
            require(tokenStake.balanceOf(address(this)) >= reward + amount, "Saldo insuficiente do contrato");
            tokenStake.transfer(msg.sender, amount + reward);
            emit Withdrawn(msg.sender, amount, reward);
        } else {
            tokenStake.transfer(msg.sender, amount);
            emit Withdrawn(msg.sender, amount, 0);
        }
    }

    function claimNFT() external nonReentrant {
        StakeInfo storage s = stakes[msg.sender];
        uint256 pending = _calculatePendingPoints(msg.sender);
        s.points += pending;
        s.since = block.timestamp;
        require(s.points >= NFT_THRESHOLD, "Pontos insuficientes para NFT");
        s.points -= NFT_THRESHOLD;

        uint256 tokenId = nftContract.safeMint(msg.sender);
        emit NFTAwarded(msg.sender, tokenId);
    }

    // Permite ao dono depositar tokens no contrato para financiar recompensas
    function fund(uint256 amount) external {
        tokenStake.transferFrom(msg.sender, address(this), amount);
    }
}