pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
  // ToDo: add constructor and mint tokens for deployer,
  //       you can use the above import for ERC20.sol. Read the docs ^^^

  constructor() ERC20('Gold', 'GLD') {
    _mint(msg.sender,1000*(10**18));
  }
}
