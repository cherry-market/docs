# Product Upload & AI Write Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 모바일 기준으로 상품 이미지 업로드, 상품 등록, AI 설명 생성까지 동작하는 Phase 5 기능을 완성한다.  
**Architecture:** 클라이언트 pre‑signed 업로드 → S3 이벤트 → Lambda 리사이즈 → 내부 콜백으로 DB 반영 → 리스트/상세는 썸네일/상세 URL만 사용한다.  
**Tech Stack:** Spring Boot 3, JPA, AWS SDK v2(S3 Presigner), React(Vite), Zustand

---

### Task 1: ProductImage 스키마/DTO 매핑 업데이트

**Files:**
- Modify: `cherry-server/src/main/java/com/cherry/server/product/domain/ProductImage.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductSummaryResponse.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductDetailResponse.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/dev/seed/SeedDataGenerator.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/dev/seed/SeedJdbcSeeder.java`
- Test: `cherry-server/src/test/java/com/cherry/server/product/ProductImageMappingTest.java`

**Step 1: Write the failing test**

```java
class ProductImageMappingTest {
    @Test
    void summary_uses_thumbnail_url_when_present() {
        User seller = User.builder().email("a@a.com").nickname("seller").password("pw").build();
        Category category = Category.builder().code("PHOTO").displayName("포토카드").isActive(true).sortOrder(1).build();
        Product product = Product.builder()
                .seller(seller).title("t").description("d").price(1000)
                .status(ProductStatus.SELLING).tradeType(TradeType.DIRECT).category(category)
                .build();
        ProductImage image = ProductImage.builder()
                .product(product)
                .imageUrl("https://cdn/detail.jpg")
                .thumbnailUrl("https://cdn/thumb.jpg")
                .imageOrder(0)
                .isThumbnail(true)
                .build();
        product.getImages().add(image);

        ProductSummaryResponse dto = ProductSummaryResponse.from(product, false, 0L, List.of());
        assertThat(dto.thumbnailUrl()).isEqualTo("https://cdn/thumb.jpg");
    }
}
```

**Step 2: Run test to verify it fails**

Run: `.\gradlew test --tests com.cherry.server.product.ProductImageMappingTest`  
Expected: FAIL (thumbnailUrl가 null)

**Step 3: Write minimal implementation**

```java
@Column(name = "original_url", length = 500)
private String originalUrl;

@Column(name = "thumbnail_url", length = 500)
private String thumbnailUrl;

@Column(name = "image_url", length = 500)
private String imageUrl; // nullable 허용
```

```java
thumbnailUrl(product.getImages().stream()
    .filter(ProductImage::isThumbnail)
    .findFirst()
    .map(img -> img.getThumbnailUrl() != null ? img.getThumbnailUrl() : img.getImageUrl())
    .orElse(null))
```

```java
imageUrls(product.getImages().stream()
    .map(ProductImage::getImageUrl)
    .filter(Objects::nonNull)
    .sorted(Comparator.comparingInt(ProductImage::getImageOrder))
    .toList())
```

**Step 4: Run test to verify it passes**

Run: `.\gradlew test --tests com.cherry.server.product.ProductImageMappingTest`  
Expected: PASS

**Step 5: Commit**

```bash
git add cherry-server/src/main/java/com/cherry/server/product/domain/ProductImage.java \
        cherry-server/src/main/java/com/cherry/server/product/dto/ProductSummaryResponse.java \
        cherry-server/src/main/java/com/cherry/server/product/dto/ProductDetailResponse.java \
        cherry-server/src/test/java/com/cherry/server/product/ProductImageMappingTest.java
git commit -m "feat: add original/thumbnail urls to product images"
```

---

### Task 2: 업로드 준비 API (pre‑signed URL)

**Files:**
- Create: `cherry-server/src/main/java/com/cherry/server/upload/dto/UploadImagesRequest.java`
- Create: `cherry-server/src/main/java/com/cherry/server/upload/dto/UploadImagesResponse.java`
- Create: `cherry-server/src/main/java/com/cherry/server/upload/UploadController.java`
- Create: `cherry-server/src/main/java/com/cherry/server/upload/UploadService.java`
- Create: `cherry-server/src/main/java/com/cherry/server/upload/StorageProperties.java`
- Modify: `cherry-server/build.gradle`
- Modify: `cherry-server/src/main/resources/application-local.yml`
- Test: `cherry-server/src/test/java/com/cherry/server/upload/UploadControllerTest.java`

**Step 1: Write the failing test**

```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class UploadControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean UploadService uploadService;

    @Test
    void rejects_invalid_content_type() throws Exception {
        String payload = """
        {"files":[{"fileName":"a.gif","contentType":"image/gif","size":1024}]}
        """;
        mockMvc.perform(post("/api/upload/images")
                .contentType(MediaType.APPLICATION_JSON)
                .content(payload))
            .andExpect(status().isBadRequest());
    }
}
```

