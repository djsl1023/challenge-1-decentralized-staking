// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  event Stake(address, uint256);

  //mapping of individual balances
  mapping(address => uint256) public balances;
  //goal threshold
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool public openForWithdraw = false;
  bool public executeCalled = false;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    address sender = msg.sender;
    uint256 amount = msg.value;

    balances[sender] += amount;
    emit Stake(sender, amount);
  }



  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {
    require(block.timestamp >= deadline, "Not time yet");
    require(!executeCalled, "Already Executed");

    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
    else{
      openForWithdraw = true;
    }
    executeCalled = true;
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public {
    require(openForWithdraw, "Can't withdraw at this time");
    uint256 amount = balances[msg.sender];
    require(amount > 0, "No funds to withdraw");
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
    return block.timestamp >= deadline ? 0 : deadline - block.timestamp;
  }


  // Add the `receive()` special function that receives eth and calls stake()


}
