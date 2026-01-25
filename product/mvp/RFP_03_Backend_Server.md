# RFP-03 서버 띄우기, API 추가

## Cherry Backend MVP v0.1 – Product Feed Performance & Trending (MVP)

### 0. 문서 목적

- RFP-02에서 완성된 모바일 웹뷰 UI에 **실제 백엔드 API를 연결**한다.
- 외부에서 접속 가능한 “동작하는 서비스”를 빠르게 확보한다.
- **P0는 성능/캐시 임팩트가 큰 기능만 구현**한다:
    1. 상품 리스트를 빠르게 가져오기(무한 스크롤)
    2. “지금 뜨는 체리픽”을 조회수 기반으로 랭킹(Top10) 노출

---

## 1. 범위(Scope)

### 1.1 포함 범위 (P0 – 제출 전 반드시)

1. AWS에 백엔드 배포(최소 구성)
2. 상품 목록 조회 API (무한 스크롤 커서 기반)
3. 상품 상세 조회 API
4. 조회수 집계(상세 진입 기준)
5. 체리픽 트렌딩 Top10 API
6. (선택) 간단한 인증(로그인 상태 연결용) – Mock 또는 Firebase 토큰 검증 중 택1

### 1.2 포함 범위 (P1 – 시간되면)

- 찜(픽) 목록 조회/토글 API
- 마이페이지 사용자 정보 조회 API
- 검색(최소 구현: DB 인덱스 기반, 단어 포함 검색 정도)
- 기본 운영 로그(요청 시간 로그)

### 1.3 제외 범위 (P2 – 다음 단계로 명시)

- 실시간 채팅(Socket/WebSocket)
- OpenSearch 도입(“고려 사항”으로만 문서화)
- BFF 고도화
- 이메일 인증(링크 기반/Firebase) 실제 구현

---

## 2. 구현 원칙

### 2.1 무한 스크롤 원칙

- 프론트는 스크롤 하단 도달 시 `GET /products`를 반복 호출한다.
- 백엔드는 **커서 기반 페이지네이션(cursor pagination)**을 제공한다.
- 중복 요청 방지/정렬 일관성 유지 목적상 **offset paging 지양**.

### 2.2 성능 원칙(제출용 최소 목표)

- 기본 리스트(최신순) 첫 페이지는 빠르게 응답해야 한다.
- 체리픽(trending) Top10은 빠르게 응답해야 한다.
- “빠름”의 정의는 RFP-03 완료 후 측정으로 수치화(별도 문서/리포트로 작성).

---

## 3. 시스템 구성(최소 배포)

### 3.1 AWS 최소 구성 (권장)

- Backend: EC2 + Docker(또는 ECS Fargate 중 1개 선택)
- DB: RDS (MySQL 또는 PostgreSQL)
- Cache: Redis (ElastiCache 또는 EC2 Redis)

> 본 RFP-03에서는 “운영 레벨 HA”는 요구하지 않는다.
> 
> 
> “배포되어 접속 가능한 환경”이 목표다.
> 

---

## 4. 데이터 모델(최소 테이블)

### 4.1 users (P0 선택)

- `id` (PK)
- `email` (nullable 가능: 소셜 로그인만 쓰면)
- `nickname`
- `profile_image_url`
- `created_at`, `updated_at`

### 4.2 products (P0)

- `id` (PK)
- `seller_user_id` (FK users.id)
- `title`
- `description`
- `price`
- `status` (SELLING / RESERVED / SOLD)
- `trade_type` (DIRECT / DELIVERY / BOTH)
- `created_at`, `updated_at`

### 4.3 product_images (P0 권장)

- `id` (PK)
- `product_id` (FK)
- `image_url`
- `sort_order`

### 4.4 product_view_events (P0 선택)

> “정교한 집계”가 필요하면 사용.
> 
> 
> MVP에서는 Redis 집계만으로도 가능.
> 
- `id`
- `product_id`
- `viewer_id` (nullable 가능)
- `session_id` (optional)
- `created_at`

---

## 5. API 요구사항 (P0)

### 5.1 Health Check

`GET /health`

- Response: 200 OK, `{ "status": "ok" }`

---

### 5.2 상품 목록 조회 (무한 스크롤)

`GET /products`

### Query Parameters

- `limit` (default 20, max 50)
- `cursor` (nullable)
- `sort` (default `LATEST`)
    - `LATEST` (created_at desc, id desc)

