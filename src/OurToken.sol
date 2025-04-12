//SPDX-License-Identifier:MIT

pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OurToken", "TT") {
        // giving ERC20 constructor its arguements //ERC20("OurToken", "TT") calls the parent constructor, setting:
        _mint(msg.sender, initialSupply); //This mints the initial supply of tokens to the address that deploys the contract (msg.sender).
    }
}
