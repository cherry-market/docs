# Phase 3 Filters Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Deliver Phase 3 (3.2~3.5) by adding backend filter parameters + sorting (LATEST/LOW_PRICE/HIGH_PRICE), category API, category/tags in product responses, and UI updates with POPULAR removed.

**Architecture:** Backend introduces a filter request DTO, JPA Specifications for dynamic filtering, cursor pagination per sort, and a category API. Frontend fetches categories via a hook, passes filters to `/products`, removes client-side filtering, and maps category/tags with relative time formatting.

**Tech Stack:** Spring Boot 3.4, Java 21, Spring Data JPA, MySQL (local, `DB_PASSWORD=1234`), React 19, Vite, Tailwind CSS, Zustand.

---

### Task 1: Phase 3.2 - Extend product list API params (no filtering yet)

**Files:**
- Create: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductSortBy.java`
- Create: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductListRequest.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/service/ProductService.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/controller/ProductController.java`
- Modify: `cherry/shared/services/productApi.ts`
- Test: `cherry-server/src/test/java/com/cherry/server/product/ProductListRequestTest.java`

**Step 1: Write the failing test**

```java
// cherry-server/src/test/java/com/cherry/server/product/ProductListRequestTest.java
package com.cherry.server.product;

import static org.assertj.core.api.Assertions.assertThat;

import com.cherry.server.product.domain.ProductStatus;
import com.cherry.server.product.domain.TradeType;
import com.cherry.server.product.dto.ProductListRequest;
import com.cherry.server.product.dto.ProductSortBy;
import org.junit.jupiter.api.Test;

class ProductListRequestTest {

    @Test
    void builds_request_with_sort_defaults() {
        ProductListRequest request = ProductListRequest.builder()
                .status(ProductStatus.SELLING)
                .categoryCode("photocard")
                .minPrice(1000)
                .maxPrice(5000)
                .tradeType(TradeType.DIRECT)
                .sortBy(ProductSortBy.LOW_PRICE)
                .build();

        assertThat(request.sortByOrDefault()).isEqualTo(ProductSortBy.LOW_PRICE);
        assertThat(request.categoryCode()).isEqualTo("photocard");
    }
}
```

**Step 2: Run test to verify it fails**

Run: `cd cherry-server/.worktrees/phase3-filters-20260123 && DB_PASSWORD=1234 ./gradlew test --tests "com.cherry.server.product.ProductListRequestTest"`
Expected: FAIL (missing classes).

**Step 3: Write minimal implementation (DTO + controller/service signature)**

```java
// cherry-server/src/main/java/com/cherry/server/product/dto/ProductSortBy.java
package com.cherry.server.product.dto;

public enum ProductSortBy {
    LATEST,
    LOW_PRICE,
    HIGH_PRICE
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/dto/ProductListRequest.java
package com.cherry.server.product.dto;

import com.cherry.server.product.domain.ProductStatus;
import com.cherry.server.product.domain.TradeType;
import lombok.Builder;

@Builder
public record ProductListRequest(
        ProductStatus status,
        String categoryCode,
        Integer minPrice,
        Integer maxPrice,
        TradeType tradeType,
        ProductSortBy sortBy
) {
    public ProductSortBy sortByOrDefault() {
        return sortBy == null ? ProductSortBy.LATEST : sortBy;
    }
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/service/ProductService.java
public ProductListResponse getProducts(String cursor, int limit, Long userId, ProductListRequest request) {
    // NOTE: filtering added in Task 2
    return getProducts(cursor, limit, userId);
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/controller/ProductController.java
@GetMapping
public ResponseEntity<ProductListResponse> getProducts(
        @AuthenticationPrincipal UserPrincipal principal,
        @RequestParam(required = false) String cursor,
        @RequestParam(defaultValue = "20") @Min(1) @Max(50) int limit,
        @RequestParam(required = false) ProductStatus status,
        @RequestParam(required = false) String categoryCode,
        @RequestParam(required = false) Integer minPrice,
        @RequestParam(required = false) Integer maxPrice,
        @RequestParam(required = false) TradeType tradeType,
        @RequestParam(required = false) ProductSortBy sortBy
) {
    Long userId = principal == null ? null : principal.id();
    ProductListRequest request = ProductListRequest.builder()
            .status(status)
            .categoryCode(categoryCode)
            .minPrice(minPrice)
            .maxPrice(maxPrice)
            .tradeType(tradeType)
            .sortBy(sortBy)
            .build();
    return ResponseEntity.ok(productService.getProducts(cursor, limit, userId, request));
}
```

