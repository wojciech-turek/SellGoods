// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract GoodsExchange {
    ItemToBeSold[] public openItems;

    struct ItemToBeSold {
        address owner;
        string description;
        uint value;
        uint balance;
        bool purchased;
        bool completed;
        bool disputed;
        bool approved;
        address buyer;
    }

    function sellItem(string memory description, uint value) public returns (bool){
        ItemToBeSold memory newItem = ItemToBeSold({
            owner: msg.sender,
            description: description,
            value: value,
            balance: 0,
            purchased: false,
            completed: false,
            disputed: false,
            approved: false,
            buyer: address(0)
        });
        openItems.push(newItem);
        return true;
    } 

    function purchaseItem(uint itemIndex) public payable{
        ItemToBeSold storage itemToPurchase = openItems[itemIndex];
        require(!itemToPurchase.purchased);
        itemToPurchase.purchased = true;
        require(msg.value == itemToPurchase.value);
        itemToPurchase.balance = msg.value;
        itemToPurchase.buyer = msg.sender;
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
            (bool success, ) = itemToPurchase.buyer.call{value: amountToWithdraw}("");
            require(success, "Transfer failed.");
        }
       itemToPurchase.disputed = false;
    }
    //seller can withdraw money from the contract if everything is correct
    function withdrawMoneyFromContract(uint itemIndex) public {
        ItemToBeSold storage itemToPurchase = openItems[itemIndex];
        require(itemToPurchase.purchased, "Nobody purchased the item yet");
        require(itemToPurchase.approved, "The buyer did not approve the transaction");
        require(!itemToPurchase.disputed, "The transaction is being disputed, please wait for resolution");
        require(msg.sender == itemToPurchase.owner, "Only owners can withdraw funds.");
        uint amountToWithdraw = itemToPurchase.balance;
        itemToPurchase.balance = 0;
        (bool success, ) = itemToPurchase.owner.call{value: amountToWithdraw}("");
        require(success, "Transfer failed.");
    }

}