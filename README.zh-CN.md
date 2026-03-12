# 1keeper Skill 使用说明

English version: [README.md](README.md)

本仓库提供 `1keeper` skill，用于基于 1keeper Open API / WS 完成信号跟踪与交易操作。

Skill 路径：
- `skills/1keeper`

## 1. 初始化配置

首次使用时，不需要手动改配置文件。  
只需要把 API Key 发送给 Agent，Agent 会自动完成初始化：

可直接先发送自然语言指令：
- “帮我初始化1keeper配置”

1. 用户发送 API Key 给 Agent。
2. Agent 通过 API Key 获取：
- Solana 主钱包（`chain_id=501`）
- BSC 主钱包（`chain_id=56`）
3. Agent 自动写入两条链主钱包配置：
- `wallets.solanaPrimaryWalletAddress`
- `wallets.bnbPrimaryWalletAddress`
4. Agent 自动设置默认链为 Solana（`501`），并将当前 skill 主钱包设置为 Solana 主钱包。
5. Agent 回显初始化结果给用户（默认链、Sol/BSC 主钱包、当前 skill 主钱包）。

## 2. 常见使用场景（自然语言交互）

你可以直接用自然语言描述需求，以下是典型场景：

1. 查询地址主链币余额
- “查询这个地址主链币余额”
- “查一下我当前钱包的 SOL 余额”
- “看下 BSC 主钱包的 BNB 余额”

2. 买入 Token
- “买入这个 CA”
- “用 0.1 SOL 买入这个 token”
- “在 BSC 上买入这个地址，金额 0.01 BNB”

3. 卖出 Token
- “卖出这个 token”
- “把这个 CA 卖出 50%”
- “全部卖出这个地址”

4. 查询交易记录
- “查询最近交易记录”
- “看下最近 10 条交易”
- “查询这个钱包最近的买卖记录”

## 3. 升级技能

当你希望更新 skill 时，直接使用自然语言：
- “更新SKILL”
- “升级SKILL”
- “同步SKILL”

或在 `skills/1keeper` 下执行脚本：

```bash
./scripts/update-skill.sh
```

说明：
- 更新来源为公共仓库 `https://github.com/onektrading/agent-skills`
- 脚本只更新 skill 文件，不会自动重启 OpenClaw
