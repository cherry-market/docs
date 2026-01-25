# 문서 목차 (INDEX)

이 문서는 Cherry `docs/` 산출물을 **타입 기준**으로 정리한 목차입니다. 각 섹션은 `mvp/`, `phase-2/` 같은 **타임라인 폴더**로 구분되어 있습니다.

## 기획 (Product)

- [MVP 정의](product/mvp/0_MVP_Definition.md)
- [기능 정의](product/mvp/1_Functional_Definition.md)
- [화면 정의(모바일 웹뷰)](product/mvp/2_Screen_Definition.md)
- [RFP (탐색/필터/상세)](product/mvp/RFP_01_Product_Search_Filter_Detail.md)
- [RFP (백엔드 서버/피드/트렌딩)](product/mvp/RFP_03_Backend_Server.md)
- [RFP (Phase 2 - 모바일 웹뷰 화면단 구현)](product/phase-2/RFP_02_모바일%20웹뷰%20화면단%20구현.md)

## 시스템 아키텍처 (Architecture)

- [운영/배포 사실 기반 아키텍처](architecture/mvp/ARCHITECTURE.md)
- Mermaid 아티팩트
  - [목차](architecture/mvp/mermaid/README.md)
  - [Use Cases](architecture/mvp/mermaid/use-cases.md)
  - [ERD](architecture/mvp/mermaid/erd.md)
  - [CI/CD + Runtime](architecture/mvp/mermaid/cicd.md)
- [아키텍처 아티팩트 구현 플랜](architecture/mvp/plans/2026-01-24-architecture-artifacts.md)

## API / 연동 (API)

- [API 스펙(v0.1 MVP)](api/mvp/API_Specification.md)
- [API 환경설정 가이드](api/mvp/API_CONFIGURATION.md)

> 참고: 실제 서버 구현은 `GET /products` 필터/정렬, `GET /categories` 등을 포함합니다. (근거: `cherry-server/src/main/java/com/cherry/server/product/controller/ProductController.java`, `cherry-server/src/main/java/com/cherry/server/product/controller/CategoryController.java`)

## 개발 노트 (Dev)

- [Repo Quickstart](dev/shared/REPO_QUICKSTART.md)
- [Backend Overview](dev/shared/BACKEND_OVERVIEW.md)
- [Frontend Overview](dev/shared/FRONTEND_OVERVIEW.md)

- [상품 이미지/태그 엔티티 설계](dev/mvp/plans/2026-01-23-product-image-tag-entity-design.md)
- [Local MySQL 시드 구현 플랜](dev/mvp/plans/2026-01-24-seed-local-mysql-data.md)
- [로컬 MySQL 시드 데이터 넣기](dev/mvp/database/seed-local-mysql.md)
- SQL
  - [DDL](dev/mvp/sql/ddl_product_image_tag.sql)
  - [Mock data script](dev/mvp/sql/mock_data_script.sql)
  - [테스트 세팅](dev/mvp/sql/test_product_setting_mock.sql)
- [Phase 2~4 Mock Data Guide](dev/phase-2/PHASE_2_4_Mock_Data_Guide.md)
- [Phase 3 Filters Design](dev/phase-3/plans/2026-01-23-phase-3-filters-design.md)
- [Phase 4 Product List Caching Design](dev/phase-4/plans/2026-01-24-product-list-caching-design.md)
- [조회수 증가/Redis 트렌딩 메커니즘 설명](dev/phase-4/조회수_증가_Redis.md)

## 리포트 / 작업 로그 (Reports)

- [작업 TODO(Phase 1~4)](reports/shared/TODO.md)
- [Phase 2 작업 지시서(픽/찜)](reports/phase-2/PHASE_2_WORK_ORDER.md)
- [픽(찜) 기능 분석/리뷰](reports/phase-2/Pick_Review.md)
- [Phase 2 작업완료 보고](reports/phase-2/RFP_02_작업완료보고.md)
- [성능 개선 보고서(캐싱)](reports/phase-4/performance_improvement.md)
- [AI 활용 기록](reports/mvp/how-i-used-ai.md)

## AI (Prompts / Rules)

- [AI 에이전트 산출물 가이드](ai/shared/AGENT_OUTPUT_GUIDE.md)

- 목업 이미지 생성 가이드
  - [ALBUM](ai/mvp/image-generation/ALBUM.md)
  - [PHOTOCARD](ai/mvp/image-generation/PHOTOCARD.md)
  - [LIGHTSTICK](ai/mvp/image-generation/LIGHTSTICK.md)
  - [FASHION_GOODS](ai/mvp/image-generation/FASHION_GOODS.md)
  - [DOLL_KEYRING](ai/mvp/image-generation/DOLL_KEYRING.md)

## 에셋 (Assets)

- ALB Flow 이미지 (mvp)
  - [ALB Flow 1](assets/mvp/architecture/Cheryi%20api%20ALB%20Flow-2026-01-24-095901.png)
  - [ALB Flow 2](assets/mvp/architecture/Cheryi%20api%20ALB%20Flow-2026-01-24-100041.png)
  - [ALB Flow 3](assets/mvp/architecture/Cheryi%20api%20ALB%20Flow-2026-01-24-100056.png)
- `wrk` 캡처 이미지 (phase-4)
  - [wrk 5](assets/phase-4/performance/wrk_부하테스트_02_히카리풀_5.png)
  - [wrk 10](assets/phase-4/performance/wrk_부하테스트_03_히카리풀_10.png)
