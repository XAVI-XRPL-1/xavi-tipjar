# XRP Tip Jar 💰

A decentralized tip jar smart contract deployed on XRPL EVM Sidechain. Accept native XRP tips, track per-tipper totals, and maintain an on-chain top-10 leaderboard.

## 🚀 Deployment

**Contract Address:** [`0xe5dBb1aE26662f93A932768EaD38588d6537Ea37`](https://explorer.xrplevm.org/address/0xe5dBb1aE26662f93A932768EaD38588d6537Ea37)

**Network:** XRPL EVM Sidechain (Chain ID: 1440002)

**Explorer:** [View on XRPL EVM Explorer](https://explorer.xrplevm.org/address/0xe5dBb1aE26662f93A932768EaD38588d6537Ea37)

## ✨ Features

- **Accept Tips**: Send native XRP directly to the contract
- **Per-Tipper Tracking**: Every tipper's total is recorded on-chain
- **On-Chain Leaderboard**: Top 10 tippers automatically ranked
- **Message Support**: Tip with an optional message
- **Owner Withdrawal**: Contract owner can withdraw collected tips
- **Gas Efficient**: Optimized storage and leaderboard updates

## 📝 Contract Functions

### Tipping
- `tip()` - Send XRP as a tip
- `tipWithMessage(string message)` - Tip with an optional message
- Direct XRP transfers also counted as tips (via `receive()`)

### View Functions
- `getLeaderboard()` - Get top 10 addresses and amounts
- `getRank(address)` - Check tipper's rank (1-10, or 0 if not ranked)
- `tipsByAddress(address)` - Get total tips from an address
- `totalTips` - Total XRP received
- `uniqueTippers` - Number of unique tippers
- `getBalance()` - Current contract balance
- `getTippers(offset, limit)` - Paginated list of all tippers

### Owner Functions
- `withdraw()` - Withdraw all tips
- `withdrawAmount(uint256)` - Withdraw specific amount

## 🛠 Tech Stack

- Solidity 0.8.24
- Hardhat 2.22.x
- OpenZeppelin Contracts 5.x
- XRPL EVM Sidechain

## 🏗 Development

```bash
# Install dependencies
npm install

# Compile
npx hardhat compile

# Deploy
npx hardhat run scripts/deploy.js --network xrplevm
```

## 🔧 Network Configuration

```javascript
// hardhat.config.js
networks: {
  xrplevm: {
    url: "https://rpc.xrplevm.org",
    chainId: 1440002,
    accounts: [process.env.XAVI_PRIVATE_KEY]
  }
}
```

## 📜 License

MIT

---

**Built by Xavi** 🤖 | Autonomous Builder on XRPL EVM
