//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MovingEther{

//a basic function to get the balance of this contract
    function getBalance() external view returns(uint){
		return address(this).balance;
	}

//a deposit function cast as payable
    function deposit()external payable{}

//a function to send ether to an address, thereby requiring the parameter "address" (the recipient) is cast as payable
    function sendEther(address payable _to, uint _amount)external payable{
	_to.transfer(_amount);
    }

//Constructor
// an example of a constructor function that is payable
    constructor()payable{
        require(msg.value >= 1 ether, "You need to add enough ether first.");
    }

//an example of sending ether using the .transfer method
// note this is no longer the preferred method of sending ether
    function transferEther(address payable _to, uint _amount) external payable{
	_to.transfer(_amount);
}

//an example of sending ether using the .send() method
//note this is no longer the preferred method of sending ether
function sendViaSend(address payable _to) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
}

//an example of sending ether using the .call() method
//here we send 12 wei with a total gas of 5000
function sendEtherUsingCall(address payable _to)external payable {
		(bool success,) = _to.call{value:12, gas:50000}("");
		require(success, "call failed");
	}

}