```ts
// cherry/shared/services/productApi.ts
export type ProductSortBy = 'LATEST' | 'LOW_PRICE' | 'HIGH_PRICE';
export interface ProductListFilters {
  status?: 'SELLING' | 'RESERVED' | 'SOLD';
  categoryCode?: string;
  minPrice?: number;
  maxPrice?: number;
  tradeType?: 'DIRECT' | 'DELIVERY' | 'BOTH';
  sortBy?: ProductSortBy;
}

getProducts: (cursor?: string, limit = 20, token?: string | null, filters?: ProductListFilters) => {
  const params = new URLSearchParams();
  if (cursor) params.append('cursor', cursor);
  params.append('limit', String(limit));
  if (filters?.status) params.append('status', filters.status);
  if (filters?.categoryCode) params.append('categoryCode', filters.categoryCode);
  if (filters?.minPrice) params.append('minPrice', String(filters.minPrice));
  if (filters?.maxPrice) params.append('maxPrice', String(filters.maxPrice));
  if (filters?.tradeType) params.append('tradeType', filters.tradeType);
  if (filters?.sortBy) params.append('sortBy', filters.sortBy);
  const endpoint = `/products?${params}`;
  return token
      ? api.authenticatedGet<ProductListResponse>(endpoint, token)
      : api.get<ProductListResponse>(endpoint);
},
```

**Step 4: Run test to verify it passes**

Run: `cd cherry-server/.worktrees/phase3-filters-20260123 && DB_PASSWORD=1234 ./gradlew test --tests "com.cherry.server.product.ProductListRequestTest"`
Expected: PASS

**Step 5: Commit**

```bash
cd cherry-server/.worktrees/phase3-filters-20260123

git add src/main/java/com/cherry/server/product/dto/ProductSortBy.java \
  src/main/java/com/cherry/server/product/dto/ProductListRequest.java \
  src/main/java/com/cherry/server/product/service/ProductService.java \
  src/main/java/com/cherry/server/product/controller/ProductController.java \
  src/test/java/com/cherry/server/product/ProductListRequestTest.java

git commit -m "feat: accept product list filters"

cd ../../cherry/.worktrees/phase3-filters-20260123

git add shared/services/productApi.ts

git commit -m "feat: send product list filters"
```

**QA Checkpoint (3.2):**
- `/products?sortBy=LOW_PRICE&minPrice=1000` returns 200 (filtering not applied yet).

---

### Task 2: Phase 3.3 - Implement filter query + cursor pagination

**Files:**
- Modify: `cherry-server/src/main/java/com/cherry/server/product/repository/ProductRepository.java`
- Create: `cherry-server/src/main/java/com/cherry/server/product/repository/ProductSpecifications.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/service/ProductService.java`
- Test: `cherry-server/src/test/java/com/cherry/server/product/ProductCursorSpecTest.java`

**Step 1: Write the failing test**

```java
// cherry-server/src/test/java/com/cherry/server/product/ProductCursorSpecTest.java
package com.cherry.server.product;

import static org.assertj.core.api.Assertions.assertThat;

import com.cherry.server.product.dto.ProductSortBy;
import org.junit.jupiter.api.Test;

class ProductCursorSpecTest {

    @Test
    void supports_latest_sort() {
        assertThat(ProductSortBy.LATEST).isEqualTo(ProductSortBy.LATEST);
    }
}
```

**Step 2: Run test to verify it fails**

Run: `cd cherry-server/.worktrees/phase3-filters-20260123 && DB_PASSWORD=1234 ./gradlew test --tests "com.cherry.server.product.ProductCursorSpecTest"`
Expected: FAIL (missing classes).

**Step 3: Write minimal implementation (specs + cursor parsing + sort)**

