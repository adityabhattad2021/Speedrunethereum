// SPDX-license-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Monyo is ERC20 {
    constructor(address toMint,uint256 amountToMint)
        ERC20("MonyoToken","MON")
    {
        _mint(toMint,amountToMint);
    }
}