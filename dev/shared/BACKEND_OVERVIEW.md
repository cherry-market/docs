# Backend Overview (cherry-server)

이 문서는 외부 리뷰/온보딩을 위한 “백엔드 코드 구조/흐름 요약”입니다. (상세 API 계약은 `docs/api/mvp/API_Specification.md` 참고)

## 기술 스택 (레포 기준)

- Java 21 + Spring Boot 3.4 (`cherry-server/build.gradle`)
- Spring Web / Validation / Security / Data JPA / Data Redis
- MySQL(runtime), H2(test)
- JWT (`io.jsonwebtoken:jjwt-*`)

## 패키지 구조 (상위)

`cherry-server/src/main/java/com/cherry/server/`

- `auth/`: 회원가입/로그인
- `security/`: JWT 필터/인증 주입, Spring Security 설정
- `product/`: 상품/카테고리/태그/이미지, 리스트 조회/상세/트렌딩
- `wish/`: 찜(좋아요) 기능
- `user/`: 내 정보 조회 등
- `ai/`: AI 상품 설명 생성 (Gemini API)
- `upload/`: 이미지 업로드 (Presigned URL, S3)
- `config/`: CORS 프로파일별 설정
- `global/`: 헬스체크 등 공통 엔드포인트

## 요청 처리 흐름 (요약)

1. `SecurityConfig`에서 CORS/CSRF/세션/인가 규칙 설정
2. `JwtAuthenticationFilter`가 `Authorization: Bearer <token>`을 파싱해 `UserPrincipal`을 SecurityContext에 주입
3. Controller에서 `@AuthenticationPrincipal UserPrincipal`을 통해 사용자 식별자 사용(익명 허용 엔드포인트는 `null` 가능)

## 주요 엔드포인트 (MVP 기준)

- Auth
  - `POST /auth/signup`, `POST /auth/login` (`auth/controller/AuthController.java`)
- Products
  - `GET /products` (cursor pagination + 필터/정렬) (`product/controller/ProductController.java`)
  - `GET /products/{productId}` (상세 + 트렌딩 조회수 증가) (`product/controller/ProductController.java`)
  - `GET /products/trending` (Redis ZSET 기반) (`product/controller/ProductController.java`)
  - `POST /products/{productId}/views` (옵션: 상세 조회 로직 재사용) (`product/controller/ProductController.java`)
  - `GET /products/my` (내 판매 상품, PENDING 포함, 인증 필수) (`product/controller/ProductController.java`)
- AI
  - `POST /api/ai/generate-description` (Gemini API 기반 판매글 생성) (`ai/AiController.java`)
- Upload
  - `POST /api/upload/images` (Presigned URL 발급) (`upload/controller/UploadController.java`)
  - `POST /internal/images/complete` (Lambda 콜백) (`upload/controller/ImageCallbackController.java`)
- Categories
  - `GET /categories` (`product/controller/CategoryController.java`)
- Likes (Pick)
  - `POST /products/{productId}/like`, `DELETE /products/{productId}/like` (`wish/controller/WishController.java`)
  - `GET /products/{productId}/like-status`, `GET /me/likes` (`wish/controller/WishController.java`)
- Health
  - `GET /health` (`global/controller/HealthController.java`)

## 캐시/Redis 사용 (요약)

- 트렌딩: ZSET 키 `trending:views:24h`, TTL 24h (`product/repository/RedisProductTrendingRepository.java`)
- 리스트 캐시: `products:list:*`, TTL 300s (`product/service/ProductService.java`)
- 내 찜 목록 캐시: `likes:list:*`, TTL 300s (`wish/service/WishService.java`)
- 무효화:
  - 찜 추가/삭제 시 `likes:list` 및 `products:list` 패턴 삭제 (`wish/service/WishService.java`)

## 환경/프로파일

- 기본 포트: `8080` (`cherry-server/src/main/resources/application.yml`)
- CORS:
  - `local`/`dev`: `*` 허용 (`config/CorsLocalDevConfig.java`)
  - `prod`: `https://cheryi.com` 허용 (`config/CorsProdConfig.java`)