```java
// cherry-server/src/main/java/com/cherry/server/product/repository/ProductRepository.java
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface ProductRepository extends JpaRepository<Product, Long>, JpaSpecificationExecutor<Product> {
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/repository/ProductSpecifications.java
package com.cherry.server.product.repository;

import com.cherry.server.product.domain.Category;
import com.cherry.server.product.domain.Product;
import com.cherry.server.product.domain.ProductStatus;
import com.cherry.server.product.domain.TradeType;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;

public final class ProductSpecifications {

    private ProductSpecifications() {
    }

    public static Specification<Product> hasStatus(ProductStatus status) {
        return (root, query, cb) -> status == null ? null : cb.equal(root.get("status"), status);
    }

    public static Specification<Product> hasTradeType(TradeType tradeType) {
        return (root, query, cb) -> tradeType == null ? null : cb.equal(root.get("tradeType"), tradeType);
    }

    public static Specification<Product> hasCategoryCode(String categoryCode) {
        return (root, query, cb) -> {
            if (categoryCode == null || categoryCode.isBlank()) {
                return null;
            }
            Join<Product, Category> category = root.join("category");
            return cb.equal(category.get("code"), categoryCode);
        };
    }

    public static Specification<Product> minPrice(Integer minPrice) {
        return (root, query, cb) -> minPrice == null ? null : cb.greaterThanOrEqualTo(root.get("price"), minPrice);
    }

    public static Specification<Product> maxPrice(Integer maxPrice) {
        return (root, query, cb) -> maxPrice == null ? null : cb.lessThanOrEqualTo(root.get("price"), maxPrice);
    }

    public static Specification<Product> cursorLatest(LocalDateTime cursorCreatedAt, Long cursorId) {
        return (root, query, cb) -> {
            if (cursorCreatedAt == null || cursorId == null) {
                return null;
            }
            Predicate createdBefore = cb.lessThan(root.get("createdAt"), cursorCreatedAt);
            Predicate sameTimeLowerId = cb.and(
                    cb.equal(root.get("createdAt"), cursorCreatedAt),
                    cb.lessThan(root.get("id"), cursorId)
            );
            return cb.or(createdBefore, sameTimeLowerId);
        };
    }

    public static Specification<Product> cursorPriceAsc(Integer cursorPrice, Long cursorId) {
        return (root, query, cb) -> {
            if (cursorPrice == null || cursorId == null) {
                return null;
            }
            Predicate priceGreater = cb.greaterThan(root.get("price"), cursorPrice);
            Predicate samePriceLowerId = cb.and(
                    cb.equal(root.get("price"), cursorPrice),
                    cb.lessThan(root.get("id"), cursorId)
            );
            return cb.or(priceGreater, samePriceLowerId);
        };
    }

    public static Specification<Product> cursorPriceDesc(Integer cursorPrice, Long cursorId) {
        return (root, query, cb) -> {
            if (cursorPrice == null || cursorId == null) {
                return null;
            }
            Predicate priceLower = cb.lessThan(root.get("price"), cursorPrice);
            Predicate samePriceLowerId = cb.and(
                    cb.equal(root.get("price"), cursorPrice),
                    cb.lessThan(root.get("id"), cursorId)
            );
            return cb.or(priceLower, samePriceLowerId);
        };
    }
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/service/ProductService.java
public ProductListResponse getProducts(String cursor, int limit, Long userId, ProductListRequest request) {
    ProductSortBy sortBy = request.sortByOrDefault();

    if (request.minPrice() != null && request.maxPrice() != null && request.minPrice() > request.maxPrice()) {
        throw new IllegalArgumentException("minPrice must be <= maxPrice");
    }

    CursorParts cursorParts = CursorParts.from(cursor, sortBy);

    Specification<Product> spec = Specification.where(ProductSpecifications.hasStatus(request.status()))
            .and(ProductSpecifications.hasTradeType(request.tradeType()))
            .and(ProductSpecifications.hasCategoryCode(request.categoryCode()))
            .and(ProductSpecifications.minPrice(request.minPrice()))
            .and(ProductSpecifications.maxPrice(request.maxPrice()))
            .and(cursorParts.toSpecification());

    Slice<Product> slice = productRepository.findAll(spec, PageRequest.of(0, limit, cursorParts.sort()));
    // map to ProductSummaryResponse and build nextCursor
}

private record CursorParts(ProductSortBy sortBy, LocalDateTime cursorCreatedAt, Integer cursorPrice, Long cursorId) {
    static CursorParts from(String cursor, ProductSortBy sortBy) {
        if (cursor == null) {
            return new CursorParts(sortBy, null, null, null);
        }
        try {
            String[] parts = cursor.split("_");
            Long cursorId = Long.parseLong(parts[1]);
            if (sortBy == ProductSortBy.LATEST) {
                return new CursorParts(sortBy, LocalDateTime.parse(parts[0]), null, cursorId);
            }
            return new CursorParts(sortBy, null, Integer.parseInt(parts[0]), cursorId);
        } catch (Exception ignored) {
            return new CursorParts(sortBy, null, null, null);
        }
    }

    Specification<Product> toSpecification() {
        return switch (sortBy) {
            case LATEST -> ProductSpecifications.cursorLatest(cursorCreatedAt, cursorId);
            case LOW_PRICE -> ProductSpecifications.cursorPriceAsc(cursorPrice, cursorId);
            case HIGH_PRICE -> ProductSpecifications.cursorPriceDesc(cursorPrice, cursorId);
        };
    }

    Sort sort() {
        return switch (sortBy) {
            case LATEST -> Sort.by(Sort.Direction.DESC, "createdAt").and(Sort.by(Sort.Direction.DESC, "id"));
            case LOW_PRICE -> Sort.by(Sort.Direction.ASC, "price").and(Sort.by(Sort.Direction.DESC, "id"));
            case HIGH_PRICE -> Sort.by(Sort.Direction.DESC, "price").and(Sort.by(Sort.Direction.DESC, "id"));
        };
    }
}
```

