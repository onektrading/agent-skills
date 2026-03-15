# Open API 接口文档

所有接口需要通过 `api_key` 进行认证，每个接口限流 **1 次/秒**（按 IP）。

---

## 1. 下单交易

**POST** `/api/open/placeorder`

通过 API Key 进行买入/卖出交易。

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) 或 `56`(BSC) |
| `token_address` | string | 是 | Token 合约地址 |
| `wallet_address` | string | 否 | 钱包地址，为空则使用主钱包 |
| `trade_side` | int | 是 | 交易方向，`1` 买入，`2` 卖出 |
| `input_amount` | float | 是 | 买入时为原生代币数量（最小 0.001）；卖出时为百分比（0~1） |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "token_address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
  "wallet_address": "",
  "trade_side": 1,
  "input_amount": 0.1
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": {
    "txid": "5K8v...txid"
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `txid` | string | 链上交易哈希 |

### 错误码

| code | message | 说明 |
|------|---------|------|
| 208602 | Invalid Parameter | 参数缺失或格式错误 |
| 208603 | chain_id is invalid | chain_id 不合法 |
| 208604 | token_address is invalid | token_address 无效 |
| 208605 | trade_side is invalid | trade_side 不合法 |
| 208606 | amount must be greater than 0.001 | 金额过小 |
| 208607 | api key not found | API Key 无效 |
| 208608 | wallet_address is invalid | wallet_address 无效 |
| 208609 | wallet not found | 钱包未找到 |
| 208610 | token not found | Token 未找到 |
| 208613 | insufficient balance | 余额不足 |
| 208617 | build transaction failed | 构建交易失败 |
| 208618 | sign transaction failed | 签名交易失败 |
| 208619 | send transaction failed | 发送交易失败 |

---

## 2. 交易对查询

**POST** `/api/open/pair`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `address` | string | 是 | Token 合约地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "address": "So11111111111111111111111111111111111111112"
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": {
    "chain_id": "solana",
    "pool_address": "58oQChx4yWmvKdwLLZzBi4ChoCc2fqCUWBkwMihLYQo2"
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `chain_id` | string | 链标识，如 `solana`、`bsc` |
| `pool_address` | string | 交易对地址 |

### 错误码

| code | message | 说明 |
|------|---------|------|
| 208601 | Invalid Parameter | 参数缺失或格式错误 |
| 208602 | api key not found | API Key 无效 |

---

## 3. OHLCV K线数据

**POST** `/api/open/ohlcv`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `network` | string | 是 | 网络，`solana` 或 `bsc` |
| `pool` | string | 是 | 池子地址 |
| `timeframe` | string | 是 | 时间周期，`minute` 或 `hour` |
| `before` | int64 | 否 | 截止时间戳（秒） |
| `aggregate` | string | 否 | 聚合粒度，默认 `"1"` |
| `limit` | int64 | 否 | 返回条数，最大 100 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "network": "solana",
  "pool": "58oQChx4yWmvKdwLLZzBi4ChoCc2fqCUWBkwMihLYQo2",
  "timeframe": "hour",
  "before": 1772771058,
  "aggregate": "1",
  "limit": 50
}
```

### 响应

返回 `ohlcv_list` 数组，每条数据格式为 `[timestamp, open, high, low, close, volume]`：

```json
{
  "code": 10000,
  "message": "ok",
  "data": [
    [1772769600, 88.57, 88.57, 88.39, 88.41, 11323.79],
    [1772766000, 88.47, 88.72, 88.05, 88.57, 58642.97]
  ]
}
```

> 当无数据时 `data` 返回空数组 `[]`。

### 错误码

| code | message | 说明 |
|------|---------|------|
| 208701 | Invalid Parameter | 参数格式错误 |
| 208702 | api key not found | API Key 无效 |
| 208703 | pool is required | pool 地址为空 |
| 208704 | timeframe must be minute or hour | timeframe 不合法 |
| 208705 | request failed | 请求失败 |
| 208706 | parse response failed | 解析响应失败 |

---

## 4. 钱包余额查询

**POST** `/api/open/balance`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) 或 `56`(BSC) |
| `wallet_address` | string | 是 | 钱包地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "wallet_address": "5ZWj7a1f8tWkjBESHKgrLmXshuXxqeY9SYcfbshpAqPG"
}
```

### 响应

返回该钱包下所有余额大于 0 的 Token 列表：

