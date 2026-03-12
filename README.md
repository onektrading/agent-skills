# 1keeper Skill Guide

Chinese version: [README.zh-CN.md](README.zh-CN.md)

This repository provides the `1keeper` skill for signal-driven and manual trading workflows based on 1keeper Open API / WS.

Skill path:
- `skills/1keeper`

## 1. Initialization

No manual config editing is required for first-time setup.  
The user only needs to send an API Key to the Agent, and the Agent completes initialization automatically:

You can start with a natural-language instruction:
- "Help me initialize 1keeper config"

1. User sends API Key to Agent.
2. Agent resolves primary wallets via API Key:
- Solana primary wallet (`chain_id=501`)
- BSC primary wallet (`chain_id=56`)
3. Agent writes both wallet addresses into skill config:
- `wallets.solanaPrimaryWalletAddress`
- `wallets.bnbPrimaryWalletAddress`
4. Agent sets default chain to Solana (`501`) and sets the skill current primary wallet to Solana primary wallet.
5. Agent shows initialization summary to the user (default chain, Sol/BSC primary wallets, current skill primary wallet).

## 2. Common Scenarios (Natural Language)

Use natural language directly. Typical examples:

1. Query native coin balance on the main chain
- "Check native balance for this address"
- "Show SOL balance for my current wallet"
- "Check BNB balance of my BSC primary wallet"

2. Buy token
- "Buy this CA"
- "Buy this token with 0.1 SOL"
- "Buy this address on BSC with 0.01 BNB"

3. Sell token
- "Sell this token"
- "Sell 50% of this CA"
- "Sell all for this address"

4. Query recent trades
- "Show recent trades"
- "Show my last 10 trades"
- "Query recent buy/sell records for this wallet"

## 3. Upgrade Skill

If you want to update the skill, use natural language:
- "Update SKILL"
- "Upgrade SKILL"
- "Sync SKILL"

Or run the script in `skills/1keeper`:

```bash
./scripts/update-skill.sh
```

Notes:
- Update source: `https://github.com/onektrading/agent-skills`
- Script only updates skill files and does not restart OpenClaw automatically