**Step 4: Run test to verify it passes**

Run: `cd cherry-server/.worktrees/phase3-filters-20260123 && DB_PASSWORD=1234 ./gradlew test --tests "com.cherry.server.product.ProductCursorSpecTest"`
Expected: PASS

**Step 5: Commit**

```bash
cd cherry-server/.worktrees/phase3-filters-20260123

git add src/main/java/com/cherry/server/product/repository/ProductRepository.java \
  src/main/java/com/cherry/server/product/repository/ProductSpecifications.java \
  src/main/java/com/cherry/server/product/service/ProductService.java \
  src/test/java/com/cherry/server/product/ProductCursorSpecTest.java

git commit -m "feat: add product filters and cursor sort"
```

**QA Checkpoint (3.3):**
- `/products?sortBy=LOW_PRICE` is ascending.
- `/products?sortBy=HIGH_PRICE` is descending.
- `nextCursor` continues each sort correctly.

---

### Task 3: Phase 3.4 - Category API + category/tags in responses

**Files:**
- Create: `cherry-server/src/main/java/com/cherry/server/product/dto/CategoryResponse.java`
- Create: `cherry-server/src/main/java/com/cherry/server/product/service/CategoryService.java`
- Create: `cherry-server/src/main/java/com/cherry/server/product/controller/CategoryController.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/repository/CategoryRepository.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductSummaryResponse.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductDetailResponse.java`
- Test: `cherry-server/src/test/java/com/cherry/server/product/CategoryApiTest.java`

**Step 1: Write the failing test**

```java
// cherry-server/src/test/java/com/cherry/server/product/CategoryApiTest.java
package com.cherry.server.product;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.cherry.server.product.controller.CategoryController;
import com.cherry.server.product.service.CategoryService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(controllers = CategoryController.class)
class CategoryApiTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CategoryService categoryService;

    @Test
    void get_categories_returns_ok() throws Exception {
        when(categoryService.getActiveCategories()).thenReturn(java.util.List.of());

        mockMvc.perform(get("/categories"))
                .andExpect(status().isOk());
    }
}
```

**Step 2: Run test to verify it fails**

Run: `cd cherry-server/.worktrees/phase3-filters-20260123 && DB_PASSWORD=1234 ./gradlew test --tests "com.cherry.server.product.CategoryApiTest"`
Expected: FAIL (missing classes).

**Step 3: Write minimal implementation (category API + response mapping)**

