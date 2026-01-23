-- ======================================================================================
-- Cherry Mock Data Insert Script
-- 
-- [개요]
-- 이 스크립트는 목업 이미지와 메타데이터를 기반으로 상품 및 상품 이미지를 등록합니다.
-- Product 엔티티에는 category 필드가 없으나, 요청사항에 따라 SQL에는 포함하였습니다.
-- 실제 실행 전 DB 스키마에 해당 컬럼 및 테이블(product_images)이 존재하는지 확인해야 합니다.
-- 
-- [Placeholder 규칙]
-- {PRODUCT_INDEX}: 파일명에서 추출한 숫자 (예: 001) -> Product ID로 사용 권장하거나 Auto Inc 사용
-- {CATEGORY}: 파일명에서 추출 (album, photocard 등)
-- {TITLE}: .md 파일의 [상품명]
-- {DESCRIPTION}: .md 파일의 전체 내용
-- {PRICE}: 랜덤 생성 (예: 15000)
-- {HASH}: 파일명 해시값
-- ======================================================================================

START TRANSACTION;

-- --------------------------------------------------------------------------------------
-- 1. Helper: 유령 판매자 생성 (Seller ID: 1 ~ 50)
-- --------------------------------------------------------------------------------------
-- 비밀번호는 BCrypt 더미 ('$2a$10$...')
INSERT IGNORE INTO users (id, email, nickname, password, created_at, updated_at)
VALUES (1, 'mock_seller_01@cherry.com', 'MockSeller01', '$2a$10$dummyhashvalue', NOW(), NOW());


-- --------------------------------------------------------------------------------------
-- 2. 상품 (Products) & 이미지 (Product_Images) 등록
-- --------------------------------------------------------------------------------------
-- 각 섹션은 하나의 상품 세트입니다.

-- [Example 1: Fashion Goods 001]
-- Source: image_fashion_goods_001.md
INSERT INTO products (
    seller_user_id, 
    title, 
    description, 
    price, 
    status, 
    trade_type, 
    category,  -- 주의: 현재 Product.java에는 없음 (Schema Update 필요)
    created_at, 
    updated_at
) VALUES (
    1, 
    '데일리 심플 로고 볼캡 모자 (블랙)', 
    '아이돌 공항 패션 느낌 나는 깔끔한 블랙 볼캡입니다.\n군더더기 없는 디자인이라 남녀공용으로 쓰기 좋아요.\n상태: 시착 1회 (새상품급)', 
    15000, 
    'SELLING', 
    'DELIVERY', 
    'fashion_goods', 
    NOW() - INTERVAL FLOOR(RAND() * 30) DAY, 
    NOW()
);

-- Last Insert ID Capture (MySQL)
SET @pid_fashion_001 = LAST_INSERT_ID();

-- Images for Fashion Goods 001
-- 규칙: thumbnail (idx 0), detail 0, detail 1, detail 2 ...
INSERT INTO product_images (product_id, image_url, image_order, is_thumbnail) VALUES
(@pid_fashion_001, 'https://s3.ap-northeast-2.amazonaws.com/cherry-mock/fashion_goods/image_fashion_goods_001_0_thumbnail_{HASH}.jpg', 0, true),
(@pid_fashion_001, 'https://s3.ap-northeast-2.amazonaws.com/cherry-mock/fashion_goods/image_fashion_goods_001_0_{HASH}.jpg', 1, false),
(@pid_fashion_001, 'https://s3.ap-northeast-2.amazonaws.com/cherry-mock/fashion_goods/image_fashion_goods_001_1_{HASH}.jpg', 2, false);


-- [Example 2: Photocard 001]
-- Source: image_photocard_001.md
INSERT INTO products (
    seller_user_id, title, description, price, status, trade_type, category, created_at, updated_at
) VALUES (
    1, 
    'STARSTRUCK 앨범 - \'JAE\' 손가락 하트 포토카드', 
    '팬들 사이에서 갈망 포카로 불리는 \'JAE\'의 손가락 하트 버전입니다!\n하자 없음 (빛 비춤 인증 가능)\n최상급 컨디션입니다.', 
    55000, 
    'SELLING', 
    'DIRECT', 
    'photocard', 
    NOW() - INTERVAL FLOOR(RAND() * 30) DAY, 
    NOW()
);
SET @pid_photo_001 = LAST_INSERT_ID();

INSERT INTO product_images (product_id, image_url, image_order, is_thumbnail) VALUES
(@pid_photo_001, 'https://s3.ap-northeast-2.amazonaws.com/cherry-mock/photocard/image_photocard_001_0_thumbnail_{HASH}.jpg', 0, true),
(@pid_photo_001, 'https://s3.ap-northeast-2.amazonaws.com/cherry-mock/photocard/image_photocard_001_0_{HASH}.jpg', 1, false),
(@pid_photo_001, 'https://s3.ap-northeast-2.amazonaws.com/cherry-mock/photocard/image_photocard_001_1_{HASH}.jpg', 2, false);


-- [TEMPLATE: Use this logic for loop generation]
-- INSERT INTO products (seller_user_id, title, description, price, status, trade_type, category, created_at, updated_at)
-- VALUES (1, '{TITLE}', '{DESCRIPTION}', {PRICE}, 'SELLING', 'DELIVERY', '{CATEGORY}', NOW(), NOW());
-- SET @new_pid = LAST_INSERT_ID();
-- INSERT INTO product_images (product_id, image_url, image_order, is_thumbnail) VALUES
-- (@new_pid, '{S3_PATH}/{CATEGORY}/image_{CATEGORY}_{PRODUCT_INDEX}_0_thumbnail_{HASH}.jpg', 0, true),
-- (@new_pid, '{S3_PATH}/{CATEGORY}/image_{CATEGORY}_{PRODUCT_INDEX}_0_{HASH}.jpg', 1, false),
-- (@new_pid, '{S3_PATH}/{CATEGORY}/image_{CATEGORY}_{PRODUCT_INDEX}_1_{HASH}.jpg', 2, false);

COMMIT;
