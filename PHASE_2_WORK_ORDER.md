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

## 2. Backend Implementation (cherry-server) ✅ **COMPLETE**

**Target Package**: `com.cherry.server.wish` (New Package)

### 2.1 Domain Layer (`domain`) ✅

- [x] **Entity**: `ProductLike`
  - Fields:
    - `Long id` (PK, GeneratedValue)
    - `User user` (ManyToOne, fetch=LAZY, JoinColumn "user_id")
    - `Product product` (ManyToOne, fetch=LAZY, JoinColumn "product_id")
    - `LocalDateTime createdAt` (from `BaseTimeEntity`)
  - **Constraints**: Composite Unique Index on `(user_id, product_id)` to prevent duplicate likes.
  - **Methods**: `static ProductLike create(User user, Product product)`

### 2.2 Infrastructure Layer (`repository`) ✅

- [x] **Repository**: `ProductLikeRepository` (extends `JpaRepository`)
  - `boolean existsByUserAndProduct(User user, Product product)`
  - `void deleteByUserAndProduct(User user, Product product)`
  - `Slice<ProductLike> findAllByUserIdWithProductCursor(...)` with JOIN FETCH

### 2.3 Application Layer (`service`) ✅

- [x] **Service**: `WishService`
  - `@Transactional` required.
  - `void addLike(Long userId, Long productId)` - Idempotent implementation
  - `void removeLike(Long userId, Long productId)`
  - `ProductListResponse getMyLikes(Long userId, String cursor, int limit)` - Cursor-based pagination

### 2.4 Presentation Layer (`controller`) ✅

- [x] **Controller**: `WishController`
- **Endpoints**:
  - `POST /products/{productId}/like`: Requires Auth. Returns 200 OK.
  - `DELETE /products/{productId}/like`: Requires Auth. Returns 204 No Content.
  - `GET /products/{productId}/like-status`:Returns `boolean isLiked`.
  - `GET /me/likes`: Returns `ProductListResponse` with cursor pagination.

**Constraint Checklist**:

- [x] Use `record` for DTOs.
- [x] Strictly follow SOLID principles.
- [x] Write `WishApiTest` using `@WebMvcTest`.

---

## 3. Frontend Implementation (cherry) 95% COMPLETE ⚠️

**Target Directory**: `features/wish`

### 3.1 Business Logic ✅

- [x] **API**: `shared/services/wishApi.ts`
  - `addLike(productId: number): Promise<void>`
  - `removeLike(productId: number): Promise<void>`
  - `getMyLikes(cursor?, limit): Promise<ProductListResponse>`
- [x] **Hook**: `features/wish/hooks/usePick.ts`
  - Logic: Optimistic Update. Update UI immediately, rollback if API fails.

### 3.2 UI Components ✅

- [x] **Component**: `PickButton.tsx` (`features/wish/ui/PickButton.tsx`)
  - Props: `productId: number`, `initialIsLiked: boolean`.
  - Design:
    - Icon: Heart (Outline -> Filled).
    - Color: `#FF2E88` (Cherry Primary) when active.
    - Animation: **Tactile** (scale 0.95 active), **Pop** (scale 1.2 on logic trigger).
- [x] **Integration**:
  - Add `PickButton` to `ProductCard`.
  - Add `PickButton` to `ProductDetail`.

### 3.3 Page ⚠️ **NEEDS API INTEGRATION**

- [ ] **Route**: with `AuthGuard`.
- [ ] **Page**: `features/wish/ui/MyPickPage.tsx`
  - Currently uses mock data (`products.slice(0, 3)`)
  - **TODO**: Integrate with `wishApi.getMyLikes()` using infinite scroll

---

## 4. Work Sequence ✅ **COMPLETE**

1. [x] **Backend**: create Entity -> Repository -> Service -> Controller -> Test.
2. [x] **Verify Backend**: Run Tests.
3. [x] **Frontend**: create API -> Hook -> Components -> Page.
4. [ ] **Verify Frontend**: Browser test flow. **← FINAL VERIFICATION NEEDED**

---

## 5. QA & Fixes Required (Phase 2)

### 5.1 Backend Fixes ✅ **ALL COMPLETE**

- [x] Align security policy for `GET /products/{productId}/like-status` (enforce auth at SecurityConfig).
- [x] Revisit `JwtAuthenticationFilter.shouldNotFilter` so GET `/products/**` can still read tokens for personalization.
- [x] Prevent N+1 in `getMyLikes` (fetch join implemented).
- [x] Handle duplicate-like race safely (idempotent behavior + exception handling).
- [x] Align pagination contract for `GET /me/likes` (cursor-based implemented).

### 5.2 Frontend Fixes

