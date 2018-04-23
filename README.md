# Ludum Dare 41 #
### Combine 2 Incompatible Genres ###

---

Name: **Advance Cookware** (?)

Genres: **Cooking game** / **TBS combat**

Synopsis:

Explore the open-world desert in your cooking bus. Find ingredients, combine them to create recipes with specific characteristics. The resultant dishes can be used as support for your exploration, as stat boosts, or in combat as your units.

Combat is a turn-based (soft time limit) strategy on an isometric grid against enemies of the desert (animals, aliens). To produce your units, you need to cook them during the combat, requiring some time management and multitasking.

---

## Baseline game scores ##

(for B rank)

 - carrot: 140
 - cucumber: 240
 - tomato: 80
 - tenderise: 50

## Current focus ##

 - tbs win / loss conditions
   - at the beginning of each turn check unit counts
 - end turn button
 - HUD for RV health and turn timer / status
 - HUD for kitchen

## TODO ##

 - gameplay
   - open world
   - tbs
 - graphics
   - particle effecs
   - [.] time progression via palette shifts
   - gui
 - audio
   - sfx
   - music

## Bucket ##

in order of importance

 - GPLY show timer warning when in TBS mode
 - GPLY tutorial / instruction text in bottom left
 - GPLY tooltip in bottom right
 - GPLY / VIS particles for TBS traits / status effects
 - GPLY shift baseline according to skill
 - VIS death animation
 - PERF cull back faces
 - VIS show path in TBS
 - VIS shadows

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
