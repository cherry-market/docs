# Cherry Backend TODO

> **작업 우선순위**: 외부 공유/데모 전까지 완료 목표

---

## Phase 1: 인증 시스템 (로그인/회원가입)

### 1.1 사용자 인증 기반 구축

- [x] Firebase Auth 설정 (또는 Mock 인증 결정) - JWT 직접 구현으로 대체됨
- [x] JWT 토큰 검증 필터 구현
- [x] `SecurityConfig` 작성 (Spring Security)
- [x] 인증 실패 시 에러 핸들링

### 1.2 회원가입 API

- [x] `POST /auth/signup` 엔드포인트 구현
- [x] 닉네임 중복 체크 로직
- [x] User 생성 및 DB 저장

### 1.3 로그인 API

- [x] `POST /auth/login` 엔드포인트 구현
- [x] 토큰 발급 로직
- [x] Refresh Token 처리 (선택) - 생략 (AccessToken만 구현)

### 1.4 사용자 정보 조회

- [x] `GET /me` 엔드포인트 구현
- [x] 인증된 사용자 정보 조회
- [x] 프로필 이미지 URL 반환

---

## Phase 2: 찜(픽) 기능 ✅

### 2.1 데이터 모델

- [x] `ProductLike` Entity 생성 (user_id, product_id, created_at)
- [x] 복합 유니크 인덱스 설정 (user_id + product_id)
- [x] `ProductLikeRepository` 작성

### 2.2 찜 API

- [x] `POST /products/{productId}/like` - 찜 추가
- [x] `DELETE /products/{productId}/like` - 찜 취소
- [x] `GET /products/{productId}/like-status` - 찜 여부 확인
- [x] 인증 필수 처리 (로그인 사용자만)

### 2.3 찜 목록 조회

- [x] `GET /me/likes` - 내가 찜한 상품 목록
- [x] 커서 기반 페이지네이션 적용
- [x] ProductSummaryResponse 형식으로 반환

### 2.4 목업 데이터 생성 준비

- [x] 대량 테스트 데이터 생성 스크립트 작성
- [x] 카테고리/아티스트/상품 더미 데이터 생성
- [x] 다양한 필터 조건 테스트를 위한 데이터셋 구성
- [x] 성능 테스트를 위한 데이터 볼륨 확보

### 2.5 상품 이미지 상세 연동

- [x] 상품 상세에서 다중 이미지 조회 (S3 URL)

---

## Phase 3: 필터 기능

### 3.1 상품 카테고리/태그 모델 추가

- [x] `Category` Entity 생성 (code, display_name, is_active, sort_order)
- [x] `Product` Entity에 category 필드 추가
- [x] tags 테이블/조인 엔티티 추가
- 변경 이력: RFP-01에 artist/artistId가 있으나 MVP에서는 tags로 대체

### 3.4 카테고리 반영 (프론트 연동 전 준비)

- [x] 카테고리 목록 DB 조회 API 준비
- [x] 상품 리스트/상세에 카테고리 값 반영

### 3.5 태그/시간 UI 준비 (프론트)

- [x] 상품 상세 UI에 해시태그 표시
- [x] 상품 시간 표시를 상대 시간으로 변환 (n분/시간/일/년 전)

### 3.2 필터 API 파라미터 추가

- [x] `GET /products` 파라미터 확장:
  - [x] `status` (SELLING/RESERVED/SOLD)
  - [x] `categoryCode`
  - [x] `minPrice`, `maxPrice`
  - [x] `tradeType` (DIRECT/DELIVERY/BOTH)
  - [x] `sortBy` (LATEST/LOW_PRICE/HIGH_PRICE)
- 변경 이력: RFP-01의 `artistId`는 MVP에서 미사용(태그로 대체)

### 3.3 필터 쿼리 구현

- [x] `ProductRepository`에 동적 쿼리 추가 (Criteria API custom query)
- [x] 필터 조합 시 AND 조건 처리
- [x] 커서 페이지네이션과 필터 조합 테스트

---

## Phase 4: 상품 리스트 캐싱

> **목적**: 현재 커서 기반 조회를 느리게 만든 뒤, 캐싱으로 개선하는 과정을 개발 기록에 포함

### 4.1 성능 저하 시나리오 구성

- [x] 대량 테스트 데이터 생성 (1만 건)
- [x] 성능 측정 (before 기준 수치 확보)

### 4.2 Redis 캐싱 전략 설계

- [x] 캐시 키 설계: `products:list:{cursor}:{filters}`
- [x] TTL 설정 (예: 5분)
- [x] 캐시 무효화 정책 (상품 등록/수정/삭제 시)

### 4.3 캐싱 구현

- [x] `@Cacheable` 어노테이션 적용 또는 수동 Redis 캐싱
- [x] Cache-Aside 패턴 구현
- [x] `ProductListResponse` 직렬화/역직렬화 처리

### 4.4 성능 비교 및 문서화

- [x] 캐싱 적용 후 성능 측정 (after 수치)
- [x] Before/After 비교 표 작성
- [x] 성능 개선 보고서 작성 (`docs/reports/phase-4/performance_improvement.md`)

---

## 제외 항목 (시간 부족으로 연기)

- ~~검색 기능 (제목/태그/아티스트 검색)~~ → 캐싱 우선
- ~~가격 정렬 (낮은순/높은순)~~ → Phase 3 이후 시간 있으면
- ~~실시간 채팅~~ → MVP 이후
- ~~OpenSearch 도입~~ → MVP 이후

---

**우선순위 요약**:  
1️⃣ 인증 → 2️⃣ 찜 → 3️⃣ 필터 → 4️⃣ 캐싱

**작업 시작일**: 2026-01-21  
**목표 완료일**: 2026-01-24
