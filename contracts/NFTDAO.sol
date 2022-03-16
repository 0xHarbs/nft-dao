// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTMarketplace.sol";

contract NFTDAO is NFTMarketplace {
    uint256 numOfProposals;

    struct Proposal {
        string name;
        string description;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        mapping(uint256 => bool) voters;
    }

    mapping(uint256 => Proposal) public proposals;

    modifier holderOnly() {
        require(super.balanceOf(msg.sender) > 0, "Not an NFT holders");
        _;
    }

    modifier proposalActive(uint256 proposalId) {
        require(
            proposals[proposalId].deadline > block.timestamp,
            "Deadline for proposal has passed"
        );
        _;
    }

    modifier proposalInactive(uint256 proposalId) {
        require(
            proposals[proposalId].deadline < block.timestamp,
            "Proposal is still active"
        );
        require(proposals[proposalId].executed == false);
        _;
    }

    constructor() {}

    function createProposal(string memory _name, string memory _description)
        public
        holderOnly
    {
        Proposal storage proposal = proposals[numOfProposals];
        proposal.name = _name;
        proposal.description = _description;
        proposal.deadline = block.timestamp + 1 weeks;
        numOfProposals++;
    }

    function voteOnProposal(uint256 proposalId, bool value)
        external
        holderOnly
        proposalActive(proposalId)
    {
        Proposal storage proposal = proposals[proposalId];
        uint256 eligibleVotes = super.balanceOf(msg.sender);
        uint256 numOfVotes = 0;

        for (uint256 i; i < eligibleVotes; i++) {
            uint256 voteId = super.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[voteId] == false) {
                numOfVotes += 1;
                proposal.voters[voteId] == true;
            }
        }

        require(numOfVotes > 0, "You do not have any more eligible votes");

        if (value) {
            proposal.yesVotes += numOfVotes;
        } else if (!value) {
            proposal.noVotes += numOfVotes;
        }
    }

    function executeProposal(uint256 proposalId)
        public
        holderOnly
        proposalInactive(proposalId)
    {
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
    }

    receive() external payable {}

    fallback() external payable {}
}