- [x] Load initial like status on detail/list (use `initialIsLiked` from API response).
- [x] Prevent negative like counts when base count is unknown (Math.max(0, ...) implemented).
- [x] Ensure `MyPickPage` uses real API instead of mock data. **← REMAINING TASK**
- [x] Replace inline `<style>` usage in `ProductDetail` with Tailwind-configured animation. **← REMAINING TASK**

### 5.3 QA Checklist

- [x] Anonymous user cannot like; prompt appears and no API call succeeds.
- [x] Logged-in user like/unlike works from list and detail; state persists after refresh/re-entry.
- [ ] `MyPickPage` renders correct list from API, handles empty/loading/error states. **← REMAINING**
- [x] Rapid toggle (double click) does not create duplicates or inconsistent UI.
- [x] Pagination on `GET /me/likes` matches agreed contract and returns consistent results.

---

## 6. 🎯 Remaining Tasks for Codex (FINAL PHASE)

**Status**: Backend 100% ✅ | Frontend Core 100% ✅ | Frontend Page 60% ⚠️  
**Estimated Time**: 50 minutes total

---

### Task 6.1: MyPickPage API Integration (HIGH PRIORITY - 30min)

**File**: `cherry-client/features/wish/ui/MyPickPage.tsx`  
**Current Issue**: Using mock data `products.slice(0, 3)`  
**Blocking**: Phase 2 cannot be marked complete

#### Step 1: Create `useMyLikes` Hook

**New File**: `features/wish/hooks/useMyLikes.ts`

**Pattern**: Copy from `features/product/hooks/useProducts.ts` (lines 10-83)

```typescript
import { useState, useCallback, useEffect } from "react";
import type { Product } from "@/features/product/types";
import { wishApi } from "@/shared/services/wishApi";
import { ProductMapper } from "@/shared/mappers/productMapper";
import { useAuthStore } from "@/features/auth/model/authStore";

export const useMyLikes = () => {
  const token = useAuthStore((state) => state.token);
  const [products, setProducts] = useState<Product[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadInitial = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await wishApi.getMyLikes(null, 20);
      const mappedProducts = ProductMapper.toFrontendList(response.items);
      setProducts(mappedProducts);
      setCursor(response.nextCursor);
    } catch (err) {
      console.error("Failed to load likes:", err);
      setError("찜 목록을 불러오는데 실패했습니다.");
    } finally {
      setIsLoading(false);
    }
  }, [token]);

  const loadMore = useCallback(async () => {
    if (isLoadingMore || !cursor) return;
    setIsLoadingMore(true);
    try {
      const response = await wishApi.getMyLikes(cursor, 20);
      const mappedProducts = ProductMapper.toFrontendList(response.items);
      setProducts((prev) => [...prev, ...mappedProducts]);
      setCursor(response.nextCursor);
    } catch (err) {
      console.error("Failed to load more likes:", err);
    } finally {
      setIsLoadingMore(false);
    }
  }, [cursor, isLoadingMore, token]);

  const refresh = useCallback(async () => {
    await loadInitial();
  }, [loadInitial]);

  useEffect(() => {
    void loadInitial();
  }, [loadInitial]);

  return {
    products,
    isLoading,
    isLoadingMore,
    error,
    hasMore: cursor !== null,
    loadMore,
    refresh,
  };
};
```

#### Step 2: Update MyPickPage.tsx

**File**: `features/wish/ui/MyPickPage.tsx`

Replace mock data logic with:

```typescript
import { useMyLikes } from '../hooks/useMyLikes';
import { Loader2 } from 'lucide-react';
import { HOME_INFINITE_SCROLL_OFFSET_PX } from '@/features/home/constants';

export const MyPickPage: React.FC = () => {
    const { isLoggedIn } = useAuthStore();
    const navigate = useNavigate();

    const {
        products: likedProducts,
        isLoading,
        isLoadingMore,
        error,
        hasMore,
        loadMore
    } = useMyLikes();

    // Infinite scroll listener (pattern from Home.tsx lines 91-104)
    useEffect(() => {
        if (!isLoggedIn) return;

        const handleScroll = () => {
            if (
                window.innerHeight + document.documentElement.scrollTop >=
                document.documentElement.offsetHeight - HOME_INFINITE_SCROLL_OFFSET_PX
            ) {
                if (!isLoadingMore && hasMore) {
                    loadMore();
                }
            }
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, [loadMore, isLoadingMore, hasMore, isLoggedIn]);

    if (!isLoggedIn) {
        return (/* existing LoginPrompt */);
    }

    if (isLoading) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <Loader2 size={48} className="animate-spin text-cherry" />
            </div>
        );
    }

    return (
        <div className="pb-24 bg-white min-h-screen">
            <PageHeader title="체리픽" />
            <ProductList
                products={likedProducts}
                onItemClick={(p) => navigate(ROUTES.PRODUCT_DETAIL(p.id))}
                emptyMessage="찜한 상품이 없어요"
            />
            {isLoadingMore && (
                <div className="py-8 flex justify-center">
                    <Loader2 size={24} className="animate-spin text-cherry" />
                </div>
            )}
        </div>
    );
};
```

