// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract GovernancaDAO is Ownable, ReentrancyGuard {
    IERC20 public tokenGovernanca;

    struct Proposal {
        string description;
        uint256 startBlock;
        uint256 endBlock;
        uint256 votesYes;
        uint256 votesNo;
        bool executed;
        mapping(address => bool) voted;
    }

    Proposal[] public proposals;
    uint256 public votingPeriod = 100; // blocos (ajustável)

    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 id, address voter, bool support, uint256 weight);
    event Executed(uint256 id);

    constructor(address _tokenGovernanca) Ownable(msg.sender) {
        tokenGovernanca = IERC20(_tokenGovernanca);
    }

    function createProposal(string calldata description) external {
        proposals.push();
        Proposal storage p = proposals[proposals.length - 1];
        p.description = description;
        p.startBlock = block.number;
        p.endBlock = block.number + votingPeriod;
        emit ProposalCreated(proposals.length - 1, description);
    }

    function vote(uint256 proposalId, bool support) external nonReentrant {
        Proposal storage p = proposals[proposalId];
        require(block.number >= p.startBlock && block.number <= p.endBlock, "Votacao fora do periodo");
        require(!p.voted[msg.sender], "Ja votou");
        uint256 weight = tokenGovernanca.balanceOf(msg.sender);
        require(weight > 0, "Sem poder de voto");
        p.voted[msg.sender] = true;
        if (support) {
            p.votesYes += weight;
        } else {
            p.votesNo += weight;
        }
        emit Voted(proposalId, msg.sender, support, weight);
    }

    function execute(uint256 proposalId) external onlyOwner {
        Proposal storage p = proposals[proposalId];
        require(block.number > p.endBlock, "Votacao ainda ativa");
        require(!p.executed, "Ja executada");
        p.executed = true;
        // Lógica de execução simplificada – apenas emite evento
        emit Executed(proposalId);
    }

    function setVotingPeriod(uint256 _votingPeriod) external onlyOwner {
        votingPeriod = _votingPeriod;
    }
}