> P0에서는 정렬은 LATEST만 지원해도 됨.
> 
> 
> 가격 정렬 등은 P1로.
> 

### Response (예시)

```json
{
"items":[
{
"id":1,
"title":"아이브 원영 공방 포카",
"price":45000,
"status":"SELLING",
"tradeType":"BOTH",
"thumbnailUrl":"...",
"createdAt":"2026-01-19T12:00:00Z"
}
],
"nextCursor":"..."
}

```

### 커서 규칙(권장)

- `cursor`는 `(created_at, id)` 기반으로 생성
- 다음 페이지 조건:
    - `created_at < last_created_at` OR
    - `created_at == last_created_at AND id < last_id`
- `nextCursor`는 마지막 item의 `(created_at, id)`를 encode한 값

---

### 5.3 상품 상세 조회

`GET /products/{productId}`

### Response (예시)

```json
{
"id":1,
"title":"...",
"price":45000,
"status":"SELLING",
"tradeType":"BOTH",
"imageUrls":["...","..."],
"description":"...",
"tags":[],
"seller":{
"id":10,
"nickname":"..."
},
"createdAt":"..."
}

```

---

### 5.4 조회수 증가 (상세 진입 기준)

> 프론트가 상세를 열 때마다 1회 호출(또는 상세 조회 API 내부에서 증가 처리)
> 

### 옵션 A(권장: 명확)

`POST /products/{productId}/views`

- Response: 204 No Content

### 정책(P0 최소)

- “상세 진입”을 조회로 간주한다.
- 중복 방지는 P0에서는 생략 가능(혹은 세션 기반 N초 제한을 P1로)

---

### 5.5 체리픽 트렌딩 Top10 (조회수 기반)

`GET /products/trending`

### Query Parameters

- `limit` (default 10, max 20)
- `window` (optional)
    - `24h` (default) 또는 `today`

### Response

- `/products` items와 동일한 요약 형태로 반환
- 정렬은 랭킹 순서(조회수 desc)

### 구현 정책

- P0 목표는 **Redis 기반 랭킹**이다.
- Redis 사용 전 baseline(비교용)으로 DB 정렬 방식은 선택(P0 optional).

---

## 6. Redis 설계 (P0 핵심)

### 6.1 Trending 랭킹 (ZSET)

- Key 예시:
    - `trending:views:24h`
- Member: `productId`
- Score: view count

### 업데이트

- 조회수 증가 시 `ZINCRBY trending:views:24h 1 {productId}`

### 조회

- `ZREVRANGE trending:views:24h 0 9 WITHSCORES`
- 결과 productId로 상품 요약 조회 후 응답 구성

### TTL / 윈도우

- P0에서는 `24h` 고정 권장
- “정교한 슬라이딩 윈도우”는 P1/P2

---

## 7. 인증 (P0 선택 / P1)

### 7.1 P0 최단 루트(데모/검증용)

- UI는 이미 mock 로그인 상태를 사용 중이므로
- 백엔드 인증은 P0에서 필수는 아님

### 7.2 P1 권장(현실적인 최소 인증)

- Firebase Auth(구글 로그인) ID Token을 서버에서 검증
- 유저 프로필(users) 생성/조회
- `GET /me` 같은 최소 API 제공

---

## 8. 완료 기준 (Acceptance Criteria)

### P0 완료

- AWS에 백엔드가 배포되어 외부에서 호출 가능
- `GET /products`가 커서 기반으로 무한 스크롤에 맞게 동작
- `GET /products/{id}`가 정상 동작
- 상세 진입 시 조회수가 증가(POST views 또는 내부 처리)
- `GET /products/trending`이 Top10을 반환하며 Redis 랭킹을 사용
- RFP-02 프론트 화면이 “실제 데이터”로 렌더링 가능

---

## 9. 산출물(증빙용 – 최소)

- API 목록 및 간단한 아키텍처 다이어그램 1장
- Redis 랭킹 키 설계/정책 문단(짧게)
- (추후) 성능 비교 결과(베이스라인 vs Redis) 표 1개

---

## 10. 다음 단계(RFP-04/05 후보)

- 검색: DB 인덱스 기반 → OpenSearch 확장 검토
- 찜(픽): 토글/목록 + 캐시 전략
- 채팅: 실시간(WebSocket) + 메시지 저장 모델
- 이미지 업로드: S3 Presigned URL + CDN
- 관측성: p95, 로그, 트레이싱
