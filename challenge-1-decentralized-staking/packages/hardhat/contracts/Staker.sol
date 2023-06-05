// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    event Stake(address indexed sender, uint256 indexed amount);
    event Execute(uint256 amount);
    event Withdraw(address indexed withdrawer, uint256 indexed amount);
    error NoBalanceToWithdraw();
    error TransectionFailed();

    ExampleExternalContract public exampleExternalContract;
    uint256 public deadline;

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    bool public openForWithdraw;

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(
            !completed,
            "The Staker has already transfered funds to the External Contract"
        );
        _;
    }

    constructor(address exampleExternalContractAddress) {
        deadline = block.timestamp + 72 hours;
        openForWithdraw = false;
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable notCompleted {
        balances[msg.sender] = msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    function execute() public notCompleted {
        uint256 timeleft = timeLeft();
        if (timeleft == 0 && threshold < address(this).balance) {
          uint256 currentBalance = address(this).balance;
          exampleExternalContract.complete{value: currentBalance}();
          emit Execute(currentBalance);
        }
    }

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() public {
        if (threshold > address(this).balance) {
            openForWithdraw = true;
        }
        require(openForWithdraw, "Contract is not open for withdraw");
        uint256 proceeds = balances[msg.sender];
        if (proceeds <= 0) {
            revert NoBalanceToWithdraw();
        }
        balances[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        if (!success) {
            revert TransectionFailed();
        }
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
