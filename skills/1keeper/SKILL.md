---
name: 1keeper
description: Use this skill when the user asks to operate 1keeper Open API or Open WebSocket workflows, including ws signal delivery, token info lookup, buy/sell orders, quick TP/SL modes, order management, single-address copy-trading, multi-address copy-trading, wallet balance, recent trades, wallet list, primary-wallet management, or asks to update the skill (e.g. "更新SKILL", "升级SKILL", "同步SKILL", "Update SKILL", "Upgrade SKILL", "Sync SKILL").
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

Default copy preset fields:
- `copyDefaults.addressCopy.sellOrdersCfg`
- `copyDefaults.addressCopy.copyAdvCfg`
- `copyDefaults.multiAddressCopy.sellOrdersCfg`
- `copyDefaults.multiAddressCopy.copyAdvCfg`
- `copyDefaults.signalCopy.sellOrdersCfg`
- `copyDefaults.signalCopy.copyAdvCfg`

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
  "copyDefaults": {
    "addressCopy": {
      "sellOrdersCfg": "[{\"type\":1,\"take_profit_percent\":20,\"sell_percent\":100},{\"type\":2,\"stop_loss_percent\":10,\"sell_percent\":100}]",
      "copyAdvCfg": "{\"liquidity\":{\"min\":3000},\"copy_amount\":{\"min\":0.001},\"token_age\":{\"max\":60},\"min_lp_burnt\":100,\"exclude_holding\":true,\"protocol_list\":[\"pumpfun\",\"bonk\",\"moonshot\",\"bags\",\"believe\",\"studio\",\"dbc\",\"launchlab\",\"moonit\"]}"
    },
    "multiAddressCopy": {
      "sellOrdersCfg": "[{\"type\":1,\"take_profit_percent\":20,\"sell_percent\":100},{\"type\":2,\"stop_loss_percent\":10,\"sell_percent\":100}]",
      "copyAdvCfg": "{\"liquidity\":{\"min\":3000},\"copy_amount\":{\"min\":0.001},\"token_age\":{\"max\":60},\"min_lp_burnt\":100,\"exclude_holding\":true,\"protocol_list\":[\"pumpfun\",\"bonk\",\"moonshot\",\"bags\",\"believe\",\"studio\",\"dbc\",\"launchlab\",\"moonit\"]}"
    },
    "signalCopy": {
      "sellOrdersCfg": "[{\"type\":1,\"take_profit_percent\":20,\"sell_percent\":100},{\"type\":2,\"stop_loss_percent\":10,\"sell_percent\":100}]",
      "copyAdvCfg": "{\"liquidity\":{\"min\":3000},\"copy_amount\":{\"min\":0.001},\"token_age\":{\"max\":60},\"min_lp_burnt\":100,\"exclude_holding\":true,\"protocol_list\":[\"pumpfun\",\"bonk\",\"moonshot\",\"bags\",\"believe\",\"studio\",\"dbc\",\"launchlab\",\"moonit\"]}"
    }
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
- buy-with-TP/SL flow: set TP/SL mode during buy -> buy confirm -> TP/SL confirm -> create orders
- buy-success quick TP/SL flow: `使用止盈止损` -> mode select -> confirm -> create orders
- order flow: create/cancel/list/query
- copy-trading flow: create/update/start/pause/stop/list/detail/trades
- multi-address-copy flow: create/update/start/pause/stop/list
- signal-copy flow: create/update/start/pause/stop/list
- task state flow: signal-copy + address-copy + multi-address-copy status query, pause, restart, stop
- pnl flow: copy-task and signal-task收益查询（按接口返回字段）
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
6. Order (挂单) endpoints:
- `/api/open/cond/add`
- `/api/open/cond/cancel`
- `/api/open/cond/list`
- `/api/open/cond/info`
7. Copy-trading endpoints:
- `/api/open/copy/add`
- `/api/open/copy/update`
- `/api/open/copy/stop`
- `/api/open/copy/start`
- `/api/open/copy/pause`
- `/api/open/copy/list`
- `/api/open/copy/info`
- `/api/open/copy/trades`
8. Signal-copy endpoints:
- `/api/open/signal/add`
- `/api/open/signal/update`
- `/api/open/signal/stop`
- `/api/open/signal/start`
- `/api/open/signal/pause`
- `/api/open/signal/list`
9. Multi-address-copy endpoints:
- `/api/open/mcopy/add`
- `/api/open/mcopy/update`
- `/api/open/mcopy/pause`
- `/api/open/mcopy/start`
- `/api/open/mcopy/stop`
- `/api/open/mcopy/list`
10. Quick TP/SL callback protocol:
- `TPSL:<id>` open quick TP/SL from a completed buy
- `TPSLMODE:<id>:DOUBLE|CONSERVATIVE|CUSTOM` choose mode
- `TPSLCONFIRM:<id>` / `TPSLCANCEL:<id>` confirm or cancel order creation

## Order (挂单), address-copy, multi-address-copy & signal-copy rules

1. Order `order_type`:
- `1` take profit
- `2` stop loss
- `3` dip-buy
- `4` dip-sell
2. For `order_type <= 4`, `trigger_price` is required.
3. Order/copy create or update operations are write actions:
- require explicit confirmation before execution
- return user-readable error mapping on failure
4. Default preset injection for address-copy, multi-address-copy, and signal-copy create/update:
- `sellOrdersCfg = [{"type":1,"take_profit_percent":20,"sell_percent":100},{"type":2,"stop_loss_percent":10,"sell_percent":100}]`
- `copyAdvCfg = {"liquidity":{"min":3000},"copy_amount":{"min":0.001},"token_age":{"max":60},"min_lp_burnt":100,"exclude_holding":true,"protocol_list":["pumpfun","bonk","moonshot","bags","believe","studio","dbc","launchlab","moonit"]}`
- use `copyDefaults.addressCopy.*` for `/api/open/copy/add` and `/api/open/copy/update` when user does not override
- use `copyDefaults.multiAddressCopy.*` for `/api/open/mcopy/add` and `/api/open/mcopy/update` when user does not override
- use `copyDefaults.signalCopy.*` for `/api/open/signal/add` and `/api/open/signal/update` when user does not override
5. Copy-trading lifecycle actions:
- create (`/copy/add`)
- update (`/copy/update`)
- start (`/copy/start`)
- pause (`/copy/pause`)
- stop (`/copy/stop`)
6. Signal-copy lifecycle actions:
- create (`/signal/add`)
- update (`/signal/update`)
- start (`/signal/start`)
- pause (`/signal/pause`)
- stop (`/signal/stop`)
7. Multi-address-copy lifecycle actions:
- create (`/mcopy/add`)
- update (`/mcopy/update`)
- start (`/mcopy/start`)
- pause (`/mcopy/pause`)
- stop (`/mcopy/stop`)
8. Query actions must support:
- order list/detail
- copy task list/detail
- multi-address-copy task list
- copy trades history

## Copy-task status, lifecycle, and PnL rules

1. Signal-copy task status query:
- use `/api/open/signal/list` as default source
- support filters: `chain_id`, `wallet_address`
- when user asks a single task status, match by `copy_id`; if no exact id, return candidate tasks and ask user to pick
2. Signal-copy pause/restart/stop:
- pause: `/api/open/signal/pause`
- restart: `/api/open/signal/start`
- stop: `/api/open/signal/stop`
- all write actions require explicit final confirmation
3. Signal-copy task PnL:
- read收益 fields from `/api/open/signal/list` response when available (for example `acc_pnl`, `total_pnl`, `total_pnl_usd`)
- if current response does not include收益 fields, explicitly tell user that this endpoint did not return PnL data
4. Single-address copy task status query:
- use `/api/open/copy/list` with `chain_id` + optional `wallet_address`
- filter `copy_address` for exact match, and/or use `/api/open/copy/info` by `copy_id`
5. Single-address copy pause/restart/stop:
- pause: `/api/open/copy/pause`
- restart: `/api/open/copy/start`
- stop: `/api/open/copy/stop`
- all write actions require explicit final confirmation
6. Multi-address copy task status query:
- use `/api/open/mcopy/list` as default source
- support filter: `chain_id`
- match task by multi-copy `id`, `group_id`, and optional `wallet_address`
7. Multi-address copy pause/restart/stop:
- pause: `/api/open/mcopy/pause`
- restart: `/api/open/mcopy/start`
- stop: `/api/open/mcopy/stop`
- all write actions require explicit final confirmation
- use `id` as required task identifier (not `copy_id`)
8. Multi-address copy create/update:
- create: `/api/open/mcopy/add` requires `group_id`
- update: `/api/open/mcopy/update` requires `id`
- if `group not found` or `group has no addresses`, return clear user-facing error

## Quick TP/SL modes (tokeninfo pricing only)

1. Trigger point:
- during buy flow, user may choose to set TP/SL mode before final buy confirmation
- after buy order success, show button: `使用止盈止损` for post-buy setup
2. Entry behavior:
- if user already set TP/SL during buy flow, carry the selected mode into post-buy creation flow
- if user did not set TP/SL during buy flow, prompt post-buy quick setup by default
3. Pricing baseline:
- use `/api/open/tokeninfo` current price as `basePrice` snapshot
- do not use `/api/open/trades` for TP/SL pricing baseline
- if `tokeninfo.price` is missing/invalid, block creation and return clear error
4. Trigger price formulas:
- `tpPrice = basePrice * (1 + tpPct/100)`
- `slPrice = basePrice * (1 - slPct/100)`
5. Built-in quick modes:
- `DOUBLE` (翻倍保本):
  - TP1: `+100%`, sell `50%`
  - TP2: `+300%`, sell remaining `50%`
  - SL: `-50%`, sell `100%`
- `CONSERVATIVE` (保守模式):
  - TP: `+30%`, sell `100%`
  - SL: `-30%`, sell `100%`
- `CUSTOM` (自定义):
  - user inputs TP/SL percentages
  - TP sell `100%`, SL sell `100%`
6. Custom input validation:
- TP must be `> 0`
- SL must be `> 0` and `< 100`
7. Execution mapping:
- use `/api/open/cond/add` and split to multiple orders per selected mode
- all quick-mode order creations must require final confirmation
8. Order display (MC-first):
- for order preview/list/detail, display trigger values as market cap (`MC`) instead of unit price
- internal trigger calculation still uses token price formulas; display layer converts to MC
- MC conversion: `triggerMC = triggerPrice × effectiveSupply` (USD)
- `effectiveSupply` follows tokeninfo rule: if supply is `2,000,000,000`, use `1,000,000,000`
- avoid showing `trigger_price` directly unless user explicitly asks for raw price
9. Order display template:
```text
挂单信息
模式: <DOUBLE|CONSERVATIVE|CUSTOM>
链: <SOL|BNB>
CA: <token_address>
基准市值: <$number | N/A>
条目:
1) <止盈|止损> <+/-pct>% 触发市值=<$number | N/A> 卖出=<pct%>
2) ...
```

## Trade detail rendering rules

1. Amount fields must be unit-explicit:
- do not output ambiguous amount values without unit tags
- for buy/sell trade detail, prefer dual-unit format:
  - `成交金额: <native_amount> <SOL|BNB>(<usd_amount> USD)`
- never label USD value as SOL/BNB amount (avoid `0.8851 SOL` when it is USD)
2. If only one unit is available:
- native only: `成交金额(主链币): <amount> <SOL|BNB>`
- USD only: `成交金额(USD): <amount> USD`
3. Price field must label quote currency:
- `成交价格: $<price>` means USD per token
4. Recommended trade detail template:
```text
交易详情
• Token: <symbol>
• 成交数量: <token_amount> <symbol>
• 成交金额: <native_amount> <SOL|BNB>(<usd_amount> USD)
• 成交价格: $<price>
```

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
