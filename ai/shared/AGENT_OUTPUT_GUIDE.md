# AI 에이전트 산출물 가이드 (Docs 구조/Phase 기준)

이 문서는 AI 에이전트가 Cherry 작업 중 생성하는 문서/산출물을 `docs/`에 **타입 기준 + phase 기준**으로 일관되게 추가하기 위한 규칙입니다.

## 0) 기본 원칙 (필수)

- 새 산출물은 반드시 `docs/` 아래에 저장한다.
- 저장 후 `docs/INDEX.md`에 링크를 추가한다. (문서의 시작점)
- 파일 인코딩은 UTF-8을 기본으로 한다.
- 링크는 가능한 한 **상대경로**를 사용한다. (공백이 있는 파일명 링크는 `%20` 인코딩)

## 1) 어디에 저장할까? (결정 트리)

1. 산출물 타입을 먼저 고른다: `product | architecture | api | dev | reports | ai | assets`
2. 변경이 속한 타임라인을 고른다: `mvp | phase-2 | phase-3 | phase-4 | shared`
3. 해당 폴더에 저장한다:

```
docs/<type>/<phase>/
```

## 2) 타입별 저장 위치 가이드

| 타입            | 목적                                                    | 예시 저장 위치                           |
| --------------- | ------------------------------------------------------- | ---------------------------------------- |
| `product/`      | 기획/요구사항/RFP/화면정의                              | `docs/product/mvp/`                      |
| `architecture/` | 운영/배포 아키텍처, 다이어그램(Mermaid), 아키텍처 플랜  | `docs/architecture/mvp/`                 |
| `api/`          | API 스펙/계약, 연동 설정/환경변수                       | `docs/api/mvp/`                          |
| `dev/`          | 구현 노트, 설계/기술 결정 기록(ADR 성격), SQL/DB 가이드 | `docs/dev/phase-3/`, `docs/dev/mvp/sql/` |
| `reports/`      | 작업지시서, 회고, 성능 보고서, 완료 보고                | `docs/reports/phase-2/`                  |
| `ai/`           | AI 프롬프트, 규칙, 작업 방식 가이드, 템플릿             | `docs/ai/shared/`                        |
| `assets/`       | 이미지/스크린샷/다이어그램 파일                         | `docs/assets/<phase>/<topic>/`           |

## 3) 네이밍 규칙 (권장)

- “기획/정의서”: 기존 파일명 유지 또는 의미 기반 명명 (`MVP_Definition.md` 등)
- “플랜/설계”: 날짜 + 주제
  - 예: `YYYY-MM-DD-<topic>-design.md`
- “리포트”: 날짜 + 범위(또는 phase) + 주제
  - 예: `YYYY-MM-DD-phase-4-performance-report.md`
- “에셋”: 날짜 + 주제 + 출처(선택)
  - 예: `2026-01-24-alb-flow.png`

## 4) 산출물 추가 체크리스트 (필수)

1. 파일을 올바른 위치에 생성했는가? (`docs/<type>/<phase>/...`)
2. `docs/INDEX.md`에 링크를 추가했는가?
3. 파일명/링크에 공백이 있다면 `%20` 인코딩이 되어 있는가?
4. 기존 문서에서 옮긴/바꾼 경로가 있다면 참조 링크도 업데이트했는가?

## 5) `docs/INDEX.md` 링크 검증 (PowerShell)

`docs/INDEX.md` 안의 Markdown 링크 중, 로컬 파일 경로가 실제로 존재하는지 빠르게 확인합니다.

```powershell
$path = '.\\docs\\INDEX.md'
$text = [System.IO.File]::ReadAllText($path, (New-Object System.Text.UTF8Encoding($false)))
$links = [regex]::Matches($text, '\\[[^\\]]+\\]\\(([^)]+)\\)') | ForEach-Object { $_.Groups[1].Value }
$links | Where-Object { $_ -notmatch '^(https?:|mailto:)' } | Select-Object -Unique | ForEach-Object {
  $decoded = $_.Replace('%20',' ')
  $fs = Join-Path (Split-Path -Parent $path) $decoded
  if(!(Test-Path -LiteralPath $fs)){ \"MISSING: $_ -> $fs\" }
}
```
