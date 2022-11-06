globals [
  max-infected-people
  day-of-max-infected-people
  daily-delta
  total-infected
  daily-infections
  max-daily-infections
  day-of-max-daily-infections
  daily-deaths
  max-daily-deaths
  day-of-max-daily-deaths
  cumulative-infections
  avg-daily-delta
  total-delta
  moving-average
  day-1
  day-2
  day-3
  day-4
  day-5
  transmissibility ; what is the chance the healthy person becomes sick if they contact a carrier
  ;interactions ; total dialy interactions
  pop-density
  Ro
]


turtles-own[
  never-infected?
  infected?
  recovered?
  dead?
  immune?
  vaccinated?
  masked?
  distanced?
  quarantine-if-sick?
  quarantined?
  superspreader?

  infectionDay            ; day infections occured
  recoveryDay             ; day recovered
  quarantineDay           ; day entered quarantited if infected
  immune-days             ; days immune if recovered
  mouthBreather           ; how likely is this person to infect others if they come into contact
  secondaryinfections     ; how many people this person has infected
  lambda                  ; used to calculate movement
  movement                ; how much this person moves each day
  interactions
  num-neighbors
]

to setup
  clear-all
  set-patch-size (275 / max-pxcor) ; just resets display size
  reset-ticks
  setup-turtles
  setup-maskers
  setup-distancers
  setup-quarantiners
  setup-mouthbreathers
  setup-initial-infected
  color-turtles
  set max-infected-people (count turtles with [infected?])
  set day-of-max-infected-people 0
  set cumulative-infections (count turtles with [infected?])
  set max-daily-infections 0
  set day-of-max-daily-infections 0
  set max-daily-deaths 0
  set day-of-max-daily-deaths 0
  set transmissibility (base-prob-of-transmissibility / 100)
  set pop-density (num-people / (((max-pxcor * 2) + 1) * ((max-pycor * 2) + 1) ) )
  set Ro (0)
  update-plots
;  startingconditions             ; prints starting conditions in Command Center
end


; DSR Start out with everybody never-infected and nothing else
to setup-turtles
  create-turtles num-people [
    set color black
    set shape "person"
    set size 2
    set never-infected? true
    set masked? false
    set distanced? false
    set vaccinated? false
    set infected? false
    set superspreader? false
    set quarantine-if-sick? false
    set quarantined? false
    set recovered? false
    set immune? false
    set dead? false
    set immune-days 0
    set mouthBreather 0
    set secondaryinfections 0
    set lambda random-gamma shape-r ((base-sociability / 100) / (1 - base-sociability / 100) )
    set movement 0
    set infectionDay 0
    set recoveryDay 0
    set quarantineDay 0
    set interactions 0
    set num-neighbors 0
    setxy random-pxcor random-pycor
  ]
end

; DSR Make some people mask users
to setup-maskers
  ask n-of ((percent-who-mask / 100) * num-people) turtles [
    set masked? true
  ]
end


; DSR Make some people social distancers
to setup-distancers
  ask n-of((percent-who-distance / 100) * num-people) turtles [
    set distanced? true
  ]
end


; Give some people propensity to quarantine when sick
to setup-quarantiners
  ask n-of ((percent-who-quarantine / 100) * num-people) turtles [
  set quarantine-if-sick? true
  ]
end


; DSR Make some people start out infected
to setup-initial-infected
  ask n-of init-infected turtles [
    set infected? true
    set never-infected? false
    set-disease-days
  ]
end

; DSR Assign values indicating how much each turtles spreads disease in the absence of wearing a mask
to setup-mouthbreathers
  let mu (base-prob-of-transmissibility / 100)
  let v (Transmission-shape-parameter)
  let alpha (mu * v)
  let beta ((1 - mu) * v)
  ask turtles [
    set mouthBreather ((random-beta alpha beta) * transmissibility-scalar)
  ]
end


