# Cherry Backend TODO

> **작업 우선순위**: 외부 공유/데모 전까지 완료 목표

---

## Phase 1: 인증 시스템 (로그인/회원가입) ✅

- [x] JWT 토큰 검증 필터 구현 + SecurityConfig
- [x] `POST /auth/signup`, `POST /auth/login` 구현
- [x] `GET /me` 인증된 사용자 정보 조회

---

## Phase 2: 찜(픽) 기능 ✅

- [x] `ProductLike` Entity + Repository (복합 유니크 인덱스)
- [x] 찜 API: `POST/DELETE /products/{productId}/like`, `GET /products/{productId}/like-status`
- [x] `GET /me/likes` 커서 기반 페이지네이션
- [x] 찜 개수(likeCount) 집계 및 API 반환
- [x] 프론트: PickButton, 찜 목록 페이지, 무한 스크롤

### 미완료 (Phase 2 잔여)

- [ ] MyPickPage QA: 빈 상태/로딩/에러 상태 핸들링 브라우저 테스트
  - 참고: `features/wish/ui/MyPickPage.tsx`

---

## Phase 3: 필터 기능 ✅

- [x] Category/Tag Entity, 동적 쿼리 (Criteria API)
- [x] `GET /products` 필터 파라미터: status, categoryCode, minPrice, maxPrice, tradeType, sortBy
- [x] 커서 페이지네이션 + 필터 조합

---

## Phase 4: 상품 리스트 캐싱 ✅

- [x] Redis Cache-Aside 패턴 (TTL 5분)
- [x] 캐시 무효화 정책 (ProductEntityListener + ProductCacheInvalidator)
- [x] Before/After 성능 비교 보고서

---

## Phase 5: 상품 등록 + 이미지 파이프라인 ✅

### 5.1 이미지 업로드 파이프라인 ✅

- [x] Presigned URL 기반 S3 직접 업로드 (`POST /api/upload/images`)
- [x] 이미지 포맷 검증 (JPG, PNG, WebP) + contentType 매칭
- [x] Lambda 리사이즈: detail(1280px) + thumbnail(256px)
- [x] Lambda → 서버 콜백 (`POST /internal/images/complete`)

### 5.2 상품 등록 API ✅

- [x] `POST /products` 구현 (유효성 검사, 태그 파싱, 판매자 매핑)
- [x] 다중 이미지 처리 (최대 10장, imageKey 연결)

### 5.3 이미지 파이프라인 개선 (Phase 5.5) ✅

- [x] `ProductStatus.PENDING` 추가 — 이미지 처리 중 상태
- [x] PENDING → SELLING 자동 전환 (모든 이미지 처리 완료 시)
- [x] 공개 목록/트렌딩에서 PENDING 상품 자동 제외
- [x] imageKey 인코딩 포맷: `{order}_{t|f}_{UUID}.{ext}`
- [x] Lambda: 조건부 thumbnail 생성 + 콜백 재시도 로직
- [x] ImageCallbackService: 멱등성 처리 + 로깅 강화
- [x] `GET /products/my` 엔드포인트 (PENDING 포함 본인 상품 조회)
- [x] SecurityConfig: `/products/my` 인증 필수, `/error` permitAll 추가
- [x] DB: `status` ENUM에 PENDING 추가, `datetime(6)` → `datetime(0)` 전체 적용

### 미완료 (Phase 5 잔여 — 선택 사항)

- [ ] **프론트엔드 이미지 일괄 업로드**: 현재 이미지를 개별 요청으로 보내 모든 이미지가 `0_t_` 인코딩됨. 한 요청으로 보내면 Lambda thumbnail 최적화 효과 발생
- [ ] **PENDING 상품 상세 접근 제한**: 판매자 본인 외 PENDING 상품 직접 접근 차단
- [ ] **GET /products/my 프론트 연동**: 판매자 마이페이지에서 PENDING 상태 "처리 중" 표시

### 5.4 AI 상품 설명 생성 (미착수)

- [ ] 키워드 기반 설명 자동 생성 프롬프트
- [ ] `POST /ai/generate-description` 엔드포인트

---

## Phase 6: 다음 항목 (미착수)

- [ ] 상품 수정/삭제 기능
  - 이미지 삭제/순서변경/썸네일 재지정
- [ ] 검색 기능 (제목/태그 검색)
  - OpenSearch 도입 검토
- [ ] 실시간 채팅

---
