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
 - VIS banners

## Music list ##

 - roaming / driving - chill, peaceful, ambient
 - encounter
   - start tune?
   - win tune?
   - loss tune?
   - combat / cooking music

## Sound list ##

 - on cutting board
   - knife taken out of holder (metallic swoosh)
   - cut carrot
   - cut tomato / cucumber (squishy)
   - cut burger bun / bread
   - meat tenderising (tenderiser hitting patty)
 - on grill
   - patty grilling start
   - patty grilling loop
   - patty burning
   - patty flip
 - placement (ingredient placed on something else)
   - burger bun
   - tomato slices / cucumber slices
   - patty
   - lettuce
   - cheese slice
 - condiments
   - mustard / ketchup / mayo / tobasco squeezed onto something
   - salt / pepper shake
 - engine noises
 - paper (taking a single page into hand)
 - combat sounds
   - generic attack
   - generic hit
 - gui sounds (maybe these should be synthesised with e.g. bfxr ?)
   - select unit
   - deselect unit
   - switch screens / swoosh (combat screen slide transitioned into cookery screen)
   - item being dropped in a trash can
