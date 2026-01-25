# Cherry Backend API Specification (v0.1 MVP)

## Overview

- **Base URL**: `http://localhost:8080`
- **Environment**: Development (H2 Local DB)
- **Timezone**: UTC (Server standard)

---

## 1. 상품 목록 (Feed)

`GET /products`

메인 화면의 피드를 조회합니다. **커서 기반 무한 스크롤(Cursor Pagination)**을 지원합니다.

### Request

| Parameter | Type    | Required | Default | Description                                           |
| :-------- | :------ | :------- | :------ | :---------------------------------------------------- |
| `cursor`  | String  | No       | null    | 다음 페이지 조회를 위한 커서 값 (`createdAt_id` 형태) |
| `limit`   | Integer | No       | 10      | 한 번에 로딩할 개수                                   |

### Response

```json
{
  "items": [
    {
      "id": 1,
      "title": "아이브 원영 공방 포카",
      "price": 45000,
      "status": "SELLING", // SELLING | RESERVED | SOLD
      "tradeType": "BOTH", // DIRECT | DELIVERY | BOTH
      "thumbnailUrl": "https://...",
      "createdAt": "2026-01-20T17:00:00"
    }
  ],
  "nextCursor": "2026-01-20T17:00:00_1"
}
```

---

## 2. 상품 상세 (Detail)

`GET /products/{productId}`

상품의 상세 정보를 반환합니다. 이 API를 호출하면 내부적으로 **조회수가 카운트(Ranking Score +1)**됩니다.

### Request

- Path Variable: `productId` (Long)

### Response

```json
{
  "id": 1,
  "title": "아이브 원영 공방 포카",
  "price": 45000,
  "status": "SELLING",
  "tradeType": "BOTH",
  "imageUrls": ["https://..."],
  "description": "상태 좋아요. 쿨거 시 네고 가능",
  "seller": {
    "id": 10,
    "nickname": "CherrySeller"
  },
  "createdAt": "2026-01-20T17:00:00"
}
```

---

## 3. 실시간 인기 랭킹 (Trending)

`GET /products/trending`

최근 24시간 동안 조회수가 가장 높은 상품 Top 10을 반환합니다. (Redis ZSET 기반)

### Response

- 형식은 **상품 목록(`items`)**과 동일합니다.
- `nextCursor`는 `null`입니다.

```json
{
  "items": [
    {
      "id": 15,
      "title": "인기 터지는 포카",
      "price": 120000,
      "...": "..."
    }
    // ... 최대 10개
  ],
  "nextCursor": null
}
```

---

## 4. 서버 상태 확인 (System)

`GET /health`

### Response

```json
{
  "status": "ok"
}
```
