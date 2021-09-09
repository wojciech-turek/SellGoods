# Smart Contract that handles a trading deal between two users.

To test run the contract navigate to `https://remix.ethereum.org/` and copy pase the contract code and compile it.

### Running SellGoodsErc20 Smart Contract in Remix

1. Deploy the contract using Injected Web3 to Rinkeby.
2. Use `sellItem` function and give your object `description`, `value`(*if you want 1 token then type 1 * number of decimals of that token*) and `token` which is the currency in which you'd like to get paid. **Must be ERC20 standard token.**
3. Switch to a wallet with a ERC-20 token (Rinkeby) that you will use for testing. It has to be the same as `token` described in point above.
4. For this scenario as we do not have an interface built we will need to manually approve the smart contract deployed via Remix. Copy contract address deployed in remix.
5. Go to https://rinkeby.etherscan.io/token/XXXXX where XXXXX is the address of your token.
6. Click on `Contract` tab then `Write Contract` and connect your wallet with the tokens.
7. Call the `approve` function with number of tokens from point 2 and address of the smart contract from Remix.
8. Once approved go back to Remix and call `purchaseItem` with amount again from point 2 and an itemIndex `0`, since we only made one item for sale.
9. The buyer can now `disputePurchase` or `approvePurchase` by providing the itemIndex for which he paid for.
10. If `disputePurchase` was called there needs to be a third party address that will call `settleDispute` which will either unblock the contract or refund the money to buyer.
11. If `approvePurchase` was called the money held in contract for that item can be withdrawn by the seller of the product.

### Running SellGoods Smart Contract in Remix (operating on ETH not tokens)

Much like the above but we can skip the part where we go to etherscan and approve the contract.

1. Call `sellItem` and provide description and price (in wei).
2. Change wallet for better proof of transaction, make sure at least price + transaction costs of ETH.
3. Add value equal to the price of the item in Remix and call `purchaseItem`.
4. Similarly to previous list the buyer can now `disputePurchase` or `approvePurchase`.
10. If `disputePurchase` was called there needs to be a third party address that will call `settleDispute` which will either unblock the contract or refund the money to buyer.
11. If `approvePurchase` was called the money held in contract for that item can be withdrawn by the seller of the product.


 ### Testing 
 
 1. Clone the repo and run `npm install` in your console in the project directory
 2. Run tests with `npx hardhat test`
 3. To get a coverage report run `npx hardhat coverage`, you can find the report in `/coverage` directory, open `index.html` to view.