**Step 2: Run test to verify it fails**

Run: `.\gradlew test --tests com.cherry.server.upload.UploadControllerTest`  
Expected: FAIL (endpoint 없음)

**Step 3: Write minimal implementation**

```java
public record UploadImagesRequest(
    @Size(min = 1, max = 10) List<FileMeta> files
) {
  public record FileMeta(
      @NotBlank String fileName,
      @Pattern(regexp = "image/(jpeg|png|webp)") String contentType,
      @Positive @Max(10_485_760) long size
  ) {}
}
```

```java
@PostMapping("/api/upload/images")
public UploadImagesResponse prepare(
    @AuthenticationPrincipal UserPrincipal principal,
    @Valid @RequestBody UploadImagesRequest request
) {
    return uploadService.prepare(request);
}
```

```gradle
implementation 'software.amazon.awssdk:s3'
implementation 'software.amazon.awssdk:s3-presigner'
```

**Step 4: Run test to verify it passes**

Run: `.\gradlew test --tests com.cherry.server.upload.UploadControllerTest`  
Expected: PASS

**Step 5: Commit**

```bash
git add cherry-server/src/main/java/com/cherry/server/upload \
        cherry-server/build.gradle
git commit -m "feat: add upload prepare api with presigned urls"
```

---

### Task 3: 상품 등록 API

**Files:**
- Modify: `cherry-server/src/main/java/com/cherry/server/product/controller/ProductController.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/service/ProductService.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/repository/TagRepository.java`
- Create: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductCreateRequest.java`
- Create: `cherry-server/src/main/java/com/cherry/server/product/dto/ProductCreateResponse.java`
- Test: `cherry-server/src/test/java/com/cherry/server/product/ProductCreateApiTest.java`

**Step 1: Write the failing test**

```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ProductCreateApiTest {
  @Autowired MockMvc mockMvc;

  @Test
  void rejects_missing_category() throws Exception {
    String payload = """
    {"title":"t","price":1000,"description":"d","tradeType":"DIRECT","imageKeys":[],"tags":[]}
    """;
    mockMvc.perform(post("/products").contentType(MediaType.APPLICATION_JSON).content(payload))
      .andExpect(status().isBadRequest());
  }
}
```

**Step 2: Run test to verify it fails**

Run: `.\gradlew test --tests com.cherry.server.product.ProductCreateApiTest`  
Expected: FAIL (endpoint 없음)

**Step 3: Write minimal implementation**

```java
public record ProductCreateRequest(
    @NotBlank @Size(min = 2) String title,
    @PositiveOrZero int price,
    String description,
    @NotNull Long categoryId,
    @NotNull TradeType tradeType,
    @Size(max = 10) List<String> imageKeys,
    List<String> tags
) {}
```

```java
@PostMapping
public ResponseEntity<ProductCreateResponse> createProduct(
    @AuthenticationPrincipal UserPrincipal principal,
    @Valid @RequestBody ProductCreateRequest request
) {
    return ResponseEntity.status(HttpStatus.CREATED).body(productService.createProduct(principal.id(), request));
}
```

**Step 4: Run test to verify it passes**

Run: `.\gradlew test --tests com.cherry.server.product.ProductCreateApiTest`  
Expected: PASS

**Step 5: Commit**

```bash
git add cherry-server/src/main/java/com/cherry/server/product \
        cherry-server/src/test/java/com/cherry/server/product/ProductCreateApiTest.java
git commit -m "feat: add product create api"
```

---

### Task 4: 이미지 처리 완료 콜백 API (내부)

**Files:**
- Create: `cherry-server/src/main/java/com/cherry/server/upload/dto/ImageCallbackRequest.java`
- Create: `cherry-server/src/main/java/com/cherry/server/upload/ImageCallbackController.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/security/SecurityConfig.java`
- Modify: `cherry-server/src/main/java/com/cherry/server/product/repository/ProductImageRepository.java`
- Test: `cherry-server/src/test/java/com/cherry/server/upload/ImageCallbackApiTest.java`

**Step 1: Write the failing test**

```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ImageCallbackApiTest {
  @Autowired MockMvc mockMvc;

  @Test
  void rejects_missing_internal_token() throws Exception {
    String payload = """
    {"imageKey":"products/original/1.jpg","detailUrl":"d","thumbnailUrl":"t","imageOrder":0,"isThumbnail":true}
    """;
    mockMvc.perform(post("/internal/images/complete")
            .contentType(MediaType.APPLICATION_JSON)
            .content(payload))
        .andExpect(status().isUnauthorized());
  }
}
```

**Step 2: Run test to verify it fails**

Run: `.\gradlew test --tests com.cherry.server.upload.ImageCallbackApiTest`  
Expected: FAIL (endpoint 없음)

**Step 3: Write minimal implementation**

```java
@PostMapping("/internal/images/complete")
public ResponseEntity<Void> complete(
    @RequestHeader("X-Internal-Token") String token,
    @Valid @RequestBody ImageCallbackRequest request
) {
    if (!token.equals(internalToken)) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
    imageCallbackService.apply(request);
    return ResponseEntity.noContent().build();
}
```

```java
@Query("select pi from ProductImage pi where pi.originalUrl = :originalUrl")
Optional<ProductImage> findByOriginalUrl(@Param("originalUrl") String originalUrl);
```

**Step 4: Run test to verify it passes**

Run: `.\gradlew test --tests com.cherry.server.upload.ImageCallbackApiTest`  
Expected: PASS

**Step 5: Commit**

```bash
git add cherry-server/src/main/java/com/cherry/server/upload \
        cherry-server/src/main/java/com/cherry/server/security/SecurityConfig.java \
        cherry-server/src/main/java/com/cherry/server/product/repository/ProductImageRepository.java
