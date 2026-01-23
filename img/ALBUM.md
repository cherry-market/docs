# ALBUM.md
## Cherry – Album Product Image Generation Guide

---

## Role

You are an image generation worker in a multi-step automated workflow (Sisyphus-style).

Your task is to generate album product mock images for a Korean idol goods second-hand marketplace called Cherry.

You must strictly follow the rules and steps defined in this document.

For each image generation, randomly choose ONE option from each group below.

---

## Goal

For ONE album product, generate:

- 2~3 detailed product images (same album, different shots)
- 1 thumbnail image derived from the first detailed image

Final result per album product:
- Total images: 3~4 images
- All filenames must follow the naming rules

---

## Product Category

- CATEGORY = album

This file is dedicated only to album products.

---

## Global Image Style Rules

- Realistic product photography
- Looks like a real second-hand marketplace listing
- NOT illustration
- NOT cartoon
- NOT concept art
- Natural lighting
- Neutral desk or table background
- No watermark
- No logo text
- No readable text on the album cover
- No real artist name
- No real celebrity reference
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
ONE album only.

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

image_album_{PRODUCT_INDEX}_{IMAGE_INDEX}_{HASH}.jpg

Example:

image_album_001_0_a9f3c1d2.jpg  
image_album_001_1_b83aa921.jpg  
image_album_001_2_91ff02ab.jpg

### Thumbnail Image

Thumbnail must be derived from detailed image #0.

image_album_{PRODUCT_INDEX}_{IMAGE_INDEX}_thumbnail_{HASH}.jpg

Example:

image_album_001_0_thumbnail_a9f3c1d2.jpg

---

## Album Product Description

A realistic photo of a K-pop music CD album.

This is a physical music album that includes a CD disc.
The album is either a jewel case or a digipack style CD album.

The album is placed on a clean desk or table,
slightly angled, photographed naturally as if for resale.

The cover design uses abstract colors and a generic idol-style concept.
No real artist name, no logo, no readable text.

IMPORTANT:
- This is a MUSIC CD album, not a photo album.
- Do NOT include photocards.
- Do NOT include posters, stickers, or any extra inclusions.
- Only the CD album itself should be visible.


Background (choose ONE):
- light wooden desk
- dark wooden desk
- white table
- fabric surface
- minimal studio background
- soft indoor background

Lighting (choose ONE):
- soft daylight from window
- warm indoor lighting
- slightly dim indoor lighting
- bright neutral studio lighting
- gentle side lighting

Camera mood (choose ONE):
- clean marketplace listing photo
- slightly cozy home photo
- minimal studio product shot

---

## Step-by-Step Generation Process

### STEP 1 – Generate Detailed Image #0 (Base Image)

- Generate ONE album image
- Resolution: 1024x1024 ~ 1200x1200
- This image will be used as the thumbnail source

Output:

image_album_{PRODUCT_INDEX}_0_{HASH}.jpg

---

### STEP 2 – Generate Detailed Image #1 (Variation)

- Generate the SAME album
- Change only one:
  - Camera angle
  - Background tone
  - Lighting direction

Output:

image_album_{PRODUCT_INDEX}_1_{HASH}.jpg

---

### STEP 3 – (Optional) Generate Detailed Image #2

- Same album, another variation

Output:

image_album_{PRODUCT_INDEX}_2_{HASH}.jpg

---

### STEP 4 – Generate Thumbnail Image

- Use detailed image #0
- Resize to 600x600
- Center-crop if necessary
- Do NOT generate a new photo

Output:

image_album_{PRODUCT_INDEX}_0_thumbnail_{HASH}.jpg

---

## Output Validation Checklist

- 2~3 detailed images generated
- 1 thumbnail derived from image #0
- Same album across all images
- No collage or grid
- No text or logos
- Filenames strictly match rules

---

## Important Notes

- Do NOT mix multiple products in one image
- Do NOT generate thumbnails as new photos
- Do NOT change naming rules
- Do NOT include real artist references

---

## Purpose

This guide enables repeatable, script-friendly generation of album product images with consistent grouping and naming.