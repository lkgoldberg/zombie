breed[ zombies zombie ]
breed [ humans human ]

globals [ choice the-humans ]

zombies-own [
  hordemates      ;; agentset of nearby zombies
  nearest-zombie  ;; closest one of our hordemates
  speed
]

humans-own [
  speed
]

;;; SETUP AND GO METHODS ;;;

to setup [ n ]
  clear-all
  set choice n ;; human method of survivial, fight or \

  if (choice = 2) [ ;; for cluster strategy, put purple patches where humans should cluster
    ask patches [
      if (pycor >= 32 and pycor <= 38  and abs((pxcor + 6)) mod 13 <= 3) [ ;; 100% hardcoded smh
        set pcolor violet
      ]
    ]
  ]
  setup-zombies
  setup-humans
  reset-ticks
end


to setup-zombies
  create-zombies z-population [
    set color red
    set size 1
    setxy random-xcor / 2 ceiling (random-ycor / 4) ;; zombies start in bottom quarter of screen
    set heading 0
    set shape  "default"
    set hordemates no-turtles
    set speed zombie-speed
  ]
end


to setup-humans
  create-humans h-population [
    set color green + random 3
    set size 1
    setxy random-xcor random-ycor; (max-pycor - ceiling (random-ycor / 4)) ;; humans start in top quarter of screen
    set shape  "default"
    set speed human-speed



  ]
end


to go
  ifelse not any? humans or not any? zombies ;; stop when only one type of turtle left
  [ stop ]
  [
    ask zombies [ hunt ]
    ask humans [ make-a-choice ]

  ]

    tick

end


;;; HUMAN METHODS ;;;

to make-a-choice
  if (choice = 0) [ fight-zombies ]
  if (choice = 1)  [ flee-zombies ]
  if (choice = 2) [ form-clusters ]
  if (choice = 3) [circle-cluster]
  fd human-speed
end


to fight-zombies ;; TODO: factor out code
  let closest-zombie min-one-of zombies [ distance myself ]
  if closest-zombie != nobody [
    ifelse [ distance myself ] of closest-zombie < shoot-range
    [
      if random 4 > 1 [ ;; kill zombie with 75% chance
        ask closest-zombie [ die ]
      ]
    ]
    [
      ifelse [ distance myself ] of closest-zombie < human-perception
      [ face closest-zombie
        rt 180
        ;fd human-speed
      ]
      [ random-walk human-speed ]
    ]
  ]
end

to form-clusters ;; TODO: factor out code
  let closest-zombie min-one-of zombies [ distance myself ]
  if closest-zombie != nobody [
    ifelse [ distance myself ] of closest-zombie < shoot-range
    [
      if random 4 > 1 [ ;; kill zombie with 75% chance
        ask closest-zombie [ die ]
      ]
    ]
    [
      ifelse [ distance myself ] of closest-zombie < human-perception
      [ face closest-zombie
        rt 180
        ;fd human-speed
      ]
      [
        if pcolor != violet [
          random-walk human-speed
        ]
      ]
    ]
  ]
end



to circle-cluster
  let closest-zombie min-one-of zombies [ distance myself ]
  if closest-zombie != nobody [
    ifelse [ distance myself ] of closest-zombie < shoot-range
    [
      if random 4 > 1 [ ;; kill zombie with 75% chance
        ask closest-zombie [ die ]
      ]
    ]
    [
      ifelse [ distance myself ] of closest-zombie < human-perception
      [ face closest-zombie
        rt 180
        ;fd human-speed
      ]
    [  fd ( pi * 1 / 180 ) * (human-speed )
        rt human-speed
        lt random human-speed

      ]
    ]
  ]
end




to flee-zombies
 let closest-zombie min-one-of zombies [ distance myself ]
 if closest-zombie != nobody [
    ifelse [ distance myself ] of closest-zombie < human-perception
    [
      face closest-zombie  ;;face zombie
      rt 180               ;; turn around
     ; repeat 1 [ask humans [fd human-speed]  display ]     ;; move away
    ]
    [ random-walk human-speed ]
  ]
