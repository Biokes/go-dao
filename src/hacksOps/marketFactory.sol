// // SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.7.0 <= 0.8.21;

// import {MarketPlace} from "./marketPlace.sol";
// import {IERC20} from "./IERC20.sol";

// // Use the register function and register your address to start, it will deploy and return a unique marketplace contract for you
// // Only you can interact with the contract, open it and drain it. GoodLuck!!!
// contract MarketPlaceFactory {
//     address owner;
//     uint256 id;
//     bool paused;
//     IERC20 public vault;

//     mapping(address => mapping(address => bool)) isRegisteredOwner;
//     mapping(address => bool) isRegisteredPlayer;
//     mapping(address => uint256) PlayerId;
//     mapping(address => bool) hasCompleted;
//     mapping(address => bool) isWhitelisted;

//     struct Players {
//         address _player;
//         string playerName;
//     }

//     Players[] public players;

//     struct Winners {
//         address winner;
//         address marketPlace;
//         string playerName;
//     }

//     Winners[] public winners;

//     modifier whenNotPaused() {
//         if (paused) revert("Too late!");
//         _;
//     }

//     constructor(address vaultTokens) payable {
//         owner = msg.sender;
//         vault = IERC20(vaultTokens);
//     }

//     function pause() external {
//         require(msg.sender == owner);
//         paused = true;
//     }

//     function unPause() external {
//         require(msg.sender == owner);
//         paused = false;
//     }

//     function addFunds() external payable {
//         require(msg.sender == owner, "Only me go handle all the bills...");
//     }

//     function x() external {
//         require(msg.sender == owner, "You can't touch my money");
//         (bool s,) = owner.call{value: address(this).balance}("");
//         require(s);
//     }

//     function whitelist(address[] memory players_) external {
//         require(msg.sender == owner);
//         for (uint256 i = 0; i < players_.length; i++) {
//             isWhitelisted[players_[i]] = true;
//         }
//     }

//     function register(string memory name) external whenNotPaused returns (address) {
//         id++;
//         require(!isRegisteredPlayer[msg.sender], "I know you already!");
//         isRegisteredPlayer[msg.sender] = true;
//         PlayerId[msg.sender] = id;
//         MarketPlace yourMarketPlace = new MarketPlace(address(vault));
//         bool s = vault.transfer(address(yourMarketPlace), 1e18);
//         require(s);
//         isRegisteredOwner[msg.sender][address(yourMarketPlace)] = true;

//         Players memory player;
//         player._player = msg.sender;
//         player.playerName = name;
//         players.push(player);

//         return address(yourMarketPlace);
//     }

//     function Complete(address _yourMarketPlaceAddress) external whenNotPaused returns (bool) {
//         require(isRegisteredOwner[msg.sender][_yourMarketPlaceAddress], "Impersonator!!!");
//         require(!hasCompleted[msg.sender], "What do you want again!!!");
//         if (MarketPlace(_yourMarketPlaceAddress).isComplete() && MarketPlace(_yourMarketPlaceAddress).drained()) {
//             hasCompleted[msg.sender] = true;
//             string memory name = players[PlayerId[msg.sender] - 1].playerName;
//             Winners memory winner;
//             winner.winner = msg.sender;
//             winner.marketPlace = _yourMarketPlaceAddress;
//             winner.playerName = name;
//             winners.push(winner);
//         } else {
//             revert("But Why...");
//         }
//     }

//     receive() external payable {
//         require(msg.value == 0, "I don't want your money :)");
//     }
// }