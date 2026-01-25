# Phase 5: Product Upload & AI Write (Work Order)

> **목표**: 판매자가 상품 사진과 정보를 등록하고, AI를 활용해 판매글을 쉽게 작성할 수 있도록 지원합니다.

---

## 1. Backend (`cherry-server`)

### 1.1 이미지 업로드 (Image Upload)

- **API**: `POST /api/upload/images` (Multipart/form-data)
- **기능**:
  - 다중 이미지 업로드 (최대 10장)
  - 포맷 검증 (JPG, PNG, WebP) 및 용량 제한 (장당 10MB)
  - S3 (또는 Local) 저장 후 URL 반환
- **Output**: `List<String> imageUrls`

### 1.2 AI 상품 설명 생성 (AI Write)

- **API**: `POST /api/ai/generate-description`
- **Request**:
  - `keywords`: (예: "아이브, 장원영, 포카, 미개봉")
  - `category`: (예: "PHOTOCARD")
- **Logic**:
  - OpenAI/Gemini API 연동 (비동기 또는 타임아웃 처리 주의)
  - 프롬프트 엔지니어링: "이 상품의 매력을 살린 판매글을 작성해줘..."
- **Output**: `String generatedDescription` (Markdown/Text)

### 1.3 상품 등록 (Product Registration)

- **API**: `POST /api/products`
- **Request**:
  - `title`, `price`, `description`
  - `categoryId`, `tradeType`, `status` (Default: SELLING)
  - `imageUrls` (List), `tags` (List<String>)
- **Validations**:
  - 제목 최소 2자, 가격 0원 이상
  - 카테고리 필수
- **Logic**:
  - `Product` 엔티티 생성 및 `ProductImage`, `ProductTag` 저장
  - 로그인 유저를 판매자(Seller)로 설정

---

## 2. Frontend (`cherry-client`)

### 2.1 상품 등록 페이지 (`/products/new`)

- **이미지 업로더**:
  - 드래그 앤 드롭 또는 파일 선택
  - 미리보기 (Preview) 및 삭제
- **입력 폼**:
  - 제목, 카테고리(Select), 가격, 거래 방식
  - 태그 입력 (Enter로 추가)

### 2.2 AI 글쓰기 모달

- "AI로 설명 쓰기" 버튼 클릭 시 모달 오픈
- 키워드 입력 → "생성" → 결과 미리보기 → "적용하기"
- 적용 시 본문 `textarea`에 자동 입력

---

## 3. 검증 계획 (Verification)

- [ ] Postman을 이용한 이미지 업로드 테스트
- [ ] 상품 등록 후 상세 페이지(`GET /products/{id}`)에서 이미지/태그 확인
- [ ] AI 생성 속도 및 품질 확인
