// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Lottery {
    // Address of the contract manager
    address public manager;

    // Array of participant addresses (payable for payment)
    address payable[] public participants;

    constructor() {
        // Set the contract creator as the manager
        manager = msg.sender;
    }

    receive() external payable {
        // Require a specific entry fee of 1 ether
        require(msg.value == 1 ether);

        // Add the participant to the list
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        // Restrict balance access to the contract manager
        require(msg.sender == manager);

        // Return the contract's current balance
        return address(this).balance;
    }

    // Function to generate a pseudorandom number (not truly random)
    function random() public view returns(uint) {
        // Use a combination of block variables and participant count for unpredictability
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, participants.length)));
    }

    function selectWinner() public {
        // Only allow the manager to call this function
        require(msg.sender == manager);

        // Require at least 3 participants for a meaningful lottery
        require(participants.length >= 3);

        // Generate a pseudorandom number
        uint r = random();

        // Select a winner based on the random number
        uint index = r % participants.length;
        address payable winner = participants[index];

        // Transfer the entire contract balance to the winner
        winner.transfer(getBalance());

        // Reset the participants list for the next round
        participants = new address payable[](0);
    }
}
