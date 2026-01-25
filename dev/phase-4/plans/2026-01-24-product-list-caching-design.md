# Product List Caching Design (Phase 4)

## Goals
- Reduce DB load and response time for `GET /products` and `GET /me/likes` with cursor-based pagination.
- Align with Big Tech patterns: Cache-Aside + TTL + write-time invalidation.
- Keep correctness acceptable for list UX (allowing slight staleness for counts).

## Scope
- Cache list responses for:
  - `GET /products`
  - `GET /me/likes`
- Do **not** cache images (handled by AWS/browser cache).
- Do **not** cache per-user `isLiked`; compute on request.
- Allow stale `likeCount` from cache.

## Architecture
- Redis (single-node, local on EC2) via Spring Data Redis (Lettuce).
- Cache-Aside pattern:
  1) Read cache first.
  2) On miss, query DB and populate cache.
  3) On cache failure, fall back to DB without failing the request.
- TTL: 5 minutes.
- Invalidation: write-time delete + TTL as a safety net.

## Cache Key Strategy
- Key format (A):
  - `products:list:{cursor}:{filters}:{sortBy}:{limit}`
- Likes list:
  - `likes:list:{userId}:{cursor}:{limit}`
- `filters` is a normalized string from `ProductSearchCondition`:
  - Example: `status=SELLING|category=ACRYLIC|minPrice=1000|maxPrice=20000|tradeType=DIRECT`
- Same input always generates the same key.

## Data Flow
### GET /products
1. Build cache key from `cursor`, `filters`, `sortBy`, `limit`.
2. Try Redis:
   - Hit: return cached `ProductListResponse`, then compute `isLiked` from DB and apply.
   - Miss: run DB query, build `ProductListResponse`, write to Redis, return.
3. `likeCount` is taken from cache (stale allowed).

### GET /me/likes
1. Build cache key from `userId`, `cursor`, `limit`.
2. Try Redis:
   - Hit: return cached `ProductListResponse`.
   - Miss: run DB query, build response, cache, return.
3. `likeCount` is taken from cache (stale allowed).

## Invalidation Policy
### Immediate invalidation (delete keys)
- Product create/update/delete.
- Like add/remove.

### Strategy
- For simplicity on a single-node Redis: delete by prefix `products:list:*`.
- For likes: delete by prefix `likes:list:{userId}:*` on add/remove.
- TTL ensures eventual consistency even if invalidation fails.

## Error Handling
- Redis read/write/serialization failures:
  - Log error and continue with DB response.
- Invalidation failures:
  - Log error and rely on TTL to refresh.

## Performance Measurement
- Before:
  - Use 100k+ products and complex filter combinations.
  - Record average latency, p95 latency, TPS.
- After:
  - Same scenario with cache enabled.
  - Record Redis hit rate and compare metrics.
- Document in `docs/reports/phase-4/performance_improvement.md` (Phase 4.4).

## Testing Plan
- Unit test for cache key normalization (same params -> same key).
- Service integration test:
  - Cache hit skips DB path.
  - Cache miss populates Redis.
- Avoid broad tests if current test infra is minimal; keep focused.

## Open Questions
- None.