```json
{
  "code": 10000,
  "message": "ok",
  "data": [
    {
      "token_address": "So11111111111111111111111111111111111111111",
      "wallet_address": "5ZWj7a1f8tWkjBESHKgrLmXshuXxqeY9SYcfbshpAqPG",
      "amount": "1.523456"
    },
    {
      "token_address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
      "wallet_address": "5ZWj7a1f8tWkjBESHKgrLmXshuXxqeY9SYcfbshpAqPG",
      "amount": "100.50"
    }
  ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `token_address` | string | Token 合约地址 |
| `wallet_address` | string | 钱包地址 |
| `amount` | string | 余额 |

> 仅返回余额 > 0 的 Token，无持仓时 `data` 返回空数组 `[]`。

### 错误码

| code | message | 说明 |
|------|---------|------|
| 208801 | Invalid Parameter | 参数缺失或格式错误 |
| 208802 | api key not found | API Key 无效 |
| 208803 | chain_id is invalid | chain_id 不合法 |
| 208804 | query balance failed | 查询余额失败 |

---

## 5. 最近交易记录

**POST** `/api/open/trades`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) 或 `56`(BSC) |
| `wallet_address` | string | 是 | 钱包地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "wallet_address": "5ZWj7a1f8tWkjBESHKgrLmXshuXxqeY9SYcfbshpAqPG"
}
```

### 响应

返回最近 10 条交易记录：

