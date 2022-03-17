// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTFactory.sol";
import "hardhat/console.sol";

contract NFTMarketplace is NFTFactory {
    uint256 saleCounter;

    struct SaleListing {
        uint256 price;
        address owner;
    }

    SaleListing[] public sales;
    mapping(uint256 => SaleListing) public tokenToListing;

    constructor() {}

    function sellToken(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender);
        require(_price > 0, "Price must be more than 0 wei");
        approve(address(this), _tokenId);

        sales.push(SaleListing(_price, msg.sender));
        tokenToListing[_tokenId] = sales[saleCounter];
        saleCounter++;
    }

    function buyToken(uint256 _tokenId) public payable {
        SaleListing memory sale = tokenToListing[_tokenId];
        require(msg.value > sale.price);
        _transfer(sale.owner, msg.sender, _tokenId);
    }
}