git commit -m "feat: add internal image callback api"
```

---

### Task 5: AI 설명 생성 API

**Files:**
- Create: `cherry-server/src/main/java/com/cherry/server/ai/AiController.java`
- Create: `cherry-server/src/main/java/com/cherry/server/ai/AiService.java`
- Create: `cherry-server/src/main/java/com/cherry/server/ai/dto/AiGenerateRequest.java`
- Create: `cherry-server/src/main/java/com/cherry/server/ai/dto/AiGenerateResponse.java`
- Test: `cherry-server/src/test/java/com/cherry/server/ai/AiControllerTest.java`

**Step 1: Write the failing test**

```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AiControllerTest {
  @Autowired MockMvc mockMvc;

  @Test
  void returns_generated_description() throws Exception {
    String payload = """
    {"keywords":"아이브, 장원영, 포카","category":"PHOTOCARD"}
    """;
    mockMvc.perform(post("/api/ai/generate-description")
            .contentType(MediaType.APPLICATION_JSON).content(payload))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.generatedDescription").isNotEmpty());
  }
}
```

**Step 2: Run test to verify it fails**

Run: `.\gradlew test --tests com.cherry.server.ai.AiControllerTest`  
Expected: FAIL

**Step 3: Write minimal implementation**

```java
public AiGenerateResponse generate(AiGenerateRequest request) {
    String text = "판매글: " + request.keywords() + " (카테고리: " + request.category() + ")";
    return new AiGenerateResponse(text);
}
```

**Step 4: Run test to verify it passes**

Run: `.\gradlew test --tests com.cherry.server.ai.AiControllerTest`  
Expected: PASS

**Step 5: Commit**

```bash
git add cherry-server/src/main/java/com/cherry/server/ai \
        cherry-server/src/test/java/com/cherry/server/ai/AiControllerTest.java
git commit -m "feat: add ai description generate api"
```

---

### Task 6: 프론트 업로드/AI 연동

**Files:**
- Modify: `cherry-client/shared/services/productApi.ts`
- Modify: `cherry-client/features/product/pages/ProductWrite.tsx`
- Modify: `cherry-client/features/product/pages/AIProductWrite.tsx`

**Step 1: Write the failing test**

Frontend 테스트 인프라가 없으므로 생략 (수동 검증으로 대체).

**Step 2: Run test to verify it fails**

N/A

**Step 3: Write minimal implementation**

```ts
export const productApi = {
  prepareUpload: (token: string, files: UploadFileMeta[]) =>
    api.authenticatedPost<UploadImagesResponse>('/api/upload/images', token, { files }),
  createProduct: (token: string, body: ProductCreateRequest) =>
    api.authenticatedPost<ProductCreateResponse>('/products', token, body),
  generateDescription: (token: string, body: AiGenerateRequest) =>
    api.authenticatedPost<AiGenerateResponse>('/api/ai/generate-description', token, body),
};
```

```tsx
// ProductWrite.tsx 업로드 흐름
const inputRef = useRef<HTMLInputElement>(null);
const handleImageUpload = () => inputRef.current?.click();
const handleFilesSelected = async (e: React.ChangeEvent<HTMLInputElement>) => {
  const files = Array.from(e.target.files ?? []);
  // prepareUpload → S3 PUT → imageKeys 저장
};
```

**Step 4: Run test to verify it passes**

수동 검증:
1) `/products/new`에서 1~2장 업로드 → 미리보기 표시
2) 등록 → 리스트에서 썸네일 확인
3) 상세에서 이미지 슬라이더 확인
4) AI 글 작성에서 결과 적용 확인

**Step 5: Commit**

```bash
git add cherry-client/shared/services/productApi.ts \
        cherry-client/features/product/pages/ProductWrite.tsx \
        cherry-client/features/product/pages/AIProductWrite.tsx
git commit -m "feat: integrate upload and ai write in client"
```
