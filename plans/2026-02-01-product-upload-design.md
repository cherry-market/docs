# Phase 5 상품 업로드 & AI Write 설계

작성일: 2026-02-01

## 목표
- 판매자가 모바일 기준으로 상품 이미지를 업로드하고 게시글을 등록할 수 있다.
- 리스트는 썸네일(256), 상세는 리사이즈(긴 변 1280) 이미지를 사용한다.
- 원본 이미지는 보관만 하고 클라이언트에 노출하지 않는다.
- AI 설명 생성 API를 제공해 작성 편의를 높인다.

## 비목표
- 원본 확대/다운로드 기능
- 고급 이미지 검수(유해성 검사/저작권 판단)
- CDN/캐시 고도화(후속 단계)

## 핵심 결정
- 업로드 방식: **클라이언트 직접 S3 업로드(pre-signed URL)**  
- 리사이즈: **S3 이벤트 → Lambda 리사이즈 → 내부 콜백으로 DB 업데이트**  
- 저장 구조: `product_images`에 `original_url`, `thumbnail_url` 추가  
  - `image_url`은 **상세 리사이즈(1280)** 로 사용
  - `thumbnail_url`은 **썸네일(256×256 crop)** 로 사용
  - `is_thumbnail`은 대표 이미지(첫 이미지) 표시용
- 클라이언트 노출: **썸네일/상세만 노출**, 원본 URL 미노출

## 데이터 모델
`product_images`
- 기존: `image_url`, `image_order`, `is_thumbnail`
- 추가: `original_url`, `thumbnail_url`
- 정책
  - 한 이미지 = 한 row (original/detail/thumbnail을 한 row에 저장)
  - `is_thumbnail=true`는 대표 이미지(리스트/카드 노출)
  - `image_order`는 상세 슬라이더 순서
  - 기존 썸네일 전용 row가 있는 경우 **백필/정리** 필요

## 이미지 규격
- 썸네일: **256×256 (center crop)**
- 상세: **긴 변 1280px (비율 유지)**
- 입력 제한: **최대 10장, 10MB, JPG/PNG/WebP**

## 아키텍처 / 데이터 흐름
1) 클라이언트 → `POST /api/upload/images`  
   - 파일 메타(이름/타입/크기) 전달  
   - 서버는 검증 후 **pre‑signed URL + imageKey** 반환  
2) 클라이언트 → S3 직접 업로드(PUT)  
3) S3 이벤트 → Lambda  
   - 원본 리사이즈 → `detail/`, `thumb/` 저장  
4) Lambda → `POST /internal/images/complete`  
   - `imageKey` 기준으로 `thumbnail_url`, `image_url` 업데이트  
5) 클라이언트 → `POST /products`  
   - 상품 등록 시 `imageKeys` 전달  
   - 서버가 `original_url`을 생성해 저장

## API 계약(요약)
### 1) 업로드 준비
`POST /api/upload/images`
- Request
  - `files`: [{ `fileName`, `contentType`, `size` }]
- Response
  - `items`: [{ `imageKey`, `uploadUrl`, `requiredHeaders` }]

### 2) 상품 등록
`POST /products`
- Request
  - `title`, `price`, `description`, `categoryId`, `tradeType`
  - `imageKeys` (순서 유지)
  - `tags` (List<String>)
- Response
  - `productId`

### 3) AI 설명 생성
`POST /api/ai/generate-description`
- Request: `keywords`, `category`
- Response: `generatedDescription`

### 4) 이미지 처리 완료(내부)
`POST /internal/images/complete`
- Request: `imageKey`, `detailUrl`, `thumbnailUrl`, `imageOrder`, `isThumbnail`
- Auth: 내부 토큰/서명

## 프론트 매핑
- 리스트/카드: `ProductSummary.thumbnailUrl`
- 상세: `ProductDetail.imageUrls`
- 업로드 UI: 업로드 상태(대기/업로드중/처리중/완료/실패)

## 오류 처리 요약
- 업로드 준비: 검증 실패 → 400
- S3 업로드 실패: 클라이언트 재시도
- Lambda 실패: 재시도/Dead Letter Queue
- 콜백 실패: 재시도 후 캐시 무효화

## 캐시 영향
- 상품 등록 시 `ProductCacheInvalidator`로 리스트 캐시 무효화
- 이미지 URL 업데이트 시 동일하게 캐시 무효화

## AWS 작업 범위 (외부)
- S3 버킷/정책 설정
- Lambda 리사이즈 함수 배포
- S3 이벤트 트리거 연결
