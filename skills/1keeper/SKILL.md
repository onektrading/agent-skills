---
name: 1keeper
description: Use this skill when the user asks to operate 1keeper Open API or Open WebSocket workflows, including ws signal delivery, token info lookup, buy/sell orders, wallet balance, recent trades, wallet list, primary-wallet management, or asks to update the skill (e.g. "更新SKILL", "升级SKILL", "同步SKILL", "Update SKILL", "Upgrade SKILL", "Sync SKILL").
---

# 1keeper OpenClaw Skill

Implement or maintain a 1keeper trading workflow that integrates:
- Open WebSocket signal stream
- Open API query/trade endpoints

## Protocol sources

Read the protocol references before coding:
- [Open API](references/api_open.md)
- [Open WS API](references/api_open_ws.md)

Treat these files as the source of truth for request/response fields and error codes.

## Config template contract

Use the wallet config format defined in `1keeper-config.template.json`.
This template is maintained by Agent/runtime. User should not manually edit it during initialization.

Required wallet fields:
- `wallets.solanaPrimaryWalletAddress`
- `wallets.bnbPrimaryWalletAddress`

Template:
```json
{
  "apiKey": "YOUR_API_KEY_HERE",
  "baseUrl": "https://api1.1keeper.com",
  "chainId": 501,
  "wallets": {
    "solanaPrimaryWalletAddress": "YOUR_SOLANA_PRIMARY_WALLET_ADDRESS",
    "bnbPrimaryWalletAddress": "YOUR_BNB_PRIMARY_WALLET_ADDRESS"
  },
  "allowTrades": false,
  "telegramBotToken": "",
  "chatId": ""
}
```

## Initialization flow (follow 1keeper-SETUP.md)

Use [1keeper-SETUP.md](1keeper-SETUP.md) as the onboarding guide, then complete this initialization sequence.
User-side requirement: only provide API Key to Agent; no manual config editing.

1. Ask user for `apiKey`.
2. Agent writes `apiKey` into runtime config.
3. Query primary wallets from Open API:
- call `/api/open/wallets` with `chain_id=501` and select `is_primary=1` as Solana primary wallet
- call `/api/open/wallets` with `chain_id=56` and select `is_primary=1` as BSC primary wallet
4. Agent writes resolved wallet addresses into:
- `wallets.solanaPrimaryWalletAddress`
- `wallets.bnbPrimaryWalletAddress`
5. Agent sets default chain to Solana:
- `chainId = 501`
6. Agent sets skill current primary wallet to Solana primary wallet.
7. Agent shows initialization summary to user:
- default chain (`501`)
- Solana primary wallet address
- BSC primary wallet address
- current skill primary wallet (must equal Solana primary wallet)

## Required behavior

1. Complete initialization flow before trade/query operations.
2. Enforce rate limiting for Open API calls (>= 1 second spacing, use 1100ms safety interval).
3. Keep one WS connection with heartbeat and reconnect.
4. Push WS signals to Telegram and include actions for:
- query token/CA details
- trade this CA
5. Support interaction flows:
- signal-triggered query/trade flow
- user-triggered token query, buy, sell, balance query, recent trades query
- all buy/sell actions must require final confirmation
6. Persist user settings, active chats, pending actions, and callback contexts in local JSON state.
7. Respect trade safety gate:
- when trade mode is disabled, block buy/sell order operations and return a clear message.

## Data conventions

1. Chain IDs:
- `501` = Solana
- `56` = BSC
2. Sell input for `/api/open/placeorder` is ratio (`0~1`), not token quantity.
3. Wallet management endpoints:
- `/api/open/wallets` for list
- `/api/open/wallet/primary` for set primary
4. When wallet is in main-wallet mode, query operations should resolve current primary wallet before calling balance/trades.
5. Keep callback payloads short and store full callback context in local JSON state.

## Token info rendering rules

When rendering token info from `/api/open/tokeninfo`, use market-cap based output:

1. Primary display:
- `当前市值 = 当前价格 × 供应量` (USD)
- `ATH 市值 = ATH 价格 × 供应量` (USD)
- `距 ATH = (当前市值 - ATH 市值) / ATH 市值 × 100%`
2. Secondary display:
- name/symbol
- contract address
- chain
- supply
- holders
- launchpad
- create time
3. Special rule:
- if supply is exactly `2,000,000,000`, force market-cap calculation with `1,000,000,000`.
4. Do not use unit-price rows as primary output:
- do not show `当前价格`
- do not show `ATH价格`
5. Launchpad normalization:
- if `launchpad == "mayhem"`, render as `mayhem(pump.fun)`
6. Number formatting:
- market cap values use USD integer with `$` prefix (no decimals), e.g. `$5420`
- drawdown uses one decimal percentage, e.g. `-6.6%`
- supply uses thousands separators, e.g. `1,000,000,000`
- if any source field is missing/invalid, render `N/A`

Output template (must follow this label set):
```text
Token 信息查询结果
名称: <symbol or name>
合约地址: <token_address>
链: <SOL|BNB>
当前市值: <$number | N/A>
ATH市值: <$number | N/A>
距ATH: <pct | N/A>
总供应量: <formatted supply>
持有人: <holders>
发射平台: <launchpad>
创建时间: <local datetime>
```

## WS signal subscription and delivery

1. Keep one WS connection to Open WS with heartbeat and reconnect.
2. Deliver signal messages to Telegram with CA query/trade actions.
3. Delivery target policy:
- if `CHAT_ID` is configured, deliver signals only to this chat.
- if `CHAT_ID` is empty, deliver to known chats in local JSON state (`activeChats`).
4. Chain filter policy:
- if chat has selected chain, only push matching chain signals.
- if chat has no selected chain, allow all-chain signal push.
5. Security policy:
- support `AUTHORIZED_CHAT_IDS` allowlist for interactive access and signal delivery.

## Deployment checklist

1. Set env vars:
- `TELEGRAM_BOT_TOKEN`
- `ONEKEEPER_API_KEY`
- `ONEKEEPER_API_BASE_URL` (default `https://api1.1keeper.com`)
- `STATE_FILE` (local JSON state path, e.g. `./data/openclaw-keeper-state.json`)
- `CHAT_ID` (optional, signal target chat)
- `AUTHORIZED_CHAT_IDS` (optional, comma-separated allowlist)
- `ONEKEEPER_ALLOW_TRADES`
2. Validate chain and wallet settings before trade actions.
3. Log order attempts and txid, never log API key.
4. Do not store real secrets in skill files:
- keep only template placeholders in `1keeper-config.template.json`
- put runtime secrets in local env/config outside skill package

## Skill update (manual trigger, no auto-restart)

When user says similar intents:
- `更新SKILL`
- `升级SKILL`
- `同步SKILL`
- `Update SKILL`
- `Upgrade SKILL`
- `Sync SKILL`

Run direct update without version-check step:
- `scripts/update-skill.sh`

Behavior:
- pulls latest skill from `https://github.com/onektrading/agent-skills` (`main`)
- syncs to `~/.openclaw/skills/1keeper`
- does **not** restart OpenClaw
- reminds user to decide restart manually

Manual command:
```bash
./scripts/update-skill.sh
```