```java
// cherry-server/src/main/java/com/cherry/server/product/dto/CategoryResponse.java
package com.cherry.server.product.dto;

import com.cherry.server.product.domain.Category;

public record CategoryResponse(String code, String displayName) {
    public static CategoryResponse from(Category category) {
        return new CategoryResponse(category.getCode(), category.getDisplayName());
    }
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/repository/CategoryRepository.java
import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findByIsActiveTrueOrderBySortOrderAsc();
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/service/CategoryService.java
package com.cherry.server.product.service;

import com.cherry.server.product.dto.CategoryResponse;
import com.cherry.server.product.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<CategoryResponse> getActiveCategories() {
        return categoryRepository.findByIsActiveTrueOrderBySortOrderAsc()
                .stream()
                .map(CategoryResponse::from)
                .toList();
    }
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/controller/CategoryController.java
package com.cherry.server.product.controller;

import com.cherry.server.product.dto.CategoryResponse;
import com.cherry.server.product.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping("/categories")
    public ResponseEntity<List<CategoryResponse>> getCategories() {
        return ResponseEntity.ok(categoryService.getActiveCategories());
    }
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/dto/ProductSummaryResponse.java
public record ProductSummaryResponse(
        Long id,
        String title,
        int price,
        ProductStatus status,
        TradeType tradeType,
        String thumbnailUrl,
        LocalDateTime createdAt,
        boolean isLiked,
        long likeCount,
        String categoryCode,
        String categoryName
) {
    public static ProductSummaryResponse from(Product product, boolean isLiked, long likeCount) {
        return ProductSummaryResponse.builder()
                .id(product.getId())
                .title(product.getTitle())
                .price(product.getPrice())
                .status(product.getStatus())
                .tradeType(product.getTradeType())
                .thumbnailUrl(product.getImages().stream()
                        .filter(ProductImage::isThumbnail)
                        .findFirst()
                        .map(ProductImage::getImageUrl)
                        .orElse(null))
                .createdAt(product.getCreatedAt())
                .isLiked(isLiked)
                .likeCount(likeCount)
                .categoryCode(product.getCategory() == null ? null : product.getCategory().getCode())
                .categoryName(product.getCategory() == null ? null : product.getCategory().getDisplayName())
                .build();
    }
}
```

```java
// cherry-server/src/main/java/com/cherry/server/product/dto/ProductDetailResponse.java
public record ProductDetailResponse(
        Long id,
        String title,
        int price,
        ProductStatus status,
        TradeType tradeType,
        List<String> imageUrls,
        String description,
        SellerResponse seller,
        LocalDateTime createdAt,
        boolean isLiked,
        long likeCount,
        String categoryCode,
        String categoryName,
        List<String> tags
) {
    public static ProductDetailResponse from(Product product, boolean isLiked, long likeCount) {
        return ProductDetailResponse.builder()
                .id(product.getId())
                .title(product.getTitle())
                .price(product.getPrice())
                .status(product.getStatus())
                .tradeType(product.getTradeType())
                .imageUrls(product.getImages().stream()
                        .filter(img -> !img.isThumbnail())
                        .sorted(Comparator.comparingInt(ProductImage::getImageOrder))
                        .map(ProductImage::getImageUrl)
                        .toList())
                .description(product.getDescription())
                .seller(new SellerResponse(product.getSeller().getId(), product.getSeller().getNickname()))
                .createdAt(product.getCreatedAt())
                .isLiked(isLiked)
                .likeCount(likeCount)
                .categoryCode(product.getCategory() == null ? null : product.getCategory().getCode())
                .categoryName(product.getCategory() == null ? null : product.getCategory().getDisplayName())
                .tags(product.getProductTags().stream()
                        .map(productTag -> productTag.getTag().getName())
                        .toList())
                .build();
    }
}
```

**Step 4: Run test to verify it passes**

Run: `cd cherry-server/.worktrees/phase3-filters-20260123 && DB_PASSWORD=1234 ./gradlew test --tests "com.cherry.server.product.CategoryApiTest"`
Expected: PASS

**Step 5: Commit**

```bash
cd cherry-server/.worktrees/phase3-filters-20260123

git add src/main/java/com/cherry/server/product/dto/CategoryResponse.java \
  src/main/java/com/cherry/server/product/service/CategoryService.java \
  src/main/java/com/cherry/server/product/controller/CategoryController.java \
  src/main/java/com/cherry/server/product/repository/CategoryRepository.java \
  src/main/java/com/cherry/server/product/dto/ProductSummaryResponse.java \
  src/main/java/com/cherry/server/product/dto/ProductDetailResponse.java \
  src/test/java/com/cherry/server/product/CategoryApiTest.java

git commit -m "feat: add category api and product category fields"
```