to go
  set daily-infections 0
  set daily-deaths 0
  ask turtles [
    set interactions 0
  ]
  no-display                      ;DSR Turns off all updates to the current view until the display command is issued; speeds things up
  move-normal1
  quarantine
  die-from-infection
  recover-from-infection
  if (percent-to-vaccinate != 0) and (ticks < 31) [vaccinate]


  ; DSR Daily calculation of some global variables
  calculate-daily-interactions
  if (ticks >= 1) [
;    calculate-max-infected
    calculate-daily-delta
    calculate-avg-daily-delta
    calculate-total-infected
    calculate-moving-average
    update-max-daily-infections
    update-max-daily-deaths
    update-max-infected-people
  ]

  if (count turtles with [dead? or recovered?] ) >= 1 [
    set Ro (mean [secondaryinfections] of turtles with [dead? or recovered?])
  ]

  ; DSR Update current view, update plots, and advance to the next day
  color-turtles
  display
  tick
  if ticks > 365 [stop]
end


; DSR Have turtles that are not dead, distanced, or quarantined move.
to move-normal1
  ask turtles [
    if dead? or distanced? or quarantined? [stop]                        ; DSR Only turtles that are not dead, distanced, or quarantined move.
    set movement (random-poisson lambda)                                 ; DSR Figure out how far turtle will move today (integer number of steps)
    let y 0                                                              ; DSR Tracks how far a turtle has moved today (integer number of steps)
    let z 0                                                              ; DSR 0 or 1 depending upon whether turtle gets infected

    while [y < movement and z = 0] [                                     ; DSR Keep going until turtle has moved as far as they will go or gotten infected
      ; DSR turn in a random direction and move forward distance of 1
      right random 360
      forward 1

      ; DSR Add to your list of interactions this tick
      set interactions (interactions + (count (turtles-on neighbors)))

      ; DSR If you are infected, try to infect the people around you
      if (infected?) [infect-susceptibles]

      ; DSR If you are susceptible, see if you pick up an infection from someone nearby
      if (not infected? and not immune? and z = 0 ) [
       ; DSR If vaccinated, calculate how much it helps reduce susceptibility
        let susceptibility 1
        if vaccinated? [set susceptibility (1 - vaccine-efficacy / 100)]
        ; DSR Check people around you to see if any are infected and not quarantining
        ask turtles-on neighbors [
          set interactions (interactions + 1)
          if (infected? and not quarantined?)[
            ; DSR If so, infectivity of person depends on whether thay are wearing a mask
            let infectivity ifelse-value (masked? = true)
              [mouthBreather * (1 - mask-efficacy / 100)]
              [mouthBreather]

            if (random-float 1 < (infectivity * [susceptibility] of myself)) [  ; DSR myself refer to the turtle who asked the neighbors
              set secondaryinfections (secondaryinfections + 1)
              set z 1
            ]
          ]
        ]

        ; DSR Change values to show you are infected and call disease-days-or-die to see how long you will be sick or whether you will die
        if (z = 1) [
          set infected? true
          set never-infected? false
          set recovered? false
          set cumulative-infections (cumulative-infections + 1)
          set daily-infections (daily-infections + 1)
          set secondaryinfections 0
          set-disease-days
        ]
      ]
      set y (y + 1)
      if (z = 1) [stop] ; DSR If just became infected, stop moving and exit while loop
    ] ; DSR Go back to beginning of while loop
  ] ; DSR Move on to next turtle
end


