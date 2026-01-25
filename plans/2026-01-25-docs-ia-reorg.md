# Docs IA Reorganization Plan

> **For Codex:** REQUIRED SUB-SKILL: Use `executing-plans` to implement this plan task-by-task.

**Goal:** Reorganize `docs/` into a review-friendly, type-based structure with per-phase subfolders, while keeping links/references consistent.

**Architecture:** Create new top-level buckets (`product/`, `architecture/`, `api/`, `dev/`, `ai/`, `reports/`, `assets/`) and move existing documents into `mvp/`, `phase-2/`, `phase-3/`, `phase-4/`, or `shared/` subfolders. Update `docs/INDEX.md` (and any other docs) to point to the new paths.

**Tech Stack:** Markdown docs, PowerShell filesystem moves, ripgrep for reference updates.

---

## Target Information Architecture (IA)

```
docs/
  INDEX.md
  api/{mvp,phase-2,phase-3,phase-4,shared}/
  product/{mvp,phase-2,phase-3,phase-4,shared}/
  architecture/{mvp,phase-2,phase-3,phase-4,shared}/
  dev/{mvp,phase-2,phase-3,phase-4,shared}/
  ai/{mvp,phase-2,phase-3,phase-4,shared}/
  reports/{mvp,phase-2,phase-3,phase-4,shared}/
  assets/{mvp,phase-2,phase-3,phase-4,shared}/
```

---

### Task 1: Create folders (idempotent)

**Files:**
- Create directories under:
  - `docs/api/`
  - `docs/product/`
  - `docs/architecture/`
  - `docs/dev/`
  - `docs/ai/`
  - `docs/reports/`
  - `docs/assets/`

**Step 1: Create directories**

Run:
```powershell
$cats = @("api","product","architecture","dev","ai","reports","assets")
$phases = @("mvp","phase-2","phase-3","phase-4","shared")
foreach($c in $cats){ foreach($p in $phases){ New-Item -ItemType Directory -Force -Path (Join-Path ".\\docs" "$c\\$p") | Out-Null } }
New-Item -ItemType Directory -Force -Path ".\\docs\\assets\\mvp\\architecture" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\assets\\phase-4\\performance" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\ai\\mvp\\image-generation" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\dev\\mvp\\plans" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\dev\\mvp\\database" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\dev\\mvp\\sql" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\dev\\phase-3\\plans" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\dev\\phase-4\\plans" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\architecture\\mvp\\mermaid" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\architecture\\mvp\\plans" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\reports\\phase-2" | Out-Null
New-Item -ItemType Directory -Force -Path ".\\docs\\reports\\phase-4" | Out-Null
```

---

### Task 2: Move files into the new IA

**Files (moves):**
- API
  - `docs/API_CONFIGURATION.md` → `docs/api/mvp/API_CONFIGURATION.md`
  - `docs/API_Specification.md` → `docs/api/mvp/API_Specification.md`
- Product (requirements)
  - `docs/working/0_MVP_Definition.md` → `docs/product/mvp/0_MVP_Definition.md`
  - `docs/working/1_Functional_Definition.md` → `docs/product/mvp/1_Functional_Definition.md`
  - `docs/working/2_Screen_Definition.md` → `docs/product/mvp/2_Screen_Definition.md`
  - `docs/working/RFP_01_Product_Search_Filter_Detail.md` → `docs/product/mvp/RFP_01_Product_Search_Filter_Detail.md`
  - `docs/working/RFP_03_Backend_Server.md` → `docs/product/mvp/RFP_03_Backend_Server.md`
  - `docs/working/RFP_02_모바일 웹뷰 화면단 구현.md` → `docs/product/phase-2/RFP_02_모바일 웹뷰 화면단 구현.md`
- Architecture
  - `docs/ai-prompt/rules/ARCHITECTURE.md` → `docs/architecture/mvp/ARCHITECTURE.md`
  - `docs/architecture/README.md` → `docs/architecture/mvp/mermaid/README.md`
  - `docs/architecture/use-cases.md` → `docs/architecture/mvp/mermaid/use-cases.md`
  - `docs/architecture/erd.md` → `docs/architecture/mvp/mermaid/erd.md`
  - `docs/architecture/cicd.md` → `docs/architecture/mvp/mermaid/cicd.md`
  - `docs/plans/2026-01-24-architecture-artifacts.md` → `docs/architecture/mvp/plans/2026-01-24-architecture-artifacts.md`