end


;;; ZOMBIES METHODS ;;;

to hunt  ;; turtle procedure
  find-hordemates
  pursue-humans
  if any? hordemates
  [
    find-nearest-zombie
    if distance nearest-zombie <= minimum-separation
    [ separate ]
  ]
  fd zombie-speed
  convert-human
end


to find-hordemates  ;; turtle procedure
  set hordemates other zombies in-radius zombie-perception
end


to find-nearest-zombie ;; turtle procedure
  set nearest-zombie min-one-of hordemates [ distance myself ]
end


to separate  ;; turtle procedure
  turn-away ([ heading ] of nearest-zombie) max-separate-turn
end


to pursue-humans  ;; turtle procedure
  let closest-human min-one-of humans [ distance myself ]
  ifelse count humans = 0
  [ stop ]
  [
    ifelse [ distance myself ] of closest-human <= zombie-perception
    [
      face closest-human
    ]
    [ random-walk zombie-speed ]
  ]
end


to convert-human  ;; turtle procedure
  ask humans-on patch-here  [
    set breed zombies
    set color violet
    set shape "default"
  ]
end


;;; HELPER PROCEDURES

to random-walk [ walk-speed]
  ifelse not can-move? 1
  [ rt 180 ]
  [ rt random 360 ]
  ;fd walk-speed
end


to turn-towards [ new-heading max-turn ]  ;; turtle procedure
  turn-at-most (subtract-headings new-heading heading) max-turn
end


to turn-away [ new-heading max-turn ]  ;; turtle procedure
  turn-at-most (subtract-headings heading new-heading) max-turn
end


;; turn right by "turn" degrees (or left if "turn" is negative),
;; but never turn more than "max-turn" degrees
to turn-at-most [ turn max-turn ]  ;; turtle procedure
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ] ]
    [ rt turn ]
end


; Code based on Uri Wilensky's flocking model
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
288
43
1106
862
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-40
40
-40
40
1
1
1
ticks
120.0

BUTTON
1290
610
1370
643
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
12
112
235
145
z-population
z-population
1
1000
506.0
5
1
NIL
HORIZONTAL

SLIDER
1
442
234
475
max-separate-turn
max-separate-turn
0.0
80
61.25
0.25
1
degrees
HORIZONTAL

SLIDER
3
362
226
395
vision
vision
0.0
10.0
0.0
0.5
1
patches
HORIZONTAL

SLIDER
1
400
224
433
minimum-separation
minimum-separation
0.0
5.0
5.0
0.25
1
patches
HORIZONTAL

SLIDER
25
75
197
108
h-population
h-population
1
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
1289
566
1390
599
Fight Setup
setup 0
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1287
512
1381
545
Flee Setup
setup 1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
24
162
196
195
human-speed
human-speed
0
1
0.65
0.05
1
NIL
HORIZONTAL

SLIDER
24
199
196
232
zombie-speed
zombie-speed
0
1
0.35
0.05
1
NIL
HORIZONTAL

SLIDER
17
273
189
306
human-perception
human-perception
0
100
12.0
1
1
NIL
HORIZONTAL

SLIDER
14
309
238
342
zombie-perception
zombie-perception
0
100
15.0
1
1
patches
HORIZONTAL

PLOT
1148
45
1646
452
Populations
Time
Count
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"zombies" 1.0 0 -2674135 true "" "plot count zombies"
"humans" 1.0 0 -13840069 true "" "plot count humans"

BUTTON
1290
648
1375
681
Go Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
33
238
205
271
shoot-range
shoot-range
0
20
5.0
1
1
NIL
HORIZONTAL

