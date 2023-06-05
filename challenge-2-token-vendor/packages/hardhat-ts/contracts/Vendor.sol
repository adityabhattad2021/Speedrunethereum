pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import './YourToken.sol';

contract Vendor is Ownable {

  event BuyTokens(address buyer,uint256 amountOfEth,uint256 amountOfTokens);
  using SafeMath for uint256;

  uint256 public constant tokensPerEth = 100;
  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    require(yourToken.balanceOf(address(this))>=tokensPerEth*msg.value,"Not Enough Tokens To Transfer");
    yourToken.transfer(
      msg.sender,
      tokensPerEth*msg.value
    );
    emit BuyTokens(msg.sender,msg.value,tokensPerEth*msg.value);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {

    (bool success,) = payable(msg.sender).call{value:address(this).balance}("");
    if(!success){
      revert("Could not withdraw");
    }
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amount) public {
    require(amount>0,"You need to sell atleast some tokens");
    uint256 allowence  = yourToken.allowance(msg.sender,address(this));
    require(allowence>=amount,"Check the token allowence");
    yourToken.transferFrom(msg.sender,address(this),amount);
    (bool success,) = payable(msg.sender).call{value:amount.div(tokensPerEth)}("");
    if(!success){
      revert("Transfer of ETH not successfull");
    }
  }
}
