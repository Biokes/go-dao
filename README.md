# ERC20 Diamond Implementation

This directory contains a complete, functional, and ready-to-deploy implementation of the Diamond Standard (EIP-2535) for an ERC20 token.

## Overview

The Diamond Standard allows for the creation of upgradeable smart contracts where multiple facets (contracts) can be combined into a single diamond proxy contract. This implementation includes:

- **Diamond Proxy Contract**: The main contract that delegates function calls to appropriate facets
- **Diamond Library**: Contains the core logic for managing facets and diamond storage
- **ERC20 Facet**: Implements all ERC20 token functionality
- **DiamondCut Interface**: For adding, replacing, and removing facets
- **DiamondLoupe Interface**: For introspection and querying diamond facets
- **Comprehensive Tests**: Full test suite covering all functionality
- **Deployment Script**: Ready-to-use deployment script

## Architecture

```
src/erc20Diamond/
├── Diamond.sol                 # Main diamond proxy contract
├── DiamondCutInterface.sol     # Interface for facet management
├── DiamondLoupeInterface.sol   # Interface for diamond introspection
├── interfaces/
│   └── IERC20.sol             # Standard ERC20 interface
├── libs/
│   └── DiamondLibrary.sol     # Core diamond functionality
├── facets/
│   └── ERC20Facet.sol         # ERC20 token implementation
└── scripts/
    └── DeployDiamond.s.sol    # Deployment script
```

## Key Features

### ✅ Complete ERC20 Implementation
- Standard ERC20 functions (transfer, approve, transferFrom, etc.)
- Proper event emission
- Balance and allowance management
- Input validation

### ✅ Diamond Standard Compliance
- Full EIP-2535 implementation
- Facet management (add, replace, remove)
- Diamond introspection capabilities
- Secure upgrade mechanism

### ✅ Additional Features
- Mint and burn functions (owner/admin controlled)
- Diamond loupe for querying facets and functions
- Comprehensive test coverage
- Ready for deployment

## Usage

### Basic ERC20 Operations

```solidity
// Deploy the diamond
ERC20Diamond diamond = new ERC20Diamond();

// Check token info
string memory name = diamond.name();        // "RAFIK NAME SERVICE TOKEN"
string memory symbol = diamond.symbol();    // "RNST"
uint256 totalSupply = diamond.totalSupply(); // 1,000,000 tokens

// Transfer tokens
diamond.transfer(recipient, amount);

// Approve spending
diamond.approve(spender, amount);

// Transfer on behalf of another address
diamond.transferFrom(from, to, amount);
```

### Facet Management

```solidity
// Add a new facet
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: newFacetAddress,
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: selectors
});

diamond.diamondCut(cut, address(0), "");
```

### Introspection

```solidity
// Get all facets
IDiamondLoupe.Facet[] memory facets = diamond.facets();

// Get function selectors for a facet
bytes4[] memory selectors = diamond.facetFunctionSelectors(facetAddress);

// Get facet address for a function
address facet = diamond.facetAddress(functionSelector);
```

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-contract DiamondTest

# Run with verbose output
forge test -vvv
```

## Deployment

1. Set up your environment variables:
```bash
export PRIVATE_KEY=your_private_key_here
```

2. Deploy using the provided script:
```bash
forge script script/DeployDiamond.s.sol --broadcast --verify
```

## Security Features

- **Access Control**: Only the diamond owner can modify facets
- **Input Validation**: Proper validation for all ERC20 operations
- **Secure Storage**: Uses diamond storage pattern to avoid collisions
- **Delegate Call Protection**: Proper fallback mechanisms for facet delegation

## Gas Optimization

- Efficient storage layout using diamond storage pattern
- Minimal gas overhead for facet delegation
- Optimized function selectors and facet management

## Extending the Diamond

To add new functionality:

1. Create a new facet contract
2. Implement the desired functions
3. Deploy the facet
4. Use `diamondCut` to add the facet to the diamond

Example:
```solidity
// 1. Create new facet
contract NewFeatureFacet {
    function newFunction() external {
        // Implementation
    }
}

// 2. Add to diamond
bytes4[] memory selectors = new bytes4[](1);
selectors[0] = NewFeatureFacet.newFunction.selector;

IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: address(newFeatureFacet),
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: selectors
});

diamond.diamondCut(cut, address(0), "");
```

## License

MIT License - see the SPDX headers in individual files.

## Support

This implementation follows the official EIP-2535 Diamond Standard specification and includes comprehensive testing and documentation for production use.


  DiamondCutFacet deployed at:  0x12f1E87801e89bc9773567111388C28020Fe5E5c
  Diamond deployed at:  0xa62778500329180ad58eE786C5F6Ff3835f8cD7a
  RafikTokenFacet deployed at:  0xb641aaAA356aF78614E0Bb65f0C3920cE7C68988
  TokenMetaDataFacet deployed at:  0x129761e142c03Da18eE8Bcb1fB1F9C291549267b
  SwapFacet deployed at:  0x305F599fbCd667dbb9ca28960751430A1e8Fc3Ad