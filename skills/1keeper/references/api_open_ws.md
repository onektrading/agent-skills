# Open WebSocket API 文档

## 连接地址

```
wss://ws.1keeper.com/wso?api_key=ak_xxxxxxxxxxxxxxxx
```

## 认证方式

通过 URL 参数 `api_key` 进行认证，每个 `api_key` 仅允许创建 **1 个**连接。

## 限流

每个 IP 每 **5 秒**最多建立 1 次连接。

---

## 心跳

客户端需定期发送心跳消息保持连接，超过 **120 秒**无心跳将断开。

### 客户端发送

```json
{"op": "hb"}
```

### 服务端响应

```json
{"op": "hb", "ts": 1741608000000}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `ts` | int64 | 服务端当前时间戳（毫秒） |

---

## 推送数据

连接成功后，服务端会实时推送聪明钱信号数据，无需客户端订阅。

### 消息格式

```json
{
  "topic": "s:msignal-token",
  "data": {
    "token_address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "symbol": "USDC",
    "price": 0.00012345,
    "mc": 125000.50,
    "time": 1741608000
  }
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `topic` | string | 消息主题，Solana 为 `s:msignal-token`，BSC 为 `b:msignal-{chain_id}:token` |
| `data.token_address` | string | Token 合约地址 |
| `data.symbol` | string | Token 符号 |
| `data.price` | float | 当前价格 |
| `data.mc` | float | 当前市值 |
| `data.time` | int64 | 信号时间戳（秒） |

---

## 错误码

| HTTP Status | 说明 |
|-------------|------|
| 401 | `api_key` 为空或无效 |
| 429 | 连接数超限（同一 api_key 已有连接）或 IP 限流触发 |

## 示例

### JavaScript

```javascript
const ws = new WebSocket("wss://ws.1keeper.com/wso?api_key=ak_xxxxxxxxxxxxxxxx");

ws.onopen = () => {
  console.log("connected");
  // 定期发送心跳
  setInterval(() => ws.send(JSON.stringify({ op: "hb" })), 30000);
};

ws.onmessage = (event) => {
  const msg = JSON.parse(event.data);
  console.log("signal:", msg.data);
};
```
