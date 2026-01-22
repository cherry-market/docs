# Phase 2 Work Order: Pick (Wishlist) Feature

**Assigned To**: Codex (AI Agent)
**Priority**: High (Must complete for Portfolio)
**References**:
- `@[cherry-docs/TODO.md]`: Phase 2 Requirements
- `@[cherry-docs/ARCHITECTURE.md]`: Architecture Standard
- `@[AGENTS.md]`: Coding Standards & Conventions

---

## 1. Overview
Implement the "Pick" (Wishlist) functionality where logged-in users can like/unlike products.
This involves full-stack implementation from DB Schema to UI Components.

## 2. Backend Implementation (cherry-server)

**Target Package**: `com.cherry.server.wish` (New Package)

### 2.1 Domain Layer (`domain`)
- **Entity**: `ProductLike`
    - Fields:
        - `Long id` (PK, GeneratedValue)
        - `User user` (ManyToOne, fetch=LAZY, JoinColumn "user_id")
        - `Product product` (ManyToOne, fetch=LAZY, JoinColumn "product_id")
        - `LocalDateTime createdAt` (from `BaseTimeEntity`)
    - **Constraints**: Composite Unique Index on `(user_id, product_id)` to prevent duplicate likes.
    - **Methods**: `static ProductLike create(User user, Product product)`

### 2.2 Infrastructure Layer (`repository`)
- **Repository**: `ProductLikeRepository` (extends `JpaRepository`)
    - `boolean existsByUserAndProduct(User user, Product product)`
    - `void deleteByUserAndProduct(User user, Product product)`
    - `Page<ProductLike> findAllByUserId(Long userId, Pageable pageable)`

### 2.3 Application Layer (`service`)
- **Service**: `WishService`
    - `@Transactional` required.
    - `void addLike(Long userId, Long productId)`
        - Validate User and Product existence.
        - Check for duplicate like (if exists, ignore or throw friendly message).
    - `void removeLike(Long userId, Long productId)`
    - `Page<ProductSummaryResponse> getMyLikes(Long userId, Pageable pageable)`
        - Map `ProductLike` entities to `ProductSummaryResponse`. (Use `ProductMapper` if available or manual mapping).

### 2.4 Presentation Layer (`controller`)
- **Controller**: `WishController`
- **Endpoints**:
    - `POST /products/{productId}/like`: Requires Auth. Returns 200 OK or 201 Created.
    - `DELETE /products/{productId}/like`: Requires Auth. Returns 204 No Content.
    - `GET /products/{productId}/like-status`: (Optional) Returns `boolean isLiked`.
    - `GET /me/likes`: Returns `Page<ProductSummaryResponse>` (or custom Cursor response if consistent with Product List).

**Constraint Checklist**:
- [ ] Use `record` for DTOs.
- [ ] Strictly follow SOLID principles.
- [ ] Use `Result` or `ApiResponse` wrapper if project standard commands it.
- [ ] Write `WishApiTest` using `@WebMvcTest`.

---

## 3. Frontend Implementation (cherry)

**Target Directory**: `features/wish`

### 3.1 Business Logic
- **API**: `shared/services/wishApi.ts`
    - `addLike(productId: number): Promise<void>`
    - `removeLike(productId: number): Promise<void>`
    - `getMyLikes(page: number): Promise<PageResponse<ProductSummary>>`
- **Hook**: `features/wish/hooks/usePick.ts`
    - Logic: Optimistic Update. Update UI immediately, rollback if API fails.

### 3.2 UI Components
- **Component**: `PickButton.tsx` (`features/wish/ui/PickButton.tsx`)
    - Props: `productId: number`, `initialIsLiked: boolean`.
    - Design: 
        - Icon: Heart (Outline -> Filled).
        - Color: `#FF2E88` (Cherry Primary) when active.
        - Animation: **Tactile** (scale 0.95 active), **Pop** (scale 1.2 on logic trigger).
- **Integration**:
    - Add `PickButton` to `ProductCard`.
    - Add `PickButton` to `ProductDetail`.

### 3.3 Page
- **Route**: with `AuthGuard`.
- **Page**: `features/wish/ui/MyPickPage.tsx`
    - Grid layout of liked products.

---

## 4. Work Sequence
1.  **Backend**: create Entity -> Repository -> Service -> Controller -> Test.
2.  **Verify Backend**: Run Tests.
3.  **Frontend**: create API -> Hook -> Components -> Page.
4.  **Verify Frontend**: Browser test flow.

---

## 5. QA & Fixes Required (Phase 2)

### 5.1 Backend Fixes
- [ ] Align security policy for `GET /products/{productId}/like-status` (enforce auth at SecurityConfig, or allow anonymous and return false consistently).
- [ ] Revisit `JwtAuthenticationFilter.shouldNotFilter` so GET `/products/**` can still read tokens for personalization without fragile path exceptions.
- [ ] Prevent N+1 in `getMyLikes` (fetch join or repository projection including product data).
- [ ] Handle duplicate-like race safely (idempotent behavior or catch unique constraint violation).
- [ ] Align pagination contract for `GET /me/likes` (cursor-based per TODO, or update spec explicitly).

### 5.2 Frontend Fixes
- [ ] Load initial like status on detail/list (use `getLikeStatus` or include `isLiked` in product APIs).
- [ ] Prevent negative like counts when base count is unknown (hide count, clamp at 0, or use server-provided counts).
- [ ] Ensure `MyPickPage` uses real like counts or avoids misleading counters.
- [ ] Replace inline `<style>` usage in `PickButton` with Tailwind-configured animation to comply with "Tailwind only".

### 5.3 QA Checklist
- [ ] Anonymous user cannot like; prompt appears and no API call succeeds.
- [ ] Logged-in user like/unlike works from list and detail; state persists after refresh/re-entry.
- [ ] `MyPickPage` renders correct list, no negative counts, and handles empty/loading/error states.
- [ ] Rapid toggle (double click) does not create duplicates or inconsistent UI.
- [ ] Pagination on `GET /me/likes` matches agreed contract and returns consistent results.
