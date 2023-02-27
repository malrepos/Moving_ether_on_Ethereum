# Moving ether on Ethereum

![ethereum Coins](images/ethereum-coins.jpg)

Programming takes on an extra dimension when payments come into play. When there is the idea of “money” involved in a function, when not only data is sent but a currency, things start to get serious, and also interesting. Solidity, like any language, is learned through trial and error, lessons and practice, however the concept and logic behind moving ether around and paying gas require a more focused study. This is, after all, something new and different.

The syntax of sending ether can be tricky to begin with. It seemed to me I had to cast an address or a function as payable multiple times before the compiler would let me go ahead with the contract. And at times I could seemingly not send ether using a function parameter, only low level transactions, which frustrated me. No doubt understanding and internalizing the syntax is easier if I know what is actually happening behind the scenes at a deeper level. What am I actually doing when I cast an address as payable? What is an address if it is not payable? How does ether 'enter' and remain in the contract? These are the kinds of questions many, including myself , would think to ask but often do not pursue the answer. With something as fundamental and revolutionary as programmable money, this passivity is a mistake. You need to understand how the native currency ether works on the Ethereum network.

So, moving ether around Ethereum. That is the focus.

## balance.

Contracts, like wallets, can hold ether.

This is the easiest place to start and occupies a resting point, a static state for any contract. As contracts can hold ether, the question quickly becomes, how much ether does this contract have. We can find that out by getting the address of the contract and asking for it's balance.

```
address(this).balance;
```

Here we are asking for the address of the contract this code resides in. In practice, it is the contract I am coding and we can include this code snippet in a function so that we can call the function and get the balance of the contract.

The code for a function that will get a contract’s own balance becomes stock code as we end up writing it so often:

```
function getBalance() external view returns(uint){
return address(this).balance;
```

What is perhaps strange is that a contract can hold ether. A contract has a balance, it has funds, currency (ether) it can spend. What decides how the contract will spend the currency it holds is the code in that contract. If there is a withdraw function in the contract, and this function is public without any access controls on it, then anyone can call the function and the contract will happily send the ether it has anywhere it is told to.

A contract has a balance meaning the address that the contract has been deployed to has a balance of ether, and it is up to the developer of said contract to decide how that contract will handle it.

We can, of course, also get the balance of an external contract, that is, a contract other than the one we are writing code in. For this we need the address of the contract. A function to do this is as follows:

```
function getExternalContractBalance(address contractAddress) public view returns(uint){
return contractAddress.balance;
```

## payable.

When sending ether we must declare or cast functions and addresses as payable in solidity. By doing so these functions and addresses are then able receive ether. If the address is a smart contract address then it needs to at least have a fallback or receive function, declared as payable, in order to receive ether.

If I intend for the contract to receive ether I can write a function that will allow this and declare it payable. I should also include a fallback and receive functions, both payable, in case any call to the payable function is unsuccessful. My contract can still receive ether.

## constructor payable

There are use cases where we need to deposit ether into a contract upon the creation of that contract. For this to work we need to declare the constructor as payable. As a constructor is most often used for declaring variables on contract creation, it is perhaps rare to see. The following constructor requires that the contract be deployed with a minimum of 1 ether, thereby necessitating that the constructor be payable.

```
constructor()payable{
require(msg.value >= 1 ether, "You need to add enough ether first.");
}
```

In the above example we have a constructor that requires 1 ether be included in the transaction when the constructor is called. Because we are sending ether with this constructor it must be cast as payable. Now when the contract is deployed to the blockchain it will hold at least 1 ether, or else the transaction will throw an error.

## address payable

We also need to cast an address as payable if we plan to send ether to it. By casting an address as payable it is able to call the solidity functions ‘.transfer’, ‘.send’, and have ether sent to it.

```
address payable owner;
```

## function payable

I can create a basic deposit function, where an external user is able to deposit ether into my contract by calling this deposit function. Because the function is receiving ether, it is handling currency, it needs to be marked as payable, kind of like giving it special privileges.

function deposit() external payable{}
I can do more with this function, for example adding the senders address and the amount they sent to a mapping, however this is all I need in a function for it to be able to accept ether into the contract.

## function parameter payable

If I am including an address as a function parameter, and sending ether to that address in my function, then I need to set this parameter address as payable, as well as setting the function as payable. To belabor a point, if there is any sending of ether, to any address, that address needs to be set as payable.

```
    function sendEther(address payable _to, uint _amount)external payable{_to.transfer(_amount);
```

## transfer.

I call the .transfer function on a payable address. For example:

```
function sendEther(address payable _to, uint _amount) external payable{
_to.transfer(_amount);
```

I first cast this address as payable in the function parameters, then declare this function as payable, and then call the transfer function, passing the amount I want to transfer from this address. The recipient in this case is specified in the function parameters (\_to), as is the amount (\_amount).

