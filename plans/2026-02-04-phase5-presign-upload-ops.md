# Phase 5 S3 Presign + Callback Verification Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 운영 환경에서 `/api/upload/images` presigned URL 발급 → S3 원본 업로드 → Lambda 리사이즈 → 서버 콜백(`/internal/images/complete`) → DB 반영까지 End-to-End 검증한다.

**Architecture:** 서버는 S3 PutObject presigned URL을 발급하고, 클라이언트는 `products/original/`에 업로드한다. S3 이벤트로 Lambda가 리사이즈 후 콜백을 호출하면 서버가 `product_images.original_url` 기준으로 레코드를 찾아 `image_url/thumbnail_url`을 업데이트한다.

**Tech Stack:** Spring Boot 3, AWS SDK v2(S3Presigner), S3, Lambda(Node.js), RDS(MySQL)

---

### Task 1: 서버 IAM 권한 준비

**Files:**
- (문서) `docs/reports/phase-5/PHASE_5_WORK_ORDER.md`

**Step 1: IAM 정책 준비**
- 필수:
  - `s3:PutObject` on `arn:aws:s3:::<bucket>/products/original/*`
- 선택:
  - `s3:GetObject` on `arn:aws:s3:::<bucket>/products/detail/*`
  - `s3:GetObject` on `arn:aws:s3:::<bucket>/products/thumb/*`

**Step 2: 서버 실행 주체에 권한 부여**
- ECS/EC2/온프레 환경에 맞게 Role 또는 User/AccessKey를 준비한다.
- 권장: Role 기반(DefaultCredentialsProvider) 사용.

---

### Task 2: 운영 환경변수 주입 확인

**Files:**
- `cherry-server/src/main/resources/application-prod.yml`

**Step 1: 필수 환경변수**
- `INTERNAL_TOKEN`
- `STORAGE_BUCKET`
- `STORAGE_REGION`
- `STORAGE_BASE_URL`
- `STORAGE_PRESIGN_EXPIRE_SECONDS`

**Step 2: 값 검증**
- `STORAGE_BASE_URL`는 서버가 `originalUrl`을 생성/조회할 때 사용하는 base URL이므로, Lambda 콜백의 `imageKey`와 결합했을 때 실제 업로드된 원본 URL과 동일해야 한다.

---

### Task 3: End-to-End 시나리오 검증

**Files:**
- (코드) `cherry-server/src/main/java/com/cherry/server/upload/UploadController.java`
- (코드) `cherry-server/src/main/java/com/cherry/server/upload/ImageCallbackController.java`

**Step 1: presign 발급**
- 호출: `POST https://api.cheryi.com/api/upload/images`
- Body 예시:
  - `{"files":[{"fileName":"a.jpg","contentType":"image/jpeg","size":12345}]}`
- 기대: `items[0].imageKey`, `items[0].uploadUrl`, `items[0].requiredHeaders.Content-Type`

**Step 2: S3 원본 업로드**
- `PUT <uploadUrl>`
- 헤더: `Content-Type: <requiredHeaders.Content-Type>`

**Step 3: Lambda 리사이즈 확인**
- `products/detail/`, `products/thumb/`에 객체 생성 확인

**Step 4: 콜백 및 DB 반영 확인**
- 서버 로그에서 `/internal/images/complete` 204 확인
- DB에서 `product_images`의 `image_url`, `thumbnail_url`, `image_order`, `is_thumbnail` 업데이트 확인

