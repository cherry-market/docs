# PHOTOCARD.md
## Cherry – Photocard Product Image Generation Guide

---

## Role

You are an image generation worker in a multi-step automated workflow (Sisyphus-style).

Your task is to generate photocard product mock images for a Korean idol goods second-hand marketplace called Cherry.

You must strictly follow the rules and steps defined in this document.

---

## Goal

For ONE photocard product, generate:

- 2~3 detailed product images (same photocard, different shots)
- 1 thumbnail image derived from the first detailed image

Final result per product:
- Total images: 3~4 images
- All filenames must follow the naming rules

---

## Product Category

- CATEGORY = photocard

This file is dedicated only to photocard products.

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
- No real artist name
- No real celebrity face
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
ONE photocard only.

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

image_photocard_{PRODUCT_INDEX}_{IMAGE_INDEX}_{HASH}.jpg

Example:

image_photocard_001_0_a9f3c1d2.jpg  
image_photocard_001_1_b83aa921.jpg  
image_photocard_001_2_91ff02ab.jpg

### Thumbnail Image

Thumbnail must be derived from detailed image #0.

image_photocard_{PRODUCT_INDEX}_{IMAGE_INDEX}_thumbnail_{HASH}.jpg

Example:

image_photocard_001_0_thumbnail_a9f3c1d2.jpg

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

## Photocard Product Description

Use this description in every generation.

A realistic K-pop idol photocard.

A single rectangular photocard placed on a flat surface.
The photocard shows a generic idol-style portrait.

IMPORTANT:
- The face must NOT resemble any real celebrity.
- No real group name.
- No real artist name.
- No logos or readable text.

The photocard should look like a collectible item sold second-hand.

Realistic photography.
Clean background.
Natural lighting.

---

## Step-by-Step Generation Process

### STEP 1 – Generate Detailed Image #0 (Base Image)

- Generate ONE photocard image
- Resolution: 1024x1024 ~ 1200x1200
- This image will be used as the thumbnail source

Output:

image_photocard_{PRODUCT_INDEX}_0_{HASH}.jpg

---

### STEP 2 – Generate Detailed Image #1 (Variation)

- Generate the SAME photocard
- Change only one:
  - Camera angle
  - Background choice
  - Lighting condition
  - Slight position change

Output:

image_photocard_{PRODUCT_INDEX}_1_{HASH}.jpg

---

### STEP 3 – (Optional) Generate Detailed Image #2

- Same photocard, another variation

Output:

image_photocard_{PRODUCT_INDEX}_2_{HASH}.jpg

---

### STEP 4 – Generate Thumbnail Image

- Use detailed image #0
- Resize to 600x600
- Center-crop if necessary
- Do NOT generate a new photo

Output:

image_photocard_{PRODUCT_INDEX}_0_thumbnail_{HASH}.jpg

---

## Output Validation Checklist

- 2~3 detailed images generated
- 1 thumbnail derived from image #0
- Same photocard across all images
- No collage or grid
- No real celebrity resemblance
- Filenames strictly match rules

---

## Important Notes

- Do NOT mix multiple products in one image
- Do NOT generate thumbnails as new photos
- Do NOT change naming rules
- Do NOT include real idol or group references

---

## Purpose

This guide enables repeatable, script-friendly generation of photocard product images with consistent grouping and naming for automated posting.

---