[It seems that .transfer is no longer recommended for transferring ether. .call is now the preferred method.]

When using .transfer to make a transaction, 2300 gas is required. That is, if the transaction is a straight transfer of ether, as above, then in order for it to complete, 2300 gas must be sent with the transaction. If the transaction fails an error will be thrown.

## send.

.send is also no longer recommended for sending Ether but it is worth knowing as many past contracts used it.

In the case of send, the method returns a bool indicating whether the transfer was successful or not

(The following is from solidity-by-example.org/sending-ether)

```
function sendViaSend(address payable _to) public payable {
bool sent = _to.send(msg.value);
require(sent, "Failed to send Ether");
```

We see here a require statement below the send transaction. So if the transaction is unsuccessful the variable sent becomes false which will result in "Failed to send Ether" being returned as the error statement.

Send is no longer recommended due to changes in gas costs. .send and .transfer used a hard dependency of 2300 on gas. Meaning, only 2300 gas was sent to ensure that the transaction went through and that reentrancy was protected against. With changes in gas cost this amount of gas is no longer sufficient.

## call.

The call function proves to be a little more complicated at first. This is owing to the fact that it can do more than a simple transfer and therefore requires more detail when coding. Along with value there is data in a call() function and this has to be handled, or at least knowingly discarded.

It is because of this increased functionality that call proves to be more useful and have more applicability to an advanced smart contract.

So what makes up a call function? Or in other words, what is sent and what is received?

First of all, the call function is a low level function.

Using call will return the transaction status as a Boolean, so whether the transaction was successful or not, as well as data.

The basic structure of a call function is as follows:

```
function myCall(address _to)external payable {
(bool success, bytes data) = _to.call{value:12, gas:50000}("");
require(success, "call failed");
```

We have the value parameter set here. In this case we are only sending 12 wei in our transaction. We also define how much gas we are sending with our transaction. In this case 50000 is enough as we are doing very little. This may not be enough as we start to write to storage or whatever else. Testing inside Remix is vital here. We also need not hard code the gas amount, leaving it open to use as much as it needs.

It returns a bool as mentioned. It also returns data of type bytes.

It seems call() is the function of choice when sending ether, and given that it is more complicated than the other two options, a deeper dive is a good idea and in order.

Here is an example using call to send some ether to a contract address. In this case the sender does not know the specific function to call and will therefore rely on the fallback function to be executed in the receiving contract.

```
function sendEtherUsingCall(address payable _addr) public payable {
(bool success, bytes memory data) = _addr.call{value: msg.value, gas: 5000}(
abi.encodeWithSignature("someFunctionCall()")
);
```

We can see here that using call will return a bool and bytes data. In the case of the bool, it will be true if the transactions executes, and false if it fails. In the case of the data, we can use this to call a function by name in the receiving contract.

It is advised not to use call to call functions in other contracts, but to instead interface with that contract.

Sending ether using .call() can often be more gas efficient than actually calling a sendEther function in the receiving contract, and thus is often recommended. .call will engage the fallback or receive functions to send ether.

We pass in the address we want to call, and add the parameters of value and gas. We can specify the amount of ether we want to send in wei, and the amount of gas we want to send for this transaction.

If we are simply sending ether using call, and not using call to call a function, then we can leave the second parameter empty like so:

```
function sendEtherUsingCall(address payable _addr) public payable {
(bool success, ) = _addr.call{value: msg.value, gas: 5000}("");
```

There is the potential for a reentrancy attack when using call. It stems from the fact that we may send more gas than needed to execute our ether transfer, and this remaining gas can be used inside the fallback function call uses to then renter the senders contract and do harm. Essentially, it's like we still have gas in the tank of our car and a malicious actor can then hop into our still running car and do damage with it, damage specifically to the original driver - the one who initiated the call.

## fallback.

A fallback function is what it's name says. It is a function that provides a fallback or safety net if no other payable function is found.

We can imagine a user or contract trying to send ether as well as some data to our contract by calling a specific function. If that function does not exist as called then the fallback function will be engaged instead.

Including a fallback function in our contract allows our contract to receive ether, regardless of what else exists in the contract.

```
fallback() external payable {}
```

A fallback function is used when the transaction contains both msg.value as well as data. If there is only a value sent, and a receive function exists, the receive function will be used.

## receive.

receive is a function that allows a contract to receive ether. Unlike the fallback() function, receive will be called if there is no msg.data in the transaction. In other words, if it is purely a transfer of ether, the receive function is called. If there is data being sent along with ether, then fallback() will be called instead.

```
receive() external payable{}
```

## gas.

At first I thought gas was easy, and it kinda was. It made sense in a computer science way that in order for a computer to prevent things like infinite loops and resource hogs something like gas would need to be introduced. cntrl + c on a blockchain is not an option. Gas is like the American term for what powers a car. You put gas in, you get so many kilometers of drive out of the car, and when the gas runs out you better have reached your destination.