#### References:

- **Pattern Hook**: `features/product/hooks/useProducts.ts`
- **Infinite Scroll**: `features/home/pages/Home.tsx` (lines 91-104)
- **API**: `shared/services/wishApi.ts` (already exists)
- **Constants**: `features/home/constants.ts` → `HOME_INFINITE_SCROLL_OFFSET_PX`

---

### Task 6.2: Remove Inline Styles (MEDIUM PRIORITY - 20min)

**File**: `cherry-client/features/product/components/ProductDetail.tsx`  
**Issue**: Contains `<style>` tag (lines 221-229)  
**Violates**: "Tailwind only" policy from GEMINI.md

#### Step 1: Update `tailwind.config.js`

Add to `theme.extend`:

```javascript
module.exports = {
  theme: {
    extend: {
      keyframes: {
        fadeIn: {
          "0%": { opacity: "0", transform: "scale(0.98)" },
          "100%": { opacity: "1", transform: "scale(1)" },
        },
      },
      animation: {
        fadeIn: "fadeIn 0.3s ease-out",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    function ({ addUtilities }) {
      addUtilities({
        ".pb-safe": {
          "padding-bottom": "max(16px, env(safe-area-inset-bottom))",
        },
      });
    },
  ],
};
```

#### Step 2: Update ProductDetail.tsx

1. **Remove** `<style>` tag (lines 221-229)
2. **Change** className:

   ```tsx
   // BEFORE:
   className = "... animate-[fadeIn_0.3s_ease-out] ...";

   // AFTER:
   className = "... animate-fadeIn ...";
   ```

3. **Verify** `.pb-safe` class still works in bottom bar

---

## 7. Completion Checklist for Codex

### Development:

- [x] Create `useMyLikes` Hook in `features/wish/hooks/useMyLikes.ts`
- [x] Update `MyPickPage.tsx` to use `useMyLikes()` and infinite scroll
- [x] Update `tailwind.config.js` with `fadeIn` animation and `pb-safe` utility
- [x] Remove `<style>` tag from `ProductDetail.tsx`
- [x] Update className to use `animate-fadeIn`

### Testing (Browser):

- [x] Login and add/remove picks from product detail page
- [x] Navigate to 찜 tab (MyPickPage)
- [x] Verify real liked products appear (not mock data)
- [x] Scroll down and verify infinite scroll loads more
- [x] Verify loading spinner appears during fetch
- [x] Test ProductDetail fade-in animation
- [x] Verify bottom bar safe area padding works

### Final Verification:

- [x] Run `npm run dev` with no errors
- [x] No inline `<style>` tags remain anywhere
- [x] All Tailwind utilities work correctly

---

## 8. Success Criteria

✅ **MyPickPage loads real data from `GET /me/likes`**  
✅ **Infinite scroll works with cursor-based pagination**  
✅ **All styles use Tailwind config (no inline styles)**  
✅ **Phase 2 = 100% Complete**

**After completion, Phase 2 is ready for deployment.**

---

## 9. 🔧 Phase 2 Extension: Like Count Feature (DISCOVERED POST-MVP)

**Status**: Requirements Identified  
**Priority**: High (User-Facing Feature Gap)  
**Discovery Date**: 2026-01-22  
**Assigned To**: Codex

### 9.1 Problem Statement

**Observed Issue**: 찜 하트 아이콘은 표시되지만, 찜 개수(숫자 카운트)가 표시되지 않음

**Root Cause Analysis** (Code-Based):

- ✅ DB Structure: `product_likes` 테이블 정상, (user_id, product_id) 유니크 인덱스 존재
- ✅ Like Add/Remove: `WishService.addLike/removeLike` 정상 동작
- ❌ **API Design Gap**: `ProductSummaryResponse`에 `likeCount` 필드 없음
- ❌ **Aggregation Logic Missing**: `ProductLikeRepository`에 COUNT 쿼리 메서드 없음
- ❌ **Service Integration**: `ProductService`에 likeCount 계산 로직 없음

**Conclusion**: Backend에서 찜 개수를 집계하고 반환하는 로직이 설계되지 않음

### 9.2 Implementation Approach

#### Decision: Real-time COUNT Query (MVP)

**Rationale**:

- Current Traffic: < 100 req/s (Portfolio Project)
- Data Consistency: 100% guaranteed with DB query
- Implementation Complexity: Low
- Alternative (Cached Column): Requires transaction management, overkill for MVP

