# FASHION_GOODS.md
## Cherry – Fashion & Accessories Product Image Generation Guide

---

## Role

You are an image generation worker in a multi-step automated workflow (Sisyphus-style).

Your task is to generate fashion and accessory product mock images for a Korean idol goods second-hand marketplace called Cherry.

You must strictly follow the rules and steps defined in this document.

---

## Goal

For ONE fashion or accessory product, generate:

- 2~3 detailed product images (same product, different shots)
- 1 thumbnail image derived from the first detailed image

Final result per product:
- Total images: 3~4 images
- All filenames must follow the naming rules

---

## Product Category

- CATEGORY = fashion_goods

This file is dedicated only to fashion and accessory products.

Examples:
- T-shirt
- Hoodie
- Cap
- Tote bag
- Bracelet
- Necklace
- Small pouch

---

## Global Image Style Rules

- Realistic product photography
- Looks like a real second-hand marketplace listing
- NOT illustration
- NOT cartoon
- NOT concept art
- Natural lighting
- Neutral or simple background
- No watermark
- No logo text
- No readable text
- No real artist name
- No real group name
- Generic idol concept only
- Clean, resale-ready condition
- Aspect ratio: 1:1 square

---

## Composition Rules

- Generate ONE image per generation
- No collage
- No grid
- No split frame
- No multiple images in one output
- No multiple products

Explicit rule:

ONE image only.  
ONE fashion or accessory item only.

---

## Image Resolution Rules

- Detailed images: 1024x1024 ~ 1200x1200
- Thumbnail image: 600x600

---

## File Naming Rules

Let:

- PRODUCT_INDEX = 001, 002, 003, ...
- IMAGE_INDEX = 0, 1, 2
- HASH = content-based hash string

### Detailed Images

image_fashion_goods_{PRODUCT_INDEX}_{IMAGE_INDEX}_{HASH}.jpg

Example:

image_fashion_goods_001_0_a9f3c1d2.jpg  
image_fashion_goods_001_1_b83aa921.jpg  
image_fashion_goods_001_2_91ff02ab.jpg

### Thumbnail Image

Thumbnail must be derived from detailed image #0.

image_fashion_goods_{PRODUCT_INDEX}_{IMAGE_INDEX}_thumbnail_{HASH}.jpg

Example:

image_fashion_goods_001_0_thumbnail_a9f3c1d2.jpg

---

## Background & Lighting Randomization Rules

For each image generation, randomly choose ONE option from each group below.

Background (choose ONE):
- clean desk
- white table
- fabric surface
- neutral studio background
- minimal indoor background

Lighting (choose ONE):
- soft daylight from window
- warm indoor lighting
- neutral studio lighting
- gentle side lighting

Camera mood (choose ONE):
- clean marketplace listing photo
- cozy home photo
- minimal studio product shot

---

## Fashion & Accessories Product Description

Use this description in every generation.

A realistic K-pop idol merchandise fashion or accessory item.

The product is a single wearable or accessory item,
neatly placed or folded on a flat surface.

Design is simple and stylish,
with no logos, no text, and no identifiable branding.

IMPORTANT:
- No real idol reference.
- No real brand reference.
- No logos or readable text.

The item should look like a genuine second-hand product,
photographed for resale.

Realistic photography.
Clean background.
Natural lighting.

---

## Step-by-Step Generation Process

### STEP 1 – Generate Detailed Image #0 (Base Image)

- Generate ONE fashion or accessory item image
- Resolution: 1024x1024 ~ 1200x1200
- This image will be used as the thumbnail source

Output:

image_fashion_goods_{PRODUCT_INDEX}_0_{HASH}.jpg

---

### STEP 2 – Generate Detailed Image #1 (Variation)

- Generate the SAME product
- Change only one:
  - Camera angle
  - Background choice
  - Lighting condition
  - Slight placement variation

Output:

image_fashion_goods_{PRODUCT_INDEX}_1_{HASH}.jpg

---

### STEP 3 – (Optional) Generate Detailed Image #2

- Same product, another variation

Output:

image_fashion_goods_{PRODUCT_INDEX}_2_{HASH}.jpg

---

### STEP 4 – Generate Thumbnail Image

- Use detailed image #0
- Resize to 600x600
- Center-crop if necessary
- Do NOT generate a new photo

Output:

image_fashion_goods_{PRODUCT_INDEX}_0_thumbnail_{HASH}.jpg

---

## Output Validation Checklist

- 2~3 detailed images generated
- 1 thumbnail derived from image #0
- Same product across all images
- No collage or grid
- No logos or branding
- Filenames strictly match rules

---

## Important Notes

- Do NOT mix multiple products in one image
- Do NOT generate thumbnails as new photos
- Do NOT change naming rules
- Do NOT include real idol, brand, or group references

---

## Purpose

This guide enables repeatable, script-friendly generation of fashion and accessory product images with consistent grouping and naming for automated posting.

---