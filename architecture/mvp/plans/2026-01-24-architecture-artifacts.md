# Architecture Artifacts Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Provide Markdown + Mermaid artifacts for Use Case, ERD, and CI/CD diagrams that match the current Cherry scope, including frontend deployment flow and the media S3 bucket.

**Architecture:** Summarize current backend features and infrastructure based on existing code and `docs/architecture/mvp/ARCHITECTURE.md`. Publish three Mermaid diagrams under `docs/architecture/mvp/mermaid/`. Keep scope to implemented features only (auth, products, likes, tags, categories, images, trending) and current AWS deployment.

**Tech Stack:** Spring Boot, MySQL, Redis, GitHub Actions, Docker, GHCR, AWS (EC2, RDS, ALB, Route53, CloudFront, S3).

---

### Task 1: Create Use Case diagram

**Files:**
- Create: `docs/architecture/mvp/mermaid/use-cases.md`

**Step 1: Write the diagram file**

```markdown
# Use Case Diagram (Backend Scope)

```mermaid
flowchart LR
  Guest((Guest))
  Member((Member))

  Guest --> Browse[상품 목록 조회/필터/정렬]
  Guest --> View[상품 상세 조회]
  Guest --> Trending[트렌딩 조회]
  Guest --> Signup[회원가입]
  Guest --> Login[로그인]

  Member --> Browse
  Member --> View
  Member --> Trending
  Member --> Me[내 정보 조회]
  Member --> Like[찜 추가/취소]
  Member --> LikeStatus[찜 여부 조회]
  Member --> LikesList[내 찜 목록 조회]
```
```

**Step 2: Visual check**

Open `docs/architecture/mvp/mermaid/use-cases.md` in GitHub or Markdown preview and confirm the Mermaid diagram renders.

**Step 3: Commit**

```bash
git add docs/architecture/mvp/mermaid/use-cases.md
git commit -m "docs: add use case diagram"
```

---

### Task 2: Create ERD diagram

**Files:**
- Create: `docs/architecture/mvp/mermaid/erd.md`

**Step 1: Write the diagram file**

```markdown
# ERD

```mermaid
erDiagram
  USERS ||--o{ PRODUCTS : sells
  CATEGORIES ||--o{ PRODUCTS : categorizes
  PRODUCTS ||--o{ PRODUCT_IMAGES : has
  PRODUCTS ||--o{ PRODUCT_TAGS : tagged
  TAGS ||--o{ PRODUCT_TAGS : tags
  USERS ||--o{ PRODUCT_LIKES : likes
  PRODUCTS ||--o{ PRODUCT_LIKES : liked_by

  USERS {
    bigint id PK
    varchar email
    varchar nickname
    varchar password
    varchar profile_image_url
    datetime created_at
    datetime updated_at
  }

  CATEGORIES {
    bigint id PK
    varchar code
    varchar display_name
    boolean is_active
    int sort_order
    datetime created_at
    datetime updated_at
  }

  PRODUCTS {
    bigint id PK
    bigint seller_user_id FK
    varchar title
    text description
    int price
    varchar status
    varchar trade_type
    bigint category_id FK
    datetime created_at
    datetime updated_at
  }

  PRODUCT_IMAGES {
    bigint id PK
    bigint product_id FK
    varchar image_url
    int image_order
    boolean is_thumbnail
    datetime created_at
    datetime updated_at
  }

  TAGS {
    bigint id PK
    varchar name
    datetime created_at
    datetime updated_at
  }

  PRODUCT_TAGS {
    bigint id PK
    bigint product_id FK
    bigint tag_id FK
    datetime created_at
    datetime updated_at
  }

  PRODUCT_LIKES {
    bigint id PK
    bigint user_id FK
    bigint product_id FK
    datetime created_at
    datetime updated_at
  }
```
```

**Step 2: Visual check**

Open `docs/architecture/mvp/mermaid/erd.md` in GitHub or Markdown preview and confirm the Mermaid diagram renders.

**Step 3: Commit**

```bash
git add docs/architecture/mvp/mermaid/erd.md
git commit -m "docs: add erd diagram"
```

---

### Task 3: Create CI/CD & Runtime diagram (FE + BE)

**Files:**
- Create: `docs/architecture/mvp/mermaid/cicd.md`

**Step 1: Write the diagram file**

```markdown
# CI/CD & Runtime Architecture (Frontend + Backend)

```mermaid
flowchart LR
    subgraph CI_CD [GitHub Actions]
        GHA_FE[FE Build & S3 Upload]
        GHA_BE[BE Docker Build & Deploy]
    end

    subgraph User_Interaction [User]
        User((User))
    end

    subgraph AWS_Global [AWS Cloud - Global]
        Route53[Route 53]
        CloudFront[Amazon CloudFront]
        S3Static[(Amazon S3 - Static)]
        S3Media[(Amazon S3 - Product Images)]
    end

    subgraph AWS_Region [AWS Cloud - ap-northeast-2]
        subgraph VPC [VPC]
            subgraph ALB [ALB: cheryi-api-alb]
                L80[Listener: HTTP 80]
                L443[Listener: HTTPS 443\nACM: *.cheryi.com]
            end

            subgraph Target_Group [Target Group: cheryi-api-tg]
                EC2[EC2 Instance\nDocker App: 8080\nHealth Check: /health]
            end

            RDS[(Amazon RDS - MySQL)]
            Redis[(Redis)]
        end
    end

    %% CI/CD Flow
    GHA_FE --> S3Static
    GHA_BE --> EC2

    %% Frontend Flow
    User -- "HTTPS 443\nhttps://cheryi.com" --> CloudFront
    CloudFront -- "Origin Access" --> S3Static

    %% Backend Flow
    User -- "https://api.cheryi.com" --> Route53
    Route53 -- "HTTPS 443" --> L443
    User -- "HTTP 80" --> L80
    L80 -- "301 Redirect" --> L443
    L443 -- "Forward (HTTP 8080)" --> EC2
    EC2 -- "JDBC 3306" --> RDS
    EC2 -- "TCP 6379" --> Redis

    %% Media Flow
    User -- "Image GET" --> S3Media
```
```

**Step 2: Visual check**

Open `docs/architecture/mvp/mermaid/cicd.md` in GitHub or Markdown preview and confirm the Mermaid diagram renders.

**Step 3: Commit**

```bash
git add docs/architecture/mvp/mermaid/cicd.md
git commit -m "docs: add cicd runtime diagram"
```

---

### Task 4: Create index README

**Files:**
- Create: `docs/architecture/mvp/mermaid/README.md`

**Step 1: Write the index file**

```markdown
# Architecture Artifacts

- Use Case: `docs/architecture/mvp/mermaid/use-cases.md`
- ERD: `docs/architecture/mvp/mermaid/erd.md`
- CI/CD & Runtime: `docs/architecture/mvp/mermaid/cicd.md`
```

**Step 2: Commit**

```bash
git add docs/architecture/mvp/mermaid/README.md
git commit -m "docs: add architecture artifacts index"
```

---

Plan complete and saved to `docs/architecture/mvp/plans/2026-01-24-architecture-artifacts.md`.

Two execution options:
1) Subagent-Driven (this session) – requires superpowers:subagent-driven-development  
2) Parallel Session (separate) – use superpowers:executing-plans

Which approach do you want?