**QA Checkpoint (3.4):**
- `GET /categories` returns active categories sorted by `sort_order`.
- `/products` includes `categoryCode`, `categoryName` and `/products/{id}` includes `tags`.

---

### Task 4: Phase 3.5 - UI updates (categories, tags, relative time, server filters)

**Files:**
- Create: `cherry/features/category/types.ts`
- Create: `cherry/shared/services/categoryApi.ts`
- Create: `cherry/shared/mappers/categoryMapper.ts`
- Create: `cherry/features/category/hooks/useCategories.ts`
- Create: `cherry/shared/utils/formatRelativeTime.ts`
- Modify: `cherry/shared/mappers/productMapper.ts`
- Modify: `cherry/features/product/types.ts`
- Modify: `cherry/features/product/constants.ts`
- Modify: `cherry/features/product/hooks/useProducts.ts`
- Modify: `cherry/features/home/pages/Home.tsx`
- Modify: `cherry/features/product/components/FilterSheet.tsx`
- Modify: `cherry/features/home/components/Header.tsx`
- Modify: `cherry/features/product/components/ProductDetail.tsx`
- Modify: `cherry/features/product/components/ProductCard.tsx`
- Remove: `cherry/shared/constants/categories.ts`

**Step 1: Write the failing test (relative time formatter)**

```ts
// cherry/shared/utils/formatRelativeTime.test.ts
import { describe, expect, test } from 'vitest';
import { formatRelativeTime } from './formatRelativeTime';

describe('formatRelativeTime', () => {
  test('returns minutes for recent time', () => {
    const now = new Date('2026-01-23T12:00:00Z');
    const value = new Date('2026-01-23T11:55:00Z');
    expect(formatRelativeTime(value, now)).toBe('5분 전');
  });
});
```

**Step 2: Run test to verify it fails**

Run: `cd cherry/.worktrees/phase3-filters-20260123 && npm install && npx vitest run shared/utils/formatRelativeTime.test.ts`
Expected: FAIL (missing formatter or vitest).

**Step 3: Write minimal implementation (frontend wiring)**

```ts
// cherry/features/category/types.ts
export interface Category {
  code: string;
  name: string;
}
```

```ts
// cherry/shared/services/categoryApi.ts
import { api } from './api';

export interface CategoryResponse {
  code: string;
  displayName: string;
}

export const categoryApi = {
  getCategories: () => api.get<CategoryResponse[]>('/categories'),
};
```

```ts
// cherry/shared/mappers/categoryMapper.ts
import type { Category } from '@/features/category/types';
import type { CategoryResponse } from '@/shared/services/categoryApi';

export class CategoryMapper {
  static toFrontend(backend: CategoryResponse): Category {
    return {
      code: backend.code,
      name: backend.displayName,
    };
  }

  static toFrontendList(backendList: CategoryResponse[]): Category[] {
    return backendList.map(this.toFrontend);
  }
}
```

```ts
// cherry/features/category/hooks/useCategories.ts
import { useEffect, useState } from 'react';
import type { Category } from '@/features/category/types';
import { categoryApi } from '@/shared/services/categoryApi';
import { CategoryMapper } from '@/shared/mappers/categoryMapper';

export const useCategories = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const load = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const response = await categoryApi.getCategories();
        if (isMounted) {
          setCategories(CategoryMapper.toFrontendList(response));
        }
      } catch {
        if (isMounted) {
          setError('카테고리를 불러오는데 실패했습니다.');
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };
    void load();
    return () => {
      isMounted = false;
    };
  }, []);

  return { categories, isLoading, error };
};
```

```ts
// cherry/shared/utils/formatRelativeTime.ts
export const formatRelativeTime = (value: Date, now = new Date()): string => {
  const diffMs = now.getTime() - value.getTime();
  const minutes = Math.floor(diffMs / (1000 * 60));
  if (minutes < 60) return `${minutes}분 전`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}시간 전`;
  const days = Math.floor(hours / 24);
  if (days < 365) return `${days}일 전`;
  const years = Math.floor(days / 365);
  return `${years}년 전`;
};
```

```ts
// cherry/shared/mappers/productMapper.ts (show only new fields)
import { formatRelativeTime } from '@/shared/utils/formatRelativeTime';