; DSR See if you can infect one or more people
to infect-susceptibles
  let x 0                                         ; DSR keeps track of how many people you infect today

  ; DSR Infectivity of person depends on whether thay are wearing a mask
  let infectivity ifelse-value (masked? = true)
    [mouthBreather * (mask-efficacy / 100)]
    [mouthBreather]

  ask turtles-on neighbors [
    if (dead? or infected? or immune? or distanced?) [stop]  ; DSR Ignore people who cannot become infected
    set interactions (interactions + 1)
    ; DSR Adjust susceptibility if vaccinated
    let susceptibility 1
    if vaccinated? [set susceptibility (susceptibility - vaccine-efficacy / 100)]
    ; DSR See if they get infected; if so change their settings and call disease-days-or-die to see how long they will be sick or whether they will die
    if (random-float 1 < ([infectivity] of myself * susceptibility))[  ; DSR myself refer to the turtle who asked the neighbors
      set secondaryinfections 0
      set infected? true
      set never-infected? false
      set recovered? false
      set-disease-days
      set x (x + 1)
      set cumulative-infections (cumulative-infections + 1)
      set daily-infections (daily-infections + 1)
    ]
  ]

  ; DSR See if you qualify as a super spreader
  set secondaryinfections (secondaryinfections + x)
  if (secondaryinfections >= Super-Spreader-Threshold)[set superspreader? true]
end


to set-disease-days
  set infectionDay ticks
  set quarantineDay (infectionDay + min list 2 (base-quarantine-start + one-of [-1 1] * random-poisson 2)) ; DSR start of quarantine takes a minimum of 2 days post-infection, distributed around base-quarantine-start)
  set recoveryDay (infectionDay + min list 5 (base-recovery-time + one-of [-1 1] * random-poisson 5)) ; DSR recovery takes a minimum of 5 days post-infection, distributed around base-recovery-time
end


; DSR See if infected people go into quarantine today
to quarantine
  ask turtles with [infected? and not quarantined? and quarantine-if-sick?]
  [
    if (ticks >= quarantineDay) [
      set quarantined? true
    ]
  ]
end

to die-from-infection
  let daily-fatality-rate (1 - (1 - base-case-fatality-rate / 100) ^ (1 / base-recovery-time))
  let ratio count turtles with [infected?] / treatment-capacity
  if ratio > 1 [set daily-fatality-rate daily-fatality-rate * (1 + 0.25 * ratio ^ 2)]
  ask turtles with [infected?] [
    if random-float 1 < daily-fatality-rate [
      set dead? true
      set infected? false
      set immune? false
      set quarantined? false
      set recovered? false
      set daily-deaths daily-deaths + 1
    ]
  ]
end


; DSR See if infected people recover today
to recover-from-infection ;;I -> R
  ask turtles with [infected?] [
    if (ticks = recoveryDay) [
      set infected? false
      set recovered? true
      set quarantined? false
      set immune? true
      ifelse base-length-of-immunity = 0   ; DSR effectively permanent if parameter = 0; otherwise minimum of 30 days or random value around parameter
        [set immune-days 1e5]
        [set immune-days min list 30 (base-length-of-immunity + one-of [-1 1] * random-poisson 10)]
    ]
  ]
end

; DSR See if recovered people lose their immunity today
to lose-immunity
  ask turtles with [immune?] [
    if (ticks >= recoveryDay + immune-days) [set immune? false]
  ]
end


; Vaccinate some people each day. Don't vaccinate people who are already infected or dead
to vaccinate
  let number-to-vaccinate-today num-people * (percent-to-vaccinate / 100) / 30
  let number-vaccinated-today 0
  while [number-vaccinated-today < number-to-vaccinate-today] [
    ifelse any? turtles with [not vaccinated? and not dead? and not infected?]
      [ask one-of turtles with [not vaccinated? and not dead? and not infected?] [
        set vaccinated? true
        set number-vaccinated-today number-vaccinated-today + 1]
      ]
      [set number-vaccinated-today number-to-vaccinate-today]
  ]
end


; DSR Update Appearance of Turtles
to color-turtles
  ask turtles with [never-infected?] [
    set color 104
    if masked? [set color 106]
    if distanced? [set color 107]
    if masked? and distanced? [set color 108]
  ]
  ask turtles with [infected?] [
    set color 14
    if quarantined? [set color 16]
  ]
  ask turtles with [recovered?] [
    set color 54
  if not immune? [set color 57]
  ]
  ask turtles with [dead?] [
    set color white
    set shape "flower"]
