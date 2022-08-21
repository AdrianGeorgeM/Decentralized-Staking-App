// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    //Mappings
    // Solidity Mappingss
    // In our smart contract, I'll need two mappings to help us store some data.
    // In particular, I need something to keep track of:
    //     how much ETH is deposited into the contract
    //     the time that the deposit happened

    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositTimestamps;

    // Public Variables
    // The reward rate sets the interest rate for the disbursement of ETH on the principal amount staked.
    // The withdrawal and claim deadlines help us set deadlines for the staking mechanics to begin/end.

    uint256 public constant rewardRatePerSecond = 0.1 ether;
    uint256 public withdrawalDeadline = block.timestamp + 120 seconds;
    uint256 public claimDeadline = block.timestamp + 240 seconds;
    uint256 public currentBlock = 0;

    // Events
    //  emit them in key parts of our contract to ensure that I maintain best programming practices.
    event Stake(address indexed sender, uint256 amount);
    event Received(address, uint256);
    event Execute(address indexed sender, uint256 amount);

    // Modifiers
    //     Solidity modifiers are pieces of code that can run before and/or after a function call.

    // While they have many different purposes, one of the most common and basic use cases is for restricting access to certain functions if particular conditions are not fully met.
    /*
  Checks if the withdrawal period has been reached or not
  */

    //   The modifiers withdrawalDeadlineReached(bool requireReached) & claimDeadlineReached(bool requireReached) both accept a boolean parameter and check to ensure that their respective deadlines are either true or false.

    // The modifier notCompleted() operates in a similar fashion but is actually a little bit more complex in nature even though it contains feIr lines of code.

    // It actually calls on a function completed() from an external contract outside of Staker and checks to see if it's returning true or false to confirm if that flag has been switched.
    modifier withdrawalDeadlineReached(bool requireReached) {
        uint256 timeRemaining = withdrawalTimeLeft();
        if (requireReached) {
            require(timeRemaining == 0, "Withdrawal period is not reached yet");
        } else {
            require(timeRemaining > 0, "Withdrawal period has been reached");
        }
        _;
    }

    modifier claimDeadlineReached(bool requireReached) {
        uint256 timeRemaining = claimPeriodLeft();
        if (requireReached) {
            require(timeRemaining == 0, "Claim deadline is not reached yet");
        } else {
            require(timeRemaining > 0, "Claim deadline has been reached");
        }
        _;
    }

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "Stake already completed!");
        _;
    }

    // READ ONLY Time Functions
    // The conditional simply checks whether the current time is greater than or less than the deadlines dictated in the public variables section.
    // If the current time is greater than the pre-arranged deadlines, I know that the deadline has passed and I return 0 to signify that a "state change" has occurred.
    // Otherwise, I simply return the remaining time before the deadline is reached.
    /*
  READ-ONLY function to calculate the time remaining before the minimum staking period has passed
  */
    function withdrawalTimeLeft()
        public
        view
        returns (uint256 withdrawalTimeLeft)
    {
        if (block.timestamp >= withdrawalDeadline) {
            return (0);
        } else {
            return (withdrawalDeadline - block.timestamp);
        }
    }

    /*
  READ-ONLY function to calculate the time remaining before the minimum staking period has passed
  */
    function claimPeriodLeft() public view returns (uint256 claimPeriodLeft) {
        if (block.timestamp >= claimDeadline) {
            return (0);
        } else {
            return (claimDeadline - block.timestamp);
        }
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Depositing/Staking Function
    // Stake function for a user to stake ETH in our contract
    // use the modifiers created earlier by setting the params within withdrawalDeadlineReached() to be false and claimDeadlineReached() to be false since I don't want either deadline to have passed yet.
    //The rest of the function is fairly standard in a typical "deposit" scenario where our balance mapping is updated to include the money sent in.

    // I also set our deposit timestamp with the current time of the deposit so that I access that stored value for interest calculations later.
    function stake()
        public
        payable
        withdrawalDeadlineReached(false)
        claimDeadlineReached(false)
    {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        depositTimestamps[msg.sender] = block.timestamp;
        emit Stake(msg.sender, msg.value);
    }
}
