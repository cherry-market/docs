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

## 4. 내 판매 상품 목록

`GET /products/my`

로그인한 판매자의 상품 목록을 조회합니다 (PENDING 포함). 인증 필수.

### Request

| Parameter | Type    | Required | Default | Description |
| :-------- | :------ | :------- | :------ | :---------- |
| `cursor`  | String  | No       | null    | 커서 값 (`createdAt_id` 형태) |
| `limit`   | Integer | No       | 20      | 한 번에 로딩할 개수 (최대 50) |

### Response

- 형식은 **상품 목록(`items`)**과 동일합니다.
- `status`에 `PENDING`이 포함될 수 있습니다.

### 접근 제한

- 인증 필수 (미인증 시 401)

---

## 5. 상품 상세 접근 제한 (PENDING)

`GET /products/{productId}`에서 PENDING 상태 상품은 **판매자 본인만** 조회 가능합니다.

| 요청자 | 응답 |
|--------|------|
| 비로그인 | 404 Not Found |
| 다른 사용자 | 404 Not Found (존재 자체 숨김) |
| 판매자 본인 | 200 OK (정상 조회) |

---

## 6. AI 상품 설명 생성

`POST /api/ai/generate-description`

키워드 기반으로 K-POP 굿즈 판매글을 자동 생성합니다. Google Gemini API (gemini-2.0-flash) 사용.

### Request

```json
{
  "keywords": "아이브 장원영 포카, 미개봉",
  "category": "PHOTOCARD",
  "personality": "친근함",
  "tone": "POLITE"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `keywords` | String | Yes | 상품 키워드 |
| `category` | String | Yes | 카테고리 코드 |
| `personality` | String | No | AI 성격 (친근함/귀여움/깔끔함) |
| `tone` | String | No | 말투 (SHORT/POLITE/SOFT) |

### Response

```json
{
  "generatedDescription": "안녕하세요! 아이브 장원영 포카 양도합니다 ✨ ..."
}
```

### 비고

- Gemini API 키 미설정 시 fallback 메시지 반환
- 타임아웃/에러 시에도 fallback 메시지 반환 (서비스 중단 없음)

---

## 7. 서버 상태 확인 (System)

`GET /health`

### Response

```json
{
  "status": "ok"
}
```