end

; DSR Reporting Calculations
to update-max-daily-infections
  if daily-infections > max-daily-infections [
    set max-daily-infections daily-infections
    set day-of-max-daily-infections ticks
  ]
end

to update-max-daily-deaths
  if daily-deaths > max-daily-deaths [
    set max-daily-deaths daily-deaths
    set day-of-max-daily-deaths ticks
  ]
end

to update-max-infected-people
  if (count turtles with [infected?]) > max-infected-people [
    set max-infected-people (count turtles with [infected?])
    set day-of-max-infected-people ticks
  ]
end

to calculate-max-infected
  let x (count turtles with [infected? and not dead?])
  if x > max-infected-people
  [set max-infected-people x]
end

to calculate-total-infected
  set total-infected (count turtles with [infected? and not dead?]) ;double parenthesis not necessary
end

to calculate-daily-delta
  set daily-delta (count turtles with [infected? and not dead?] - total-infected)
end

to calculate-avg-daily-delta
  let y (daily-delta)
  set total-delta (total-delta + y)
  set avg-daily-delta (total-delta / ticks)
end

to calculate-moving-average
  set day-1 (day-2)
  set day-2 (day-3)
  set day-3 (day-4)
  set day-4 (day-5)
  set day-5 (daily-delta)
  if (ticks >= 5) [
  set moving-average ((day-1 + day-2 + day-3 + day-4 + day-5) / 5)
  ]
end

to calculate-daily-interactions
  ask turtles [
    ;set interactions? (interactions? + (count turtles-on neighbors) )
    set num-neighbors interactions ; this is pretty dumb and can be cleaned up - but it works rn
  ]
end

