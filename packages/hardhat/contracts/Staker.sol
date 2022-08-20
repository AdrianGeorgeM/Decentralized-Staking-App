// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

//Mappings 
// Solidity Mappingss
// In our smart contract, we'll need two mappings to help us store some data.
// In particular, we need something to keep track of:
//     how much ETH is deposited into the contract
//     the time that the deposit happened

  mapping(address => uint256) public balances;
  mapping(address => uint256) public depositTimestamps;

  uint256 public constant rewardRatePerSecond = 0.1 ether;
  uint256 public withdrawalDeadline = block.timestamp + 120 seconds;
  uint256 public claimDeadline = block.timestamp + 240 seconds;
  uint256 public currentBlock = 0;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }
