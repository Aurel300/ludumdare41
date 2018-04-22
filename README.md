# Ludum Dare 41 #
### Combine 2 Incompatible Genres ###

---

Name: **Advance Cookware** (?)

Genres: **Cooking game** / **TBS combat**

Synopsis:

Explore the open-world desert in your cooking bus. Find ingredients, combine them to create recipes with specific characteristics. The resultant dishes can be used as support for your exploration, as stat boosts, or in combat as your units.

Combat is a turn-based (soft time limit) strategy on an isometric grid against enemies of the desert (animals, aliens). To produce your units, you need to cook them during the combat, requiring some time management and multitasking.

---

## Current focus ##

 - cooking
   - assembling burger
     <- burger model + graphics
     <- plates
     <- gui to deploy / trash

## TODO ##

 - gameplay
   - open world - 1h
     - driving
     - encounters
     - locations
     - arcs
   - cooking - 4h
     - [.] methods
     - [.] ingredients
     - timers
     - stats
   - tbs - 2h
     - units
   - overall stats, progression
 - graphics
   - pseudo-3D renderer - 10h
     - [x] walls, floors, tilts
     - [x] simple 3D build method
   - particle effecs
   - [.] time progression via palette shifts
   - cooking
     - [.] cookware
     - [.] ingredients
   - tbs
     - units
   - gui
 - audio
   - sfx
   - voice acting?
   - music

## Bucket ##

 - PERF cull back faces
 - VIS shadows