to topdecilex
if ticks > 30 [
    print("total infected") print(count(turtles with [infected? or recovered? or dead?]))

    let mid (median[secondaryinfections] of turtles with [infected? or recovered? or dead?])
    print("median") print(mid)
    print("count above median") print(count(turtles with [(infected? or recovered? or dead?) and secondaryinfections > mid]))

    set mid (median[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("second median") print(mid)
    print("mean") print(mean[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("count above median") print(count(turtles with [(infected? or recovered? or dead?) and secondaryinfections > mid]))

    set mid (median[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("third median")print(mid)
    print("mean") print(mean[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("count above median") print(count(turtles with [(infected? or recovered? or dead?) and secondaryinfections > mid]))

    set mid (median[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("fourth median") print(mid)
    print("mean") print(mean[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("count above median") print(count(turtles with [(infected? or recovered? or dead?) and secondaryinfections > mid]))

    set mid (median[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("fifth median") print(mid)
    print("mean") print(mean[secondaryinfections] of turtles with [secondaryinfections > mid])
    print("count above median") print(count(turtles with [(infected? or recovered? or dead?) and secondaryinfections > mid]))
  ]
end

to-report topdecile
if count(turtles with [infected? or recovered? or dead?]) > 10 [

    ;print("bloop")
    let infectious (count(turtles with [infected? or recovered? or dead?]) / 10)
    let avg ( mean ([secondaryinfections] of max-n-of infectious turtles [secondaryinfections]))
    ;print("average")print(avg)

    ;print("how many are in top 10%")print(count( max-n-of infectious turtles [secondaryinfections?]))
    ;print("that times average")print(avg * infectious)
    ;print("total infected recovered or dead")print(count(turtles with [infected? or recovered? or dead?]) - init-infected)
    ;print("total secondary infections")print(sum ([secondaryinfections?] of turtles))
    ;print((avg * infectious) / ((count(turtles with [infected? or recovered? or dead?]) - init-infected)))

    let proportion ((avg * infectious) / (sum ([secondaryinfections] of turtles)))

    report proportion
  ]

  ;print (sum [secondaryinfections?] of turtles)
end

to-report prop-dead
  let y (count turtles with [dead?])
  report y / num-people
end

to-report prop-uninfected
  report (count turtles with [not infected? and not immune?]) / num-people
end

to-report random-beta [ #alpha #beta ]
  let XX random-gamma #alpha 1
  let YY random-gamma #beta 1
  report XX / (XX + YY)
end

to-report random-nbinom [ #r #p ]
  let lambda2 random-gamma #r ((#p) / (1 - #p) )
  report random-poisson lambda2
end

to change-tendencies
  setup-maskers
  setup-distancers
  setup-quarantiners
end

; DSR Print Starting conditions in console
to startingconditions
  print("START")
  print ("num-people") print(num-people)
  print ("base-sociability") print(base-sociability)
  print ("shape-r") print(shape-r)
  print ("base-prob-of-transmissibility") write (base-prob-of-transmissibility) print("%")
  print ("Transmission-shape-parameter") print(Transmission-shape-parameter)
  print ("density") print(pop-density)
end
@#$#@#$#@
GRAPHICS-WINDOW
286
10
849
574
-1
-1
5.5
1
10
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
days
30.0

BUTTON
13
22
80
56
NIL
setup
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
160
22
224
56
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
50
89
175
122
num-people
num-people
0
20000
10000.0
100
1
NIL
HORIZONTAL

SLIDER
50
125
176
158
init-infected
init-infected
1
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
19
357
226
390
base-sociability
base-sociability
0
100
75.0
1
1
(0-100)
HORIZONTAL

PLOT
850
10
1459
334
Disease Status of Original Population over Time
days
% of original population
0.0
370.0
0.0
100.0
true
true
"" ""
PENS
"never-infected" 1.0 0 -14070903 true "" "plot (count turtles with [never-infected?]) / num-people * 100\n"
"infected" 1.0 0 -5298144 true "" "plot (count turtles with [infected?]) / num-people * 100"
"recovered" 1.0 0 -12087248 true "" "plot (count turtles with [immune?]) / num-people * 100"
"dead" 1.0 0 -16777216 true "" "plot (count turtles with [dead?]) / num-people * 100"

MONITOR
999
685
1138
730
max infected people
max-infected-people
0
1
11

MONITOR
1145
683
1325
728
day of max infected people
day-of-max-infected-people
0
1
11

SLIDER
19
428
226
461
percent-who-mask
percent-who-mask
0
100
0.0
1
1
%
HORIZONTAL

SLIDER
19
464
226
497
mask-efficacy
mask-efficacy
0
100
65.0
1
1
%
HORIZONTAL

TEXTBOX
374
587
773
782
                                   Worldview Key\nBlue - Never Infected                            Red - Infected\n Darkest - not mask, not distancing       Dark - quarantined \n Lighter - masked                                    Light - quarantined\n Even Lighter - distanced\n Even Lighter - masked and distanced \n \nGreen - Recovered                                White Flower - Dead\n  Dark - Not Immune\n  Light - Immune
12
0.0
0

SLIDER
19
392
227
425
percent-who-distance
percent-who-distance
0
100
1.0
1
1
%
HORIZONTAL

SLIDER
20
964
228
997
Super-Spreader-Threshold
Super-Spreader-Threshold
0
50
10.0
2
1
NIL
HORIZONTAL

SLIDER
14
189
235
222
base-prob-of-transmissibility
base-prob-of-transmissibility
0
100
25.0
1
1
%
HORIZONTAL

SLIDER
16
885
225
918
Transmission-shape-parameter
Transmission-shape-parameter
2
2
2.0
0
1
NIL
HORIZONTAL

SLIDER
19
500
226
533
percent-who-quarantine
percent-who-quarantine
0
100
0.0
1
1
%
HORIZONTAL

BUTTON
267
843
414
876
update tendencies
change-tendencies
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
49
818
199
836
Other Parameters
14
0.0
1

TEXTBOX
8
336
260
356
Population Tendency Parameters
14
0.0
1

SLIDER
17
843
225
876
shape-r
shape-r
1.5
1.5
1.5
0
1
NIL
HORIZONTAL

SLIDER
18
927
224
960
transmissibility-scalar
transmissibility-scalar
0.7
0.7
0.7
0
1
NIL
HORIZONTAL

SLIDER
17
633
223
666
percent-to-vaccinate
percent-to-vaccinate
0
100
0.0
1
1
%
HORIZONTAL

SLIDER
17
669
222
702
vaccine-efficacy
vaccine-efficacy
0
100
90.0
1
1
%
HORIZONTAL

TEXTBOX
30
580
203
600
Treatment Parameters
14
0.0
1

SLIDER
13
258
234
291
base-recovery-time
base-recovery-time
7
21
14.0
1
1
days
HORIZONTAL

SLIDER
13
224
234
257
base-case-fatality-rate
base-case-fatality-rate
0
2
1.0
0.1
1
%
HORIZONTAL

SLIDER
19
538
228
571
base-quarantine-start
base-quarantine-start
2
7
5.0
1
1
days
HORIZONTAL

MONITOR
953
367
1095
412
number never infected
count turtles with [never-infected?]
0
1
11

MONITOR
1098
367
1206
412
number infected
count turtles with [infected?]
0
1
11

MONITOR
1209
367
1327
412
number recovered
count turtles with [recovered?]
0
1
11

TEXTBOX
55
805
1475
825
************************************************************************************ IGNORE EVERYTHING BELOW THIS LINE ***********************************************************************************************
12
0.0
1

BUTTON
85
22
148
55
step
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

TEXTBOX
1083
344
1206
363
Current Statistics
14
0.0
1

TEXTBOX
1062
480
1221
499
Cumulative Statistics
14
0.0
1

MONITOR
1062
505
1137
550
infections
cumulative-infections
0
1
11

MONITOR
1143
505
1201
550
deaths
count turtles with [dead?]
0
1
11

MONITOR
1027
418
1136
463
daily infections
daily-infections
0
1
11

MONITOR
1140
418
1228
463
daily deaths
daily-deaths
0
1
11

MONITOR
998
583
1136
628
max daily infections
max-daily-infections
0
1
11

MONITOR
1143
583
1322
628
day of max daily infections
day-of-max-daily-infections
0
1
11

MONITOR
999
635
1135
680
max daily deaths
max-daily-deaths
0
1
11

MONITOR
1145
633
1323
678
day of max daily deaths
day-of-max-daily-deaths
0
1
11

TEXTBOX
1083
562
1197
581
Other Statistics
14
0.0
1

TEXTBOX
39
165
184
187
Disease Parameters
14
0.0
1

TEXTBOX
46
66
185
86
Starting Conditions
14
0.0
1

SLIDER
7
293
283
326
base-length-of-immunity
base-length-of-immunity
0
1000
180.0
1
1
days (0=forever)
HORIZONTAL

SLIDER
17
598
221
631
treatment-capacity
treatment-capacity
0
1000
500.0
1
1
persons
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

A model of an infectious disease within a community.

People move about randomly, and if they run into a person who is sick, they have a chance of getting sick themselves. The illness runs on average two weeks, and has a 1% death rate.
These processes are all stochastic, so somebody could die on day 2 of the illness, or could have it for a month

Here is what makes this model unique:


I have seen a couple of models online which illustrate the effects of social distancing on the spread of a disease, but they typically did this by social distancing the entire population, which to me seems like a bit of an unnecessary oversimplification. For this model, I'm interested in breaking down social distancing into two of its components:
	1. How many people are distancing? Is it half the population? 75%? 10%?
	2. How aggressively are they distancing? Are they literally staying in one place? or are they just being more cautious, going out less?

This model allows us to explore how varying 1 and 2 affect the outcome of the entire community. Is social distancing useless unless most people do it? Is social distancing useless unless it's extreme? Can we effect a meaningful change in outcome by having only a small proportion of citizens social distance?

Additionally, I've created a self-balancing mechanism which can be turned on or off. 
This self-balancing mechanism is to help try to model how a society would eaase out of social distancing while the virus was still present.
A couple of new variables that the self-balancing uses:

	[threshold] - this is the "acceptable" infected proportion of the population (ie, "the healthcare system can't handle more than 5% of the population sick with this thing at any one time, so we have to keep it under 5%")

	[distance-step-ups] - when the proportion of people currently infected ([prop-infected]) nears the threshold, the proportion of the population social distancing increases. If the [prop-infected] rises above the threshold, or daily net new cases are  too high (indicating rapid growth), the proportion of the population taking social distancing measures increases. So, for example, if 11% of the population is infected, the number of people taking social distancing measures would increase by ([distance-step-ups] * [num-people]) amount every day until prop-infected falls below 10%. 

	[distance-step-downs] - the same as the above, but for easing social distancing restrictions. Once prop-infected falls below ([threshold]*.75) and net new cases are negative, the proportion of people social distancing is decreased by ([distance-step-downs] * [num-people]). 


What should the step-ups and step-downs be? That’s a good question. The granularity with which a society can adjust how many of its citizens are social distancing unclear and subject to political pressures. On one end of the spectrum, we could imagine a government announcing every morning which birthdays were allowed to leave the house. On the other end of the spectrum, we could imagine a government announcing at the start of the month that everyone must stay inside, and at the end of the month, letting everybody out. The most realistic course of action is probably somewhere in the middle. I think most citizens would get awfully fed up with a government micromanaging and making frequent adjustments, however, we probably want something more attentive than the second scenario. This is an added challenge — we want a self-balancing system that takes large enough steps so as not to require super frequent adjustments, but also keeps the virus at acceptable levels. To start, I’ve set the [distancing-step-ups] (by what percentage of the population do we increase the total number of people distancing) at 10%. I’ve done the same for [distancing-step-downs]  (by how much do we decrease the number of people social distancing).  We can imagine city governments being able to adjust social distancing behavior with this sort of granularity by taking steps such as expanding and contracting the list of “essential businesses”. (Note: I am well aware of the fact that opening and shuttering businesses adds a whole new level of economic stress and greatly impacts these business’s ability to plan. That being said, I think what we’re interested in here is the effect of slowly opening or closing the economy on the spread of a virus, not the economic difficulties and feasibility of opening and closing the economy.)




## HOW IT WORKS
&& 
## HOW TO USE IT
(what rules the agents use to create the overall behavior of the model)


I'll go through the variables and what is a good range for them to be set at:

num-people = This is the number of total people in the community, for this size grid, I think 1500 is a decent starting point. Less people -> disease has harder time spreading, more people -> disease spreads more easily

init-infected = This is how many initial cases the community has. You can set it as low as you want


num-people-social-distancing = of the total number of people, how many of them are socially distancing? Play around with this one, you start to be able to really see the impact once it's over 60% of the population. Also try it with zero! REMEMBER: this number must be lower than num-people

sociability-of-non-distancers = how much do non social distancers move around? The higher this number, the larger their movements. Try different numbers for this.

sociability-of-distancers = how much do social distancers move around? This number should be pretty low, I think generally, below 1. Play around with it, but just remember that it should be lower than sociability-of-non-distancers.

NOTE: the sociability of an individual does not change if he becomes infected. Distancers will continue to distance even if they become infected, but they will change color to red.

Once there are no more active infections in the community, people stop social distancing. 


## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

To begin building this, I modified code for an SIR model by Paul Smaldino
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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
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
