/*
Dentacoin Foundation Presale Bonus
*/

pragma solidity ^0.4.11;



//Dentacoin token import
contract exToken {
  function transfer(address, uint256) returns (bool) {  }
  function balanceOf(address) constant returns (uint256) {  }
}


// Presale Bonus after Presale
contract PresaleBonus {
  uint public getBonusTime = 14 days;                                         // Time span from contract deployment to end of bonus request period. Afterwards bonus will be paid out
  uint public startTime;                                                      // Time of contract deployment
  address public owner;                                                       // Owner of this contract, who may refund all remaining DCN and ETH
  exToken public tokenAddress;                                                // Address of the DCN token: 0x08d32b0da63e2C3bcF8019c9c5d849d7a9d791e6
  mapping (address => bool) public requestOf;                                 // List of all DCN holders, which requested the bonus

  modifier onlyBy(address _account){                                          // All functions modified by this, must only be used by the owner
    require(msg.sender == _account);
    _;
  }

  function PresaleBonus() {                                                   // The function that is run only once at contract deployment
    owner = msg.sender;                                                       // Set the owner address to that account, which deploys this contract
    startTime = now;                                                          // Set the start time of the request period to the contract deployment time
    tokenAddress = exToken(0x08d32b0da63e2C3bcF8019c9c5d849d7a9d791e6);       // Define Dentacoin token address
  }

  //Send tiny amount of eth to request DCN bonus
    function () payable {                                                     // This empty function runs by definition if anyone sends ETH to this contract
      if ((startTime + getBonusTime) > now) {                                 // If the request period has not ended yet, then do the following:
        require(msg.value == 0);                                              // Check if the requester sends 0 ETH to this contract (proof of ownership)
        require(requestOf[msg.sender] == false);                              // Check if the requester didn't request yet
        requestOf[msg.sender] = true;                                         // Finally add the requester to the list of requesters
      } else {                                                                // If the request period has ended, then do the following:
        require(requestOf[msg.sender]);                                       // Check if requester is found on the requester list
        require(tokenAddress.balanceOf(msg.sender) >= 10);                    // Check of the requester address holds at least 10 DCN
        uint256 bonus = tokenAddress.balanceOf(msg.sender)/10;                // Set the bonus amount to 10% of the requesters DCN holdings
        tokenAddress.transfer(msg.sender, bonus);                             // Transfer the bonus from this contract to the requester
      }
    }

  // refund to owner
    function refundToOwner () onlyBy(owner) {                                 // Send remaining ETH and DCN to the contract owner
        if (!msg.sender.send(this.balance)) {                                 // Send ether to the owner
            throw;
        }
        tokenAddress.transfer(owner, tokenAddress.balanceOf(this));           // Send DCN to the owner
    }
}