What began to confuse me was gas limits and gas costs, and ultimately being in charge of specifying these values. Before using solidity I mostly used Uniswap and Metamask, and these utilities would take care of these values for me, at least for the most part. It is when I have control over gas, and this control is directly connected to functions in a smart contract, that gas became much more complicated and harder to understand.

Of course it need not have been that confusing.

First, it must be made explicit that gas costs money. And that this fiat cost of gas fluctuates.

The gas a user pays goes to the validators - previously miners - who validate the transaction on the blockchain. Paying gas is like paying a driver to take you to where you want to go.

Gas is a measure of computation. That is, the amount of gas needed is based on the amount of computation needed.

We can get the cost of a transaction by multiplying the amount of gas used by the gas price. For example 23,000 gas used multiplied by a gas price of 0.000001071 Gwei (or 0.000000000000001071 Ether).

The amount of gas needed has to do with the EVM and what it costs for each stack call to be processed. These costs are agreed upon, they have been decided and set. Thus we can calculate how much a specific function will cost by going through it's opcode calls and adding up it's gas costs. This is why we can run a function on Remix and get a gas cost and that total cost will be similar as if the contract was on Ethereum mainnet.

How it works is the solidity compiler compiles your solidity code down to EVM opcodes. These opcodes then have a set number of gas units required to execute.

This is an interesting situation. We have processes that have a cost and that cost is locked in. Of course this can change over time, and has done as we saw with the .transfer and .send functions. Ultimately this is decided by people, by a team of people, and it is dependent on the hardware available and how it is able to run the EVM.

## gas limit

The gas limit when sending a transaction is how much gas we're willing to pay. This confused me in the beginning, and the reason is that it requires the user/ developer take responsibility for setting how much gas they want to use. There is risk in this as the gas limit set may be less than the gas needed to complete the transaction. The transaction may fail because the gas limit I set was too low. The element of risk and responsibility can be confusing and can make people feel there is more to it. No, there is simply less of a safety net.

We can show the use of gas limit in Remix, much to most beginner solidity developer's surprise. It is a setting in Remix that is mostly ignored, simply due to the fact that when we're using Remix we are, at least initially, more concerned with writing a contract without bugs that does what we want it to. Remix prioritizes this by setting the gas limit so high that it becomes a non issue in any deployment or transaction.

But we can use this to test gas limits for a transaction and thereby get a better understanding of what the gas limit is and how it dictates the success or failure of contracts and transactions.

## gas price

gas price is the cost of one unit of gas.

We can determine how much we pay in gwei by multiplying the gas amount by the gas price.

So what is the gas amount?

The amount of gas your contract will use depends on what your contract does. If your contract has 4 functions and they all write to storage variables and write to an array and so on, that contract will use more than one that has one function that only sends ether. Think of the amount of gas a contract uses similar to the amount of work a computer needs to do to execute the transactions in your contract. The more work the more gas needed.

Gas price, on the other hand, is more of an economic concept dependent on supply and demand. Gas price fluctuates according to market conditions. So the gas price for contract A may be different at 2pm than it was at 1pm. In order to determine how much we will pay to execute a transaction is to multiply the gas amount by the gas price at any given time. Anyone who has used Uniswap through Metamask to swap tokens will have seen the change in gas price in real time.

There are other aspects to gas price and the amount a user might pay, such as tips, however this is good enough for a basic understanding. Gas price, gas units, and reducing gas in a contract is a growing topic, one made even more complex by the merge and the dynamic landscape.

## ether and currency units

1 Ether is in fact 1 followed by 18 zeros if we write it in it's lowest unit, Wei.

A good analogy is 1 dollar. I can give you 1 dollar, or I can give you 100 cents. In the unit of cents, a dollar has 2 trailing zeros. Ether has 18 making it much more divisible.

The most commonly used units of value in Ethereum are Ether, Wei and Gwei. I don't think I've seen the other ones written in practice at all, to be honest. There are also units for amounts greater than 1 Ether, but we will leave that for the whales.

For the most part, when using a wallet like Metamask, the USD converted value of the amount of ether you are spending is given, thereby establishing a value that is more easily understandable. Really, when we start to talk about wei and gwei, the context for when these units become relevant are in development. Outside of setting gas limits and coding the sending of ether in a contract there is little need for this knowledge. Wallets are and will increasingly become the gateway into blockchains and any UI worth a damn will include fiat conversion to your local currency so that you know what you're spending.

For those under the hood, I have found that by learning what is possible for unit specification, mistakes can be avoided. For example we can specify we are using Ether rather than the default wei in certain cases, making the reading of values much easier.

## Conclusion

There is a lot of information here, and some of it may be confusing when taken out of the programming context. It is details like these, however, that would’ve made those first few attempts at sending ether much more understandable, much less blindly following someone else’s lead.
