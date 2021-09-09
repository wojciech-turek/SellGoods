// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract GoodsExchangeErc20{
    
    mapping(address => uint) public balances;
    ItemToBeSold[] public openItems;

    struct ItemToBeSold {
        address owner;
        string description;
        uint value;
        uint balance;
        bool purchased;
        address currency;
        bool completed;
        bool disputed;
        bool approved;
        address buyer;
    }

    function sellItem(string memory description, uint value, address token) public returns (bool){
        ItemToBeSold memory newItem = ItemToBeSold({
            owner: msg.sender,
            description: description,
            value: value,
            balance: 0,
            purchased: false,
            currency: token,
            completed: false,
            disputed: false,
            approved: false,
            buyer: address(0)
        });
        openItems.push(newItem);
        return true;
    } 
    //the user has checked the product and everything is correct
     function approvePurchase(uint itemIndex) public {
        ItemToBeSold storage itemToPurchase = openItems[itemIndex];
        require(itemToPurchase.buyer == msg.sender, "Only buyers can approve.");
        itemToPurchase.approved = true;
    }

    //both buyer and seller can dispute the transaction
    function disputePurchase(uint itemIndex) public {
        ItemToBeSold storage itemToPurchase = openItems[itemIndex];
        require(itemToPurchase.purchased);
        itemToPurchase.disputed = true;

    }

        //third party can settle a dispute and return money back to the buyer
    function settleDispute(uint itemIndex, bool purchaseReverted) public {
        ItemToBeSold storage itemToPurchase = openItems[itemIndex];
        require(msg.sender != itemToPurchase.owner,"Owners cannot settle disputes.");
        require(msg.sender != itemToPurchase.buyer,"Buyers cannot settle disputes.");
        // assumed the buyer has returned the faulty product or the situation is otherwise settled 
        if(purchaseReverted){
            uint amountToWithdraw = itemToPurchase.balance;
            itemToPurchase.balance = 0;
            IERC20(itemToPurchase.currency).transfer(itemToPurchase.buyer, amountToWithdraw);
        }
       itemToPurchase.disputed = false;
    }

    function withdrawMoneyFromContract(uint itemIndex) public {
        ItemToBeSold storage itemToPurchase = openItems[itemIndex];
        require(itemToPurchase.purchased, "Nobody purchased the item yet");
        require(itemToPurchase.approved, "The buyer did not approve the transaction");
        require(!itemToPurchase.disputed, "The transaction is being disputed, please wait for resolution");
        require(msg.sender == itemToPurchase.owner, "Only owners can withdraw funds.");
        uint amountToWithdraw = itemToPurchase.balance;
        itemToPurchase.balance = 0;
        IERC20(itemToPurchase.currency).transfer(msg.sender, amountToWithdraw);
    }

    //query the balance of a user for specific token
    function getBalanceOf(address _token) public view returns(uint){
        return IERC20(_token).balanceOf(msg.sender);
    }

    //deduct the token from the holders address and hold it in the contract
    function purchaseItem(uint amount, uint itemIndex) public returns(bool){
        ItemToBeSold storage itemToPurchase = openItems[itemIndex];
        require(!itemToPurchase.purchased);
        itemToPurchase.purchased = true;
        require(amount == itemToPurchase.value);
        itemToPurchase.balance += amount;
        // ! The user must previously approve the contract to allow it to call transferFrom
        IERC20(itemToPurchase.currency).transferFrom(msg.sender, address(this), amount);
        itemToPurchase.buyer = msg.sender;
        return true;
    }
    //query the balance of a contract for specific token
    function getContractBalanceOf(address _token) public view returns(uint){
        return IERC20(_token).balanceOf(address(this));
    }
}