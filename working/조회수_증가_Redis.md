# 조회수 증가 및 Redis 저장 메커니즘

## 📊 전체 플로우

```mermaid
graph TD
    A[사용자 클릭] --> B[프론트엔드: useProductDetail(id)]
    B --> C[GET /api/products/{id}]
    C --> D[ProductController.getProduct]
    D --> E[ProductService.getProduct]
    E --> F[1. DB에서 상품 조회]
    E --> G[2. Redis에 조회수 증가]
    G --> H[Redis ZSET 업데이트]
```

**상세 단계:**
1. **프론트엔드**: 사용자가 상품을 클릭하면 `useProductDetail` 훅이 작동하여 `GET /api/products/{id}`를 호출합니다.
2. **컨트롤러/서비스**: 백엔드의 `ProductService.getProduct`가 실행됩니다.
3. **데이터 처리**:
    - `productRepository`를 통해 DB에서 상품 정보를 가져옵니다.
    - `productTrendingRepository`를 통해 Redis의 해당 상품 점수(조회수)를 1 증가시킵니다.

---

## 🔍 코드 분석

### 1. ProductService.java (조회수 증가 시작점)

```java
@Transactional
public ProductDetailResponse getProduct(Long productId) {
    // 1. DB에서 상품 조회
    Product product = productRepository.findById(productId)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));

    // 2. 조회수 증가 (Redis에 비동기 저장)
    productTrendingRepository.incrementViewCount(productId);

    // 3. DTO로 변환하여 반환
    return ProductDetailResponse.from(product);
}
```

> [!IMPORTANT]
> **@Transactional**: DB 트랜잭션 내에서 조회가 이루어지며, 조회수 증가는 별도의 저장소(Redis) 작업으로 처리됩니다.

### 2. RedisProductTrendingRepository.java (Redis 저장 로직)

```java
@Repository
@RequiredArgsConstructor
public class RedisProductTrendingRepository implements ProductTrendingRepository {
    
    private final StringRedisTemplate redisTemplate;
    private static final String TRENDING_KEY = "trending:views:24h";

    @Override
    public void incrementViewCount(Long productId) {
        // Redis ZSET에 Score +1
        redisTemplate.opsForZSet().incrementScore(
            TRENDING_KEY,           // Key: "trending:views:24h"
            productId.toString(),   // Member: 상품 ID
            1.0                     // Score 증가량
        );
    }
}
```

---

## 🗄️ Redis 데이터 구조

### ZSET (Sorted Set) 사용
Redis의 `ZSET`은 Member(상품 ID)와 Score(조회수)를 쌍으로 저장하며, Score를 기준으로 자동 정렬됩니다.

**저장 예시:**
- **Key**: `trending:views:24h`
- **Structure**:
| Member (상품 ID) | Score (조회수) |
| :--- | :--- |
| "999" | 5 |
| "1" | 3 |
| "2" | 2 |

---

## ⏱️ 24시간 윈도우 관리 (현황 및 개선방안)

### 현재 구현
- **Key**: `trending:views:24h` (고정값)
- **TTL**: 설정되어 있지 않음 (데이터가 누적됨)

### 개선 방안 (P1)
1. **TTL 설정**: 키 생성 시 24시간 후 만료되도록 설정
2. **일별 키 분리**: `trending:views:2026-01-21`과 같이 날짜별로 관리

---

## 🧪 Redis 확인 방법

실제로 데이터가 잘 쌓이고 있는지 Redis CLI를 통해 확인할 수 있습니다.

```bash
# 특정 상품의 현재 조회수 확인
ZSCORE trending:views:24h "999"

# 점수가 높은 순으로 상위 10개 조회
ZREVRANGE trending:views:24h 0 9 WITHSCORES
```

---

## 📝 요약

| 항목 | 설명 |
| :--- | :--- |
| **트리거** | 상세 페이지 진입 (`GET /api/products/{id}`) |
| **저장소** | Redis (ZSET 구조) |
| **Key** | `trending:views:24h` |
| **로직** | `ZINCRBY` (기존 점수에 +1) |
| **정렬** | 조회수 내림차순 자동 정렬 |