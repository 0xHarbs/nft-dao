// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTFactory is ERC721Enumerable, Ownable {
    uint256 public tokenIds = 0;
    uint256 maxTokenIds = 5000;
    uint256 _tokenPrice = 0.05 ether;
    bool public _paused;

    mapping(uint256 => string) private _tokenURIs; // URI as mapping due to changes - best practice?

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    constructor() ERC721("Factory", "ERCC") {}

    function mint() public payable onlyWhenNotPaused {
        require(msg.value > _tokenPrice, "Need to send more Ether");
        require(
            tokenIds < maxTokenIds,
            "Max number of tokens have been minted"
        );
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function setPaused(bool _value) public onlyOwner {
        _paused = _value;
    }
}
