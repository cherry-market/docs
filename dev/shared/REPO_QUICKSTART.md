# Repo Quickstart
이 문서는 리뷰어/협업자가 Cherry를 빠르게 이해할 수 있도록, 레포 구조와 “어디부터 보면 좋은지”를 요약합니다.

## 레포 구성 (GitHub Organization)

- Backend: https://github.com/cherry-market/cherry-server
- Frontend: https://github.com/cherry-market/cherry-client
- Docs: https://github.com/cherry-market/docs
- Ops: https://github.com/cherry-market/ops

## 문서 시작점

- 문서 목차: `docs/INDEX.md`
- API 문서(MVP)
  - 스펙: `docs/api/mvp/API_Specification.md`
  - 환경설정: `docs/api/mvp/API_CONFIGURATION.md`
- 운영 아키텍처(MVP): `docs/architecture/mvp/ARCHITECTURE.md`

## 로컬 실행 요약

### Backend (cherry-server)

```powershell
cd .\cherry-server
$env:SPRING_PROFILES_ACTIVE="local"
$env:DB_PASSWORD="..."
.\gradlew.bat bootRun
```

- 기본 포트: `http://localhost:8080` (`cherry-server/src/main/resources/application.yml`)

### Frontend (cherry-client)

```powershell
cd .\cherry-client
npm install
Copy-Item .\.env.example .\.env.local
npm run dev
```

- 기본 접속: `http://localhost:3000` (`cherry-client/vite.config.ts`)
- API Base URL: `VITE_API_BASE_URL` (`cherry-client/shared/services/api.ts`)

## 어디부터 코드를 보면 좋나 (읽기 순서)

### Backend

1. 엔트리포인트: `cherry-server/src/main/java/com/cherry/server/CherryServerApplication.java`
2. 인증/보안:
   - `cherry-server/src/main/java/com/cherry/server/security/SecurityConfig.java`
   - `cherry-server/src/main/java/com/cherry/server/security/JwtAuthenticationFilter.java`
   - `cherry-server/src/main/java/com/cherry/server/auth/controller/AuthController.java`
3. 핵심 API:
   - `cherry-server/src/main/java/com/cherry/server/product/controller/ProductController.java`
   - `cherry-server/src/main/java/com/cherry/server/product/controller/CategoryController.java`
   - `cherry-server/src/main/java/com/cherry/server/wish/controller/WishController.java`
   - `cherry-server/src/main/java/com/cherry/server/global/controller/HealthController.java`

### Frontend

1. 엔트리포인트/라우팅:
   - `cherry-client/index.tsx`
   - `cherry-client/app/App.tsx`
2. API 클라이언트/인증:
   - `cherry-client/shared/services/api.ts`
   - `cherry-client/shared/services/authApi.ts`
   - `cherry-client/features/auth/model/authStore.ts`
   - `cherry-client/features/auth/components/AuthGuard.tsx`
3. 주요 화면:
   - `cherry-client/features/home/pages/Home.tsx`