- Dev (engineering notes)
  - `docs/PHASE_2_4_Mock_Data_Guide.md` → `docs/dev/phase-2/PHASE_2_4_Mock_Data_Guide.md`
  - `docs/working/조회수_증가_Redis.md` → `docs/dev/phase-4/조회수_증가_Redis.md`
  - `docs/plans/2026-01-23-product-image-tag-entity-design.md` → `docs/dev/mvp/plans/2026-01-23-product-image-tag-entity-design.md`
  - `docs/plans/2026-01-24-seed-local-mysql-data.md` → `docs/dev/mvp/plans/2026-01-24-seed-local-mysql-data.md`
  - `docs/plans/seed-local-mysql.md` → `docs/dev/mvp/database/seed-local-mysql.md`
  - `docs/sql/ddl_product_image_tag.sql` → `docs/dev/mvp/sql/ddl_product_image_tag.sql`
  - `docs/sql/mock_data_script.sql` → `docs/dev/mvp/sql/mock_data_script.sql`
  - `docs/sql/test_product_setting_mock.sql` → `docs/dev/mvp/sql/test_product_setting_mock.sql`
  - `docs/plans/2026-01-23-phase-3-filters-design.md` → `docs/dev/phase-3/plans/2026-01-23-phase-3-filters-design.md`
  - `docs/plans/2026-01-24-product-list-caching-design.md` → `docs/dev/phase-4/plans/2026-01-24-product-list-caching-design.md`
- AI (prompts/rules)
  - `docs/ai-prompt/img/ALBUM.md` → `docs/ai/mvp/image-generation/ALBUM.md`
  - `docs/ai-prompt/img/PHOTOCARD.md` → `docs/ai/mvp/image-generation/PHOTOCARD.md`
  - `docs/ai-prompt/img/LIGHTSTICK.md` → `docs/ai/mvp/image-generation/LIGHTSTICK.md`
  - `docs/ai-prompt/img/FASHION_GOODS.md` → `docs/ai/mvp/image-generation/FASHION_GOODS.md`
  - `docs/ai-prompt/img/DOLL_KEYRING.md` → `docs/ai/mvp/image-generation/DOLL_KEYRING.md`
- Reports (work logs / portfolio)
  - `docs/TODO.md` → `docs/reports/shared/TODO.md`
  - `docs/PHASE_2_WORK_ORDER.md` → `docs/reports/phase-2/PHASE_2_WORK_ORDER.md`
  - `docs/Pick_Review.md` → `docs/reports/phase-2/Pick_Review.md`
  - `docs/working/RFP_02_작업완료보고.md` → `docs/reports/phase-2/RFP_02_작업완료보고.md`
  - `docs/performance_improvement.md` → `docs/reports/phase-4/performance_improvement.md`
- Assets
  - `docs/Cheryi api ALB Flow-2026-01-24-095901.png` → `docs/assets/mvp/architecture/Cheryi api ALB Flow-2026-01-24-095901.png`
  - `docs/Cheryi api ALB Flow-2026-01-24-100041.png` → `docs/assets/mvp/architecture/Cheryi api ALB Flow-2026-01-24-100041.png`
  - `docs/Cheryi api ALB Flow-2026-01-24-100056.png` → `docs/assets/mvp/architecture/Cheryi api ALB Flow-2026-01-24-100056.png`
  - `docs/wrk_부하테스트_02_히카리풀_5.png` → `docs/assets/phase-4/performance/wrk_부하테스트_02_히카리풀_5.png`
  - `docs/wrk_부하테스트_03_히카리풀_10.png` → `docs/assets/phase-4/performance/wrk_부하테스트_03_히카리풀_10.png`

**Step 1: Move the files**
- Use filesystem moves (or patch-based renames) so the history is preserved where possible.

---

### Task 3: Update `docs/INDEX.md` to match the new IA

**Files:**
- Modify: `docs/INDEX.md`

**Step 1: Replace old paths with the new structure**
- Convert the index to use relative, clickable Markdown links where possible.
- Ensure each section aligns with the top-level buckets (product/architecture/api/dev/ai/reports/assets).

---

### Task 4: Update references across the repo

**Files:**
- Modify any Markdown docs referencing moved paths (examples):
  - `README.md`
  - `docs/reports/phase-2/PHASE_2_WORK_ORDER.md`

**Step 1: Search references**

Run:
```powershell
rg -n "docs/(working|sql|plans|architecture)|docs/API_|docs/TODO\\.md|docs/Pick_Review\\.md|docs/performance_improvement\\.md|docs/wrk_|docs/Cheryi api ALB Flow" -S
```

**Step 2: Update strings to new paths**

---

### Task 5: Verify and cleanup

**Step 1: Verify moved files exist**

Run:
```powershell
Get-ChildItem .\\docs -Recurse -File | Measure-Object
```

**Step 2: Check for leftover “old” file locations**

Run:
```powershell
@(
  ".\\docs\\working",
  ".\\docs\\sql",
  ".\\docs\\ai-prompt",
  ".\\docs\\architecture\\cicd.md",
  ".\\docs\\API_CONFIGURATION.md",
  ".\\docs\\API_Specification.md"
) | ForEach-Object { \"$_ => $(Test-Path $_)\" }
```

