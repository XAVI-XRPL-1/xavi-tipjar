// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TipJar
 * @author Xavi (Autonomous Builder on XRPL EVM)
 * @notice Accept native XRP tips with on-chain leaderboard tracking
 */
contract TipJar is Ownable, ReentrancyGuard {
    
    // ============ State Variables ============
    
    /// @notice Total tips received by the jar
    uint256 public totalTips;
    
    /// @notice Total number of unique tippers
    uint256 public uniqueTippers;
    
    /// @notice Mapping of tipper address to total amount tipped
    mapping(address => uint256) public tipsByAddress;
    
    /// @notice Array of all tipper addresses (for iteration)
    address[] public tippers;
    
    /// @notice Mapping to check if address has tipped before
    mapping(address => bool) public hasTipped;
    
    /// @notice Top 10 leaderboard (sorted by tip amount, descending)
    address[10] public leaderboard;
    
    // ============ Events ============
    
    event TipReceived(address indexed tipper, uint256 amount, uint256 totalFromTipper);
    event Withdrawal(address indexed owner, uint256 amount);
    event LeaderboardUpdated(address indexed tipper, uint256 newTotal, uint8 rank);
    
    // ============ Constructor ============
    
    constructor() Ownable(msg.sender) {}
    
    // ============ External Functions ============
    
    /**
     * @notice Send a tip to the jar
     * @dev Accepts native XRP, updates tipper stats and leaderboard
     */
    function tip() external payable nonReentrant {
        require(msg.value > 0, "Tip must be greater than 0");
        
        // Track first-time tippers
        if (!hasTipped[msg.sender]) {
            hasTipped[msg.sender] = true;
            tippers.push(msg.sender);
            uniqueTippers++;
        }
        
        // Update tip totals
        tipsByAddress[msg.sender] += msg.value;
        totalTips += msg.value;
        
        // Update leaderboard
        _updateLeaderboard(msg.sender);
        
        emit TipReceived(msg.sender, msg.value, tipsByAddress[msg.sender]);
    }
    
    /**
     * @notice Tip with a message (message emitted in event)
     * @param message Optional message from tipper
     */
    function tipWithMessage(string calldata message) external payable nonReentrant {
        require(msg.value > 0, "Tip must be greater than 0");
        
        if (!hasTipped[msg.sender]) {
            hasTipped[msg.sender] = true;
            tippers.push(msg.sender);
            uniqueTippers++;
        }
        
        tipsByAddress[msg.sender] += msg.value;
        totalTips += msg.value;
        
        _updateLeaderboard(msg.sender);
        
        emit TipReceived(msg.sender, msg.value, tipsByAddress[msg.sender]);
    }
    
    /**
     * @notice Withdraw all tips to owner
     */
    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
        
        emit Withdrawal(owner(), balance);
    }
    
    /**
     * @notice Withdraw specific amount to owner
     * @param amount Amount to withdraw
     */
    function withdrawAmount(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= address(this).balance, "Insufficient balance");
        
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit Withdrawal(owner(), amount);
    }
    
    // ============ View Functions ============
    
    /**
     * @notice Get the full top 10 leaderboard with amounts
     * @return addresses Array of top 10 tipper addresses
     * @return amounts Array of corresponding tip amounts
     */
    function getLeaderboard() external view returns (
        address[10] memory addresses,
        uint256[10] memory amounts
    ) {
        for (uint8 i = 0; i < 10; i++) {
            addresses[i] = leaderboard[i];
            amounts[i] = tipsByAddress[leaderboard[i]];
        }
        return (addresses, amounts);
    }
    
    /**
     * @notice Get tipper's rank on leaderboard (0 if not in top 10)
     * @param tipper Address to check
     * @return rank 1-10 if in leaderboard, 0 otherwise
     */
    function getRank(address tipper) external view returns (uint8 rank) {
        for (uint8 i = 0; i < 10; i++) {
            if (leaderboard[i] == tipper) {
                return i + 1;
            }
        }
        return 0;
    }
    
    /**
     * @notice Get contract balance
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @notice Get all tippers (paginated)
     * @param offset Starting index
     * @param limit Max number to return
     */
    function getTippers(uint256 offset, uint256 limit) external view returns (
        address[] memory tipperList,
        uint256[] memory amounts
    ) {
        uint256 end = offset + limit;
        if (end > tippers.length) {
            end = tippers.length;
        }
        
        uint256 count = end - offset;
        tipperList = new address[](count);
        amounts = new uint256[](count);
        
        for (uint256 i = 0; i < count; i++) {
            tipperList[i] = tippers[offset + i];
            amounts[i] = tipsByAddress[tippers[offset + i]];
        }
        
        return (tipperList, amounts);
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Update leaderboard after a tip
     * @param tipper Address of the tipper
     */
    function _updateLeaderboard(address tipper) internal {
        uint256 tipperTotal = tipsByAddress[tipper];
        
        // Find tipper's current position (if any)
        int8 currentPos = -1;
        for (uint8 i = 0; i < 10; i++) {
            if (leaderboard[i] == tipper) {
                currentPos = int8(i);
                break;
            }
        }
        
        // Find new position based on tip amount
        int8 newPos = -1;
        for (uint8 i = 0; i < 10; i++) {
            if (tipperTotal > tipsByAddress[leaderboard[i]]) {
                newPos = int8(i);
                break;
            }
        }
        
        // Not in top 10 and won't enter
        if (currentPos == -1 && newPos == -1) {
            return;
        }
        
        // Already at correct position
        if (currentPos == newPos) {
            emit LeaderboardUpdated(tipper, tipperTotal, uint8(newPos) + 1);
            return;
        }
        
        // Moving up in leaderboard
        if (newPos != -1 && (currentPos == -1 || newPos < currentPos)) {
            // Remove from current position if exists
            if (currentPos != -1) {
                for (uint8 i = uint8(currentPos); i < 9; i++) {
                    leaderboard[i] = leaderboard[i + 1];
                }
                leaderboard[9] = address(0);
            }
            
            // Insert at new position
            for (uint8 i = 9; i > uint8(newPos); i--) {
                leaderboard[i] = leaderboard[i - 1];
            }
            leaderboard[uint8(newPos)] = tipper;
            
            emit LeaderboardUpdated(tipper, tipperTotal, uint8(newPos) + 1);
        }
    }
    
    // ============ Receive ============
    
    /**
     * @notice Allow direct XRP transfers to count as tips
     */
    receive() external payable {
        if (msg.value > 0) {
            if (!hasTipped[msg.sender]) {
                hasTipped[msg.sender] = true;
                tippers.push(msg.sender);
                uniqueTippers++;
            }
            
            tipsByAddress[msg.sender] += msg.value;
            totalTips += msg.value;
            
            _updateLeaderboard(msg.sender);
            
            emit TipReceived(msg.sender, msg.value, tipsByAddress[msg.sender]);
        }
    }
}
