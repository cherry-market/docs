# Phase 2.4: Mock Data Generation Guide (Minimal Scope)

**Target**: Generate 10,000 Product records for infinite scroll & cursor pagination testing.  
**Assignee**: Codex  
**Date**: 2026-01-23 (Revised)  
**Document Type**: Design & Implementation Guide (Code written by Codex in separate PR)

---

## 1. 🎯 Scope & Goals (MINIMAL)

### Primary Goal
- **10,000 Products** with time-distributed `created_at` (past 30 days) to test cursor-based infinite scroll under load.

### Non-Goals (Out of Scope)
- ❌ Schema expansion (Category/Artist entities) → Phase 3
- ❌ Real image uploads → Use computed URLs from existing DTO logic
- ❌ Production deployment → Local/dev environment only

---

## 2. 🔍 Current State Analysis

### 2.1 Image Handling (No Schema Change Needed)
**Verified**: `ProductSummaryResponse` and `ProductDetailResponse` already return dummy image URLs:
```java
// ProductSummaryResponse.java:37
.thumbnailUrl("https://via.placeholder.com/150")
```

**Decision**: **Keep current DTO approach**. No `thumbnail_url` column needed for mock data.  
**S3 Strategy**: GPT will define 50 reusable URLs. Backend can compute: `s3://bucket/mock/img_{productId % 50}.jpg`

### 2.2 Critical Infrastructure Gaps

**Missing Index**: Current `ProductRepository.findAllByCursor` sorts by `(created_at, id)` but **no composite index exists**.
```sql
-- REQUIRED for 10k performance
CREATE INDEX idx_products_cursor ON products(created_at DESC, id DESC);
```

**Connection Pool Issue**: Default HikariCP (10 connections) is fine for dev, but **user goal is "limit to prevent server overload"**, not expand.
```yaml
# CORRECTED: Enforce strict limits
spring:
  datasource:
    hikari:
      maximum-pool-size: 8   # Limit connections (not expand)
      connection-timeout: 3000
      validation-timeout: 2000
```

---

## 3. 🛠 Mock Data Generation Strategy

### 3.1 Dependency Chain
1. **Users** (50 phantom sellers) → 2. **Products** (10,000 items)

### 3.2 Data Generation Logic

#### Step 1: Phantom Users (50 users)
- **Why**: `Product.seller_id` FK constraint.
- **Optimization**: Use **single BCrypt hash** for all passwords (`$2a$10$...`) to avoid 50× hashing cost.
- **Naming**: `mock_user_001` ~ `mock_user_050`

#### Step 2: Product Batch Insert (10,000 items)
- **Time Distribution**: Random `created_at` within **past 30 days** to simulate realistic timeline.
- **Method**: **`JdbcTemplate.batchUpdate()`** with manual SQL (bypass JPA auditing).
- **Batch Size**: 1000 rows/batch (10 batches total).

**Field Values**:
- `title`: "Mock Product {id}"
- `description`: Random lorem ipsum (50-200 chars)
- `price`: Random.nextInt(1_000, 500_000)
- `status`: 80% SELLING, 10% RESERVED, 10% SOLD
- `tradeType`: Random (DIRECT/DELIVERY/BOTH)
- `seller_id`: Random user from 1-50
- `created_at`: now() - Random.nextInt(0, 30) days
- `updated_at`: Same as created_at

---

## 4. 🔐 Security Requirements (CRITICAL)

### 4.1 Controller Protection
```java
@Profile("local")  // NEVER deploy to prod
@RestController
@RequestMapping("/dev")
public class MockDataController {
    
    @PostMapping("/mock-data")
    @PreAuthorize("hasRole('ADMIN')")  // Extra layer
    public ResponseEntity<String> generateMockData() {
        // Implementation by Codex
    }
}
```

### 4.2 SecurityConfig Adjustment
```java
// Add to permitAll() list ONLY for local profile
http.authorizeHttpRequests(auth -> auth
    .requestMatchers("/dev/**").permitAll()  // Only if @Profile("local") active
);
```

**Deployment Protection**: CI/CD must **reject** builds with `spring.profiles.active=local`.

---

## 5. 📊 Performance Indexing (CRITICAL)

### 5.1 Required Indexes
```sql
-- PRIORITY 1: Cursor pagination (current bottleneck)
CREATE INDEX idx_products_cursor ON products(created_at DESC, id DESC);

-- PRIORITY 2: Seller lookup (FK join optimization)
CREATE INDEX idx_products_seller ON products(seller_user_id);
```

**Note**: Category/Artist indexes deferred to Phase 3.

---

## 6. 💾 Caching Strategy (Redis)

### 6.1 Cache Scope (Minimal)
**Only cache anonymous (non-personalized) responses** to avoid `isLiked`/`likeCount` staleness.

```java
// Cache ONLY when userId is null
@Cacheable(value = "productList", key = "'anon:' + #cursor + ':' + #limit", condition = "#userId == null")
public ProductListResponse getProducts(String cursor, int limit, Long userId) {
    // existing logic
}
```

**Cache Key Format**: `productList::anon:{cursor}:{limit}`  
**TTL**: 5 minutes  
**Invalidation**: `@CacheEvict` on new Product creation (if implemented)

### 6.2 Why Not Cache Authenticated Requests?
- `ProductService.getProducts()` includes **per-user** `isLiked` status.
- Caching would require `userId` in key → cache fragmentation → low hit rate.

---

## 7. 🚀 Implementation Checklist (For Codex)

### Phase 2.4.1: Infrastructure Prep
- [ ] Add composite index: `(created_at DESC, id DESC)` on `products`
- [ ] Set HikariCP `maximum-pool-size: 8` in `application-local.yml`
- [ ] Configure Redis cache with 5min TTL

### Phase 2.4.2: Mock Data Script
- [ ] Create `MockDataController` with `@Profile("local")`
- [ ] Generate 50 phantom users (single BCrypt hash)
- [ ] Batch insert 10k products via `JdbcTemplate`
- [ ] Verify cursor pagination query plan (`EXPLAIN ANALYZE`)

### Phase 2.4.3: Validation
- [ ] Run script in local environment
- [ ] Test infinite scroll with 10k items (smooth scrolling?)
- [ ] Measure query time for page 1, page 50, page 100
- [ ] Verify Redis cache hit rate for anonymous users

---

## 8. � S3 Image Strategy (Deferred to GPT)

**Current Approach**: DTO returns `https://via.placeholder.com/150`  
**Mock Upgrade**: GPT will define:
1. 50 reusable S3 URLs (`s3://cherry-mock/products/img_{01-50}.jpg`)
2. Backend mapping: `productId % 50` to select image
3. Cache-Control headers for browser caching

**No DB changes required**. Images computed at DTO serialization time.

---

## 9. ⚠️ Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Accidental prod deployment | `@Profile("local")` + CI/CD profile check |
| DB overload during insert | Batch size 1000 + connection pool limit 8 |
| Cache staleness | Only cache anonymous responses |
| Missing index performance | Composite index on (created_at, id) |

---

**Next Step**: Provide S3 policy prompt to GPT (unchanged from original).
