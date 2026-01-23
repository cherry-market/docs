# Phase 3 Filters Design

**Goal:** Add backend-driven filtering and sorting (LATEST/LOW_PRICE/HIGH_PRICE), expose active categories, return category/tags in product responses, and update the UI to consume these changes while removing POPULAR sorting.

**Scope:** Phase 3 items 3.2 to 3.5, executed in 3.n order with QA after each sub-phase.

## API Changes

- Add `GET /categories`
  - Returns active categories only (`is_active = true`)
  - Sorted by `sort_order` ascending
  - Response fields: `code`, `displayName`
- Extend `GET /products` query params
  - `status`: SELLING | RESERVED | SOLD
  - `categoryCode`: category code string (not id)
  - `minPrice`, `maxPrice`
  - `tradeType`: DIRECT | DELIVERY | BOTH
  - `sortBy`: LATEST | LOW_PRICE | HIGH_PRICE
- Keep `GET /products/trending` as-is for "trending now"

## Backend Design

- Add request DTO for product list filters and cursor parsing.
- Implement dynamic query using Spring Data JPA Specification:
  - AND-combine status, categoryCode (join Category), min/max price, tradeType.
  - Sorting:
    - LATEST: `createdAt DESC, id DESC`
    - LOW_PRICE: `price ASC, id DESC`
    - HIGH_PRICE: `price DESC, id DESC`
  - Cursor format: `<sortValue>_<id>`
    - LATEST: `createdAt` as sortValue (ISO-8601)
    - LOW_PRICE/HIGH_PRICE: `price` as sortValue
  - Cursor predicates by sort direction to ensure stable pagination.
- Update product DTOs:
  - `ProductSummaryResponse`: add `categoryCode`, `categoryName`
  - `ProductDetailResponse`: add `categoryCode`, `categoryName`, `tags`
  - Tags are mapped from `ProductTag -> Tag.name`
- Add `CategoryController`, `CategoryService`, DTOs, and repository query for active categories.

## Frontend Design

- Add `shared/services/categoryApi.ts` and `features/category/hooks/useCategories.ts`.
- Replace hardcoded `CATEGORIES` usage with API-provided categories.
  - Keep local "ALL/전체" option.
  - Use `categoryCode` for filter values; display `categoryName`.
- Update `productApi.getProducts` to accept filter params and `sortBy`.
- Update `useProducts` to accept filter state, reset cursor and list on filter change.
- Remove client-side filtering logic from `Home.tsx`.
- Remove POPULAR from filter UI, constants, and types.
- Add relative time formatter for `uploadedTime` mapping (no JSX logic).
- Use backend `categoryName` and `tags` in list and detail UI.

## Error Handling and Validation

- Validate `minPrice <= maxPrice` in service layer; reject invalid ranges.
- Ignore invalid cursor format and treat as first page.
- Map unknown `categoryCode` to empty result set.

## Testing

- Backend:
  - Specification unit tests for each filter dimension.
  - Cursor pagination tests per sortBy (latest/price asc/desc).
  - Category API test for active-only and sort order.
- Frontend:
  - Hook tests for filter changes resetting cursor.
  - UI smoke checks: category list, filters without POPULAR, tag display, relative time.

## Phased Delivery (3.n Order)

- 3.2: Extend API params and DTOs, update `productApi` usage.
- 3.3: Implement repository Specification + cursor pagination.
- 3.4: Category API + product responses include category.
- 3.5: UI updates for tags, relative time, category sources.

## Out of Scope

- POPULAR sorting in product list.
- Search beyond current title/tag/artist matching.