**Selected Approach**: Add COUNT query to `ProductLikeRepository` and integrate into `ProductService`

### 9.3 Backend Tasks

#### Task 9.3.1: Add COUNT Methods to ProductLikeRepository

**File**: `com.cherry.server.wish.repository.ProductLikeRepository`

**Add Methods**:

```java
// Single product count
long countByProductId(Long productId);

// Bulk count (N+1 prevention)
@Query("SELECT pl.product.id as productId, COUNT(pl) as likeCount " +
       "FROM ProductLike pl " +
       "WHERE pl.product.id IN :productIds " +
       "GROUP BY pl.product.id")
List<ProductLikeCount> countByProductIds(@Param("productIds") List<Long> productIds);

// Projection interface
interface ProductLikeCount {
    Long getProductId();
    Long getLikeCount();
}
```

#### Task 9.3.2: Update ProductService Integration

**File**: `com.cherry.server.product.service.ProductService`

**Modify Methods**:

1. `getProducts(String cursor, int limit, Long userId)`:
   - After fetching products, call `countByProductIds(productIds)`
   - Create `Map<Long, Long> likeCountMap`
   - Pass `likeCountMap.getOrDefault(productId, 0L)` to DTO

2. `getProduct(Long productId, Long userId)`:
   - Call `countByProductId(productId)`
   - Pass count to `ProductDetailResponse.from(..., likeCount)`

3. `getTrending(Long userId)`:
   - Apply same logic as `getProducts`

#### Task 9.3.3: Update DTOs with likeCount Field

**Files**:

- `com.cherry.server.product.dto.ProductSummaryResponse`
- `com.cherry.server.product.dto.ProductDetailResponse`

**Changes**:

```java
@Builder
public record ProductSummaryResponse(
    Long id,
    String title,
    int price,
    ProductStatus status,
    TradeType tradeType,
    String thumbnailUrl,
    LocalDateTime createdAt,
    boolean isLiked,
    long likeCount  // ADD THIS
) {
    // Overload from method
    public static ProductSummaryResponse from(Product product, boolean isLiked, long likeCount) {
        return builder()
            .id(product.getId())
            // ... existing fields ...
            .isLiked(isLiked)
            .likeCount(likeCount)
            .build();
    }
}
```

### 9.4 Frontend Tasks

#### Task 9.4.1: Update API Type Definitions

**File**: `cherry-client/shared/services/productApi.ts`

**Add Field**:

```typescript
export interface ProductSummary {
  id: number;
  title: string;
  price: number;
  // ... existing fields ...
  isLiked: boolean;
  likeCount: number; // ADD THIS
}

export interface ProductDetail {
  // ... existing fields ...
  isLiked: boolean;
  likeCount: number; // ADD THIS
}
```

#### Task 9.4.2: Update ProductMapper

**File**: `cherry-client/shared/mappers/productMapper.ts`

**Map likeCount**:

```typescript
static toFrontend(backend: ProductSummary): Product {
    return {
        id: backend.id,
        // ... existing fields ...
        likes: backend.likeCount,  // Map to likes field
        isLiked: backend.isLiked,
    };
}
```

#### Task 9.4.3: Update Product Type

**File**: `cherry-client/features/product/types.ts`

**Remove Optional**:

```typescript
export interface Product {
  // ... existing fields ...
  likes: number; // Remove ? (always provided now)
  isLiked?: boolean;
}
```

### 9.5 Verification Plan

#### Backend Tests

- [ ] Unit Test: `ProductLikeRepository.countByProductId` returns correct count
- [ ] Unit Test: `ProductLikeRepository.countByProductIds` returns map with correct counts
- [ ] Integration Test: `GET /products` response includes `likeCount` field
- [ ] Integration Test: `GET /products/{id}` response includes `likeCount` field
- [ ] Integration Test: After adding like, `likeCount` increases by 1
- [ ] Integration Test: After removing like, `likeCount` decreases by 1

#### Frontend Tests

- [ ] Browser Test: ProductCard displays like count correctly
- [ ] Browser Test: After clicking like, count increases immediately (optimistic update)
- [ ] Browser Test: After page refresh, count persists correctly
- [ ] Type Check: `npm run dev` passes without TypeScript errors

### 9.6 Future Extensions (Not MVP)

**If Traffic > 1000 req/s**:

1. Add `like_count` column to `products` table
2. Use database triggers or application-level transaction to update count
3. Background job for count reconciliation
4. Consider Redis caching for hot products

**Current Decision**: Use real-time COUNT query for MVP simplicity

---

**Last Updated**: 2026-01-22 22:55  
**Status**: Analysis Complete, Ready for Implementation