```json
{
  "code": 10000,
  "message": "ok",
  "data": [
    {
      "token_address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
      "symbol": "USDC",
      "side": 1,
      "price": "0.00012345",
      "quantity": "1000.00",
      "amount": "0.12345",
      "txid": "5K8v...txid",
      "block_time": 1741608000,
      "mc": "125000.50"
    }
  ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `token_address` | string | Token 合约地址 |
| `symbol` | string | Token 符号 |
| `side` | int | 交易方向，`1` 买入，`2` 卖出 |
| `price` | string | 成交价格 |
| `quantity` | string | Token 数量 |
| `amount` | string | 交易金额（原生代币计） |
| `txid` | string | 交易哈希 |
| `block_time` | int64 | 区块时间戳（秒） |
| `mc` | string | 成交时市值 |

> 无交易记录时 `data` 返回空数组 `[]`。

### 错误码

| code | message | 说明 |
|------|---------|------|
| 208901 | Invalid Parameter | 参数缺失或格式错误 |
| 208902 | api key not found | API Key 无效 |
| 208903 | chain_id is invalid | chain_id 不合法 |
| 208904 | query trades failed | 查询交易记录失败 |

---

## 6. Token 信息查询

**POST** `/api/open/tokeninfo`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) 或 `56`(BSC) |
| `address` | string | 是 | Token 合约地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": {
    "address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "symbol": "USDC",
    "price": "0.00012345",
    "ath": "0.00015000",
    "supply": "1000000000",
    "holders": 12345,
    "launchpad": "pumpfun",
    "create_at": 1741608000
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `address` | string | Token 合约地址 |
| `symbol` | string | Token 符号 |
| `price` | string | 当前价格（原生代币计） |
| `ath` | string | 历史最高价格 |
| `supply` | string | 总供应量 |
| `holders` | int | 持有人数 |
| `launchpad` | string | 发射平台 |
| `create_at` | int64 | 创建时间戳（秒） |

### 错误码

| code | message | 说明 |
|------|---------|------|
| 210001 | Invalid Parameter | 参数缺失或格式错误 |
| 210002 | api key not found | API Key 无效 |
| 210003 | chain_id is invalid | chain_id 不合法 |
| 210004 | token not found | Token 未找到 |

---

## 7. 钱包列表查询

**POST** `/api/open/wallets`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) 或 `56`(BSC) |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": [
    {
      "wallet_address": "5ZWj7a1f8tWkjBESHKgrLmXshuXxqeY9SYcfbshpAqPG",
      "name": "主钱包",
      "is_primary": 1,
      "create_at": 1735689600
    }
  ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `wallet_address` | string | 钱包地址 |
| `name` | string | 钱包名称 |
| `is_primary` | int | 是否主钱包，`1` 是，`0` 否 |
| `create_at` | int64 | 创建时间戳（秒） |

> 无钱包时 `data` 返回空数组 `[]`。

### 错误码

| code | message | 说明 |
|------|---------|------|
| 212001 | Invalid Parameter | 参数缺失或格式错误 |
| 212002 | api key not found | API Key 无效 |
| 212003 | chain_id is invalid | chain_id 不合法 |
| 212004 | query wallets failed | 查询钱包失败 |

---

## 8. 设置主钱包

**POST** `/api/open/wallet/primary`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) 或 `56`(BSC) |
| `wallet_address` | string | 是 | 要设为主钱包的地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "wallet_address": "5ZWj7a1f8tWkjBESHKgrLmXshuXxqeY9SYcfbshpAqPG"
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok"
}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 212101 | Invalid Parameter | 参数缺失或格式错误 |
| 212102 | api key not found | API Key 无效 |
| 212103 | chain_id is invalid | chain_id 不合法 |
| 212104 | wallet not found | 用户钱包未找到 |
| 212105 | set primary failed | 设置主钱包失败 |

---

## 9. 创建条件单

**POST** `/api/open/cond/add`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) / `56`(BSC) |
| `order_type` | int | 是 | 挂单类型，1:止盈 2:止损 3:抄底买 4:抄底卖 |
| `wallet_address` | string | 是 | 钱包地址 |
| `input_token_address` | string | 是 | 输入代币地址 |
| `output_token_address` | string | 是 | 输出代币地址 |
| `side` | int | 是 | 方向，`1` 买入 `2` 卖出 |
| `input_token_amount` | string | 是 | 输入代币数量 |
| `trigger_price` | string | 否 | 触发价格（order_type ≤ 4 时必填） |

> Preset 自动从用户交易配置中获取，无需传入。

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "order_type": 1,
  "wallet_address": "5ZWj...",
  "input_token_address": "So11...",
  "output_token_address": "EPjF...",
  "side": 1,
  "input_token_amount": "0.5",
  "trigger_price": "0.001"
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 213001 | Invalid Parameter | 参数错误 |
| 213002 | api key not found | API Key 无效 |
| 213003 | chain_id is invalid | chain_id 无效 |
| 213004 | user not found | 用户不存在 |
| 213005 | invalid order type | order_type 无效 |
| 213006 | invalid input amount | input_token_amount 无效 |
| 213007 | invalid trigger price | trigger_price 无效 |
| 213009 | invalid side | side 无效 |
| 213010 | (动态) | 创建失败 |

---

## 10. 取消条件单

**POST** `/api/open/cond/cancel`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID |
| `order_no` | []string | 是 | 条件单号列表 |
| `wallet_address` | string | 否 | 钱包地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "order_no": ["CO20260312001", "CO20260312002"]
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 213101 | Invalid Parameter | 参数错误 |
| 213102 | api key not found | API Key 无效 |
| 213103 | chain_id is invalid | chain_id 无效 |
| 213104 | cancel failed | 取消失败 |

---

## 11. 条件单列表

**POST** `/api/open/cond/list`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID |
| `wallet_address` | string | 否 | 筛选钱包地址 |
| `token_address` | string | 否 | 筛选代币地址 |
| `status` | int | 否 | 0:全部 1:进行中 2:成功 3:失败 4:取消 |
| `side` | int | 否 | 0:全部 1:买入 2:卖出 |
| `page` | int | 否 | 页码，默认 1 |
| `page_size` | int | 否 | 每页条数，默认 10 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "status": 1,
  "page": 1,
  "page_size": 10
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": {
    "conditional_orders": [...],
    "total": 5
  }
}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 213201 | Invalid Parameter | 参数错误 |
| 213202 | api key not found | API Key 无效 |
| 213203 | chain_id is invalid | chain_id 无效 |
| 213204 | query failed | 查询失败 |
| 213205 | server error | 服务端错误 |

---

## 12. 条件单详情

**POST** `/api/open/cond/info`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID |
| `order_no` | string | 是 | 条件单号 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "order_no": "CO20260312001"
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": { ... }
}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 213301 | Invalid Parameter | 参数错误 |
| 213302 | api key not found | API Key 无效 |
| 213303 | chain_id is invalid | chain_id 无效 |
| 213304 | order not found | 订单不存在 |
| 213305 | server error | 服务端错误 |

---

## 13. 创建跟单

**POST** `/api/open/copy/add`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID |
| `wallet_address` | string | 是 | 钱包地址 |
| `copy_address` | string | 是 | 跟单目标地址 |
| `enable_lightning` | int | 否 | 是否闪电模式，0:关 1:开 |
| `buy_type` | int | 是 | 买入方式 |
| `buy_amount` | string | 是 | 买入数量 |
| `sell_type` | int | 是 | 卖出方式 |

> Preset 自动从用户交易配置中获取，无需传入。

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "wallet_address": "5ZWj...",
  "copy_address": "8abc...",
  "buy_type": 1,
  "buy_amount": "0.1",
  "sell_type": 1
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214001 | Invalid Parameter | 参数错误 |
| 214002 | api key not found | API Key 无效 |
| 214003 | (动态) | 创建失败 |

---

## 14. 更新跟单

**POST** `/api/open/copy/update`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 跟单任务 ID |
| `chain_id` | int | 是 | 链 ID |
| `wallet_address` | string | 是 | 钱包地址 |
| `copy_address` | string | 是 | 跟单目标地址 |
| `enable_lightning` | int | 否 | 是否闪电模式 |
| `buy_type` | int | 是 | 买入方式 |
| `buy_amount` | string | 是 | 买入数量 |
| `sell_type` | int | 是 | 卖出方式 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "copy_id": 123,
  "chain_id": 501,
  "wallet_address": "5ZWj...",
  "copy_address": "8abc...",
  "buy_type": 1,
  "buy_amount": "0.2",
  "sell_type": 1
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214101 | Invalid Parameter | 参数错误 |
| 214102 | api key not found | API Key 无效 |
| 214103 | (动态) | 更新失败 |

---

## 15. 停止跟单

**POST** `/api/open/copy/stop`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 跟单任务 ID |

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214201 | Invalid Parameter | 参数错误 |
| 214202 | api key not found | API Key 无效 |
| 214203 | (动态) | 停止失败 |

---

## 16. 启动跟单

**POST** `/api/open/copy/start`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 跟单任务 ID |

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214301 | Invalid Parameter | 参数错误 |
| 214302 | api key not found | API Key 无效 |
| 214303 | (动态) | 启动失败 |

---

## 17. 暂停跟单

**POST** `/api/open/copy/pause`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 跟单任务 ID |

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214401 | Invalid Parameter | 参数错误 |
| 214402 | api key not found | API Key 无效 |
| 214403 | (动态) | 暂停失败 |

---

## 18. 跟单列表

**POST** `/api/open/copy/list`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 否 | 链 ID，不传返回全部链 |
| `wallet_address` | string | 否 | 筛选钱包地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": [
    {
      "id": 123,
      "user_id": 1,
      "chain_id": 501,
      "wallet_address": "5ZWj...",
      "wallet_name": "主钱包",
      "copy_address": "8abc...",
      "buy_type": 1,
      "buy_amount": "0.1",
      "sell_type": 1,
      "status": 1,
      "buy_count": 10,
      "sell_count": 5,
      "buy_total": "1.5",
      "sell_total": "0.8",
      "acc_pnl": "0.3",
      "create_at": 1741608000,
      "update_at": 1741608000,
      "last_trade_at": 1741608000
    }
  ]
}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214501 | Invalid Parameter | 参数错误 |
| 214502 | api key not found | API Key 无效 |
| 214503 | query failed | 查询失败 |

---

## 19. 跟单详情

**POST** `/api/open/copy/info`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID |
| `copy_id` | int64 | 是 | 跟单任务 ID |

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": { ... }
}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214601 | Invalid Parameter | 参数错误 |
| 214602 | api key not found | API Key 无效 |
| 214603 | order not found | 任务不存在 |

---

## 20. 跟单交易记录

**POST** `/api/open/copy/trades`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID |
| `copy_id` | int64 | 是 | 跟单任务 ID |
| `wallet_address` | string | 否 | 筛选钱包地址 |
| `copy_wallet_address` | string | 否 | 筛选跟单目标地址 |
| `token_address` | string | 否 | 筛选代币地址 |
| `side` | int | 否 | 0:全部 1:买入 2:卖出 |
| `status` | int | 否 | 状态筛选 |
| `offset` | int | 否 | 偏移量，默认 0 |
| `limit` | int | 否 | 条数，默认 10 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "copy_id": 123,
  "offset": 0,
  "limit": 20
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": {
    "orders": [...],
    "orders_count": 50,
    "total_realized_pnl": "0.5",
    "total_realized_pnl_usd": "75.00",
    "total_unrealized_pnl": "0.1",
    "total_unrealized_pnl_usd": "15.00",
    "total_pnl": "0.6",
    "total_pnl_usd": "90.00",
    "total_buy_count": 30,
    "total_sell_count": 20,
    "total_failed_count": 2,
    "copy_address": "8abc...",
    "copy_time": 1741608000
  }
}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 214701 | Invalid Parameter | 参数错误 |
| 214702 | api key not found | API Key 无效 |
| 214703 | (动态) | 查询订单失败 |
| 214704 | (动态) | 查询订单数失败 |
| 214705 | (动态) | 查询全部交易失败 |
| 214706 | (动态) | 查询任务失败 |

---

## 21. 创建信号跟单

**POST** `/api/open/signal/add`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 是 | 链 ID，`501`(Solana) 或 `56`(BSC) |
| `wallet_address` | string | 是 | 钱包地址 |
| `enable_lightning` | int | 否 | 是否闪电模式，0:关 1:开 |
| `signal_period` | int64 | 否 | 信号周期（秒） |
| `signal_count` | int | 否 | 信号次数 |
| `buy_type` | int | 是 | 买入方式 |
| `buy_amount` | string | 是 | 买入数量 |
| `sell_type` | int | 是 | 卖出方式 |

> Preset 自动从用户交易配置中获取，无需传入。

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501,
  "wallet_address": "5ZWj...",
  "signal_period": 3600,
  "signal_count": 3,
  "buy_type": 1,
  "buy_amount": "0.1",
  "sell_type": 1
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 215001 | Invalid Parameter | 参数错误 |
| 215002 | api key not found | API Key 无效 |
| 215003 | (动态) | 创建失败 |

---

## 22. 更新信号跟单

**POST** `/api/open/signal/update`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 信号跟单任务 ID |
| `chain_id` | int | 是 | 链 ID |
| `wallet_address` | string | 是 | 钱包地址 |
| `enable_lightning` | int | 否 | 是否闪电模式 |
| `signal_period` | int64 | 否 | 信号周期（秒） |
| `signal_count` | int | 否 | 信号次数 |
| `buy_type` | int | 是 | 买入方式 |
| `buy_amount` | string | 是 | 买入数量 |
| `sell_type` | int | 是 | 卖出方式 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "copy_id": 123,
  "chain_id": 501,
  "wallet_address": "5ZWj...",
  "signal_period": 7200,
  "signal_count": 5,
  "buy_type": 1,
  "buy_amount": "0.2",
  "sell_type": 1
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 215101 | Invalid Parameter | 参数错误 |
| 215102 | api key not found | API Key 无效 |
| 215103 | (动态) | 更新失败 |

---

## 23. 停止信号跟单

**POST** `/api/open/signal/stop`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 信号跟单任务 ID |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "copy_id": 123
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 215201 | Invalid Parameter | 参数错误 |
| 215202 | api key not found | API Key 无效 |
| 215203 | (动态) | 停止失败 |

---

## 24. 启动信号跟单

**POST** `/api/open/signal/start`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 信号跟单任务 ID |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "copy_id": 123
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 215301 | Invalid Parameter | 参数错误 |
| 215302 | api key not found | API Key 无效 |
| 215303 | (动态) | 启动失败 |

---

## 25. 暂停信号跟单

**POST** `/api/open/signal/pause`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `copy_id` | int64 | 是 | 信号跟单任务 ID |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "copy_id": 123
}
```

### 响应

```json
{"code": 10000, "message": "ok"}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 215401 | Invalid Parameter | 参数错误 |
| 215402 | api key not found | API Key 无效 |
| 215403 | (动态) | 暂停失败 |

---

## 26. 信号跟单列表

**POST** `/api/open/signal/list`

### 请求参数

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `api_key` | string | 是 | API Key |
| `chain_id` | int | 否 | 链 ID，不传返回全部链 |
| `wallet_address` | string | 否 | 筛选钱包地址 |

### 请求示例

```json
{
  "api_key": "ak_xxxxxxxxxxxxxxxx",
  "chain_id": 501
}
```

### 响应

```json
{
  "code": 10000,
  "message": "ok",
  "data": [...]
}
```

### 错误码

| code | message | 说明 |
|------|---------|------|
| 215501 | Invalid Parameter | 参数错误 |
| 215502 | api key not found | API Key 无效 |
| 215503 | (动态) | 查询失败 |

---

## 通用错误

| code | message | 说明 |
|------|---------|------|
| 429 | Too Many Requests | 请求频率超限（每接口每 IP 每秒 1 次） |
