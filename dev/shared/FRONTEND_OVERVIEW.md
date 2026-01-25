# Frontend Overview (cherry-client)

이 문서는 외부 리뷰/온보딩을 위한 “프론트엔드 코드 구조/흐름 요약”입니다.

## 기술 스택 (레포 기준)

- React 19 + Vite 6 (`cherry-client/package.json`)
- React Router DOM (`react-router-dom`)
- Zustand(+persist)로 인증 상태 유지 (`features/auth/model/authStore.ts`)
- Tailwind CSS (`tailwind.config.js`)

## 엔트리포인트 / 라우팅

- 앱 진입: `cherry-client/index.tsx`
  - `BrowserRouter`로 전체 라우팅 감싸고 `App` 렌더
- 라우트 정의: `cherry-client/app/App.tsx`
  - `ROUTES`: `cherry-client/shared/constants/routes.ts`
  - 인증 필요 페이지는 `AuthGuard`로 보호 (`features/auth/components/AuthGuard.tsx`)

## 폴더 구조(큰 단위)

- `app/`: 라우팅 엔트리
- `features/`: 도메인별 기능(페이지/컴포넌트/훅 등)
  - 예: `home`, `product`, `category`, `wish`, `auth`
- `shared/`: 공통 유틸/서비스/상수/UI
  - `shared/services/api.ts`: fetch 기반 API 클라이언트
  - `shared/services/authApi.ts`: `/auth/*`, `/me` 호출 래퍼

## API 연동 방식

- API Base URL:
  - `VITE_API_BASE_URL`가 있으면 사용
  - 없으면 로컬 기본값 `http://localhost:8080` (`shared/services/api.ts`)
- 인증 호출:
  - 토큰은 `zustand/persist`로 저장 (`features/auth/model/authStore.ts`)
  - 인증 필요한 요청은 `api.authenticatedGet/post/delete`로 `Authorization: Bearer <token>` 사용

## 주요 화면 진입점(예시)

- 홈: `features/home/pages/Home.tsx`
  - URL query params로 필터 상태를 동기화하고(`useSearchParams`), 리스트를 무한 스크롤로 로드
- 상세: `features/product/pages/ProductDetailWrapper.tsx`
- 찜 목록: `features/wish/ui/MyPickPage.tsx`
