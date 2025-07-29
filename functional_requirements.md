# Decentralized Donation Platform Project Specification

## Project Overview
You will build a **Decentralized Donation Platform** where users can create donation campaigns, 
donors can contribute ETH, and funds are released to the campaign owner only after a trusted escrow approves the use of funds.
The platform includes campaign creation, donation tracking, an escrow release mechanism, and a refund option if the campaign fails.

This project tests your ability to write secure Solidity smart contracts using different function types 
(e.g., `public`, `external`, `view`, `payable`), data structures (e.g., structs, mappings), and events, 
while using Hardhat and Foundry for development and testing.

## Objectives
- Implement a single, modular Solidity smart contract with clear function types and data structures.
- Practice Solidity basics: structs, mappings, events, modifiers, and error handling.
- Use Hardhat for local development, testing, and deployment.
- Use Foundry for unit testing and basic fuzzing.
- Deploy the contract to the Sepolia testnet.
- Ensure basic security practices to prevent common vulnerabilities.

## Project Requirements

### Functional Requirements
1. **Campaign Creation**:
    - Users can create a donation campaign with:
        - A title and description.
        - A funding goal (in ETH).
        - A deadline (timestamp) after which donations stop.
    - Each campaign has a unique ID and is stored on-chain.
    - The campaign creator is recorded as the recipient of funds.

2. **Donations**:
    - Users can donate ETH to a campaign before the deadline using a `payable` function.
    - Donations are tracked per donor using a mapping.
    - The total funds raised are stored and accessible via a `view` function.

3. **Escrow Mechanism**:
    - Funds are locked in the contract until an escrow (a trusted address, set during deployment) approves their release.
    - The escrow can release funds to the campaign creator only after the funding goal is met and before the deadline.
    - The escrow can reject the campaign, allowing donors to withdraw their funds.x

4. **Refunds**:
    - If the funding goal is not met by the deadline, donors can withdraw their contributions.
    - If the escrow rejects the campaign, donors can withdraw their contributions.
    - Refunds are processed securely using an `external` function.

5. **Query Functions**:
    - Provide `view` functions to retrieve:
        - Campaign details (title, description, goal, deadline, total raised).
        - Donor’s contribution amount for a specific campaign.
        - Campaign status (active, successful, failed, or rejected).

6. **Security and Events**:
    - Use modifiers to restrict functions (e.g., only escrow can approve/reject).
    - Emit events for key actions: campaign creation, donation, fund release, refund, campaign rejection.
    - Prevent reentrancy attacks during withdrawals.
    - Use `require` or `revert` for error handling (e.g., invalid donations, expired deadlines).

### Non-Functional Requirements
- **Solidity Version**: Use Solidity ^0.8.0 for built-in overflow protection.
- **Gas Optimization**: Use appropriate data types (e.g., `uint256`, `address`) and minimize storage updates.
- **Testing**: Achieve at least 85% test coverage using Hardhat and Foundry.
- **Security**: Follow basic best practices (e.g., checks-effects-interactions pattern).
- **Deployment**: Deploy to the Sepolia testnet using Hardhat.
- **Documentation**: Provide a README with setup, deployment, and testing instructions.

## Project Structure
Organize your project as follows:
- **Contracts**: A single smart contract (`DonationPlatform.sol`) in `contracts/`.
- **Tests**: Unit tests in Hardhat (JavaScript) and Foundry (Solidity).
- **Scripts**: Hardhat scripts for deployment.
- **Docs**: A README with instructions.

## Step-by-Step Instructions

### 1. Environment Setup
- **Install Hardhat**:
    - Initialize a Hardhat project: `npx hardhat init`.
    - Install dependencies: `npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox`.
    - Configure `hardhat.config.js` for Sepolia (use Alchemy or Infura for RPC).
- **Install Foundry**:
    - Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
    - Initialize a Foundry project: `forge init`.
    - Configure `foundry.toml` for testing.
- **Install OpenZeppelin**:
    - Install OpenZeppelin: `npm install @openzeppelin/contracts`.
    - Use `ReentrancyGuard` for withdrawal functions.