uploadedTime: formatRelativeTime(new Date(backend.createdAt)),
categoryCode: backend.categoryCode,
categoryName: backend.categoryName,
tags: backend.tags ?? [],
```

```ts
// cherry/features/product/types.ts
export type ProductSortBy = 'LATEST' | 'LOW_PRICE' | 'HIGH_PRICE';

export interface Product {
  // ...
  categoryCode: string | null;
  categoryName: string | null;
  tags: string[];
  uploadedTime: string;
  tradeType: TradeType;
}

export interface FilterState {
  status: ProductStatus | 'ALL';
  categoryCode: string | 'ALL';
  minPrice: number;
  maxPrice: number;
  sortBy: ProductSortBy;
  tradeType: TradeType;
}
```

```ts
// cherry/features/product/constants.ts
export const PRODUCT_SORT_OPTIONS = [
  { id: 'LATEST', label: '최신순' },
  { id: 'LOW_PRICE', label: '낮은 가격순' },
  { id: 'HIGH_PRICE', label: '높은 가격순' },
] as const;

export const PRODUCT_FILTER_DEFAULT: FilterState = {
  status: 'ALL',
  categoryCode: 'ALL',
  minPrice: 0,
  maxPrice: 0,
  sortBy: 'LATEST',
  tradeType: 'ALL',
};
```

```ts
// cherry/features/product/hooks/useProducts.ts (signature and filters wiring)
import type { ProductListFilters } from '@/shared/services/productApi';

export const useProducts = (filters: ProductListFilters) => {
  // loadInitial/loadMore use productApi.getProducts(cursor, 20, token, filters)
  // when filters change: reset products and cursor
};
```

```tsx
// cherry/features/home/pages/Home.tsx
// 1) Use categories: const { categories } = useCategories();
// 2) Build FilterState with categoryCode
// 3) Pass filters into useProducts
// 4) Remove client-side filtering for status/category/price/tradeType
```

```tsx
// cherry/features/product/components/FilterSheet.tsx
// - Accept categories prop: Category[]
// - Build local list with { code: 'ALL', name: '전체' }
// - Remove POPULAR option
// - No JSX logic: move isSelected and label resolution to helpers
```

```tsx
// cherry/features/home/components/Header.tsx
// - Accept categories prop
// - Render category chips from categories + "전체"
```

```tsx
// cherry/features/product/components/ProductDetail.tsx
// - Render product.categoryName
// - Render tags list as #tag
```

```tsx
// cherry/features/product/components/ProductCard.tsx
// - Render product.categoryName
```

**Step 4: Run test to verify it passes**

Run: `cd cherry/.worktrees/phase3-filters-20260123 && npx vitest run shared/utils/formatRelativeTime.test.ts`
Expected: PASS

**Step 5: Commit**

```bash
cd cherry/.worktrees/phase3-filters-20260123

git add features/category/types.ts shared/services/categoryApi.ts \
  shared/mappers/categoryMapper.ts features/category/hooks/useCategories.ts \
  shared/utils/formatRelativeTime.ts shared/mappers/productMapper.ts \
  features/product/types.ts features/product/constants.ts \
  features/product/hooks/useProducts.ts features/home/pages/Home.tsx \
  features/product/components/FilterSheet.tsx features/home/components/Header.tsx \
  features/product/components/ProductDetail.tsx features/product/components/ProductCard.tsx

git rm shared/constants/categories.ts

git commit -m "feat: wire categories, filters, and relative time"
```

**QA Checkpoint (3.5):**
- Filter controls call `/products` with correct query params.
- POPULAR option removed from UI.
- Category chips render API values.
- Detail shows tags and relative time.

---

## Final Verification

- Backend tests: `cd cherry-server/.worktrees/phase3-filters-20260123 && DB_PASSWORD=1234 ./gradlew test`
- Frontend build: `cd cherry/.worktrees/phase3-filters-20260123 && npm run build`

