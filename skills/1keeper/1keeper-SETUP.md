# 1keeper Skill 初始化指南

## 目标

基于用户提供的 API Key，由 Agent 自动完成双链主钱包初始化并写入 skill 配置：
- Solana 主钱包（`chain_id=501`）
- BSC 主钱包（`chain_id=56`）

默认链必须设置为 Solana（`501`），并将 skill 当前主钱包设置为 Solana 主钱包。

## 用户侧操作

用户只需发送 API Key 给 Agent，不需要手动编辑配置文件。

## 初始化步骤

1. 用户发送 `apiKey`。
2. Agent 调用 `/api/open/wallets`（`chain_id=501`）获取 Solana 主钱包（`is_primary=1`）。
3. Agent 调用 `/api/open/wallets`（`chain_id=56`）获取 BSC 主钱包（`is_primary=1`）。
4. Agent 将两个地址写入配置：
- `wallets.solanaPrimaryWalletAddress`
- `wallets.bnbPrimaryWalletAddress`
5. Agent 设置默认链：
- `chainId = 501`
6. Agent 将 skill 当前主钱包设为 Solana 主钱包。
7. Agent 回显初始化结果给用户：
- 默认链
- Solana 主钱包地址
- BSC 主钱包地址
- 当前 skill 主钱包

## 校验

1. `chainId` 必须是 `501`。
2. 两条链主钱包地址都非空。
3. 当前 skill 主钱包与 `wallets.solanaPrimaryWalletAddress` 一致。
4. 快捷止盈止损可用性校验：
- `/api/open/tokeninfo` 可返回有效 `price`。
- 买入成功后可展示 `使用止盈止损` 按钮并进入模式选择。
- 在任一模式下都必须先二次确认后再调用 `/api/open/cond/add`。
