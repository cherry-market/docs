 # 1) 상품 생성 쿼리
  INSERT INTO cherry.products (seller_user_id, title, description, price, status, trade_type, created_at, updated_at)
  VALUES (
    1,
    'STARGAZER - The 2nd Mini Album',
    '안녕하세요! 소중하게 보관해온 ''STARGAZER'' 미니 2집 앨범 양도합니다.\n몽환적이고 신비로운 컨셉으로 많은 사랑을 받았던
  앨범입니다.\n파스텔 톤의 커버 아트웍과 금박 로고가 실제로 보면 더 영롱하고 예뻐요.\n\n[구성품]\n- 아웃박스 (Outbox)\n- 포
  토북 (Photobook)\n- CD-R\n- 포토카드 (랜덤 1종 포함)\n\n[상태 상세]\n개봉 후 구성품만 확인하고 바로 opp 봉투에 넣어 보관했
  습니다.\n스크래치나 찍힘 전혀 없는 S급 상태입니다.\nCD는 한 번도 재생하지 않았고, 포토북도 펼침 자국 없이 깨끗합니다.
  \n\n[추천 포인트]\n청량하면서도 아련한 느낌의 ''StarGazer'' 컨셉을 좋아하시는 분들께 강력 추천합니다.\n특히 이번 앨범 자켓
  촬영장이 역대급이라고 소문났던 만큼 소장 가치 충분합니다!\n\n안전하게 뽁뽁이로 포장해서 배송해 드려요.\n편하게 문의 주세
  요! 🍒',
    25000,
    'SELLING',
    'DELIVERY',
    NOW(),
    NOW()
  );
  SET @pid_album_001 = LAST_INSERT_ID();

  # 2) 이미지 쿼리
  INSERT INTO cherry.product_images (product_id, image_url, image_order, is_thumbnail, created_at, updated_at)
  VALUES
  (@pid_album_001, 'https://cheryi-product-images-prod.s3.ap-northeast-2.amazonaws.com/mock/products/images/thumb/image_album_001_0_thumbnail_e8a2b4f9.jpg', 0, true, NOW(), NOW()),
  (@pid_album_001, 'https://cheryi-product-images-prod.s3.ap-northeast-2.amazonaws.com/mock/products/images/detail/image_album_001_0_e8a2b4f9.jpg', 1, false, NOW(), NOW()),
  (@pid_album_001, 'https://cheryi-product-images-prod.s3.ap-northeast-2.amazonaws.com/mock/products/images/detail/image_album_001_1_b3a9c1d2.jpg', 2, false, NOW(), NOW()),
  (@pid_album_001, 'https://cheryi-product-images-prod.s3.ap-northeast-2.amazonaws.com/mock/products/images/detail/image_album_001_2_f4a8b2c1.jpg', 3, false, NOW(), NOW());

  # 3) 태그 쿼리
  INSERT IGNORE INTO cherry.tags (name, created_at, updated_at) VALUES
  ('album', NOW(), NOW()),
  ('cd', NOW(), NOW()),
  ('music', NOW(), NOW());

  SET @tag_album = (SELECT id FROM cherry.tags WHERE name = 'album');
  SET @tag_cd = (SELECT id FROM cherry.tags WHERE name = 'cd');
  SET @tag_music = (SELECT id FROM cherry.tags WHERE name = 'music');

  INSERT INTO cherry.product_tags (product_id, tag_id, created_at, updated_at) VALUES
  (@pid_album_001, @tag_album, NOW(), NOW()),
  (@pid_album_001, @tag_cd, NOW(), NOW()),
  (@pid_album_001, @tag_music, NOW(), NOW());
  
  # 카테고리 시드
  INSERT IGNORE INTO cherry.categories (code, display_name, is_active, sort_order, created_at, updated_at) VALUES
  ('album', '앨범', 1, 1, NOW(), NOW()),
  ('photocard', '포토카드', 1, 2, NOW(), NOW()),
  ('lightstick', '응원봉', 1, 3, NOW(), NOW()),
  ('doll_keyring', '인형/키링', 1, 4, NOW(), NOW()),
  ('fashion_goods', '패션 굿즈', 1, 5, NOW(), NOW());
  
  # products에 category_id 추가 + FK
  ALTER TABLE cherry.products ADD COLUMN category_id BIGINT NULL;
  ALTER TABLE cherry.products
    ADD CONSTRAINT fk_products_category_id FOREIGN KEY (category_id) REFERENCES cherry.categories(id);

  # 기존 상품 1건에 카테고리 적용
  UPDATE cherry.products p
  JOIN cherry.categories c ON c.code = 'album'
  SET p.category_id = c.id
  WHERE p.id = @pid_album_001;