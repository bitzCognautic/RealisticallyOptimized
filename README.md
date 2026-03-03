# RealisticallyOptimized Shader

## Overview
RealisticallyOptimized is a stylized, performance-focused shader preset with toon lighting, strong outlines, brighter sky highlights, deeper nights, and improved emissive handling for ores and light sources.

## Features
- Real-time shadow mapping for terrain, entities, textured geometry, and water.
- Toon ramp direct lighting with adjustable shadow darkness and step count.
- Day/night color tinting with global vibrance control.
- White world outline effect in final pass (Complementary-inspired depth-based method).
- Adjustable outline thickness and brightness.
- Brighter sky/sun/moon rendering with preserved geometry separation.
- Darker nighttime grading with optional cool blue weather/night tint.
- Enhanced blocklight contribution across terrain, entities, and textured passes.
- Stronger emissive treatment for major light sources (torch, lantern, glowstone, sea lantern, candles, campfire, etc.).
- Complementary-style glowing ores using per-ore groups and per-pixel ore-part detection:
- Iron, Gold, Copper, Lapis, Emerald, Diamond, Nether Quartz, Nether Gold, Redstone.
- Adjustable ore glow strength (`GLOWING_ORE_MULT`).
- Water shading with toon-lit base and no forced water glow overlay.
- Waving vegetation support via custom block material IDs.

## Install
1. Put `RealisticallyOptimized.zip` in `.minecraft/shaderpacks`.
2. Select `RealisticallyOptimized` in the Iris shader menu.
3. Ensure Shadows are enabled in Iris settings.

## Troubleshooting
- Set Graphics to Fancy or Fabulous.
- Set Shadow Quality to at least 1024.
- Test at noon near a wall and a mob (`/time set noon`).