### 2. Smart Contract Development
- **Contract**: `DonationPlatform.sol`
    - **Data Structures**:
        - Struct: `Campaign` (ID, creator, title, description, goal, deadline, totalRaised, status).
        - Mapping: `campaigns` (uint256 ID => Campaign).
        - Mapping: `donations` (uint256 ID => address donor => uint256 amount).
        - Enum: `CampaignStatus` (Active, Successful, Failed, Rejected).
    - **State Variables**:
        - `escrow`: Address of the trusted escrow (set in constructor).
        - `campaignCount`: Tracks the number of campaigns.
    - **Function Types**:
        - `public`: `createCampaign` (creates a new campaign).
        - `external payable`: `donate` (accepts ETH donations).
        - `external`: `releaseFunds` (escrow releases funds to creator), `rejectCampaign` (escrow rejects campaign), `withdrawRefund` (donors withdraw funds).
        - `view`: `getCampaignDetails`, `getDonationAmount`.
        - `private` or `internal`: Helper functions (e.g., update campaign status).
    - **Modifiers**:
        - `onlyEscrow`: Restricts functions to the escrow address.
        - `onlyActiveCampaign`: Ensures the campaign is active and not expired.
    - **Events**:
        - `CampaignCreated(uint256 id, address creator, string title, uint256 goal, uint256 deadline)`.
        - `DonationReceived(uint256 id, address donor, uint256 amount)`.
        - `FundsReleased(uint256 id, address creator, uint256 amount)`.
        - `CampaignRejected(uint256 id)`.
        - `RefundWithdrawn(uint256 id, address donor, uint256 amount)`.
    - **Key Logic**:
        - Donations: Check deadline, update `donations` mapping, emit event.
        - Fund Release: Escrow checks goal met, transfers funds, updates status.
        - Refunds: Allow withdrawals if campaign fails or is rejected, use `ReentrancyGuard`.
        - Error Handling: Use `require` for invalid inputs (e.g., zero goal, past deadline).

### 3. Testing
- **Hardhat Tests**:
    - Write unit tests in `test/DonationPlatform.test.js`.
    - Test cases:
        - Campaign creation with valid/invalid inputs.
        - Donations before/after deadline.
        - Fund release by escrow with goal met/not met.
        - Refunds after failure or rejection.
        - View functions return correct data.
    - Use `ethers` to simulate users and escrow.
- **Foundry Tests**:
    - Write tests in `test/DonationPlatform.t.sol`.
    - Test basic functionality and edge cases (e.g., zero donations, maximum ETH).
    - Add simple fuzz tests for donation amounts.
    - Run tests: `forge test`.
- **Coverage**:
    - Check coverage: `npx hardhat coverage` and `forge coverage`.

### 4. Deployment
- **Local Testing**:
    - Start Hardhat node: `npx hardhat node`.
    - Deploy locally: `npx hardhat run scripts/deploy.js`.
- **Sepolia Deployment**:
    - Update `hardhat.config.js` with Sepolia details.
    - Deploy: `npx hardhat run scripts/deploy.js --network sepolia`.
    - Verify on Etherscan: `npx hardhat verify --network sepolia <contract-address>`.

### 5. Security and Optimization
- **Security**:
    - Use `ReentrancyGuard` for `withdrawRefund` and `releaseFunds`.
    - Follow checks-effects-interactions pattern.
    - Validate inputs (e.g., non-zero goal, valid deadline).
    - Restrict escrow functions with `onlyEscrow` modifier.
- **Gas Optimization**:
    - Use `uint256` for IDs and amounts.
    - Store strings (title, description) efficiently (consider off-chain storage for production).
    - Mark functions as `external` where possible.
- **Static Analysis**:
    - Run Slither: `slither .` to catch basic issues.

### 6. Documentation
- Create a `README.md` with:
    - Project overview and features.
    - Setup instructions (Hardhat, Foundry, dependencies).
    - Deployment steps for Sepolia.
    - Testing instructions.
    - Contract address on Sepolia after deployment.

## Deliverables
- **Smart Contract**: `DonationPlatform.sol` in `contracts/`.
- **Tests**: Test suites in `test/` for Hardhat and Foundry.
- **Scripts**: Deployment script in `scripts/`.
- **Documentation**: README in the project root.
- **Deployed Contract**: Verified contract on Sepolia.

## Challenges to Test Your Skills
- **Function Types**: Use `payable`, `view`, `external`, and `public` appropriately.
- **Data Structures**: Manage structs and mappings efficiently.
- **Modifiers**: Implement access control with custom modifiers.
- **Events**: Ensure all key actions are logged for transparency.
- **Security**: Handle reentrancy and input validation.
- **Testing**: Write tests for edge cases and fuzz inputs.

## Resources
- **Solidity**: https://docs.soliditylang.org
- **Hardhat**: https://hardhat.org
- **Foundry**: https://book.getfoundry.sh
- **OpenZeppelin**: https://docs.openzeppelin.com/contracts
- **Sepolia**: Alchemy (https://alchemy.com) or Infura (https://infura.io)
- **Security**: ConsenSys Best Practices (https://consensys.github.io/smart-contract-best-practices/)
