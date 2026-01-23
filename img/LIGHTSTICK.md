# LIGHTSTICK.md
## Cherry – Lightstick Product Image Generation Guide

---

## Role

You are an image generation worker in a multi-step automated workflow (Sisyphus-style).

Your task is to generate lightstick product mock images for a Korean idol goods second-hand marketplace called Cherry.

You must strictly follow the rules and steps defined in this document.

For each image generation, randomly choose ONE option from each group below.

---

## Goal

For ONE lightstick product, generate:

- 2~3 detailed product images (same lightstick, different shots)
- 1 thumbnail image derived from the first detailed image

Final result per product:
- Total images: 3~4 images
- All filenames must follow the naming rules

---

## Product Category

- CATEGORY = lightstick

This file is dedicated only to lightstick products.

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
ONE lightstick only.

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

image_lightstick_{PRODUCT_INDEX}_{IMAGE_INDEX}_{HASH}.jpg

Example:

image_lightstick_001_0_a9f3c1d2.jpg  
image_lightstick_001_1_b83aa921.jpg  
image_lightstick_001_2_91ff02ab.jpg

### Thumbnail Image

Thumbnail must be derived from detailed image #0.

image_lightstick_{PRODUCT_INDEX}_{IMAGE_INDEX}_thumbnail_{HASH}.jpg

Example:

image_lightstick_001_0_thumbnail_a9f3c1d2.jpg

---

## Lightstick Product Description

Use this description in every generation.

A realistic photo of a K-pop idol lightstick.

The lightstick is placed on a clean desk or table,
either upright or slightly angled.

The design is simple, modern, and generic,
with a soft glowing light inside the lightstick.

No brand logo, no group name, no text.


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

- Generate ONE lightstick image
- Resolution: 1024x1024 ~ 1200x1200
- This image will be used as the thumbnail source

Output:

image_lightstick_{PRODUCT_INDEX}_0_{HASH}.jpg

---

### STEP 2 – Generate Detailed Image #1 (Variation)

- Generate the SAME lightstick
- Change only one:
  - Camera angle
  - Lighting intensity
  - Lightstick glow brightness
  - Background tone

Output:

image_lightstick_{PRODUCT_INDEX}_1_{HASH}.jpg

---

### STEP 3 – (Optional) Generate Detailed Image #2

- Same lightstick, another variation

Output:

image_lightstick_{PRODUCT_INDEX}_2_{HASH}.jpg

---

### STEP 4 – Generate Thumbnail Image

- Use detailed image #0
- Resize to 600x600
- Center-crop if necessary
- Do NOT generate a new photo

Output:

image_lightstick_{PRODUCT_INDEX}_0_thumbnail_{HASH}.jpg

---

## Output Validation Checklist

- 2~3 detailed images generated
- 1 thumbnail derived from image #0
- Same lightstick across all images
- No collage or grid
- No text, logos, or real group references
- Filenames strictly match rules

---

## Important Notes

- Do NOT mix multiple products in one image
- Do NOT generate thumbnails as new photos
- Do NOT change naming rules
- Do NOT include real idol or group references

---

## Purpose

This guide enables repeatable, script-friendly generation of lightstick product images with consistent grouping and naming for automated posting.

---