BUTTON
1258
698
1427
731
Cluster Strategy Setup
setup 2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1305
771
1413
804
Bait and Hook
setup 3
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model is an attempt to mimic the flocking of birds.  (The resulting motion also resembles schools of fish.)  The flocks that appear in this model are not created or led in any way by special leader birds.  Rather, each bird is following exactly the same set of rules, from which flocks emerge.

## HOW IT WORKS

The birds follow three rules: "alignment", "separation", and "cohesion".

"Alignment" means that a bird tends to turn so that it is moving in the same direction that nearby birds are moving.

"Separation" means that a bird will turn to avoid another bird which gets too close.

"Cohesion" means that a bird will move towards other nearby birds (unless another bird is too close).

When two birds are too close, the "separation" rule overrides the other two, which are deactivated until the minimum separation is achieved.

The three rules affect only the bird's heading.  Each bird always moves forward at the same constant speed.

## HOW TO USE IT

First, determine the number of birds you want in the simulation and set the POPULATION slider to that value.  Press SETUP to create the birds, and press GO to have them start flying around.

The default settings for the sliders will produce reasonably good flocking behavior.  However, you can play with them to get variations:

Three TURN-ANGLE sliders control the maximum angle a bird can turn as a result of each rule.

VISION is the distance that each bird can see 360 degrees around it.

## THINGS TO NOTICE

Central to the model is the observation that flocks form without a leader.

There are no random numbers used in this model, except to position the birds initially.  The fluid, lifelike behavior of the birds is produced entirely by deterministic rules.

Also, notice that each flock is dynamic.  A flock, once together, is not guaranteed to keep all of its members.  Why do you think this is?

After running the model for a while, all of the birds have approximately the same heading.  Why?

Sometimes a bird breaks away from its flock.  How does this happen?  You may need to slow down the model or run it step by step in order to observe this phenomenon.

## THINGS TO TRY

Play with the sliders to see if you can get tighter flocks, looser flocks, fewer flocks, more flocks, more or less splitting and joining of flocks, more or less rearranging of birds within flocks, etc.

You can turn off a rule entirely by setting that rule's angle slider to zero.  Is one rule by itself enough to produce at least some flocking?  What about two rules?  What's missing from the resulting behavior when you leave out each rule?

Will running the model for a long time produce a static flock?  Or will the birds never settle down to an unchanging formation?  Remember, there are no random numbers used in this model.

## EXTENDING THE MODEL

Currently the birds can "see" all around them.  What happens if birds can only see in front of them?  The `in-cone` primitive can be used for this.

Is there some way to get V-shaped flocks, like migrating geese?

What happens if you put walls around the edges of the world that the birds can't fly into?

Can you get the birds to fly around obstacles in the middle of the world?

What would happen if you gave the birds different velocities?  For example, you could make birds that are not near other birds fly faster to catch up to the flock.  Or, you could simulate the diminished air resistance that birds experience when flying together by making them fly faster when in a group.

Are there other interesting ways you can make the birds different from each other?  There could be random variation in the population, or you could have distinct "species" of bird.

## NETLOGO FEATURES

Notice the need for the `subtract-headings` primitive and special procedure for averaging groups of headings.  Just subtracting the numbers, or averaging the numbers, doesn't give you the results you'd expect, because of the discontinuity where headings wrap back to 0 once they reach 360.

## RELATED MODELS

* Moths
* Flocking Vee Formation
* Flocking - Alternative Visualizations

## CREDITS AND REFERENCES

This model is inspired by the Boids simulation invented by Craig Reynolds.  The algorithm we use here is roughly similar to the original Boids algorithm, but it is not the same.  The exact details of the algorithm tend not to matter very much -- as long as you have alignment, separation, and cohesion, you will usually get flocking behavior resembling that produced by Reynolds' original model.  Information on Boids is available at http://www.red3d.com/cwr/boids/.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Flocking model.  http://ccl.northwestern.edu/netlogo/models/Flocking.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2002.

<!-- 1998 2002 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
set population 200
setup
repeat 200 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
